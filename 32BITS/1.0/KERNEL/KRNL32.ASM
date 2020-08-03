.386

ST_SEG SEGMENT STACK 'STACK'
	
ST_SEG ENDS

DT_SEG SEGMENT PUBLIC 'DATA' USE32
	TABCONVERT      DB  '0123456789ABCDEF'
DT_SEG ENDS

PM_SEG SEGMENT PARA PUBLIC 'CODE' USE32
	ASSUME CS:PM_SEG, DS:DT_SEG

	;========================================= MACRO AREA ==========================================================

		PRINT_REG_STR16 MACRO REG
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
		ENDM

		PRINT_REG_STR32 MACRO REG
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
		ENDM
		
	;================================================================================================================

	;================================================================================================================

		START PROC
	  
			CLI      
			MOV  	AX, 10h    
			MOV		DS, AX
			MOV		SS, AX
			MOV		ES, AX
			MOV		ESP, 90000h		; stack begins from 90000h

			MOV		EDI, 0B8000h
			CALL	PRINT_MEM
			
			MOV		EDI, 0B8A00h
			CALL	PRINT_REGISTERS
			
			;PRINT_REG_STR32 'EDX'
			;
			;MOV		EDX, DT_SEG
			;SHL		DX, 4
			;ADD		EDX, OFFSET TABCONVERT
			;
			;MOV     EAX, EDX
			;CALL	PRINT_REG32						; PRINT REGISTER EDX

			HLT
	   
		START ENDP
		
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
		
		PRINT_MEM PROC
													;#################################
			MOV		ESI, 100200h 					; POSICAO DE MEMORIA QUE SERA LIDO
				
			MOV		EBX, 100200h					; ENDERECO QUE O KRNLDR.SYS CARREGOU O KRNL32.EXE
													; BASE 100000h + START DATA 270h (TABCONVERT)
			MOV		ECX, 10h						 
			XOR		EDX, EDX
			ADD		EDI, 10
			
		PRINT_MEM_HEADER:							; LOOP PRINT_MEM_HEADER
		
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
			
			CMP		EDX, 0C0h					; LIMITE DE OFFSET A SER EXIBIDO
			JE		END_PRINT_MEM
			ADD		EDX, 10h
			ADD		EDI, 54						; PASSAR PARA LINHA ABAIXO
			JMP		OFFSET_COUNT				; LOOP OFFSET_COUNT
			
		END_PRINT_MEM:
			CALL	PRINT_MEM_STR
			ADD		EDI, 2560					; PULANDO UMA LINHA
			RET
			
		PRINT_MEM ENDP
		
	;================================================================================================================
		
		PRINT_MEM_STR PROC
												; ##################################################
			MOV		ESI, 100200h				; POSICAO DE MEMORIA QUE SERA LIDO E MOSTRADO STRING
			
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
			
			CMP		EDX, 0C0h						; LIMITE DE OFFSET A SER EXIBIDO
			JE		END_PRINT_MEM_STR
			ADD		EDX, 10h
			ADD		EDI, 80h						; PASSAR PARA LINHA ABAIXO
			JMP		CONTINUE_PRINT_MEM_LINE
			
		END_PRINT_MEM_STR:
	
			RET

		PRINT_MEM_STR ENDP
		
	;================================================================================================================
		
		PRINT_REG16 PROC

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

			ADD		EDI, 140					; SALTO DE LINHA 
			
			RET
		PRINT_REG16 ENDP
		
	;================================================================================================================

		PRINT_REG32 PROC

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

			ADD		EDI, 132					; SALTO DE LINHA 
			
			RET
		PRINT_REG32 ENDP
		
	;===============================================================================================================
  
	ORG 5efh
	FIM: HLT
  
PM_SEG ENDS

END START