
;********************************************************************************************************************|
;                                                        								                             |
;       				 Funcoes responsaveis por realizar exibicao de dados no video    			                 |
;     				          	Inicio do desenvolvimento em 14-12-2017       				                         |
;                        			Por: Marcos Roberto da Costa                      			                     |
;                                                        								                             |
;********************************************************************************************************************|

RM_SEG SEGMENT PUBLIC 'CODE' USE16
	ASSUME CS:RM_SEG, SS:ST_SEG
	
	;========================================= CODE AREA ============================================================
	
		PRINTF_16 PROC FAR
		
				PUSHA
				MOV		AH, 0Eh
		CPRINT: 
				LODSB
				CMP		AL, 0
				JE		FPRINT
				INT		10h
				JMP		CPRINT
				
		FPRINT: 
				POPA
				RET
		
		PRINTF_16 ENDP
		
	;================================================================================================================

RM_SEG ENDS

comment #;*************************************************************************************************************
			FUNCAO PRINTF DE 32BITS
#;*********************************************************************************************************************

PM_SEG SEGMENT PUBLIC 'CODE' USE32
	ASSUME CS:PM_SEG, DS:DT_SEG
	
;**********************************************************************************************************************
;	PUTCH32 ()
;		- PRINTS A CHARACTER TO SCREEN
;	BL => CHARACTER TO PRINT
;
;**********************************************************************************************************************
	
		PUTCH32 PROC FAR
		
			PUSHA								; SAVE REGISTERS
			MOV		EDI, VIDMEM					; GET POINTER TO VIDEO MEMORY

			;-------------------------------;
			;   GET CURRENT POSITION		;
			;-------------------------------;

			XOR		EAX, EAX					; CLEAR EAX

			;--------------------------------
			; REMEMBER: CURRENTPOS = X + Y * COLS! X AND Y ARE IN _CURX AND _CURY.
			; BECAUSE THERE ARE TWO BYTES PER CHARACTER, COLS=NUMBER OF CHARACTERS IN A LINE.
			; WE HAVE TO MULTIPLY THIS BY 2 TO GET NUMBER OF BYTES PER LINE. THIS IS THE SCREEN WIDTH,
			; SO MULTIPLY SCREEN WITH * _CURY TO GET CURRENT LINE
			;--------------------------------

			MOV		ECX, COLS*2					; MODE 7 HAS 2 BYTES PER CHAR, SO ITS COLS*2 BYTES PER LINE
			MOV		AL, BYTE PTR [_CURY]		; GET Y POS
			MUL		ECX							; MULTIPLY Y*COLS
			PUSH	EAX							; SAVE EAX--THE MULTIPLICATION

			;--------------------------------
			; NOW Y * SCREEN WIDTH IS IN EAX. NOW, JUST ADD _CURX. BUT, AGAIN REMEMBER THAT _CURX IS RELATIVE
			; TO THE CURRENT CHARACTER COUNT, NOT BYTE COUNT. BECAUSE THERE ARE TWO BYTES PER CHARACTER, WE
			; HAVE TO MULTIPLY _CURX BY 2 FIRST, THEN ADD IT TO OUR SCREEN WIDTH * Y.
			;--------------------------------

			MOV		AL, BYTE PTR [_CURX]		; MULTIPLY _CURX BY 2 BECAUSE IT IS 2 BYTES PER CHAR
			MOV		CL, 2
			MUL		CL
			POP		ECX							; POP Y*COLS RESULT
			ADD		EAX, ECX

			;-------------------------------
			; NOW EAX CONTAINS THE OFFSET ADDRESS TO DRAW THE CHARACTER AT, SO JUST ADD IT TO THE BASE ADDRESS
			; OF VIDEO MEMORY (STORED IN EDI)
			;-------------------------------

			XOR		ECX, ECX
			ADD		EDI, EAX					; ADD IT TO THE BASE ADDRESS

			;-------------------------------;
			;   WATCH FOR NEW LINE          ;
			;-------------------------------;

			CMP		BL, 0Ah						; IS IT A NEWLINE CHARACTER?
			JE		ROW							; YEP--GO TO NEXT ROW

			;-------------------------------;
			;   PRINT A CHARACTER           ;
			;-------------------------------;

			MOV		DL, BL						; GET CHARACTER
			MOV		DH, CHAR_ATTRIB				; THE CHARACTER ATTRIBUTE
			
			;*******************************;
			;   INICIO ALTERADO MARCOS      ;
			;*******************************;
			
			
			PUSH	AX
			MOV		AX, DX
			STOSW
			POP 	AX
			
			;*******************************;
			;   FIM ALTERADO MARCOS      	;
			;*******************************;
			
													;A ALTERACAO ACIMA, FOI PQ DAVA ERRO AQUI
			;MOV		WORD PTR [EDI], DX			; WRITE TO VIDEO DISPLAY

			;-------------------------------;
			;   UPDATE NEXT POSITION        ;
			;-------------------------------;

			INC		BYTE PTR [_CURX]			; GO TO NEXT CHARACTER
		;	CMP		BYTE PTR [_CURX], COLS		; ARE WE AT THE END OF THE LINE?
		;	JE		ROW							; YEP-GO TO NEXT ROW
			JMP		DONE1						; NOPE, BAIL OUT

			;-------------------------------;
			;   GO TO NEXT ROW              ;
			;-------------------------------;

		ROW:
			MOV		BYTE PTR [_CURX], 0			; GO BACK TO COL 0
			INC		BYTE PTR [_CURY]			; GO TO NEXT ROW

			;-------------------------------;
			;   RESTORE REGISTERS & RETURN  ;
			;-------------------------------;

		DONE1:
			POPA								; RESTORE REGISTERS AND RETURN
			
			RET
		
		PUTCH32 ENDP
		
;**********************************************************************************************************************
;	PRINTF_32 ()
;		- PRINTS A NULL TERMINATED STRING
;	PARM\ EBX = ADDRESS OF STRING TO PRINT
;
;**********************************************************************************************************************
		
		PRINTF_32 PROC FAR
		
			;-------------------------------;
			;   STORE REGISTERS             ;
			;-------------------------------;

			PUSHA								; SAVE REGISTERS
			PUSH	EBX							; COPY THE STRING ADDRESS
			POP		EDI

		LOOP1:
			;-------------------------------;
			;   GET CHARACTER               ;
			;-------------------------------;

			MOV		BL, BYTE PTR [EDI]			; GET NEXT CHARACTER
			CMP		BL, 0						; IS IT 0 (NULL TERMINATOR)?
			JE		DONE2						; YEP-BAIL OUT

			;-------------------------------;
			;   PRINT THE CHARACTER         ;
			;-------------------------------;

			PUSHA
			CALL	PUTCH32					; NOPE-PRINT IT OUT
			POPA

			;-------------------------------;
			;   GO TO NEXT CHARACTER        ;
			;-------------------------------;

			INC		EDI							; GO TO NEXT CHARACTER

			JMP	LOOP1

		DONE2:

			;-------------------------------;
			;   UPDATE HARDWARE CURSOR      ;
			;-------------------------------;

			; ITS MORE EFFICIANT TO UPDATE THE CURSOR AFTER DISPLAYING
			; THE COMPLETE STRING BECAUSE DIRECT VGA IS SLOW

			MOV		BH, BYTE PTR [_CURY]		; GET CURRENT POSITION
			MOV		BL, BYTE PTR [_CURX]
			
			CALL	MOVCUR32					; UPDATE CURSOR

			POPA								; RESTORE REGISTERS, AND RETURN
			RET
			
		PRINTF_32 ENDP
		
;**********************************************************************************************************************
;	MOVECUR32 ()
;		- UPDATE HARDWARE CURSOR
;	PARM/ BH = Y POS
;	PARM/ BL = X POS
;
;**********************************************************************************************************************

		MOVCUR32 PROC FAR
		
			PUSHA								; SAVE REGISTERS (AREN'T YOU GETTING TIRED OF THIS COMMENT?)

			;-------------------------------;
			;   GET CURRENT POSITION        ;
			;-------------------------------;

			; HERE, _CURX AND _CURY ARE RELITAVE TO THE CURRENT POSITION ON SCREEN, NOT IN MEMORY.
			; THAT IS, WE DON'T NEED TO WORRY ABOUT THE BYTE ALIGNMENT WE DO WHEN DISPLAYING CHARACTERS,
			; SO JUST FOLLOW THE FORUMLA: LOCATION = _CURX + _CURY * COLS

			XOR		EAX, EAX
			MOV		ECX, COLS
			MOV		AL, BH						; GET Y POS
			MUL		ECX							; MULTIPLY Y*COLS
			ADD		AL, BL						; NOW ADD X
			MOV		EBX, EAX

			;--------------------------------------;
			;   SET LOW BYTE INDEX TO VGA REGISTER ;
			;--------------------------------------;

			MOV		AL, 0Fh
			MOV		DX, 03D4h
			OUT		DX, AL

			MOV		AL, BL
			MOV		DX, 03D5h
			OUT		DX, AL						; LOW BYTE

			;---------------------------------------;
			;   SET HIGH BYTE INDEX TO VGA REGISTER ;
			;---------------------------------------;

			XOR		EAX, EAX

			MOV		AL, 0Eh
			MOV		DX, 03D4h
			OUT		DX, AL

			MOV		AL, BH
			MOV		DX, 03D5h
			OUT		DX, AL						; HIGH BYTE

			POPA
			RET
	
		MOVCUR32 ENDP
		
;**********************************************************************************************************************
;	CLRSCR_32 ()
;		- CLEARS SCREEN
;
;**********************************************************************************************************************

		CLRSCR_32 PROC FAR
		
			PUSHA
			CLD
			MOV		EDI, VIDMEM
			MOV		CX, 2000
			MOV		AH, BYTE PTR CHAR_ATTRIB
			MOV		AL, ' '	
			REP		STOSW
			MOV		BYTE PTR [_CURX], 0
			MOV		BYTE PTR [_CURY], 0
			
			POPA
			RET
	
		CLRSCR_32 ENDP
		
;**********************************************************************************************************************
;	GOTOXY32 ()
;		- SET CURRENT X/Y LOCATION
;	PARM\	AL=X POSITION
;	PARM\	AH=Y POSITION
;
;**********************************************************************************************************************

		GOTOXY32 PROC FAR
		
			PUSHA
			MOV		BYTE PTR [_CURX], AL		; JUST SET THE CURRENT POSITION
			MOV		BYTE PTR [_CURY], AH
			POPA
			RET
	
		GOTOXY32 ENDP

PM_SEG ENDS