.286
.MODEL TINY
.STACK 100h

_TEXT SEGMENT WORD PUBLIC USE16

	;=========================================== DATA AREA ===========================================
	
	.DATA
	
		STRRED		DB	'R:00', 0
		STRGREEN	DB	'G:00', 0
		STRBLUE		DB	'B:00', 0
		
		BUFFER      DB 5 DUP (0)  
		BASE10      DW 10 
		
		RVALUE		DB	0
		GVALUE		DB 	0
		BVALUE		DB	0
		
	;================================================================================================
		
	.CODE
	
	ORG 100h
	
	.STARTUP
	
	;=========================================== MAIN ===============================================
	
		MOV		AX, CS
		MOV		DS, AX
		MOV		ES, AX
		
		MOV     AX, 3
		INT     10h
		
		MOV     AX, 1010h
		MOV     BX, 1 
		MOV     CL, 20                  		; BLUE
		MOV     CH, 63                  		; GREEN
		MOV     DH, 63                  		; RED
		INT     10h
		
		CALL	READDAC
		XOR		AX, AX
		INT		16h
		
		MOV     AH, 0h	
		MOV     AL, 12h
		INT     10h
	
		CALL	READDAC
		XOR		AX, AX
		INT		16h
		
		MOV     AX, 3
		INT     10h
		
		MOV		AX, 4C00h
		INT		21h
	
	;=========================================== READDAC ===========================================		
	
	READDAC	PROC
	
		MOV		DH, 0							; LINHA
		MOV		DL, 0							; COLUNA
		CALL	SETCURPOS
		MOV		SI, OFFSET STRRED
		CALL	PRINTSTR
		
		MOV		DH, 1							; LINHA
		MOV		DL, 0							; COLUNA
		CALL	SETCURPOS
		MOV		SI, OFFSET STRGREEN
		CALL	PRINTSTR
		
		MOV		DH, 2							; LINHA
		MOV		DL, 0							; COLUNA
		CALL	SETCURPOS
		MOV		SI, OFFSET STRBLUE
		CALL	PRINTSTR
		
		MOV		AX, 1015h
		MOV		BL, 1
		INT		10h
		
		MOV		BYTE PTR RVALUE, DH
		MOV		BYTE PTR GVALUE, CH
		MOV		BYTE PTR BVALUE, CL
		
		MOV		DH, 0							; LINHA
		MOV		DL, 2							; COLUNA
		CALL	SETCURPOS
		XOR		AX, AX
		MOV		AL, BYTE PTR RVALUE
		CALL	HEXTODEC
		
		MOV		DH, 1							; LINHA
		MOV		DL, 2							; COLUNA
		CALL	SETCURPOS
		XOR		AX, AX
		MOV		AL, BYTE PTR GVALUE
		CALL	HEXTODEC
		
		MOV		DH, 2							; LINHA
		MOV		DL, 2							; COLUNA
		CALL	SETCURPOS
		XOR		AX, AX
		MOV		AL, BYTE PTR BVALUE
		CALL	HEXTODEC
		
		RET
	
	READDAC ENDP
		
	;=========================================== PRINTSTR ===========================================
	
	PRINTSTR PROC
	
	CPRN:
		LODSB
		CMP		AL, 0
		JE		SPRN
		MOV		AH, 0Eh
		INT		10h
		JMP		CPRN
		
	SPRN:
		RET
	
	PRINTSTR ENDP
	
	;=========================================== SETCURPOS ===========================================
	
	SETCURPOS PROC
	
		MOV		AH, 02h
		MOV		BH, 0
		INT		10h
		
		RET
	
	SETCURPOS ENDP
		
	;=========================================== HEXTODEC =============================================
	
	HEXTODEC PROC
	
		XOR 	BX, BX
    
    CONT:
        XOR 	DX, DX
        DIV 	[BASE10]
        ADD 	DL, 30H 
        MOV 	[BUFFER+BX], DL
        INC 	BX
        CMP 	AL, 9
        JA 		CONT
    
    CONTINUE: 
        XOR 	DX, DX
        XCHG 	DL, AL
        ADD 	DL, 30H 
        MOV 	[BUFFER+BX], DL 
        MOV 	CX, BX 
        INC 	CX
   
		MOV 	SI, OFFSET BUFFER
		ADD 	SI, BX
		
	print: 
        MOV 	AH, 0Eh
        MOV 	AL, [SI]
        INT 	10h
        DEC 	SI
		LOOP 	PRINT
		
		RET
	
	HEXTODEC ENDP
	
	;====================================================================================================
	
_TEXT ENDS

END 	
		
		
		
		
		