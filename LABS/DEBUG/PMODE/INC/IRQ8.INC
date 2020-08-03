CODESEG16 SEGMENT USE16  						

	ENABLEIRQ8 PROC

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
			
	ENABLEIRQ8 ENDP
	
	INT70h PROC FAR
	
		PUSH	DS
		PUSH	ES
		PUSH	EAX
		PUSH	EBX
		
		XOR		EAX, EAX
		XOR		EBX, EBX
		
		MOV 	AX, SELVIDEODESC32
		MOV 	ES, AX
		MOV 	AX, SELDATADESC32
		MOV 	DS, AX
		
	@@:	MOV 	AL, 0Ah				; Status Register A
		OUT 	70h, AL
		IN 		AL, 71h
		
		TEST 	AL, 80h				; Is there an update in process?
		JNE 	@b					; If so then keep polling
		
		MOV 	AL, 0Ch				; Acknowledge the RTC
		OUT 	70h, AL
		
		IN 		AL, 71h

		ASSUME 	DS:SEGS32
		
		MOV		EDI, DWORD PTR 4
		MOV		ESI, OFFSET CHAR
		LODSB
		MOV		AH, 07h
		STOSW
		
		INC		CHAR
		
		MOV 	AL, 20h				; INFORMA O FIM DA INSTRUCAO DE INTERRUPCAO
		OUT 	0A0h, AL  			; Notify Secondary PIC
		OUT 	20h, AL  			; Notify Primary PIC
		
		POP		EBX
		POP		EAX
		POP		ES
		POP		DS
		
		IRETD

	INT70h ENDP
		
CODESEG16 ENDS