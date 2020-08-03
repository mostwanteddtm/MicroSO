.286
.MODEL TINY
.STACK 100h

_TEXT SEGMENT WORD PUBLIC USE16

	;=========================================== DATA AREA ===========================================
	
	.DATA
		RED			DW 	5272h 					; R, r 
		GREEN		DW	4767h					; G, g
		BLUE		DW	4262h					; B, b
		
		MAXCOLOR	EQU	63
		MINCOLOR	EQU 0
			
		RVALUE		DB	0
		GVALUE		DB 	0
		BVALUE		DB	0
			
		STRRED		DB	'R:00', 0
		STRGREEN	DB	'G:00', 0
		STRBLUE		DB	'B:00', 0
		
		BUFFER      DB 5 DUP (0)  
		BASE10      DW 10 
		
		CHAR		DB	0
		
		CENTERX		EQU 12
		CENTERY		EQU 18
		MSGERROR	DB 	'PRESS [R] OR [G] OR [B], BEFORE START: ', 0
		
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
		
		MOV     AX, 0100h						; DISABLE CURSOR
		MOV     CH, 3Fh							; BITS 0-7 UNUSED, BIT 5 DISABLES CURSOR, BITS 0-4 CONTROL CURSOR SHAPE
		INT     10h
		
		CALL	SETPALETTE
		CALL	SETBGCOLOR
		
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
		
	INIT:
		MOV		DH, 0							; LINHA
		MOV		DL, 0							; COLUNA
		CALL	SETCURPOS
		
		XOR		AX, AX
		INT		16h
	
	TORESTART:
	
		CMP		AL, BYTE PTR RED[0]
		JE		SETCHAR
		CMP		AL, BYTE PTR RED[1]
		JE		SETCHAR
		CMP		AL, BYTE PTR GREEN[0]
		JE		SETCHAR
		CMP		AL, BYTE PTR GREEN[1]
		JE		SETCHAR
		CMP		AL, BYTE PTR BLUE[0]
		JE		SETCHAR
		CMP		AL, BYTE PTR BLUE[1]
		JE		SETCHAR
		CMP		AL, 1Bh
		JE		SAIR
		
		CMP		BYTE PTR CHAR, 0
		JE		RESTART
		
		CALL	CHECKNEWCOLOR
		
		JMP		INIT
		
	SAIR:
		MOV     AX, 3
		INT     10h
		MOV		AX, 4C00h
		INT		21h
		
	RESTART:
		MOV		DH, CENTERX							; LINHA
		MOV		DL, CENTERY							; COLUNA
		CALL	SETCURPOS
		MOV		SI, OFFSET MSGERROR
		CALL	PRINTSTR
		XOR		AX, AX
		INT		16h
		PUSH	AX
		CALL	CLEARSTRING
		POP		AX
		JMP		TORESTART
		
	;=========================================== CLEARSTRING ========================================
	
	CLEARSTRING PROC
	
		MOV		DH, CENTERX						; LINHA
		MOV		DL, CENTERY						; COLUNA
		CALL	SETCURPOS
		MOV 	CX, SIZEOF MSGERROR
	@@: MOV		AL, 20h
		MOV		AH, 0Eh
		INT		10h
		LOOP	@b
		
		RET
			
	CLEARSTRING ENDP
		
	;=========================================== SETBGCOLOR =========================================
		
	SETBGCOLOR PROC
	
		MOV     AL, 00h							; NUMERO DE LINHAS A COLORIR | 0 = TODAS AS LINHAS DO VIDEO
		MOV     CH, 00h
		MOV     CL, 00h
		MOV     BH, 1Fh 						; SEGUNDA COR DA PALETA DE CORES (AZUL) COM LETRA BRANCA - 1Fh
		MOV     DH, 18h                     	; 18H = 24D, NUMERO DE LINHAS DO VIDEO
		MOV     DL, 4Fh                     	; 4FH = 84D, NUMERO DE COLUNAS
		MOV     AH, 06h
		INT     10h
		
		RET
		
	SETBGCOLOR ENDP
	
	;=========================================== SETCHAR ============================================

	SETCHAR	PROC
	
		MOV		BYTE PTR CHAR, AL
		JMP		INIT
		
	SETCHAR ENDP
	
	;=========================================== CHECKNEWCOLOR ======================================
	
	CHECKNEWCOLOR PROC
	
		CMP		AH, 48h
		JE		SUMVALUE
		CMP		AH, 50h
		JE		SUBVALUE
		RET
	
	CHECKNEWCOLOR ENDP
	
	;=========================================== SUMVALUE ===========================================
	
	SUMVALUE PROC
	
		MOV		AL, BYTE PTR CHAR
		
		CMP		AL, BYTE PTR RED[0]
		JE		ADDRED
		CMP		AL, BYTE PTR RED[1]
		JE		ADDRED
		CMP		AL, BYTE PTR GREEN[0]
		JE		ADDGREEN
		CMP		AL, BYTE PTR GREEN[1]
		JE		ADDGREEN
		CMP		AL, BYTE PTR BLUE[0]
		JE		ADDBLUE
		CMP		AL, BYTE PTR BLUE[1]
		JE		ADDBLUE
		
		RET
		
	ADDRED:
		CMP		BYTE PTR RVALUE, MAXCOLOR
		JE		@f
		INC		BYTE PTR RVALUE
		MOV		DH, 0							; LINHA
		MOV		DL, 2							; COLUNA
		CALL	SETCURPOS
		XOR		AX, AX
		MOV		AL, BYTE PTR RVALUE
		CALL	HEXTODEC
		CALL	SETPALETTE
		
	@@:
		RET
		
	ADDGREEN:
		CMP		BYTE PTR GVALUE, MAXCOLOR
		JE		@f
		INC		BYTE PTR GVALUE
		MOV		DH, 1							; LINHA
		MOV		DL, 2							; COLUNA
		CALL	SETCURPOS
		XOR		AX, AX
		MOV		AL, BYTE PTR GVALUE
		CALL	HEXTODEC
		CALL	SETPALETTE
		
	@@:
		RET
		
	ADDBLUE:
		CMP		BYTE PTR BVALUE, MAXCOLOR
		JE		@f
		INC		BYTE PTR BVALUE
		MOV		DH, 2							; LINHA
		MOV		DL, 2							; COLUNA
		CALL	SETCURPOS
		XOR		AX, AX
		MOV		AL, BYTE PTR BVALUE
		CALL	HEXTODEC
		CALL	SETPALETTE
		
	@@:
		RET
		
	SUMVALUE ENDP
	
	;=========================================== SUBVALUE  ==========================================
	
	SUBVALUE PROC
	
		MOV		AL, BYTE PTR CHAR
		
		CMP		AL, BYTE PTR RED[0]
		JE		SUBRED
		CMP		AL, BYTE PTR RED[1]
		JE		SUBRED
		CMP		AL, BYTE PTR GREEN[0]
		JE		SUBGREEN
		CMP		AL, BYTE PTR GREEN[1]
		JE		SUBGREEN
		CMP		AL, BYTE PTR BLUE[0]
		JE		SUBBLUE
		CMP		AL, BYTE PTR BLUE[1]
		JE		SUBBLUE
		
		RET
		
	SUBRED:
		CMP		BYTE PTR RVALUE, MINCOLOR
		JE		@f
		DEC		BYTE PTR RVALUE
		MOV		DH, 0							; LINHA
		MOV		DL, 2							; COLUNA
		CALL	SETCURPOS
		XOR		AX, AX
		MOV		AL, BYTE PTR RVALUE
		CALL	HEXTODEC
		CALL	SETPALETTE
		
	@@:
		RET
		
	SUBGREEN:
		CMP		BYTE PTR GVALUE, MINCOLOR
		JE		@f
		DEC		BYTE PTR GVALUE
		MOV		DH, 1							; LINHA
		MOV		DL, 2							; COLUNA
		CALL	SETCURPOS
		XOR		AX, AX
		MOV		AL, BYTE PTR GVALUE
		CALL	HEXTODEC
		CALL	SETPALETTE
		
	@@:
		RET
		
	SUBBLUE:
		CMP		BYTE PTR BVALUE, MINCOLOR
		JE		@f
		DEC		BYTE PTR BVALUE
		MOV		DH, 2							; LINHA
		MOV		DL, 2							; COLUNA
		CALL	SETCURPOS
		XOR		AX, AX
		MOV		AL, BYTE PTR BVALUE
		CALL	HEXTODEC
		CALL	SETPALETTE
		
	@@:
		RET
		
	SUBVALUE ENDP
	
	;=========================================== SETPALETTE =========================================
	
	SETPALETTE PROC
	
		MOV     AX, 1010h
		MOV     BX, 1							; ALTERAR A PALETA DE COR 2 (AZUL) 
		MOV     DH, RVALUE                  	; RED
		MOV     CH, GVALUE                  	; GREEN
		MOV     CL, BVALUE                  	; BLUE
		INT     10h
		
		RET

	SETPALETTE ENDP
	
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