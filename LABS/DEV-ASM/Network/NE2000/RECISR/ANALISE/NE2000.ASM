version	equ	4
;History:76,1 0

;  The following people have contributed to this code: David Horne, Eric
;  Henderson, and Bob Clements.

;  Copyright, 1988-1992, Russell Nelson, Crynwr Software

;   This program is free software; you can redistribute it and/or modify
;   it under the terms of the GNU General Public License as published by
;   the Free Software Foundation, version 1.
;
;   This program is distributed in the hope that it will be useful,
;   but WITHOUT ANY WARRANTY; without even the implied warranty of
;   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;   GNU General Public License for more details.
;
;   You should have received a copy of the GNU General Public License
;   along with this program; if not, write to the Free Software
;   Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.

include	defs.inc
include	8390.inc

;*****************************************************************************
;	NE2000 controller board offsets
;	IO port definition (BASE in io_addr)
;*****************************************************************************
NE_DATAPORT		EQU	10h		; NE2000 Port Window.
NE_RESET		EQU	1fh		; Issue a read for reset
EN_OFF			equ	0h

; Shared memory management parameters

SM_TSTART_PG	equ	040h	; First page of TX buffer
SM_RSTART_PG	equ	046h	; Starting page of RX ring
SM_RSTOP_PG		equ	080h	; Last page +1 of RX ring

public	int_no, io_addr
public	block_input

public	mcast_list_bits, mcast_all_flag
public	board_data
public	xmit
public	recv

extrn	rom_address: byte					;-> the assigned Ethernet address of the card.

extrn	my_address: byte					;-> current address

code	segment	word public
	assume	cs:code, ds:code
	
	sm_rstop_ptr	db SM_RSTOP_PG
	rxcr_bits       db ENRXCR_BCST     		; Default to ours plus multicast

	ifdef board_features
	is_overrun_690	db 0
	endif

	int_no			db 3,0,0,0				; must be four bytes long for get_number.
	io_addr			dw 0300h,0				; I/O address for card (jumpers)

	int_num	dw	0							; Interrupt # to hook for post-EOI
											; processing, 0 == none,
											
	mcast_list_bits db 0,0,0,0,0,0,0,0 		; Bit mask from last set_multicast_list
	mcast_all_flag  db 0               		; Non-zero if hware should have all
											; ones in mask rather than this list.
											
											; a temp buffer for the received header

	RCV_HDR_SIZE	equ	40h					; 2 ids @6 + protocol @2+8, + header @4
	rcv_hdr			db RCV_HDR_SIZE dup(0)
	
	BOARD_DATA_SIZE equ	32					; The board data
	board_data		db BOARD_DATA_SIZE dup(0)
	
	; Next Packet Pointer (added  - gft - 910603)
	;
	;   Initialize to the same value as the current page pointer (start page 1).
	;   Update after each reception to be the value of the next packet pointer
	;   read from the NIC Header.
	;   Copy value -1 to boundry register after each update.
	;   Compare value with contents of current page pointer to verify that a
	;   packet has been received (don't trust ISR RXE/PRX bits). If !=, one
	;   or more packets have been received.
	next_packet		db	0
	save_curr		db	0

	; Added flags and temp storage for new receive overrun processing
	;  - gft - 910604
	rcv_ovr_resend	db	0,0					; flag to indicate resend needed
	defer_upcall	db	0,0					; flag to indicate deferred upcall needed
	defer_ds		dw	?					; deferred upcall parameters
	defer_si		dw	?
	defer_cx		dw	?
	

;	Block input routine
;	CX = byte count, es:di = buffer location, ax = buffer address
block_input:
	push	ax		; save buffer address
	;loadport
	;setport EN_CCMD
	;pause_
	mov dx, 300h
	port_no = 300h
	mov	al,ENC_NODMA+ENC_PAGE0+ENC_START
	out	dx,al
	;setport	EN0_RCNTLO	; remote byte count 0
	;pause_
	mov dx, 30ah
	port_no = 30ah
	mov	al,cl
	out	dx,al
	;setport	EN0_RCNTHI
	;pause_
	mov dx, 30bh
	port_no = 30bh
	mov	al,ch
	out	dx,al
	pop	ax		; get our page back
	;setport	EN0_RSARLO
	;pause_
	mov dx, 308h
	port_no = 308h
	out	dx,al		; set as hi address
	;setport	EN0_RSARHI
	;pause_
	mov dx, 309h
	port_no = 309h
	mov	al,ah
	out	dx,al
	;setport EN_CCMD
	;pause_
	mov dx, 300h
	port_no = 300h
	mov	al,ENC_RREAD+ENC_START	; read and start
	out	dx,al
	;setport	NE_DATAPORT
	;pause_
	mov dx, 310h
	port_no = 310h
	shr	cx,1		; word count
	.286
	rep	insw
	.8086
	ret

	
; Process a transmit interrupt with the least possible latency to achieve
;   back-to-back packet transmissions.
; May only use ax and dx.
xmit:
	assume	ds:nothing
	ret

; Set the multicast filter mask bits in case promiscuous rcv wanted
set_hw_multi:
	push    cs
	pop     ds
	assume	ds:code

	;loadport
	;setport	EN_CCMD		; Chip command register
	mov		dx, 300h				; io_addr
	add		dx, 00h					; EN_CCMD
	;pause_

	mov cx,	8		; Eight bytes of multicast filter
	mov si, offset mcast_list_bits  ; Where bits are, if not all ones
	cli			; Protect from irq changing page bits
	;mov al,	ENC_NODMA+ENC_PAGE1+ENC_STOP
	mov	al, 20h+40h+01h				; ENC_NODMA+ENC_PAGE1+ENC_STOP
	out dx,	al		; Switch to page one for writing eaddr

	;setport	EN1_MULT	; Where it goes in 8390
	mov		dx, 300h				; io_addr
	add		dx, 08h					; EN1_MULT
	;pause_

	;mov al, mcast_all_flag  ; Want all ones or just selected bits?
	mov		al, 00h
	or al,  al
	je      set_mcast_2     ; Just selected ones
	mov al,	0ffh		; Ones for filter
set_mcast_all:
	out dx,	al		; Write a mask byte
	inc	dl		; Step to next one
	loop	set_mcast_all	; ..
	jmp short set_mcast_x

set_mcast_2:
	lodsb                   ; Get a byte of mask bits
	out dx,	al		; Write a mask byte
	inc	dl		; Step to next I/O register
	loop	set_mcast_2 	; ..
set_mcast_x:
	;loadport
	;setport	EN_CCMD		; Chip command register
	mov		dx, 300h				; io_addr
	add		dx, 00h					; EN_CCMD

	;pause_
	;mov al,	ENC_NODMA+ENC_PAGE0+ENC_START
	mov		al, 20h+00h+02h			; ENC_NODMA+ENC_PAGE0+ENC_START
	out dx,	al		; Restore to page zero
	ret


; ############################################################################################################################################
		
recv:

;called from the recv isr.  All registers have been saved, and ds=cs.
;Actually, not just receive, but all interrupts come here.
;Upon exit, the interrupt will be acknowledged.
;ne1000 and ne2000 routines are identical to this point (except that ne2000
;  masks off interrupts).
	assume	ds:code

check_isr:			; Was there an interrupt from this card?
	;loadport		; Point at card's I/O port base
	;setport EN0_IMR		; point at interrupt masks
	;pause_			; switch off, this way we can
	mov	dx, 30Fh
	mov	al,0		; leave the chip running.
	out	dx,al		; no interrupts please.
	;setport	EN0_ISR		; Point at interrupt status register
	;pause_
	mov dx, 307h
	in al,	dx		; Get pending interrupts
	and al,	ENISR_ALL	; Any?
	jnz	isr_test_overrun
	jmp	interrupt_done	; Go if none

;
; Revised receive overrun code which corresponds to the National DP8390
; Datasheet Addendum, June 1990.
;
; - gft - 910604
;

; Test for receive overrun in value from NIC ISR register

isr_test_overrun:
	test al,ENISR_OVER	; Was there an overrun?
	jnz	recv_overrun	; Go if so.
	jmp	recv_no_overrun	; Go if not.

recv_overrun:
jmp $ ; erro
  

recv_no_overrun:
; Handle receive flags, normal and with error (but not overrun).
	test al,ENISR_RX+ENISR_RX_ERR	; Frame received without overrun?
	jnz	recv_frame_0	; Go if so.

jmp $ ; erro

recv_frame_0:

	;loadport		; Point at Chip's Command Reg
	;setport	EN0_ISR		; Point at Interrupt status register
	;pause_
	mov dx, 307h
	mov al,	ENISR_RX+ENISR_RX_ERR
	out dx,	al		; Clear those requests
 	;setport	EN_CCMD		; ..
	;pause_
	mov dx, 300h
	cli
	mov al,	ENC_NODMA+ENC_PAGE1+ENC_START
	out dx,	al		; Switch to page 1 registers
	;setport	EN1_CURPAG	;Get current page of rcv ring
	;pause_
	mov	dx, 307h
	in al,	dx		; ..
;	mov ah,	al		; Hold current page in AH
	mov save_curr,al	; Hold last read current page register in 
				; memory instead - gft - 910611
 	;setport	EN_CCMD		; Back to page zero registers
	;pause_
	mov dx, 300h
	mov al,	ENC_NODMA+ENC_PAGE0+ENC_START
	out dx,	al		; Switch back to page 0 registers
	

; This becomes the loop back point to read packets from the ring.
; now only loop back and read until those packets received at the time 
; the current page register is read above have been read.
; - gft - 910611

recv_frame:
	mov al, next_packet	; Get saved pointer to next packet in ring
;
; change the next instruction to compare against the saved copy of the current
; page register and only read from the ring what was received up until the 
; last read from the current page register - gft - 910611
;
;	cmp al,	ah		; Read all the frames?
	cmp al,	save_curr	; Read all the frames?
	jne	recv_more_frames; hacked jump code for addition of mkle
				; macro below - gft -910521
;	jmp	recv_frame_break	; Finished them all

;
; changed jmp recv_frame_break to jmp check_isr after recv_frame_break was
; determined to be superfluous. See comments at recv_frame_break below.
; - gft - 910531
;

	jmp	check_isr	; Finished all receives, check for more
				; interrupts.

recv_more_frames:

	mov	ah,al		; make a byte address. E.G. page
	mov	al,0		; 46h becomes 4600h into buffer
	mov	bl,ah
	mov	cx,RCV_HDR_SIZE
	mov	di,offset rcv_hdr
	;movseg	es,ds
	push ds
	pop es
	call	block_input
	
	mov cx, RCV_HDR_SIZE
	mov si, offset rcv_hdr
	
	extern printmem:near
	call PRINTMEM
	
	mov al,	rcv_hdr+EN_RBUF_STAT	; Get the buffer status byte
	test al,ENRSR_RXOK	; Good frame?
	jz	recv_err_no_rcv
;
; EVEN if the NIC header status is OK, I have seen garbaged NIC headers, so
; it doesn't hurt to range check the next packet pointer here.
;
	mov al,	rcv_hdr+EN_RBUF_NXT_PG	; Start of next frame
	mov next_packet, al	; Save next packet pointer
	cmp 	al,SM_RSTART_PG	; Below around the bottom?
	jb	recv_err_no_rcv ; YES - out of range
	cmp	al,sm_rstop_ptr ; Above the top?
	jae	recv_err_no_rcv ; YES - out of range

	; ok to call rcv_frm
	;call	rcv_frm		; Yes, go accept it
	jmp	recv_no_rcv
recv_err_no_rcv:
	;or	byte ptr soft_rx_err_bits,al
	;add2	soft_rx_errors,1

	mov     al, save_curr   ; get the last known current page pointer
	mov     next_packet, al ; and use it as the next packet pointer
	jmp     check_isr       ; then go handle more interrupts

recv_no_rcv:

	mov	al,next_packet	; Grap the next packet pointer
	dec	al		; Make previous page for new boundary



	cmp al,	SM_RSTART_PG	; Wrap around the bottom?
;	jge	rcv_nwrap4
	jae	rcv_nwrap4		; - gft - 910610
	mov al,	sm_rstop_ptr	; Yes
	dec al
rcv_nwrap4:
	;loadport		; Point at the Boundary Reg again
 	;setport	EN0_BOUNDARY	; ..
	;pause_
	mov dx, 303h
	out dx,	al		; Set new boundary
	

	jmp	recv_frame	; See if any more frames


recv_no_frame:				; Handle transmit flags.

interrupt_done:
	;loadport
	;setport	EN0_IMR		; Tell card it can cause these interrupts
	;pause_
	mov dx, 30fh
	mov al,	ENISR_ALL
	out dx,	al
	ret
	
;####################################################################################################################################################

;any code after this will not be kept after initialization. Buffers
;used by the program, if any, are allocated from the memory between
;end_resident and end_free_mem.
	public end_resident,end_free_mem
end_resident	label	byte
end_free_mem	label	byte

;standard EN0_DCFG contents:
endcfg	db	048h			; Set burst mode, 8 deep FIFO

; Called once to initialize the card

	public	etopen
etopen:				; Initialize interface

;Step 1. Reset and stop the 8390.

	;call	reset_board

	; reset_8390
	; assume ds:nothing
	mov		dx, 300h 				; io_addr
	add 	dx, 1fh					; NE_RESET
	in 		al, dx
	; end reset_8390

	out		dx,al					; should set command 21, 80

	mov 	dx, 300h				; io_addr
	add 	dx, 00h					; EN_CCMD

	mov 	al,	01h+20h				; ENC_STOP+ENC_NODMA
	out 	dx,	al					; Stop the DS8390

;Step 2. Init the Data Config Reg.

	;loadport
	;mov	al,endcfg
	;setport	EN0_DCFG
	;pause_
	;out	dx,al

	mov		dx, 300h				; io_addr
	mov		al, 48h					; endcfg
	add		dx, 0eh					; EN0_DCFG
	out		dx, al

;Step 2a.  Config the Command register to page 0.
	;loadport
	;mov	al, ENC_PAGE0 + ENC_NODMA + ENC_STOP
	;setport	EN_CCMD
	;pause_
	;out	dx,al

	mov		dx, 300h				; io_addr
	mov		al, 00h + 20h + 01h		; ENC_PAGE0 + ENC_NODMA + ENC_STOP
	add		dx, 00h					; EN_CMD
	out		dx, al

;Step 3. Clear Remote Byte Count Regs.

	;mov	al, 0
	;setport	EN0_RCNTLO
	;pause_
	;out	dx,al
	;setport	EN0_RCNTHI
	;pause_
	;out	dx,al

	mov		dx, 300h				; io_addr
	mov		al, 0
	add		dx, 0ah					; EN0_RCNTLO
	out		dx, al

	mov		dx, 300h				; io_addr
	add		dx, 0bh					; EN0_RCNTHI
	out		dx, al

;Step 4. Set receiver to monitor mode

	;mov	al, ENRXCR_MON
	;setport	EN0_RXCR
	;pause_
	;out	dx,al

	mov		dx, 300h				; io_addr
	mov		al, 20h					; ENRXCR_MON
	add		dx, 0ch					; EN0_RXCR
	out		dx, al

;Step 5. Place NIC into Loopback Mode 1.

	;mov	al,ENTXCR_LOOP
	;setport	EN0_TXCR
	;pause_
	;out	dx,al

	mov		dx, 300h				; io_addr
	mov		al, 02h					; ENTXCR_LOOP
	add		dx, 0dh					; EN0_TXCR
	out		dx, al

;Step 6. Do anything special that the card needs.  Read the Ethernet address
;into rom_address.

	;call	init_card		;init the card as needed.

	assume	ds:code

	or	endcfg,ENDCFG_WTS			; endcfg = 49h

	;loadport
	;mov	al,endcfg
	;setport	EN0_DCFG
	;pause_
	;out	dx,al

	mov		dx, 300h				; io_addr
	mov		al, 49h					; endcfg
	add		dx, 0eh					; EN0_DCFG
	out		dx, al

	mov	cx,10h		; get 16 bytes,
	;movseg	es,ds
	push ds
	pop es
	mov	di,offset board_data

	;setport EN_CCMD
	;pause_
	;mov	al,ENC_NODMA+ENC_PAGE0+ENC_START
	;out	dx,al
	;setport	EN0_RCNTLO	; remote byte count 0
	;pause_
	;mov	al,20h		; count is actually doubled.
	;out	dx,al
	;setport	EN0_RCNTHI
	;pause_
	;xor	al,al		; high byte of count is zero.
	;out	dx,al

	mov		dx, 300h				; io_addr
	add		dx, 00h					; EN_CCMD
	mov		al, 20h+00h+02h			; ENC_NODMA+ENC_PAGE0+ENC_START
	out		dx, al

	mov		dx, 300h				; io_addr
	add		dx, 0ah					; EN0_RCNTLO
	mov		al, 20h					; count is actually doubled.
	out		dx, al

	mov		dx, 300h				; io_addr
	add		dx, 0bh					; EN0_RCNTHI
	xor		al, al
	out		dx, al

	mov	ax,0		; from address 0

	;setport	EN0_RSARLO
	;pause_
	;out	dx,al		; set as hi address
	;setport	EN0_RSARHI
	;pause_
	;mov	al,ah
	;out	dx,al
	;setport EN_CCMD
	;pause_
	;mov	al,ENC_RREAD+ENC_START	; read and start
	;out	dx,al
	;setport	NE_DATAPORT
	;pause_

	mov		dx, 300h				; io_addr
	add		dx, 08h					; EN0_RSARLO
	out		dx, al

	mov		dx, 300h				; io_addr
	add		dx, 09h					; EN0_RSARHI
	mov		al, ah
	out		dx, al

	mov		dx, 300h				; io_addr
	add		dx, 00h					; EN_CCMD
	mov		al, 08h+02h				; ENC_RREAD+ENC_START	; read and start
	out		dx, al

	mov		dx, 300h				; io_addr
	add		dx, 10h					; NE_DATAPORT

sp_read_loop_1:
	in	al,dx		; get a byte
	stosb			; save it
	loop	sp_read_loop_1

	push    ds              ; Copy from card's address to current address
	pop     es

	mov si, offset board_data	; address is at start
	mov di, offset rom_address
	mov cx, EADDR_LEN       ; Copy one address length
	rep     movsb           ; ..

	clc

	jnc	etopen_1		;go if it worked.
	ret
etopen_1:

;Step 7. Re-init endcfg in case they put it into word mode.

	;loadport
	;mov	al,endcfg
	;setport	EN0_DCFG
	; pause_
	;out	dx,al

	mov		dx, 300h				; io_addr
	mov		al, 49h					; endcfg
	add		dx, 0eh					; EN0_DCFG
	out		dx, al
	port_no = 30eh

;Step 8. Init EN0_STARTPG to same value as EN0_BOUNDARY

	;mov	al,SM_RSTART_PG
	;setport	EN0_STARTPG
	;pause_
	;out	dx,al

	mov		dx, 300h				; io_addr
	mov		al, 46h					; SM_RSTART_PG
	add		dx, 01h					; EN0_STARTPG
	out		dx, al

  if 1	;Paul Kranenburg suggests that this should be set to zero.
	mov	al,SM_RSTART_PG
  else
	mov	al,sm_rstop_ptr
	dec	al
  endif

	;setport	EN0_BOUNDARY
	;pause_
	;out	dx,al
	;mov	al,sm_rstop_ptr
	;setport	EN0_STOPPG
	;pause_
	;out	dx,al

	mov		dx, 300h				; io_addr
	add		dx, 03h					; EN0_BOUNDARY
	out		dx, al

	mov		dx, 300h				; io_addr
	mov		al, 80h					; sm_rstop_ptr = SM_RSTOP_PG
	add		dx, 02h					; EN0_STOPPG
	out		dx, al

;Step 9. Write 1's to all bits of EN0_ISR to clear pending interrupts.

	;mov	al, 0ffh
	;setport	EN0_ISR
	;pause_
	;out	dx,al

	mov		dx, 300h				; io_addr
	mov		al, 0ffh
	add		dx, 07h					; EN0_ISR
	out		dx, al

;Step 10. Init EN0_IMR as desired.

	;mov	al, ENISR_ALL
	;setport	EN0_IMR
	;pause_
	;out	dx,al

	mov		dx, 300h				; io_addr
	mov		al, 3fh					; ENISR_ALL
	add		dx, 0fh					; EN0_IMR
	out		dx, al
	port_no = 30fh

;Step 11. Init the Ethernet address and multicast filters.

	mov	si,offset rom_address
	mov	cx,EADDR_LEN

	;call	set_address	; Now set the address in the 8390 chip

	assume	ds:code
;enter with my_address,si -> Ethernet address, CX = length of address.
;exit with nc if okay, or cy, dh=error if any errors.

	;loadport
	;setport	EN_CCMD		; Chip command register
	mov		dx, 300h				; io_addr
	add		dx, 00h					; EN_CCMD

	pushf
	cli			; Protect from irq changing page bits

	;mov al,	ENC_NODMA+ENC_PAGE1	;+ENC_STOP
	mov	al, 20h+40h					; ENC_NODMA+ENC_PAGE1	;+ENC_STOP
	out dx,	al						; Switch to page one for writing eaddr
	;pause_

	mov		dx, 300h				; io_addr
	add		dx, 01h					; EN1_PHYS
	;setport	EN1_PHYS	; Where it goes in 8390
	port_no = 301h

set_8390_2:
	lodsb
	out	dx,al
	;pause_
	inc	dx
	loop	set_8390_2

	;loadport
	;setport	EN_CCMD		; Chip command register
	mov		dx, 300h				; io_addr
	add		dx, 00h					; EN_CCMD

	;mov al,	ENC_NODMA+ENC_PAGE0	;+ENC_STOP
	mov		al, 20h+00h				; ENC_NODMA+ENC_PAGE0	;+ENC_STOP
	out dx,	al		; Restore to page zero
	;pause_
	popf
	clc

	call	set_hw_multi  ; Put the right stuff into 8390's multicast masks

;Step 12. Program EN_CCMD for page 1.

	;loadport
	;mov	al, ENC_PAGE1 + ENC_NODMA + ENC_STOP
	;setport	EN_CCMD
	;pause_
	;out	dx,al

	mov		dx, 300h				; io_addr
	add		dx, 00h					; EN_CCMD
	mov		al, 40h+20h+01h			; al, ENC_PAGE1 + ENC_NODMA + ENC_STOP
	out		dx, al

;Step 13. Program the Current Page Register to same value as Boundary Pointer.

; THIS IS WRONG WRONG WRONG inspite of some self-contradicting National
; documentation. If the Current Page Register is initialized to the same
; value as the Boundary Pointer, the first ever packet received will be lost or
; trashed because the driver always expects packets to be received at Boundrary
; pointer PLUS ONE! 

	;mov	al,SM_RSTART_PG
	mov		al, 46h					; SM_RSTART_PG
	inc	al		; To fix the bug! - gft - 910523

	;setport	EN1_CURPAG
	mov		dx, 300h				; io_addr
	add		dx, 07h					; EN1_CURPAG
	;pause_
	out	dx,al

	mov	save_curr,al	; added in conjunction with fixes above
				; - gft - 910611
	mov	next_packet, al ; initialize next_packet to the value in
				; current - gft - 910603

;Step 14. Program EN_CCMD back to page 0, and start it.

	;mov	al, ENC_NODMA + ENC_START + ENC_PAGE0
	mov		al, 20h + 02h + 00h		; ENC_NODMA + ENC_START + ENC_PAGE0

	;setport	EN_CCMD
	mov		dx, 300h				; io_addr
	add		dx, 00h					; EN_CCMD
	;pause_
	out	dx,al

	mov	al, 0			;set transmitter mode to normal.

	;setport	EN0_TXCR
	;pause_
	mov		dx, 300h				; io_addr
	add		dx, 0dh					; EN0_TXCR
	out	dx,al

  if 0
	;mov	al, ENRXCR_BCST
	mov		al, 04h					; ENRXCR_BCST

	;setport	EN0_RXCR
	mov		dx, 300h				; io_addr
	add		dx, 0ch					; EN0_RXCR
	;pause_
	out	dx,al
  endif

	;call	set_recv_isr	; Put ourselves in interrupt chain
	extern	their_recv_isr:dword
	extern	recv_isr:proc

	mov	ah,35h			;get the old interrupt into es:bx
	mov	al,int_no		; board's interrupt vector
	or	al,al
	je	set_isr_no_irq
	add	al,8
	cmp	al,8+8			;is it a slave 8259 interrupt?
	jb	set_recv_isr_1		;no.
	add	al,70h - 8 - 8		;map it to the real interrupt.
set_recv_isr_1:
	int	21h
	mov	their_recv_isr.offs,bx	;remember the old seg:off.
	mov	their_recv_isr.segm,es

	mov	ah,25h			;now set our recv interrupt.
	mov	dx,offset recv_isr
	int	21h

	mov	al,int_no		; Now enable interrupts
	
	extern  unmaskint:proc
	call	unmaskint

set_isr_no_irq:


	mov	al, int_no		; Get board's interrupt vector
	add	al, 8
	cmp	al, 8+8			; Is it a slave 8259 interrupt?
	jb	set_int_num		; No.
	add	al, 70h - 8 - 8		; Map it to the real interrupt.
set_int_num:
	xor	ah, ah			; Clear high byte
	mov	int_num, ax		; Set parameter_list int num.

	mov al,	ENRXCR_BCST+ENRXCR_MULTI+ENRXCR_PROMP
	mov     mcast_all_flag,1
	push    ax			; Hold mode until masks are right
	call    set_hw_multi		; Set the multicast mask bits in chip
	pop     ax
	;loadport
	;setport	EN0_RXCR		; Set receiver to selected mode
	;pause_
	mov dx, 30Ch
	port_no = 30Ch
	out dx,	al
	mov     rxcr_bits,al		; Save a copy of what we set it to
	
	
	clc				; Say no error
	ret				; Back to common code

code	ends

	end
