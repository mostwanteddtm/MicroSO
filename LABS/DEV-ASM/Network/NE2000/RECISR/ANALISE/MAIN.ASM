
;  Copyright, 1988-1993, Russell Nelson, Crynwr Software

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
;   Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA

include	defs.inc

public	entry_point, sys_features, flagbyte, is_186, is_286, is_386, original_mask
public	address_len, rom_address, my_address
public	their_timer
public 	their_recv_isr
public	their_isr

public	count_in_err
public	count_out_err

public recv_isr

public	maskint
public	unmaskint

extrn	int_no: byte

;external code supplied by device-dependent module:
extrn	xmit: near
extrn	recv: near
extrn	etopen: near

code	segment word public
	assume	cs:code, ds:code

	org	100h
start:

	cld

	call	etopen							;init the driver.  If any errors,

	mov 	ax, 4c00h
	int 	21h

;***************************************** DATA AREA **********************************************************

					dw 128 dup(?)				;128 words of stack.
	our_stack		label byte

	entry_point		db 68h,?,?,?			; interrupt to communicate.
	sys_features	db 0					; 2h = MC   40h = 2nd 8259
	is_186			db 1					;=0 if 808[68], =1 if 80[123]86.
	is_286			db 1					;=0 if 80[1]8[68], =1 if 80[234]86.
	is_386			db 1					;=0 if 80[12]8[68], =1 if 80[34]86.
	flagbyte		db 0	
	original_mask	db 0					;=0 if interrupt was originally on.
	even

;the device-dependent code reads the board's address from ROM in the
;initialization code.

	address_len		dw EADDR_LEN			;default to Ethernet.
	rom_address		db MAX_ADDR_LEN dup(?)	;our address in ROM.
	my_address		db MAX_ADDR_LEN dup(?)	;our current address.

	rcv_mode_num	dw 3

	found_handle	dw 0					; temp, handle for our packet
	receive_ptr		dd 0					; the pkt receive service routine

	savespss		label dword
	savesp			dw ?					;saved during the stack swap.
	savess			dw ?

	their_timer		dd 0					;original owner of timer int
	their_recv_isr	dd 0					;original owner of board int.
	
	their_isr		dd 0				; original owner of pkt driver int
	
	in_recv_isr	db 	0	; flag to trap re-entrancy
	
;************************************* END DATA AREA **********************************************************

;######### NÃO REMOVER #############
	
count_in_err:
	assume	ds:nothing
	ret
	
count_out_err:
	assume	ds:nothing
	ret
;##################################

;
; I have had a problem with some hardware which under extreme LAN loading
; conditions will re-enter the recv_isr. Since the 8259 interrupts for
; the card are masked off, and the card's interrupt mask register is 
; cleared (in 8390.asm at least) disabling the card from interrupting, this
; is clearly a hardware problem. Due to the low frequencey of occurance, and
; extreme conditions under which this happens, it is not lilely to be fixed
; in hardware any time soon, plus retrofitting of hardware in the field will
; not happen. To protect the driver from the adverse effects of this I am
; adding a simple re-entrancy trap here.  - gft - 910617
;

;*************************************************************************************************************

recv_isr:

	;mov	ah, 0eh
	;mov	al, 31h
	;int 10h

	cmp	in_recv_isr, 0
	jne	recv_iret

	mov	in_recv_isr, 1

; I realize this re-entrancy trap is not perfect, you could be re-entered
; anytime before the above instruction. However since the stacks have not
; been swapped re-entrancy here will only appear to be a spurious interrupt.
; - gft - 910617

; In order to achieve back-to-back packet transmissions, we handle the
; latency-critical portion of transmit interrupts first.  The xmit
; interrupt routine should only start the next transmission, but do
; no other work.  It may only touch ax and dx (the only register necessary
; for doing "out" instructions) unless it first pushes any other registers
; itself.
	push	ax
	push	dx
	;call	xmit

; Now switch stacks, push remaining registers, and do remaining interrupt work.
	push	ds
	mov	ax,cs			;ds = cs.
	mov	ds,ax
	assume	ds:code

	mov	savesp,sp
	mov	savess,ss

	mov	ss,ax
	mov	sp,offset our_stack
	cld

	push	bx
	push	cx
	push	si
	push	di
	push	bp
	push	es

; The following comment is wrong in that we now do a specific EOI command,
; and because we don't enable interrupts (even though we should).

; Chips & Technologies 8259 clone chip seems to be very broken.  If you
; send it a Non Specific EOI command, it clears all In Service Register
; bits instead of just the one with the highest priority (as the Intel
; chip does and clones should do).  This bug causes our interrupt
; routine to be reentered if: 1. we reenable processor interrupts;
; 2. we reenable device interrupts; 3. a timer or other higher priority
; device interrupt now comes in; 4. the new interrupting device uses
; a Non Specific EOI; 5. our device interrupts again.  Because of
; this bug, we now completely mask our interrupts around the call
; to "recv", the real device interrupt handler.  This allows us
; to send an EOI instruction to the 8259 early, before we actually
; reenable device interrupts.  Since the interrupt is masked, we
; are still guaranteed not to get another interrupt from our device
; until the interrupt handler returns.  This has another benefit:
; we now no longer prevent other devices from interrupting while our
; interrupt handler is running.  This is especially useful if we have
; other (multiple) packet drivers trying to do low-latency transmits.
	mov	al,int_no	; Disable further device interrupts
	call	maskint

; The following is from Bill Rust, <wjr@ftp.com>
; this code dismisses the interrupt at the 8259. if the interrupt number
;  is > 8 then it requires fondling two PICs instead of just one.
	mov	al, int_no	; get hardware int #
	or	al,al		; if it's zero, then there is no IRQ to ack.
	je	recv_isr_3	; so skip the EOI processing.
	cmp	al, 8		; see if its on secondary PIC
	jg	recv_isr_4
	add	al, 60h		; make specific EOI dismissal
	out	20h, al
	jmp	short recv_isr_3	; all done
recv_isr_4:
	add	al,60h - 8	; make specific EOI (# between 9 & 15).
	out	0a0h,al		; Secondary 8259 (PC/AT only)
	mov	al,62h		; Acknowledge on primary 8259.
	out	20h,al
recv_isr_3:

;	sti				; Interrupts are now completely safe
	call	recv

	cli				;interrupts *must* be off between
					;here and the stack restore, because
					;if we have one of our interrupts
					;pending, we would trash our stack.

	mov	al,int_no	; Now reenable device interrupts
	call	unmaskint

	pop	es
	pop	bp
	pop	di
	pop	si
	pop	cx
	pop	bx

	mov	ss,savess
	mov	sp,savesp

	pop	ds
	assume	ds:nothing
	pop	dx
	pop	ax
	mov	in_recv_isr, 0	; clear the re-entrancy flag - gft - 901617
recv_iret:
	iret

;*************************************************************************************************************
	
maskint:
	or	al,al			;are they using a hardware interrupt?
	je	maskint_1		;no, don't mask off the timer!

	assume	ds:code
	mov	dx,21h			;assume the master 8259.
	cmp	al,8			;using the slave 8259 on an AT?
	jb	mask_not_irq2
	mov	dx,0a1h			;go disable it on slave 8259
	sub	al,8
mask_not_irq2:
	mov	cl,al

	in	al,dx			;disable them on the correct 8259.
	mov	ah,1			;set the bit.
	shl	ah,cl
	or	al,ah
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
maskint_1:
	ret

;*************************************************************************************************************

unmaskint:
;exit with cl = 0 if the interrupt had been enabled.
	assume	ds:code
	mov	dx,21h			;assume the master 8259.
	mov	cl,al
	cmp	cl,8			;using the slave 8259 on an AT?
	jb	unmask_not_irq2		;no
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
unmask_not_irq2:

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

	ret

	;*************************************************************************************************************

	public printmem
	;*************************************************************************************************************;
    ;                                                                                                             ;
    ; print memory                                                                                                ;
    ;   in:     si -> buffer offset                                                                               ;
    ;           cx -> number of bytes print                                                                       ;
    ;   out:    display memory bytes on screen                                                                    ;
    ;                                                                                                             ;
    ;**************************************************************************************************************                     
    printmem proc
	
		call	newline

        xor     di, di
        mov     bx, offset tab

    @@: cmp     di, 10h
        jne     cpmem
        call    newline
        xor     di, di
    cpmem:
        inc     di
        mov     ah, 0eh 
        lodsb
        mov     dl, al
		push    cx
		mov		cx, 4
        shr     al, cl
		pop		cx
        xlatb
        int     10h
        mov     al, dl
        and     al, 0fh
        xlatb
        int     10h
        mov     al, 20h
        int     10h
        loop    @b
		
		call	newline

        ret

    newline: 
		mov     ah, 0eh
        mov     al, 0dh
        int     10h

        mov     al, 0ah
        int     10h

        ret
		
	tab             	db '0123456789abcdef'
      
    printmem endp

code	ends

	end	start
