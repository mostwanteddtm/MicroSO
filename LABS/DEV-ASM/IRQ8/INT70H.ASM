.286
STK_SEG SEGMENT STACK 'STACK'
	DB 100h DUP(0)
STK_SEG ENDS

CD1_SEG SEGMENT PARA PUBLIC 'CODE' USE16
	ASSUME CS:CD1_SEG, DS:CD2_SEG, ES:CD2_SEG
	
	START PROC

		MOV		AX, CD2_SEG
		MOV		DS, AX
		
		CALL	ENABLE_IRQ8
		
		MOV		AX, 90h
		MOV		ES, AX
		XOR		DI, DI
		MOV		SI, OFFSET INT70h
		MOV		CX, LEN
		REP		MOVSB
		
		MOV     AL, 70H             ; MULTIPLY 70H BY 4, STORE RESULT IN AX:    
		
		MOV     BL, 4H				; RESULT IS 0000:01C0 
		MUL     BL          
		MOV     BX, AX
		
		XOR		AX, AX
		MOV		ES, AX
		
		XOR		SI, SI
		MOV     ES:[BX], SI
		ADD     BX, 2   
			
		MOV     AX, 90h				; COPY SEGMENT INTO INTERRUPT VECTOR:     
		MOV     ES:[BX], AX

		MOV		AX, 4C00h
		INT		21h
		
	START ENDP
	
	ENABLE_IRQ8 PROC
	
		CLI         				; Disable interrupts
		PUSH 	AX     				; Interrupt may occur while updating

		IN 		AL, 0A1h  			; Make sure IRQ8 is not masked

		AND 	AL, 0FEh 			; Set bit 0 of port 0A1 to zero
		OUT 	0A1h, AL 			

		MOV		AL, 0Bh				; Select status register B
		OUT		70h, AL				; Any write to PORT 70h 
		
		IN 		AL, 71h				; should be followed by an action to PORT 71h 
									; or the RTC wil be left in an unknown state.			
		
		OR 		AL, 10h  			; Enable update interrupts (UI=1) only
		OUT 	71h, AL 			; Write into status register  B
		
		MOV 	AL, 0Ah				; Status Register A
		OUT 	70h, AL
		MOV 	AL, 00101101b		; RTC@32.768KHz (0010), Rate@8Hz (1101)
		OUT 	71h, AL
		
		IN 		AL, 71h
		
		STI
		POP AX
		
		RET
		
	ENABLE_IRQ8 ENDP
	
CD1_SEG ENDS

CD2_SEG SEGMENT PARA PUBLIC 'CODE'
	ASSUME CS:CD2_SEG, DS:CD2_SEG, ES:CD2_SEG
	
	INT70h PROC FAR
	
		PUSH	DS
		PUSH	ES
		PUSH	AX
		PUSH	BX
		
		MOV		AX, CS
		MOV		DS, AX
		MOV		ES, AX
		
	@@:	MOV 	AL, 0Ah				; Status Register A
		OUT 	70h, AL
		IN 		AL, 71h
		
		TEST 	AL, 80h				; Is there an update in process?
		JNE 	@b					; If so then keep polling

		MOV 	AL, 0Ch				; Acknowledge the RTC
		OUT 	70h, AL
		
		IN 		AL, 71h
		
		XOR		AX, AX
		OUT		70h, AL
		
		IN		AL, 71h
		
		;MOV		SI, OFFSET CHAR
		;LODSB
		MOV		AH, 0Eh
		INT		10h
		
		MOV 	AL, 20h				; INFORMA O FIM DA INSTRUCAO DE INTERRUPCAO
		OUT 	0A0h, AL  			; Notify Secondary PIC
		OUT 	20h, AL  			; Notify Primary PIC
		
		POP		BX
		POP		AX
		POP		ES
		POP		DS
		
		IRET
		
		CHAR	DB 			'.'
		LEN		EQU			$-INT70h
		
	INT70h ENDP

CD2_SEG ENDS
	
END START
	