.286
.MODEL TINY 
.STACK 100

INCLUDE 8390.INC

segmoffs	struc										; defines offs as 0, segm as 2
	offs		dw	?
	segm		dw	?
 segmoffs	ends

_TEXT SEGMENT PUBLIC 'CODE' USE16
	ASSUME DS:_TEXT, ES:_TEXT
	
	ORG 100h
	
	MAIN PROC
	
		MOV		AX, CS
		MOV		DS, AX
		MOV		ES, AX
		
		CLI

		CALL	etopen

		IN		AL, 21h
		AND		AL, 0f7h								; UNMASK IQR 3 ON PIC 
		OUT		21h, AL

		STI
		
		MOV		AX, 4C00h
		INT		21h
		
		endcfg				db	048h					; Set burst mode, 8 deep FIFO
		
		BOARD_DATA_SIZE 	equ	32
		board_data			db 	BOARD_DATA_SIZE dup(0)
		
		MAX_ADDR_LEN		equ	16						;maximum number of bytes in our address.
		rom_address			db	MAX_ADDR_LEN dup(?)		;our address in ROM.
		
		EADDR_LEN			equ	6						;Ethernet address length.
		port_no 			= 0
		SM_RSTART_PG		equ	046h					; Starting page of RX ring
		
		SM_RSTOP_PG			equ	080h					; Last page +1 of RX ring
		sm_rstop_ptr		db	SM_RSTOP_PG
		
		mcast_list_bits 	db 0,0,0,0,0,0,0,0 			;Bit mask from last set_multicast_list
		
		next_packet			db	0
		save_curr			db	0
		
		their_recv_isr		segmoffs <,>
		their_timer			dd	0
		original_mask		db 	0
		int_no				db 	3
		int_num				dw	0						;Interrupt # to hook for post-EOI
		
	MAIN ENDP
	
	recv_isr PROC FAR
	
		;in		al, 21h
		;and		al, 0f7h
		;out		21h, al
	
		mov		ah, 0eh
		mov		al, 31h
		int		10h
		
		;loadport		; Point at Chip's Command Reg
		;setport	EN0_ISR		; Point at Interrupt status register
		;pause_
		;mov al,	ENISR_RX+ENISR_RX_ERR
		;out dx,	al		; Clear those requests

		mov		dx, 307h
		mov		al, 01h+04h
		out 	dx, al

		;setport	EN_CCMD		; ..
		;pause_
		;cli
		;mov al,	ENC_NODMA+ENC_PAGE1+ENC_START
		;out dx,	al		; Switch to page 1 registers

		mov		dx, 300h
		mov		al, 20h+40h+02h
		out		dx, al

		;setport	EN1_CURPAG	;Get current page of rcv ring
		;pause_
		;in al,	dx		; ..

		mov		dx, 307h
		in		al, dx

	;	mov ah,	al		; Hold current page in AH
		;mov save_curr,al	; Hold last read current page register in 
					; memory instead - gft - 910611

		
		;setport	EN_CCMD		; Back to page zero registers
		;pause_
		;mov al,	ENC_NODMA+ENC_PAGE0+ENC_START
		;out dx,	al		; Switch back to page 0 registers

		mov		dx, 300h
		mov		al, 20h+00h+02h
		out		dx, al
		
		;loadport
		;setport	EN0_IMR		; Tell card it can cause these interrupts
		;pause_
		;mov al,	ENISR_ALL
		;out dx,	al

		mov		dx, 30fh
		mov		al, 3fh
		out		dx, al
		
		;in		al, 21h
		;or		al, 0ffh
		;out		21h, al
		
		mov 	al, 20h				; informa o fim da instrucao de interrupcao
		out 	0a0h, al  			; notify secondary pic
		out 	20h, al  			; notify primary pic
		
		iret
	
	recv_isr ENDP
	
	timer_isr PROC
	
		iret
		
	timer_isr ENDP
	
	etopen PROC				; Initialize interface

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

		assume	ds:_TEXT

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
		pop	es
		mov	di, offset board_data

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

		assume	ds:_TEXT
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

		;call	set_hw_multi  ; Put the right stuff into 8390's multicast masks

		push    cs
		pop     ds
		assume	ds:_TEXT

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
		je      set_mcast_2_1     ; Just selected ones
		mov al,	0ffh		; Ones for filter
	set_mcast_all_1:
		out dx,	al		; Write a mask byte
		inc	dl		; Step to next one
		loop	set_mcast_all_1	; ..
		jmp short set_mcast_x_1

	set_mcast_2_1:
		lodsb                   ; Get a byte of mask bits
		out dx,	al		; Write a mask byte
		inc	dl		; Step to next I/O register
		loop	set_mcast_2_1 	; ..
	set_mcast_x_1:
		;loadport
		;setport	EN_CCMD		; Chip command register
		mov		dx, 300h				; io_addr
		add		dx, 00h					; EN_CCMD

		;pause_
		;mov al,	ENC_NODMA+ENC_PAGE0+ENC_START
		mov		al, 20h+00h+02h			; ENC_NODMA+ENC_PAGE0+ENC_START
		out dx,	al		; Restore to page zero

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

		setport	EN0_RXCR
		mov		dx, 300h				; io_addr
		add		dx, 0ch					; EN0_RXCR
		;pause_
		out	dx,al
	  endif

		;call	set_recv_isr	; Put ourselves in interrupt chain
		
		mov	ah,35h			;get the old interrupt into es:bx
		mov	al,int_no		; board's interrupt vector
		or	al,al
		je	set_isr_no_irq_1
		add	al,8
		cmp	al,8+8			;is it a slave 8259 interrupt?
		jb	set_recv_isr_1_1		;no.
		add	al,70h - 8 - 8		;map it to the real interrupt.
	set_recv_isr_1_1:
		int	21h
		mov	their_recv_isr.offs,bx	;remember the old seg:off.
		mov	their_recv_isr.segm,es

		mov	ah,25h			;now set our recv interrupt.
		mov	dx,offset recv_isr
		int	21h

		cmp	byte ptr timer_isr,0cfh	;is there just an iret at their handler?
		je	set_isr_no_timer_1	;yes, don't bother hooking the timer.

		mov	ax,3508h		;get the old interrupt into es:bx
		int	21h
		mov	their_timer.offs,bx	;remember the old seg:off.
		mov	their_timer.segm,es

		mov	ah,25h			;now set our recv interrupt.
		mov	dx,offset timer_isr
		int	21h

	set_isr_no_timer_1:
		mov	al,int_no		; Now enable interrupts
		
		;call	unmaskint
		;exit with cl = 0 if the interrupt had been enabled.
		assume	ds:_TEXT
		mov	dx,21h			;assume the master 8259.
		mov	cl,al
		cmp	cl,8			;using the slave 8259 on an AT?
		jb	unmask_not_irq2_1		;no
		in	al,dx			;get master mask
		push	ax
		in	al,61h			;wait lots of time.
		in	al,61h
		in	al,61h
		pop	ax
		and	al,not (1 shl 2)	; and clear slave cascade bit in mask
		out	dx,al			;set new master mask (enable slave int)
	;
	; 500ns Stall required here, per INTEL documentation for eisa machines
	; - gft - 910617
	;
		push	ax
		in	al,61h	; 1.5 - 3 uS should be plenty
		in	al,61h
		in	al,61h
		pop	ax
		mov	dx,0a1h			;go enable int on slave 8259
		sub	cl,8
	unmask_not_irq2_1:

		in	al,dx			;enable interrupts on the correct 8259.
		mov	ah,1			;clear the bit.
		shl	ah,cl
		mov	cl,al			;remember the original mask.
		and	cl,ah
		not	ah
		and	al,ah
	;
	; 500ns Stall required here, per INTEL documentation for eisa machines
	; - gft - 910617
	;
		push	ax
		in	al,61h	; 1.5 - 3 uS should be plenty
		in	al,61h
		in	al,61h
		pop	ax
		out	dx,al

		mov	original_mask,al
	set_isr_no_irq_1:


		mov	al, int_no		; Get board's interrupt vector
		add	al, 8
		cmp	al, 8+8			; Is it a slave 8259 interrupt?
		jb	set_int_num		; No.
		add	al, 70h - 8 - 8		; Map it to the real interrupt.
	set_int_num:
		xor	ah, ah			; Clear high byte
		mov	int_num, ax		; Set parameter_list int num.

		clc				; Say no error
		ret				; Back to common code
	
	etopen ENDP
	
_TEXT ENDS

END MAIN