;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;
;;;;	SERIAL HARDWARE MODULE
;;;;   (C) Copyright 1995 Gregory Ercolano                                
;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; INIT THE COMRING
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
initcomring	proc near
	;;; INIT VECTORS
	mov [com1in],offset com1buf
	mov [com1out],offset com1buf
	mov [com1end],offset com1buf+COMBUF_SIZE

	mov [com2in],offset com2buf
	mov [com2out],offset com2buf
	mov [com2end],offset com2buf+COMBUF_SIZE

	;;; ZERO OUT COM1 BUFFER
	mov al,'1'
	mov cx,COMBUF_SIZE
	push ds
	pop si
	mov di,offset com1buf
	call memset		;SI:DI filled with value in AL for CX bytes

	;;; ZERO OUT COM2 BUFFER
	mov al,'2'
	mov cx,COMBUF_SIZE
	mov di,offset com2buf
	call memset		;SI:DI filled with value in AL for CX bytes

	ret
initcomring	endp


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; INIT SERIAL HARDWARE
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
initserial	proc near
	push ds
	  mov ax,0040h		; bios
	  mov ds,ax
	  mov bx,[ds:0]		; com1 port address from bios
	  mov cx,[ds:2]		; com2 port address from bios
	pop ds
	mov [com1port],bx
	mov [com2port],cx

	; DISABLE COM INTERRUPTS WHILE WE FUCK WITH HARDWARE
	cli
	in al,21h
	or al,00011000b		; DISABLE IRQ3 AND IRQ4
	out 21h,al

	; DISABLE IER FOR COM1
	mov dx,[com1port]
	add dx,1
	mov al,00000000b
	out dx,al

	; DISABLE IER FOR COM2
	mov dx,[com2port]
	add dx,1
	mov al,00000000b
	out dx,al

	; COM HARDWARE INTERRUPT VECTOR INIT
	push ds
	  mov ax,0		; address interrupt table in 0000:xxxx
	  mov ds,ax
	  mov ax,cs
	  mov [ds:002eh],ax		; COM1 HARDWARE INTERRUPT (SEG)
	  mov [ds:0032h],ax		; COM2 HARDWARE INTERRUPT (SEG)

	  mov ax,offset com2int
	  mov [ds:002ch],ax		; COM2 HARDWARE INTERRUPT (OFF) 

	  mov ax,offset com1int
	  mov [ds:0030h],ax		; COM1 HARDWARE INTERRUPT (OFF) 
	pop ds

	; COM1 HARDWARE INIT
	mov dx,[com1port]
	call serialhardinit

	; COM2 HARDWARE INIT
	mov dx,[com2port]
	call serialhardinit

	in al,21h
	and al,11100111b		; ENABLE IRQ3 AND IRQ4
	out 21h,al
	ret
initserial	endp

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; LOCAL: INIT SERIAL HARDWARE
;	Hardware initialized to 9600,n,8,1
; 	dx=port base address
;	DX is maintained on return
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
serialhardinit	proc near
	; INITIALIZE BAUD RATE
	;	Also initializes DLAB in process.. 
	;	a good thing to do first.
	;
	sti
	mov ax, 0006h		;19200 baud
	call setbaud

	; SETUP IER (Interrupt Enable Register)
	;	Interrupt whenever a character is received
	add dx,1
	in al,dx
	or al, 00000001b	; 0001=chr rdy, 0010=THRE, 0100=LSR, 1000=MSR
	out dx,al
	sub dx,1

	; SETUP LCR (Line Control Register)
	add dx,3
	mov al,0000011b		; N,8,1 (no parity, 8 bit, 1 stop bit)
	out dx,al
	sub dx,3

	; SETUP MCR (Modem Control Register)
	add dx,4
	mov al,0001111b		; enable OUT1/2, DTR, RTS
	out dx,al
	sub dx,4

	; CLEAR IOR (Input/Output register) BY READING IT
	in al,dx

	; CLEAR IIR (Interrupt Ident Register) BY READING IT
	add dx,2
	in al,dx
	sub dx,2

	; CLEAR LSR (Line Status Register) BY READING IT
	add dx,5
	in al,dx
	sub dx,5

	; CLEAR MSR (Modem Status Register) BY READING IT
	add dx,6
	in al,dx
	sub dx,6

	sti
	ret
serialhardinit	endp

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; LOCAL: SET BAUD RATE
;	dx=port base for com port
;	ax=baud rate divisor
;	DX is maintained
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
setbaud	proc near
	push ax			; save baud rate divisor

	  ; ENABLE DLAB (Divisor Latch Access Bit)
	  add dx,3
	  in al,dx
	  or al,10000000b	; DLAB BIT SET
	  out dx,al
	  sub dx,3

	; SET BAUD RATE TO 9600 (what other baud rate would anyone want? ;)
	pop ax
	out dx,al		; Divisor Low
	xchg al,ah
	inc dx
	mov al,00h		; Divisor Hi
	out dx,al
	dec dx

	; DISABLE DLAB
	add dx,3
	in al,dx
	and al,01111111b	; DLAB BIT CLEAR
	out dx,al
	sub dx,3
	ret
setbaud	endp

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; COM1 AND COM2 SERIAL HARDWARE INTERRUPT ENTRY POINT
;	When data is received on the serial ports, these interrupts
;	are executed.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
com1int:
	cli
	push ax
	push bx
	push dx
	push si
	push ds

        mov ax,cs
        mov ds,ax
        mov dx,[com1port]	; I/O port
	mov bx,[com1in]		; buffer head
        in al,dx		; get waiting char
	mov [ds:bx],al		; save it in ring buffer

	; ADVANCE BUFFER HEAD
	RING_ADVANCE com1in,com1end,com1buf

	mov al,20h		; ACKNOWLEDGE IRQ3
	out 20h,al

; COMn END OF INTERRUPT
comeoi:
	pop ds
	pop si
	pop dx
	pop bx
	pop ax
	sti
	iret
	
com2int:
	cli
	push ax
	push bx
	push dx
	push si
	push ds

        mov ax,cs
        mov ds,ax
        mov dx,[com2port]	; I/O port
	mov bx,[com2in]		; buffer head
        in al,dx		; get waiting char
	mov [ds:bx],al		; save it in ring buffer

	; ADVANCE BUFFER HEAD
	RING_ADVANCE com2in,com2end,com2buf

	mov al,64h		; ACKNOWLEDGE IRQ4
	out 20h,al

	jmp short comeoi

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; OUTPUT BYTE IN AL TO SERIAL PORT
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
serialout:
	push dx
	push ds
	  push ax
	    mov ax,0040h		; bios
	    mov ds,ax
	    mov dx,[ds:0000h]	; com IO port
	    add dx,5		; LSR
so_wait:
	    in al,dx		; WAIT FOR LAST CHARACTER TO FINISH SEND
	    and al,01100000b	; test that both THRE and TSRE bits are set
	    cmp al,60h
	    jne so_wait
	    sub dx,5		; I/O REG
	  pop ax
	  out dx,al
	pop ds
	pop dx
	ret

; READ BYTE FROM INTERRUPT DRIVEN SERIAL FIFO BUFFER
;	Returns no carry if no characters ready.
;	Otherwise, carry is set, and character received in AL
;
serialin:
	mov ax,[com1in]
	cmp ax,[com1out]
	jz si_nochar

	; READ BYTE FROM FIFO BUFFER
	mov bx,[com1out]
	mov al,[ds:bx]
	RING_ADVANCE com1out,com1end,com1buf
	mov ah,al
	inc ah
	cmp al,ah
	stc
	ret
si_nochar:
	clc
	ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; SEND STRING AT [ds:si] TO SERIAL PORT
;	AX and SI trashed
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
serialoutstring	proc near
sos_loop:
	mov al,[ds:si]
	cmp al,0
	jz sos_done
	call serialout
	inc si
	jmp sos_loop
sos_done:
	ret

serialoutstring	endp

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; SEND A BREAK SIGNAL TO THE REMOTE
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
serialbreak	proc near
	push ax
	push dx
	  mov dx,[com1port]
	  add dx,3			; LCR
	  in al,dx
	  or al,01000000b		; bit #6 set: break mode
	  out dx,al

	  ; NOW HOLD IN THIS STATE FOR ONE SECOND
	  mov cx,18			; 18 ticks of clock == 1 second
	  call wait_ticks

	  xor al,01000000b		; bit #6 off = disable break
	  out dx,al
        pop dx
        pop ax
	ret
serialbreak	endp