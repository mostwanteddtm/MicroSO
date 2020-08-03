;===============================================================================================|
;																								|
; 		PRINTHEX16, PRINTHEX32, PRINTMEM16 E PRINTMEM32 PARA DEBUGAR UMA DETERMINADA 			|
;								POSICAO DE MEMORIA - 11-12-18									| 		
;																								|
;		EXEMPLOS DE CHAMADAS:																	|
;																								|
;		MOV		SI, OFFSET rootStart															|
;		MOV		CX, SIZEOF rootStart															|
;		CALL	PRINTHEX16																		|
;																								|
;		MOV		ESI, OFFSET TOTALSECTORS														|
;		MOV		ECX, SIZEOF TOTALSECTORS														|
;		XOR		EDI, EDI																		|
;		CALL	PRINTHEX32																		|
;																								|
;===============================================================================================|

DEBUGBUFFER EQU 200h

DATASEG16 SEGMENT USE16

	HEXFOR16 DB '0123456789ABCDEF'
	BUFFER16 DB	DEBUGBUFFER DUP(0)

DATASEG16 ENDS

;===============================================================================================|

DATASEG32 SEGMENT USE32

	HEXFOR32 DB '0123456789ABCDEF'
	BUFFER32 DB DEBUGBUFFER DUP(0)

DATASEG32 ENDS

;===============================================================================================|

CODESEG16 SEGMENT USE16

;===============================================================================================|

	PRINTHEX16 PROC
	
		PUSH	CX
	
		MOV		AX, CS
		MOV		ES, AX
		
		MOV		DI, OFFSET BUFFER16
		MOV		CX, DEBUGBUFFER
		REP		MOVSB
		
		POP		CX
	
		MOV		AX, CS
		MOV		DS, AX
		MOV		SI, OFFSET BUFFER16
		MOV     BX, OFFSET HEXFOR16
		
		MOV		AH, 0Eh
		ADD		SI, CX
		DEC		SI
	PRN:
		LODSB
		MOV     DL, AL
		RCR     AL, 4
		AND     AL, 0Fh
		XLATB
		INT		10h
		MOV     AL, DL
		AND     AL, 0Fh
		XLATB
		INT		10h
		SUB		SI, 2
		LOOP    PRN  
		
		JMP		$
		
	PRINTHEX16 ENDP
	
;===============================================================================================|
	
	PRINTMEM16 PROC
	
		PUSH	CX
	
		MOV		AX, CS
		MOV		ES, AX
		
		MOV		DI, OFFSET BUFFER16
		MOV		CX, DEBUGBUFFER
		REP		MOVSB
		
		POP		CX
	
		MOV		AX, CS
		MOV		DS, AX
		MOV		SI, OFFSET BUFFER16
		MOV     BX, OFFSET HEXFOR16
		
		MOV		AH, 0Eh
	PRN:
		LODSB
		MOV     DL, AL
		RCR     AL, 4
		AND     AL, 0Fh
		XLATB
		INT		10h
		MOV     AL, DL
		AND     AL, 0Fh
		XLATB
		INT		10h
		MOV		AL, 20h
		INT		10h
		LOOP    PRN  
		
		JMP		$
		
	PRINTMEM16 ENDP
	
;===============================================================================================|

CODESEG16 ENDS

CODESEG32 SEGMENT USE32

;===============================================================================================|

	PRINTHEX32 PROC
	
		PUSH	ECX
		
		MOV		AX, SELDATADESC32
		MOV		ES, AX
		MOV		EDI, OFFSET BUFFER32
		MOV		ECX, DEBUGBUFFER
		REP		MOVSB
		
		POP		ECX
		
		MOV 	AX, SELVIDEODESC32
		MOV 	ES, AX
		
		MOV 	AX, SELDATADESC32
		MOV 	DS, AX
		ASSUME 	DS:SEGS32 
		
		XOR		EDI, EDI
		MOV		ESI, OFFSET BUFFER32
	
		MOV     EBX, OFFSET HEXFOR32
		ADD		ESI, ECX
		DEC		ESI
	PRN:
		LODSB
		MOV     DL, AL
		RCR     AL, 4
		AND     AL, 0Fh
		XLATB
		MOV		AH, 7h
		STOSW
		MOV     AL, DL
		AND     AL, 0Fh
		XLATB
		MOV		AH, 7h
		STOSW 
		SUB		ESI, 2
		LOOP    PRN  
		
		JMP		$
		
	PRINTHEX32 ENDP
	
;===============================================================================================|

	PRINTMEM32 PROC
	
		PUSH	ECX
		
		MOV		AX, SELDATADESC32
		MOV		ES, AX
		MOV		EDI, OFFSET BUFFER32
		MOV		ECX, DEBUGBUFFER
		REP		MOVSB
		
		POP		ECX
		
		MOV 	AX, SELVIDEODESC32
		XOR		EDI, EDI
		MOV 	ES, AX
		
		MOV 	AX, SELDATADESC32
		MOV 	DS, AX
		ASSUME 	DS:SEGS32 
		
		XOR		EDI, EDI
		MOV		ESI, OFFSET BUFFER32
	
		MOV     EBX, OFFSET HEXFOR32
	PRN:
		LODSB
		MOV     DL, AL
		RCR     AL, 4
		AND     AL, 0Fh
		XLATB
		MOV		AH, 7h
		STOSW
		MOV     AL, DL
		AND     AL, 0Fh
		XLATB
		MOV		AH, 7h
		STOSW 
		MOV		AX, 720h
		STOSW
		LOOP    PRN  
		
		JMP		$
		
	PRINTMEM32 ENDP
	
;===============================================================================================|

CODESEG32 ENDS