.386P

INCLUDE EXE04.INC

IMAGE_BASE EQU 9000h

RM_STACK SEGMENT PARA STACK 'STACK' USE16
 
    DB  100h DUP(?)
 
RM_STACK ENDS

PM_DATA SEGMENT PARA PUBLIC 'DATA' USE32
 
	TABCONVERT      DB  '0123456789ABCDEF'
    BUFFER 			DD  0

PM_DATA ENDS
  
RM_CODE SEGMENT PARA PUBLIC 'CODE' USE16
	ASSUME  CS:RM_CODE, SS:RM_STACK

		START PROC FAR

			MOV 	AX, 03h
			INT 	10h
			
			MOV     EAX, RM_CODE
			MOV     DS, AX 

			XOR 	EBX, EBX
			MOV		ES, BX
			MOV		AH, 02h
			MOV		AL, 03h
			MOV		CH, 00h	; C
			MOV 	DH, 00h	; H
			MOV		CL, 01H	; S
			MOV		DL, 01h	; FLOPPY B
			MOV		BX, IMAGE_BASE				; ENTRYPOINT: 0:0009000h
			INT		13h
			JC 		ERROR

			XOR     EAX, EAX
			MOV  	AX, PM_CODE
			SHL 	EAX, 4      ;*16D
			ADD 	EAX, OFFSET ENTRY_POINT
			MOV 	DWORD PTR ENTRY_OFF, EAX

			XOR     EAX, EAX
			MOV  	AX, RM_CODE
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

			DB  	66h
			DB  	0EAh
			ENTRY_OFF   DD  ?
			DW  	00001000b
			
		ERROR: 
			MOV		AH, 0Eh
			MOV		AL, 41h
			INT		10h
			HLT
			
			GDT 		LABEL BYTE
			NULLDESCR   DB  08h DUP(0)
			CODEDESCR   DB  0FFh, 0FFh, 00h, 00h, 00h, 10011010b, 11001111b, 00h
			DATADESCR   DB  0FFh, 0FFh, 00h, 00h, 00h, 10010010b, 11001111b, 00h
			GDT_SIZE    EQU $ - GDT 
			GDTR        DW  GDT_SIZE - 1
			DD  		?
			
		START ENDP

RM_CODE ENDS
 
PM_CODE SEGMENT PARA PUBLIC 'CODE' USE32
	ASSUME  CS:PM_CODE, DS:PM_DATA
	
		;===================================================================
 
		ENTRY_POINT PROC FAR

			MOV 	AX, 00010000b
			MOV 	DS, AX
			MOV		ES, AX

			XOR 	ESI, ESI
			MOV  	SI, PM_DATA
			SHL 	ESI, 4
			ADD 	ESI, OFFSET BUFFER

			XOR 	EBX, EBX
			MOV  	BX, PM_DATA
			SHL 	EBX, 4
			ADD 	EBX, OFFSET TABCONVERT
			PUSH	EBX

			MOV		EDI, 0B8000h
			PUSH	EDI
			
			XOR		EAX, EAX
			XOR		EBX, EBX
			XOR		ECX, ECX
			XOR		EDX, EDX
			XOR		EDI, EDI

			ADD		AX, DS:[IMAGE_BASE+08h]						; AX = IMAGE BASE
			MOV		CX, DS:[IMAGE_BASE+06h]						; CX = RELOC ITEMS
			MOV     BX, DS:[IMAGE_BASE+18h]            			; BX = RELOC TABLE POINTER
			
			JCXZ    RELOCATIONDONE
			
		RELOCYCLE:
			MOV     DI, DS:[BX]             					; DI = ITEM OFS
			MOV     DX, DS:[BX+2]           					; DX = ITEM SEG (REL)
			ADD     DX, AX                  					; DX = ITEM SEG (ABS)
			
			PUSH    DS					
			MOV     DS, DX                  					; DS = DX
			ADD     DS:[DI], AX             					; FIXUP
			POP     DS					
			
			ADD     BX, 4                   					; POINT TO NEXT ENTRY
			LOOP    RELOCYCLE
			
		RELOCATIONDONE:
			MOV     BX, AX
			ADD     BX, DS:[IMAGE_BASE+0EH]

			ADD     AX, DS:[IMAGE_BASE+16H]            			; CS		
			MOV     BX, DS:[IMAGE_BASE+14H]                		; IP
			ADD		AX, BX
			SHL		AX, 4
			ADD		AX, IMAGE_BASE
			
			XOR 	EBX, EBX
			MOV  	BX, PM_CODE
			SHL 	EBX, 4
			ADD 	EBX, OFFSET STAGE03
			MOV		DS:[EBX], EAX
			
			POP		EDI
			POP		EBX
			CALL	PRINT_MEM16
			CALL	PRINT_REGISTERS

			;HLT												; PARA TESTAR NA MAQUINA FISICA, HABILITAR ESSA LINHA
																; E COMENTAR A INT 13h DO FLOPPY B:\
																
			DB      66					
			DB      0EAh
			STAGE03	DD	0
			DW      00001000b

		ENTRY_POINT ENDP
		
		;===================================================================

PM_CODE ENDS
   
END START