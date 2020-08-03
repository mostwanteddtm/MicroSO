CODESEG16 SEGMENT USE16

	INT21h PROC

		PUSH 	EAX
		PUSH 	ES
		PUSH 	DS
		MOV 	AX, SELDATADESC32
		MOV 	DS, AX
		ASSUME 	DS:SEGS32
		PUSH 	EBX

		IN 		AL, 60h
		TEST 	AL, 80h
		JNZ 	NOTKEY

		CMP		AL, 01h
		JE		@f
		
		MOV		BYTE PTR KEYPRESSED, AL 
		
	NOTKEY:
	
		MOV 	AL, 20H	
		OUT 	20H, AL
		
		POP 	EBX
		POP 	DS
		POP 	ES
		POP 	EAX
		IRETD
		
	@@: MOV 	AL, 20H								; INFORMA O FIM DA INSTRUCAO DE INTERRUPCAO
		OUT 	20H, AL              				; ACK IRQ
		
		CLI
			
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

		LIDT	[POLD]								; LOAD DOS INTERRUPT VECTOR
		
		CALL	RESTOREPIC
		
		STI
		
		MOV		AH, 02h
		MOV		DH, 17h
		MOV		DL, 0
		XOR		BX, BX
		INT		10h

        MOV 	AH, 04Ch                    				;  DOS termination
        INT 	21h	
	
	INT21h ENDP
		
CODESEG16 ENDS