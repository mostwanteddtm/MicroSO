
;-----------------------------------------------------------|
;                                                           |
;   Modelo de arquivo .EXE Compilado com o MASM 6.15        |
;                                                           |
;-----------------------------------------------------------| 

.286
.MODEL SMALL 

DSEG	SEGMENT	PARA PUBLIC 'DATA'
		ASSUME CS:DSEG
        HELLOWORLD	DB "Hello World!! #### Modelo de Programa .EXE ####",0         
DSEG	ENDS

STSEG	SEGMENT	BYTE STACK 'STACK'
		ASSUME CS:STSEG
		ASSUME ES:NOTHING, SS:NOTHING, DS:DSEG
		DB 0FFFFH DUP(?)
STSEG	ENDS

CSEG	SEGMENT PUBLIC 'CODE'
		ASSUME CS:CSEG
		ASSUME ES:NOTHING, SS:STSEG, DS:NOTHING

		PUBLIC START
		
START	PROC    FAR 

		MOV	    AX, SEG	DSEG
		MOV	    DS, AX
		ASSUME  DS:DSEG
		MOV	    ES, AX
		ASSUME  ES:DSEG
		MOV	    AX, CS		

		MOV	    SI, OFFSET HELLOWORLD 
		CLD
		MOV	    AH, 0EH
		MOV	    BX, 7

PRINT:
		LODSB
		OR	    AL, AL
		JZ	    SAIR
		INT	    10H		
		JMP	    PRINT

SAIR:	

		MOV     AX, 4C00H
		INT	    21H	

		INT     20H 
		
START	ENDP


CSEG	ENDS 


END     START