INCLUDE	DEFS.INC
INCLUDE	8390.INC

NE_DATAPORT		EQU	10h		; NE2000 Port Window.
NE_RESET		EQU	1fh		; Issue a read for reset
EN_OFF			EQU	0h

SM_TSTART_PG	EQU	040h	; First page of TX buffer
SM_RSTART_PG	EQU	046h	; Starting page of RX ring
SM_RSTOP_PG		EQU	080h	; Last page +1 of RX ring

CODE	SEGMENT WORD PUBLIC
	ASSUME	CS:CODE, DS:NOTHING

	ORG	100h
	
	START:

		CALL	ETOPEN							;INIT THE DRIVER.  IF ANY ERRORS,

		MOV 	AX, 4C00h
		INT 	21h

	;***************************************** DATA AREA **********************************************************
	
		SM_RSTOP_PTR	DB SM_RSTOP_PG
		RXCR_BITS       DB ENRXCR_BCST     		; Default to ours plus multicast

		INT_NO			DB 3,0,0,0				; must be four bytes long for get_number.
		IO_ADDR			DW 0300h,0				; I/O address for card (jumpers)

		INT_NUM	DW	0							; Interrupt # to hook for post-EOI
												; processing, 0 == none,
												
		MCAST_LIST_BITS DB 0,0,0,0,0,0,0,0 		; Bit mask from last set_multicast_list
		MCAST_ALL_FLAG  DB 0               		; Non-zero if hware should have all
												; ones in mask rather than this list.
												
												; a temp buffer for the received header

		RCV_HDR_SIZE	EQU	100h					; 2 ids @6 + protocol @2+8, + header @4
		RCV_HDR			DB RCV_HDR_SIZE dup(0)
		
		BOARD_DATA_SIZE EQU	32					; The board data
		BOARD_DATA		DB BOARD_DATA_SIZE DUP(0)

		NEXT_PACKET		DB	0
		SAVE_CURR		DB	0

						DW 128 DUP(?)			; 128 words of stack.
		OUR_STACK		LABEL BYTE

		ENTRY_POINT		DB 68h,?,?,?			; interrupt to communicate.
		EVEN

		ADDRESS_LEN		DW EADDR_LEN			;default to Ethernet.
		ROM_ADDRESS		DB MAX_ADDR_LEN dup(?)	;our address in ROM.

		RCV_MODE_NUM	DW 3

		FOUND_HANDLE	DW 0					; temp, handle for our packet
		RECEIVE_PTR		DD 0					; the pkt receive service routine

		SAVESPSS		LABEL DWORD
		SAVESP			DW ?					;saved during the stack swap.
		SAVESS			DW ?

		THEIR_RECV_ISR	DD 0					;original owner of board int.
		
		IN_RECV_ISR		DB 0					; flag to trap re-entrancy
		
		ENDCFG			DB	048h				;standard EN0_DCFG contents:
												; Set burst mode, 8 deep FIFO
	
	;************************************* END DATA AREA **********************************************************
	
	;*************************************************************************************************************;
	;                                                                                                             ;
	; HARDWARE INTERRUPT SERVICE ROUTINE                                                                          ;
	;   IN:     NONE                                                                         					  ;
	;   OUT:    NONE                                                                        					  ;
	;                                                                                                             ;
	;************************************************************************************************************** 

	RECV_ISR:

		CMP		IN_RECV_ISR, 0
		JNE		RECV_IRET

		MOV		IN_RECV_ISR, 1

		PUSH	AX
		PUSH	DX

	
		PUSH	DS								; Now switch stacks, push remaining registers, and do remaining interrupt work.
		MOV		AX, CS							;ds = cs.
		MOV		DS, AX
		ASSUME	DS:CODE

		MOV		SAVESP, SP
		MOV		SAVESS, SS

		MOV		SS, AX
		MOV		SP, OFFSET OUR_STACK
		CLD

		PUSH	BX
		PUSH	CX
		PUSH	SI
		PUSH	DI
		PUSH	BP
		PUSH	ES
												; this code dismisses the interrupt at the 8259. if the interrupt number
												; is > 8 then it requires fondling two PICs instead of just one.
		MOV		AL, INT_NO						; get hardware int #
		OR		AL, AL							; if it's zero, then there is no IRQ to ack.
		JE		RECV_ISR_3						; so skip the EOI processing.
		CMP		AL, 8							; see if its on secondary PIC
		JG		RECV_ISR_4
		ADD		AL, 60h							; make specific EOI dismissal
		OUT		20h, AL
		JMP		SHORT RECV_ISR_3				; all done
	RECV_ISR_4:
		ADD		AL, 60h - 8						; make specific EOI (# between 9 & 15).
		OUT		0A0h, AL						; Secondary 8259 (PC/AT only)
		MOV		AL, 62h							; Acknowledge on primary 8259.
		OUT		20h, AL
	RECV_ISR_3:

		CALL	RECV
		CLI										; interrupts *must* be off between
												; here and the stack restore, because
												; if we have one of our interrupts
												; pending, we would trash our stack.

		MOV		AL, INT_NO						; Now reenable device interrupts
		CALL	UNMASKINT

		POP		ES
		POP		BP
		POP		DI
		POP		SI
		POP		CX
		POP		BX

		MOV		SS, SAVESS
		MOV		SP, SAVESP

		POP		DS
		ASSUME	DS:NOTHING
		POP		DX
		POP		AX
		MOV		IN_RECV_ISR, 0					; clear the re-entrancy flag - gft - 901617
	RECV_IRET:
		IRET
		
	;**************************** END HARDWARE INTERRUPT SERVICE ROUTINE *****************************************
	
	;*************************************************************************************************************;
	;                                                                                                             ;
	; RECEIVE PACKET ON ETHERNET CARD                                                                             ;
	;   IN:     NONE                                                                         					  ;
	;   OUT:    NONE                                                                        					  ;
	;                                                                                                             ;
	;************************************************************************************************************** 
		
	RECV:

		ASSUME	DS:CODE

	CHECK_ISR:									; Was there an interrupt from this card?
		MOV		DX, 30Fh						; point at interrupt masks
		MOV		AL, 0							; leave the chip running.
		OUT		DX, AL							; no interrupts please.

		MOV 	DX, 307h
		IN 		AL,	DX							; Get pending interrupts
		AND 	AL,	ENISR_ALL					; Any?
		JNZ		ISR_TEST_OVERRUN
		JMP		INTERRUPT_DONE					; Go if none

	ISR_TEST_OVERRUN:							; Test for receive overrun in value from NIC ISR register
		TEST 	AL, ENISR_OVER					; Was there an overrun?
		JNZ		RECV_OVERRUN					; Go if so.
		JMP		RECV_NO_OVERRUN					; Go if not.

	RECV_OVERRUN:
		JMP 	$ 								; erro
	  
	RECV_NO_OVERRUN:							; Handle receive flags, normal and with error (but not overrun).
		TEST 	AL, ENISR_RX+ENISR_RX_ERR		; Frame received without overrun?
		JNZ		RECV_FRAME_0					; Go if so.

		JMP 	$ 								; erro

	RECV_FRAME_0:
		MOV 	DX, 307h
		MOV 	AL,	ENISR_RX+ENISR_RX_ERR
		OUT 	DX,	AL							; Clear those requests

		MOV 	DX, 300h
		CLI
		MOV 	AL,	ENC_NODMA+ENC_PAGE1+ENC_START
		OUT 	DX,	AL							; Switch to page 1 registers

		MOV		DX, 307h						;Get current page of rcv ring
		IN 		AL,	DX							; ..
	;	MOV 	AH,	AL							; Hold current page in AH
		MOV 	SAVE_CURR, AL					; Hold last read current page register in 
												; memory instead - gft - 910611
												
		MOV 	DX, 300h						; Back to page zero registers
		MOV 	AL,	ENC_NODMA+ENC_PAGE0+ENC_START
		OUT 	DX,	AL							; Switch back to page 0 registers

												; This becomes the loop back point to read packets from the ring.
												; now only loop back and read until those packets received at the time 
												; the current page register is read above have been read.
	RECV_FRAME:
		MOV 	AL, NEXT_PACKET					; Get saved pointer to next packet in ring
												; change the next instruction to compare against the saved copy of the current
												; page register and only read from the ring what was received up until the 
												; last read from the current page register - gft - 910611
	;	CMP 	AL,	AH							; Read all the frames?
		CMP 	AL,	SAVE_CURR					; Read all the frames?
		JNE		RECV_MORE_FRAMES				; hacked jump code for addition of mkle
												; macro below - gft -910521
	;	JMP		RECV_FRAME_BREAK				; Finished them all

												; changed jmp recv_frame_break to jmp check_isr after recv_frame_break was
												; determined to be superfluous. See comments at recv_frame_break below.
												; - gft - 910531
		JMP	CHECK_ISR							; Finished all receives, check for more
												; interrupts.
	RECV_MORE_FRAMES:

		MOV		AH, AL							; make a byte address. E.G. page
		MOV		AL, 0							; 46h becomes 4600h into buffer
		MOV		BL, AH

		PUSH 	DS								; movseg	es,ds
		POP 	ES

		MOV		CX, RCV_HDR_SIZE
		MOV		DI, OFFSET RCV_HDR
		CALL	BLOCK_INPUT

		MOV		SI, OFFSET RCV_HDR
		MOV		CX, DS:[SI+2]

		CALL 	PRINTMEM
		
		MOV 	AL,	RCV_HDR+EN_RBUF_STAT		; Get the buffer status byte
		TEST 	AL, ENRSR_RXOK					; Good frame?
		JZ		RECV_ERR_NO_RCV
												; EVEN if the NIC header status is OK, I have seen garbaged NIC headers, so
												; it doesn't hurt to range check the next packet pointer here.
		MOV 	AL,	RCV_HDR+EN_RBUF_NXT_PG		; Start of next frame
		MOV 	NEXT_PACKET, al					; Save next packet pointer
		CMP 	AL, SM_RSTART_PG				; Below around the bottom?
		JB		RECV_ERR_NO_RCV 				; YES - out of range
		CMP		AL, SM_RSTOP_PTR 				; Above the top?
		JAE		RECV_ERR_NO_RCV 				; YES - out of range

												; ok to call rcv_frm
		;CALL	RCV_FRM							; Yes, go accept it
		JMP	RECV_NO_RCV
	RECV_ERR_NO_RCV:
		;OR		BYTE PTR SOFT_RX_ERR_BITS, AL
		;ADD2	SOFT_RX_ERRORS, 1

		MOV     AL, SAVE_CURR   				; get the last known current page pointer
		MOV     NEXT_PACKET, AL 				; and use it as the next packet pointer
		JMP     CHECK_ISR       				; then go handle more interrupts

	RECV_NO_RCV:

		MOV		AL, NEXT_PACKET					; Grap the next packet pointer
		DEC		AL								; Make previous page for new boundary

		CMP 	AL,	SM_RSTART_PG				; Wrap around the bottom?
	;	JGE		RCV_NWRAP4
		JAE		RCV_NWRAP4						; - gft - 910610
		MOV 	AL,	SM_RSTOP_PTR				; Yes
		DEC 	AL
	RCV_NWRAP4:
												; Point at the Boundary Reg again
		MOV 	DX, 303h						; EN0_BOUNDARY
		OUT 	DX,	AL							; Set new boundary
		

		JMP		RECV_FRAME						; See if any more frames

	RECV_NO_FRAME:								; Handle transmit flags.

	INTERRUPT_DONE:
		MOV 	DX, 30fh						; EN0_IMR Tell card it can cause these interrupts
		MOV 	AL,	ENISR_ALL
		OUT 	DX,	AL
		RET
	
	;**************************** END RECEIVE PACKET ON ETHERNET CARD ********************************************

	;*************************************************************************************************************;
	;                                                                                                             ;
	; OPEN ETHERNET CARD NE2000                                                                               	  ;
	;   IN:     NONE                                                                         					  ;
	;   OUT:    NONE                                                                        					  ;
	;                                                                                                             ;
	;************************************************************************************************************** 

	ETOPEN:										; Initialize interface
		
	;Step 1. Reset and stop the 8390.		
		
		MOV		DX, 300h 						; io_addr
		ADD 	DX, 1fh							; NE_RESET
		IN 		AL, DX		
		OUT		DX, AL							; should set command 21, 80
		
		MOV 	DX, 300h						; io_addr
		ADD 	DX, 00h							; EN_CCMD
		
		MOV 	AL,	01h+20h						; ENC_STOP+ENC_NODMA
		OUT 	DX,	AL							; Stop the DS8390
		
	;Step 2. Init the Data Config Reg.		
		
		MOV		DX, 300h						; io_addr
		MOV		AL, 48h							; endcfg
		ADD		DX, 0Eh							; EN0_DCFG
		OUT		DX, AL

	;Step 2a.  Config the Command register to page 0.

		MOV		DX, 300h						; io_addr
		MOV		AL, 00h + 20h + 01h				; ENC_PAGE0 + ENC_NODMA + ENC_STOP
		ADD		DX, 00h							; EN_CMD
		OUT		DX, AL

	;Step 3. Clear Remote Byte Count Regs.

		MOV		DX, 300h						; io_addr
		MOV		AL, 0		
		ADD		DX, 0Ah							; EN0_RCNTLO
		OUT		DX, AL		
		
		MOV		DX, 300h						; io_addr
		ADD		DX, 0Bh							; EN0_RCNTHI
		OUT		DX, AL

	;Step 4. Set receiver to monitor mode

		MOV		DX, 300h						; io_addr
		MOV		AL, 20h							; ENRXCR_MON
		ADD		DX, 0Ch							; EN0_RXCR
		OUT		DX, AL

	;Step 5. Place NIC into Loopback Mode 1.

		MOV		DX, 300h						; io_addr
		MOV		AL, 02h							; ENTXCR_LOOP
		ADD		DX, 0Dh							; EN0_TXCR
		OUT		DX, AL

	;Step 6. Do anything special that the card needs.  
	;Read the Ethernet address into rom_address.

		OR		ENDCFG, ENDCFG_WTS				; endcfg = 49h
		
		MOV		DX, 300h						; io_addr
		MOV		AL, 49h							; endcfg
		ADD		DX, 0Eh							; EN0_DCFG
		OUT		DX, AL		
		
		MOV		CX, 10h							; get 16 bytes,
				
		PUSH DS									;MOVSEG	ES, DS
		POP ES		
		MOV	DI, OFFSET BOARD_DATA		
		
		MOV		DX, 300h						; io_addr
		ADD		DX, 00h							; EN_CCMD
		MOV		AL, 20h+00h+02h					; ENC_NODMA+ENC_PAGE0+ENC_START
		OUT		DX, AL		
		
		MOV		DX, 300h						; io_addr
		ADD		DX, 0Ah							; EN0_RCNTLO
		MOV		AL, 20h							; count is actually doubled.
		OUT		DX, AL		
		
		MOV		DX, 300h						; io_addr
		ADD		DX, 0Bh							; EN0_RCNTHI
		XOR		AL, AL		
		OUT		DX, AL		
		
		MOV		AX, 0							; from address 0
		
		MOV		DX, 300h						; io_addr
		ADD		DX, 08h							; EN0_RSARLO
		OUT		DX, AL		
		
		MOV		DX, 300h						; io_addr
		ADD		DX, 09h							; EN0_RSARHI
		MOV		AL, AH		
		OUT		DX, AL		
		
		MOV		DX, 300h						; io_addr
		ADD		DX, 00h							; EN_CCMD
		MOV		AL, 08h+02h						; ENC_RREAD+ENC_START	; read and start
		OUT		DX, AL		
		
		MOV		DX, 300h						; io_addr
		ADD		DX, 10h							; NE_DATAPORT
		
	SP_READ_LOOP_1:		
		IN		AL, DX							; get a byte
		STOSB									; save it
		LOOP	SP_READ_LOOP_1		
		
		PUSH    DS              				; Copy from card's address to current address
		POP     ES		
		
		MOV 	SI, OFFSET BOARD_DATA			; address is at start
		MOV 	DI, OFFSET ROM_ADDRESS		
		MOV 	CX, EADDR_LEN       			; Copy one address length
		REP     MOVSB           				; ..
		
		CLC		
		
		JNC	ETOPEN_1							;go if it worked.
		RET
	ETOPEN_1:

	;Step 7. Re-init endcfg in case they put it into word mode.

		MOV		DX, 300h						; io_addr
		MOV		AL, 49h							; endcfg
		ADD		DX, 0Eh							; EN0_DCFG
		OUT		DX, AL

	;Step 8. Init EN0_STARTPG to same value as EN0_BOUNDARY

		MOV		DX, 300h						; io_addr
		MOV		AL, 46h							; SM_RSTART_PG
		ADD		DX, 01h							; EN0_STARTPG
		OUT		DX, AL		
		
	  IF 1										;Paul Kranenburg suggests that this should be set to zero.
		MOV		AL, SM_RSTART_PG		
	  ELSE		
		MOV		AL, SM_RSTOP_PTR		
		DEC	 AL		
	  ENDIF		
		
		MOV		DX, 300h						; io_addr
		ADD		DX, 03h							; EN0_BOUNDARY
		OUT		DX, AL		
		
		MOV		DX, 300h						; io_addr
		MOV		AL, 80h							; sm_rstop_ptr = SM_RSTOP_PG
		ADD		DX, 02h							; EN0_STOPPG
		OUT		DX, al

	;Step 9. Write 1's to all bits of EN0_ISR to clear pending interrupts.

		MOV		DX, 300h						; io_addr
		MOV		AL, 0ffh		
		ADD		DX, 07h							; EN0_ISR
		OUT		DX, AL		
		
	;Step 10. Init EN0_IMR as desired.		
		
		MOV		DX, 300h						; io_addr
		MOV		AL, 3Fh							; ENISR_ALL
		ADD		DX, 0Fh							; EN0_IMR
		OUT		DX, AL

	;Step 11. Init the Ethernet address and multicast filters.

		MOV		SI, OFFSET ROM_ADDRESS			; enter with my_address,si -> Ethernet address, CX = length of address.
		MOV		CX, EADDR_LEN					; exit with nc if okay, or cy, dh=error if any errors.
		
		MOV		DX, 300h						; io_addr
		ADD		DX, 00h							; EN_CCMD
		
		PUSHF		
		CLI										; Protect from irq changing page bits
		
		MOV		AL, 20h+40h						; ENC_NODMA+ENC_PAGE1	;+ENC_STOP
		OUT 	DX,	AL							; Switch to page one for writing eaddr
		
		MOV		DX, 300h						; io_addr
		ADD		DX, 01h							; EN1_PHYS
		
	SET_8390_2:		
		LODSB		
		OUT		DX, AL		
		INC		DX		
		LOOP	SET_8390_2		
		
		MOV		DX, 300h						; io_addr
		ADD		DX, 00h							; EN_CCMD
		
		MOV		AL, 20h+00h						; ENC_NODMA+ENC_PAGE0	;+ENC_STOP
		OUT 	DX,	AL							; Restore to page zero
		
		POPF		
		CLC		
		
		CALL	SET_HW_MULTI  					; Put the right stuff into 8390's multicast masks

	;Step 12. Program EN_CCMD for page 1.

		MOV		DX, 300h						; io_addr
		ADD		DX, 00h							; EN_CCMD
		MOV		AL, 40h+20h+01h					; al, ENC_PAGE1 + ENC_NODMA + ENC_STOP
		OUT		DX, AL

	;Step 13. Program the Current Page Register to same value as Boundary Pointer.

		MOV		AL, 46h							; SM_RSTART_PG
		INC		AL								; To fix the bug! - gft - 910523
		
		MOV		DX, 300h						; io_addr
		ADD		DX, 07h							; EN1_CURPAG
		OUT		DX, AL		
		
		MOV		SAVE_CURR, AL					; added in conjunction with fixes above
												; - gft - 910611
		MOV		NEXT_PACKET, AL 				; initialize next_packet to the value in
												; current - gft - 910603

	;Step 14. Program EN_CCMD back to page 0, and start it.

		MOV		AL, 20h + 02h + 00h				; ENC_NODMA + ENC_START + ENC_PAGE0
		MOV		DX, 300h						; io_addr
		ADD		DX, 00h							; EN_CCMD
		OUT		DX, AL		
		
		MOV		AL, 0							;set transmitter mode to normal.
		MOV		DX, 300h						; io_addr
		ADD		DX, 0Dh							; EN0_TXCR
		OUT		DX, AL		
		
	  IF 0		
		MOV		AL, 04h							; ENRXCR_BCST
		MOV		DX, 300h						; io_addr
		ADD		DX, 0Ch							; EN0_RXCR
		OUT		DX, AL		
	  ENDIF		
		
		MOV		AH, 35h							; get the old interrupt into es:bx
		MOV		AL, INT_NO						; board's interrupt vector
		OR		AL, AL		
		JE		SET_ISR_NO_IRQ		
		ADD		AL, 8		
		CMP		AL, 8+8							; is it a slave 8259 interrupt?
		JB		SET_RECV_ISR_1					; no.
		ADD		AL, 70h - 8 - 8					; map it to the real interrupt.
	SET_RECV_ISR_1:
		INT		21h
		MOV		THEIR_RECV_ISR.OFFS, BX			; remember the old seg:off.
		MOV		THEIR_RECV_ISR.SEGM, ES		
		
		MOV		AH, 25h							; now set our recv interrupt.
		MOV		DX, OFFSET RECV_ISR		
		INT		21h		
		
		MOV		AL, INT_NO						; Now enable interrupts
				
		CALL	UNMASKINT		
		
	SET_ISR_NO_IRQ:		
		
		MOV		AL, INT_NO						; Get board's interrupt vector
		ADD		AL, 8		
		CMP		AL, 8+8							; Is it a slave 8259 interrupt?
		JB		SET_INT_NUM						; No.
		ADD		AL, 70h - 8 - 8					; Map it to the real interrupt.
	SET_INT_NUM:		
		XOR		AH, AH							; Clear high byte
		MOV		INT_NUM, AX						; Set parameter_list int num.

		MOV 	AL,	ENRXCR_BCST+ENRXCR_MULTI+ENRXCR_PROMP
		MOV     MCAST_ALL_FLAG, 1
		PUSH    AX								; Hold mode until masks are right
		CALL    SET_HW_MULTI					; Set the multicast mask bits in chip
		POP     AX		
		
		MOV 	DX, 30Ch		
		OUT 	DX, AL		
		MOV     RXCR_BITS, AL					; Save a copy of what we set it to
				
				
		CLC										; Say no error
		RET										; Back to common code;
		
	;************************************* END ETOPEN **********************************************************

;*************************************************************************************************************
	
maskint:
	or		al, al							; are they using a hardware interrupt?
	je		maskint_1						; no, don't mask off the timer!

	assume	ds:code
	mov		dx, 21h							; assume the master 8259.
	cmp		al, 8							; using the slave 8259 on an AT?
	jb		mask_not_irq2
	mov		dx, 0a1h						; go disable it on slave 8259
	sub		al, 8
mask_not_irq2:
	mov		cl, al

	in		al, dx							; disable them on the correct 8259.
	mov		ah, 1							; set the bit.
	shl		ah, cl
	or		al, ah
;
; 500ns Stall required here, per INTEL documentation for eisa machines
; - gft - 910617
;
	push	ax
	in		al, 61h							; 1.5 - 3 uS should be plenty
	in		al, 61h
	in		al, 61h
	pop		ax
	out		dx, al
maskint_1:
	ret

;*************************************************************************************************************

unmaskint:
;exit with cl = 0 if the interrupt had been enabled.
	assume	ds:code
	mov		dx, 21h							; assume the master 8259.
	mov		cl, al
	cmp		cl, 8							; using the slave 8259 on an AT?
	jb		unmask_not_irq2					; no
	in		al, dx							; get master mask
	push	ax
	in		al, 61h							; wait lots of time.
	in		al, 61h
	in		al, 61h
	pop		ax
	and		al, not (1 shl 2)				; and clear slave cascade bit in mask
	out		dx, al							; set new master mask (enable slave int)
;
; 500ns Stall required here, per INTEL documentation for eisa machines
; - gft - 910617
;
	push	ax
	in		al, 61h							; 1.5 - 3 uS should be plenty
	in		al, 61h
	in		al, 61h
	pop		ax
	mov		dx, 0a1h						; go enable int on slave 8259
	sub		cl, 8
unmask_not_irq2:

	in		al, dx							; enable interrupts on the correct 8259.
	mov		ah, 1							; clear the bit.
	shl		ah, cl
	mov		cl, al							; remember the original mask.
	and		cl,ah
	not		ah
	and		al,ah
;
; 500ns Stall required here, per INTEL documentation for eisa machines
; - gft - 910617
;
	push	ax
	in		al, 61h							; 1.5 - 3 uS should be plenty
	in		al, 61h
	in		al, 61h
	pop		ax
	out		dx, al

	ret

	;*************************************************************************************************************;
    ;                                                                                                             ;
    ; print memory                                                                                                ;
    ;   in:     si -> buffer offset                                                                               ;
    ;           cx -> number of bytes print                                                                       ;
    ;   out:    display memory bytes on screen                                                                    ;
    ;                                                                                                             ;
    ;**************************************************************************************************************                     
    printmem proc

		CMP		CX, 0FFh
		JLE		@f
		MOV		CX, 100
	@@:
	
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

;	Block input routine
;	CX = byte count, es:di = buffer location, ax = buffer address
block_input:
	push	ax		; save buffer address
	;loadport
	;setport EN_CCMD
	;pause_
	mov dx, 300h
	mov	al,ENC_NODMA+ENC_PAGE0+ENC_START
	out	dx,al
	;setport	EN0_RCNTLO	; remote byte count 0
	;pause_
	mov dx, 30ah
	mov	al,cl
	out	dx,al
	;setport	EN0_RCNTHI
	;pause_
	mov dx, 30bh
	mov	al,ch
	out	dx,al
	pop	ax		; get our page back
	;setport	EN0_RSARLO
	;pause_
	mov dx, 308h
	out	dx,al		; set as hi address
	;setport	EN0_RSARHI
	;pause_
	mov dx, 309h
	mov	al,ah
	out	dx,al
	;setport EN_CCMD
	;pause_
	mov dx, 300h
	mov	al,ENC_RREAD+ENC_START	; read and start
	out	dx,al
	;setport	NE_DATAPORT
	;pause_
	mov dx, 310h
	shr	cx,1		; word count
	.286
	rep	insw
	.8086
	ret

	
; Process a transmit interrupt with the least possible latency to achieve
;   back-to-back packet transmissions.
; May only use ax and dx.
;xmit:
;	assume	ds:nothing
;	ret

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

CODE	ENDS

	END START
