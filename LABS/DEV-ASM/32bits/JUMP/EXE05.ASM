.386p

INCLUDE EXE05.INC
EXTRN PRINT_MESSAGE:PROC

;####################################################################################################################
;																													;
;	O PRMEIRO ENTENDIMENTO DA MEMORIA EM MODO PROTEGIDO, MOSTRA QUE TRABALHAMOS COM ENDERECAMENTO 					;
;			BASEADO NO OFFSET. EXEMPLO: 0:0 ATE 0:FFFFFFFFh / 4194303 MB / 4GB										;
;																													;
;####################################################################################################################


DT_SEG SEGMENT PARA PUBLIC 'DATA' USE32

	MEM_CODE		DB	0CFh DUP(?)
	
DT_SEG ENDS

RM_STACK SEGMENT PARA STACK 'STACK' USE16
 
    DB  100h DUP(?)
 
RM_STACK ENDS
  
RM_SEG SEGMENT PARA PUBLIC 'CODE' USE16
	ASSUME  CS:RM_SEG, SS:RM_STACK

		START PROC
		
			MOV		AX, 03h
			INT		10h
		
			XOR     EAX, EAX
			MOV  	AX, PM_SEG
			SHL 	EAX, 4   
			ADD 	EAX, OFFSET ENTRY_POINT
			MOV 	WORD PTR CODEDESCR+2, AX
			SHR		EAX, 16
			MOV		BYTE PTR CODEDESCR+4, AL
			
			XOR     EAX, EAX
			MOV  	AX, PM_SEG
			SHL 	EAX, 4   
			ADD 	EAX, OFFSET PRINT_MESSAGE
			MOV 	WORD PTR FUNCDESCR+2, AX
			SHR		EAX, 16
			MOV		BYTE PTR FUNCDESCR+4, AL

			XOR     EAX, EAX
			MOV  	AX, RM_SEG
			SHL 	EAX, 4
			ADD 	EAX, OFFSET GDT
			MOV 	DWORD PTR GDTR+2, EAX

			LGDT    FWORD PTR GDTR

			CLI

			;-------------------------------------------------
			; ENABLES A20 LINE THROUGH SYSTEM CONTROL PORT A
			;-------------------------------------------------
			
			IN  	AL, 92h
			OR  	AL, 02h
			OUT 	92h, AL

			MOV 	EAX, CR0
			OR  	AX, 1
			MOV 	CR0, EAX

			DB 		0EAh, 0h, 0h, 08h, 0h       ; jmp to PMODE and execute
			
			PRINT_OFF   DD ?

			GDT 		LABEL BYTE
			NULLDESCR   DB  08h DUP(0)
			CODEDESCR   DB  0FFh, 0FFh, 00h, 00h, 00h, 10011010b, 11001111b, 00h
			DATADESCR   DB  0FFh, 0FFh, 00h, 00h, 00h, 10010010b, 11001111b, 00h
			FUNCDESCR   DB  0FFh, 0FFh, 00h, 00h, 00h, 10011010b, 11001111b, 00h
			GDT_SIZE    EQU $ - GDT 
			GDTR        DW  GDT_SIZE - 1
			DD  		?

		START ENDP

RM_SEG ENDS
 
PM_SEG SEGMENT PARA PUBLIC 'CODE' USE32
	ASSUME  CS:PM_SEG, DS:DT_SEG
 
		ENTRY_POINT PROC
		 
			MOV 	AX, 00010000b
			MOV 	DS, AX
			MOV		ES, AX
			
			XOR 	ESI, ESI
			MOV  	SI, DT_SEG
			SHL 	ESI, 4
			ADD 	ESI, OFFSET BUFFER
			PUSH	ESI

			XOR 	EBX, EBX
			MOV  	BX, DT_SEG
			SHL 	EBX, 4
			ADD 	EBX, OFFSET TABCONVERT
			
			; **************** DESTINATION ****************
			XOR 	EDX, EDX
			MOV  	EDX, DT_SEG
			SHL 	EDX, 4
			ADD 	EDX, OFFSET MEM_CODE
			MOV		EDI, EDX
			PUSH	EDX
			
			; **************** SOURCE ****************
			MOV		ECX, 0CFh
			XOR		EAX, EAX
			MOV		AX, PM_SEG
			SHL		EAX, 4
			ADD		EAX, OFFSET PRINT_MESSAGE
			MOV		ESI, EAX
			REP		MOVSB
			POP		EDX
			
			MOV		EDI, 0B8000h

			MOV		ESI, EDX
			CALL	PRINT_MEM16
			POP		ESI

			PRINT_REG_STR32 'ECX'
			
			XOR		ECX, ECX
			MOV		ECX, PM_SEG						; PARA VER O OFFSET DA INSTRUCAO E COMPARAR NO HxD
			SHL		ECX, 4							; COMENTE ESSA E A LINHA ACIMA
			ADD		ECX, OFFSET INST				; SENAO, O OFFSET MOSTRADO SERA O ENDERECO PMODE
			MOV     EAX, ECX
			CALL	PRINT_REG32						; PRINT REGISTER ECX
			
			PRINT_REG_STR32 'EDX'

			XOR		EDX, EDX
			MOV		DX, PM_SEG
			SHL		EDX, 4
			ADD		EDX, OFFSET PRINT_MESSAGE 
			MOV     EAX, EDX
			CALL	PRINT_REG32						; PRINT REGISTER EDX
			
			;CALL	PRINT_REGISTERS

			
			CALL	PRINT_MESSAGE
			
			INST 	LABEL BYTE
			;DB      0EAh, 0h, 0h, 0h, 0h, 18h, 0h 	; JMP TO PRINT_MESSAGE

		ENTRY_POINT ENDP
 
PM_SEG ENDS
   
END START