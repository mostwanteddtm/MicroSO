.286
.MODEL SMALL
.STACK 100h

IFNDEF DEBUG
	DEBUG		EQU 0
ENDIF

DT_SEG SEGMENT PARA PUBLIC 'DATA' USE16
	ASCII 		EQU 30h
	MESSAGE		DB	'Passando parametro pela linha de comando. Verificar o build.bat!!', 0Ah, 0Dh
				DB	'Valor de variavel DEBUG informada via linha de comando = ', 0
DT_SEG ENDS

CD_SEG SEGMENT PARA PUBLIC 'CODE' USE16
	ASSUME CS:CD_SEG, DS:DT_SEG
	
	START PROC
	
		MOV		AX, DT_SEG
		MOV		DS, AX
		
		MOV		SI, OFFSET MESSAGE
		CALL	PRINT
		
		MOV		AL, ASCII
		ADD		AL, DEBUG
		MOV		AH, 0Eh
		INT		10h
		
		XOR		AX, AX
		INT		16h
		
		MOV		AX, 4C00h
		INT		21h
		
	START ENDP
	
	PRINT PROC
	
	@@:
		LODSB
		CMP		AL, 0
		JE		@f
		MOV		AH, 0Eh
		INT		10h
		JMP		@b
	
	@@:	
		RET
	
	PRINT ENDP
	
CD_SEG ENDS

END START