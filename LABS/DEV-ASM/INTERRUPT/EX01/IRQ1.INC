CODESEG16 SEGMENT USE16

	INT09h PROC
		PUSH 	EAX
		PUSH 	ES
		PUSH 	DS
		MOV 	AX, SELVIDEODESC32
		MOV 	ES, AX
		MOV 	AX, SELDATADESC32
		MOV 	DS, AX
		ASSUME 	DS:SEGS32
		PUSH 	EBX
		IN 		AL, 60H
		PUSH 	AX
		IN 		AL, 61H
		OR 		AL, 80H
		OUT 	61H, AL
		AND 	AL, 7FH
		OUT 	61H, AL
		POP 	AX
		TEST 	AL, 80H
		JNZ 	KBINT2
		CMP		AL, 01h
		JE		@f
		LEA 	BX, SCANTABLE
		MOV		EDI, VIDEO_POS
		MOV		DL, AL
		SHR		AL, 4
		MOV		AH, 07h
		XLAT
		STOSW
		MOV		AL, DL
		AND		AL, 0FH
		XLAT
		MOV		AH, 07H
		STOSW
		ADD		VIDEO_POS, 6
		
	KBINT2: 
		MOV 	AL, 20H
		OUT 	20H, AL
		POP 	EBX
		POP 	DS
		POP 	ES
		POP 	EAX
		IRETD
		
	@@: MOV 	AL, 20H								; INFORMA O FIM DA INSTRUCAO DE INTERRUPCAO
		OUT 	20H, AL              				; ACK IRQ
			
		MOV 	AX, SELDATADESC16         			; CHANGE SEGMENTS BACK TO HAVE VALID
        MOV 	ES, AX          					;  REAL MODE ATTRIBUTES.
        MOV 	DS, AX
        MOV 	FS, AX
        MOV 	EAX,CR0
        AND 	EAX, 07FFFFFFEh
        MOV 	CR0,EAX               				; ENTER REAL MODE
        JMP 	FAR PTR FLUSHRL       				; FLUSH QUEUE
		
FLUSHRL:
		MOV 	AX, 0B800h        					; ADDRESS SCREEN MEMORY FROM REAL MODE
		MOV		ES, AX
		MOV		AX, SEGS16							; GET DATA SEGMENT ADDRESS
		MOV		DS, AX								; PUT IN DS
		MOV		AX, STK0							; GET STACK SEGMENT ADDRESS
		MOV		SS, AX								; PUT IN SS
		MOV		SP, OFFSET STK0_LIMIT				; SET STACK POINTER

		LIDT	[POLD]								; LOAD DOS INTERRUPT VECTOR
		
		STI
		
		MOV		DI, 140h
		
		MOV		AX, 0752h
		STOSW
		
		MOV		AX, 074Dh
		STOSW
		
		MOV 	DH, 2
		MOV 	DL, 0
		MOV 	BH, 0
		MOV 	AH, 2
		INT 	10h

        MOV 	AH, 04Ch                    				;  DOS termination
        INT 	21h	
	
	INT09h ENDP
		
CODESEG16 ENDS