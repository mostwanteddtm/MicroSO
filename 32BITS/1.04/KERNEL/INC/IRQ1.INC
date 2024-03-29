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
	INT09h ENDP
		
CODESEG16 ENDS