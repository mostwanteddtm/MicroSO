
;********************************************************************************************************************|
;                                                        								                             |
;       				 Funcao responsavel por carregar a tabela GDT na memoria    			                     |
;     				          	Inicio do desenvolvimento em 14-12-2017       				                         |
;                        			Por: Marcos Roberto da Costa                      			                     |
;                                                        								                             |
;********************************************************************************************************************|

RM_SEG SEGMENT PUBLIC 'CODE' USE16
	ASSUME CS:RM_SEG, SS:ST_SEG
	
	;========================================= CODE AREA ============================================================
	
		INSTALL_GDT PROC FAR
		
			XOR     EAX, EAX
			MOV  	AX, PM_SEG
			SHL 	EAX, 4      ;*16D
			ADD 	EAX, OFFSET PM_ENTRY
			MOV 	DWORD PTR PM_ENTRY_OFF, EAX

			XOR     EAX, EAX
			MOV  	AX, RM_SEG
			SHL 	EAX, 4
			ADD 	EAX, OFFSET GDT
			MOV 	DWORD PTR GDTR+2, EAX

			LGDT    FWORD PTR GDTR

			CLI
			RET
		
		INSTALL_GDT ENDP
		
	;================================================================================================================
	
RM_SEG ENDS