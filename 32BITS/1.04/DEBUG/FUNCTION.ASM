.386p
.MODEL FLAT, C

PUBLIC asmfunction

VIDEMEM	EQU 0B8000h
BASELIN EQU 0A0h

.CODE 

	asmfunction PROC, PTRVALUE:DWORD,LINENUMBER:DWORD
	
		MOV		ESI, PTRVALUE
		MOV		EAX, BASELIN
		MOV		EBX, LINENUMBER
		MUL		EBX
		MOV		EDI, VIDEMEM
		ADD		EDI, EAX	

	CONT: 
		LODSB
		CMP		AL, 0
		JE		ENDFUNC
		MOV 	AH, 7h
		STOSW
		LOOP 	CONT

	ENDFUNC:	
		RET
	
	asmfunction ENDP
	
END

			;HEX    BIN       COLOR
        	;0      0000      black				- preto
        	;1      0001      blue				- azul  
        	;2      0010      green				- verde
        	;3      0011      cyan				- ciano
        	;4      0100      red				- vermelho
        	;5      0101      magenta			- magenta
        	;6      0110      brown				- marrom
        	;7      0111      light gray		- cinza claro 
        	;8      1000      dark gray			- cinza escuro
        	;9      1001      light blue		- azul claro
        	;A      1010      light green		- verde claro
        	;B      1011      light cyan		- ciano claro
        	;C      1100      light red			- vermelho claro
        	;D      1101      light magenta		- magenta claro
        	;E      1110      yellow			- amarelo
        	;F      1111      white				- branco
        	;Bit 8-5 BackGround | Bit 4-1 ForeColor