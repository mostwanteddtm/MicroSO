.386P
;********************************************************************************************************************|
;                           	                             								                         |
;       				 		Programa responsavel por carregar o Kernel de 32 Bits    			                 |
;     				        	  	Inicio do desenvolvimento em 14-12-2017       				                     |
;                        				Por: Marcos Roberto da Costa                      			                 |
;                           	                             								                         |
;********************************************************************************************************************|

INCLUDE GDT.INC
INCLUDE A20.INC
INCLUDE FAT32.INC
INCLUDE DEBUG.INC

ST_SEG SEGMENT STACK 'STACK' USE16
					DB 100h DUP(?)
ST_SEG ENDS

DT_SEG SEGMENT PUBLIC 'DATA' USE32

	;========================================= DATA AREA ============================================================
					
	KERNELARQUIVO   DB	"KERNEL32EXE"           			
	LENKERNEL32		DB	8
	BYTESPERSECTOR	EQU 200h
	
	BASEKERNEL32RM	EQU 9000h
	BASEKERNEL32PM	EQU 100000h
	
	DWORDSECTOR		EQU	80h
	IMAGESIG		DB	'PE'

	;================================================================================================================
					
DT_SEG ENDS

RM_SEG SEGMENT PUBLIC 'CODE' USE16
	ASSUME CS:RM_SEG, SS:ST_SEG, DS:DT_SEG
	
	;========================================= CODE AREA ============================================================
	
		START PROC FAR
		
			MOV 	AX, 03h
			INT 	10h
			
			CALL	LOAD_KERNEL32
			
			CALL 	INSTALL_GDT
			
			CALL	ENABLE_A20
			
			MOV 	EAX, CR0
			OR 		AL, 1
			MOV 	CR0, EAX
			
			DB 		66h
			DB 		0EAh
			PM_ENTRY_OFF DD ?
			DW 		00001000b
			
			GDT 		LABEL BYTE
			NULLDESCR   DB  08h DUP(0)
			CODEDESCR   DB  0FFh, 0FFh, 00h, 00h, 00h, 10011010b, 11001111b, 00h
			DATADESCR   DB  0FFh, 0FFh, 00h, 00h, 00h, 10010010b, 11001111b, 00h
			GDT_SIZE    EQU $ - GDT 
			GDTR        DW  GDT_SIZE - 1
			DD  		?
					
		START ENDP
		
	;================================================================================================================

RM_SEG ENDS

PM_SEG SEGMENT PUBLIC 'CODE' USE32
	ASSUME CS:PM_SEG, DS:DT_SEG
	
	;========================================= CODE AREA ============================================================
	
		PM_ENTRY PROC

			MOV 	AX, 00010000b
			MOV 	DS, AX
			MOV 	ES, AX

			XOR  	ESI, ESI
			MOV  	ESI, DT_SEG
			SHL  	SI, 4
			ADD  	ESI, OFFSET LENKERNEL32

			XOR  	EAX, EAX
			LODSB

			MOV  	EDX, WORD PTR DWORDSECTOR
			MUL  	DX
			MOV  	ECX, EAX
	
			MOV  	ESI, WORD PTR BASEKERNEL32RM
			MOV  	EDI, DWORD PTR BASEKERNEL32PM
			REP  	MOVSD
	
			MOV  	EAX, WORD PTR BASEKERNEL32PM+60
			MOV  	EDX, [EAX]
			ADD  	EDX, WORD PTR BASEKERNEL32PM
			MOV  	ESI, DWORD PTR [EDX]
			AND  	ESI, 0000FFFFh

			XOR		EAX, EAX
			MOV  	EAX, DT_SEG
			SHL  	AX, 4
			ADD  	EAX, OFFSET IMAGESIG
			MOV  	EDI, DWORD PTR [EAX]
			AND  	EDI, 0000FFFFh
			   
			CMPSW 
			JE  	EXECUTE

			MOV  	EDI, 0B8000h
			MOV  	AH, 0Fh
			MOV  	AL, '0'
			STOSW
			HLT

		EXECUTE:
  
			MOV		EAX, WORD PTR BASEKERNEL32PM+60
			MOV  	EBX, [EAX]
			ADD  	EBX, WORD PTR BASEKERNEL32PM
			ADD		EBX, 24
			MOV		EAX, [EBX]

			MOV		EBP, DWORD PTR [EBX]
			MOV		EAX, EBP
			ADD		EBX, 20-4
			
			MOV		EBP, DWORD PTR [EBX]						
			ADD		EBX, 12									
			MOV		EAX, DWORD PTR [EBX]					
			ADD		EBP, EAX

			CALL	EBP
			
			PUSHFD
			PUSH 	DWORD PTR BASEKERNEL32PM
			PUSH 	DWORD PTR 200h
			IRETD

			
		PM_ENTRY ENDP
		
	;================================================================================================================
		
PM_SEG ENDS

END START