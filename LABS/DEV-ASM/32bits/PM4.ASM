.386P

RM_STACK SEGMENT PARA STACK 'STACK' USE16
 
    DB  100h DUP(?)
 
RM_STACK ENDS

PM_DATA SEGMENT PARA PUBLIC 'DATA' USE32
 
    MESSAGE 	DB  "Hello World From Protected Mode!!"
    MES_LEN 	EQU $ - MESSAGE

PM_DATA ENDS
  
RM_CODE SEGMENT PARA PUBLIC 'CODE' USE16
	ASSUME  CS:RM_CODE, SS:RM_STACK

		START PROC FAR

			MOV 	AX, 03h
			INT 	10h

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
 
		ENTRY_POINT PROC FAR
		 
			MOV 	AX, 00010000b
			MOV 	DS, AX
			MOV 	ES, AX
			
			XOR 	ESI, ESI
			MOV  	SI, PM_DATA
			SHL 	ESI, 4
			ADD 	ESI, OFFSET MESSAGE

			MOV		EDI, 0B8000h
			MOV 	ECX, MES_LEN
		   
		CO: LODSB
			MOV 	AH, 00001111b
			STOSW
			LOOP 	CO
			JMP $ 

		ENTRY_POINT ENDP
 
PM_CODE ENDS
   
END START