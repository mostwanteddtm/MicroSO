
;*******************************************************************************************************************;
;																												   	;
;										PUBLIC FUNCTION PRINT_REGISTERS												;
;																													;
;												TO DEBUG USE														;
;																													;
;											CALL 	START_PRINT														;
;																													;
;											XOR		EAX, EAX														;
;											MOV		AX, 7E00h 														;
;											ESI =   AX/EAX 0:7E00h													;
;											CALL 	DEFINE_MEM_PRINT												;
;											CALL	PRINT_MEM														;
;																													;
;											CALL	PRINT_REGISTERS													;
;																													;
;												AND / OR															;
;																													;
;											PRINT_REG_STR32 'EDX'													;
;																													;
;											MOV     EAX, EDX														;
;											CALL	PRINT_REG32														;
;											PRINT REGISTER EDX														;
;																													;
;*******************************************************************************************************************;

	;========================================= MACRO AREA ==========================================================

		PRINT_REG_STR16 MACRO REG
			PUSH	EAX
			MOV 	AX, REG
			XCHG	AL, AH
			MOV		AH, 00001111b
			STOSW
			MOV		AX, REG
			MOV		AH, 00001111b
			STOSW
			MOV		AL, 3Ah
			MOV		AH, 00001111b
			STOSW
			MOV		AL, 20h
			MOV		AH, 00001111b
			STOSW
			MOV		AL, 20h
			MOV		AH, 00001111b
			STOSW
			POP		EAX
		ENDM

		PRINT_REG_STR32 MACRO REG
			PUSH	EAX
			MOV 	EAX, REG
			SHR		EAX, 16
			MOV		AH, 00001111b
			STOSW
			MOV		EAX, REG
			XCHG	AL, AH
			MOV		AH, 00001111b
			STOSW
			MOV		EAX, REG
			MOV		AH, 00001111b
			STOSW
			MOV		AL, 3Ah
			MOV		AH, 00001111b
			STOSW
			MOV		AL, 20h
			MOV		AH, 00001111b
			STOSW
			POP		EAX
		ENDM
		
	;================================================================================================================

DT_SEG SEGMENT PUBLIC 'DATA' USE32
 
	LEN_DISP		EQU 0C0h
	LAST_OFFSET		EQU 10h
	TABCONVERT      DB  '0123456789ABCDEF'
	MEM_CODE		DB	LEN_DISP + LAST_OFFSET DUP(?)

DT_SEG ENDS

PM_SEG SEGMENT PUBLIC 'CODE' USE32
	ASSUME  CS:PM_SEG, DS:DT_SEG
	
	;========================================= CODE AREA ============================================================
		
		DEFINE_MEM_PRINT PROC
		
			PUSHA
		
			; **************** SOURCE ****************

			MOV		ECX, LEN_DISP + LAST_OFFSET
			MOV		ESI, EAX
			
			; **************** DESTINATION ****************
			
			XOR 	EDX, EDX
			MOV  	EDX, DT_SEG
			SHL 	EDX, 4
			ADD 	EDX, OFFSET MEM_CODE
			MOV		EDI, EDX
			
			REP		MOVSB

			POPA
		
		DEFINE_MEM_PRINT ENDP
	
	;================================================================================================================
		
		START_PRINT PROC
		
			XOR 	ESI, ESI
			MOV  	SI, DT_SEG
			SHL 	ESI, 4
			ADD 	ESI, OFFSET MEM_CODE

			XOR 	EBX, EBX
			MOV  	BX, DT_SEG
			SHL 	EBX, 4
			ADD 	EBX, OFFSET TABCONVERT

			MOV		EDI, 0B8000h
			
			RET
		START_PRINT ENDP
	
	;================================================================================================================
		
		PRINT_REGISTERS PROC						; PUBLIC PRINT_REGISTERS
		
			; **************** PRINT REGISTERS 16 BITS ****************
			
			PRINT_REG_STR16 'CS'
			
			XOR		EAX, EAX
			MOV		AX, CS
			CALL	PRINT_REG16						; PRINT REGISTER CS
			
			PRINT_REG_STR16 'DS'
			
			XOR		EAX, EAX
			MOV		AX, DS
			CALL	PRINT_REG16						; PRINT REGISTER DS
			
			PRINT_REG_STR16 'ES'
			
			XOR		EAX, EAX
			MOV		AX, ES
			CALL	PRINT_REG16						; PRINT REGISTER ES
			
			; **************** PRINT REGISTERS 32 BITS ****************
			
			PRINT_REG_STR32 'EAX'
			
			CALL	PRINT_REG32						; PRINT REGISTER EAX
			
			PRINT_REG_STR32 'EBX'

			MOV     EAX, EBX
			CALL	PRINT_REG32						; PRINT REGISTER EBX
			
			PRINT_REG_STR32 'ECX'

			MOV     EAX, ECX
			CALL	PRINT_REG32						; PRINT REGISTER ECX
			
			PRINT_REG_STR32 'EDX'

			MOV     EAX, EDX
			CALL	PRINT_REG32						; PRINT REGISTER EDX
			
			PRINT_REG_STR32 'ESI'

			MOV     EAX, ESI
			CALL	PRINT_REG32						; PRINT REGISTER ESI
			
			PRINT_REG_STR32 'EDI'

			MOV     EAX, EDI
			CALL	PRINT_REG32						; PRINT REGISTER EDI
			
			RET
		
		PRINT_REGISTERS ENDP
	
	;================================================================================================================
		
		PRINT_REG16 PROC
		
			PUSHA

			PUSH	EAX
			MOV		EDX, 1

			XCHG    AL, AH
			MOV		ECX, 2
            MOV     DS:[ESI], AX

			
		SVALUE:             
			MOV     AL, [ESI] 
			ROL     AL, 4
			AND     AL, 00001111B
			XLAT
			
			MOV 	AH, 00001111b
			STOSW
			
			MOV     AL, [ESI]
			AND     AL, 00001111B
			XLAT
			
			MOV 	AH, 00001111b
			STOSW
			
			INC		ESI
			LOOP    SVALUE

			POP   	EAX
			
			MOV		AL, 'h'
			MOV 	AH, 00001111b
			STOSW
			
			POPA
			
			ADD		EDI, 150					; SALTO DE LINHA 
			
			RET
		PRINT_REG16 ENDP
		
	;================================================================================================================
			
		PRINT_MEM PROC
		
			PUSHA
			
			XOR 	ESI, ESI
			MOV  	ESI, DT_SEG
			SHL 	ESI, 4
			ADD 	ESI, OFFSET MEM_CODE
			
			MOV		ECX, 10h
			XOR		EDX, EDX
			ADD		EDI, 10
			
		PRINT_MEM_HEADER:						; LOOP PRINT_MEM_HEADER
		
			MOV		AL, 30h
			MOV 	AH, 00001111b
			STOSW

			MOV		EAX, EDX
			XLAT
			MOV 	AH, 00001111b
			STOSW
			
			MOV		AL, 20h
			MOV 	AH, 00001111b
			STOSW
			
			INC		DX
			
			LOOP	PRINT_MEM_HEADER			; LOOP PRINT_MEM_HEADER
			
			XOR		EDX, EDX
			
			ADD		EDI, 214					; PULANDO UMA LINHA
			
		OFFSET_COUNT:							; LOOP OFFSET_COUNT

			MOV     AX, DX
			XCHG    AL, AH
			SHR     AL, 4
			XLAT
			MOV 	AH, 00001111b
			STOSW

			MOV     AX, DX
			XCHG    AL, AH
			AND     AL, 00001111b
			XLAT
			MOV 	AH, 00001111b
			STOSW

			MOV     AX, DX
			SHR     AL, 4
			XLAT
			MOV 	AH, 00001111b
			STOSW

			MOV     AX, DX
			AND     AL, 4
			XLAT
			MOV 	AH, 00001111b
			STOSW
			
			MOV		AL, 20h
			MOV 	AH, 00001111b
			STOSW

			MOV		ECX, 10h	
		PRINT_MEM_BODY:							; LOOP PRINT_MEM_BODY
			MOV     AL, [ESI] 
			ROL     AL, 4
			AND     AL, 00001111B
			XLAT
			
			MOV 	AH, 00001111b
			STOSW
			
			MOV     AL, [ESI]
			AND     AL, 00001111B
			XLAT
			
			MOV 	AH, 00001111b
			STOSW
			
			MOV		AL, 20h
			MOV 	AH, 00001111b
			STOSW
			
			INC		SI
			LOOP	PRINT_MEM_BODY				; LOOP PRINT_MEM_BODY
			
			CMP		EDX, LEN_DISP				; LIMITE DE OFFSET A SER EXIBIDO
			JE		END_PRINT_MEM
			ADD		EDX, 10h
			ADD		EDI, 54						; PASSAR PARA LINHA ABAIXO
			JMP		OFFSET_COUNT				; LOOP OFFSET_COUNT
			
		END_PRINT_MEM:
			POPA
			CALL	PRINT_MEM_STR
			ADD		EDI, 2560					; PULANDO UMA LINHA
			RET
			
		PRINT_MEM ENDP
		
	;================================================================================================================
	
		PRINT_MEM_STR PROC
		
			PUSHA
			
			XOR 	ESI, ESI
			MOV  	ESI, DT_SEG
			SHL 	ESI, 4
			ADD 	ESI, OFFSET MEM_CODE
			
			MOV		EDI, 0B81B0h
			XOR		EDX, EDX
			
		CONTINUE_PRINT_MEM_LINE:

			MOV		ECX, 10h
			
		CONTINUE_PRINT_MEM_STR:
			
			XOR		EAX, EAX
			MOV		AH, 00001111b
			MOV		AL, [ESI]
			STOSW
			
			INC		ESI
			LOOP	CONTINUE_PRINT_MEM_STR
			
			CMP		EDX, LEN_DISP					; LIMITE DE OFFSET A SER EXIBIDO
			JE		END_PRINT_MEM_STR
			ADD		EDX, 10h
			ADD		EDI, 80h						; PASSAR PARA LINHA ABAIXO
			JMP		CONTINUE_PRINT_MEM_LINE
			
		END_PRINT_MEM_STR:
		
			POPA
			RET

		PRINT_MEM_STR ENDP
		
	;================================================================================================================

		PRINT_REG32 PROC
		
			PUSHA

			PUSH	EAX
			MOV		EDX, 1

		RETURN_INIT:
			CMP		EDX, 0
			JE		NOREVERT
			SHR		EAX, 16
			
		NOREVERT:
			XCHG    AL, AH
			MOV		ECX, 2
            MOV     DS:[ESI], AX
			
		SVALUE:             
			MOV     AL, [ESI] 
			ROL     AL, 4
			AND     AL, 00001111B
			XLAT
			
			MOV 	AH, 00001111b
			STOSW
			
			MOV     AL, [ESI]
			AND     AL, 00001111B
			XLAT
			
			MOV 	AH, 00001111b
			STOSW
			
			INC		ESI
			LOOP    SVALUE
			
			CMP		EDX, 0
			JE		END_PRINT
			POP   	EAX
			DEC		EDX
			JMP		RETURN_INIT
			
		END_PRINT:
		
			MOV		AL, 'h'
			MOV 	AH, 00001111b
			STOSW

			POPA
			
			ADD		EDI, 150					; SALTO DE LINHA 
			
			RET
		PRINT_REG32 ENDP
		
	;================================================================================================================
 
PM_SEG ENDS