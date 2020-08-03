.286

INCLUDE COMMON.INC

EXTRN 		_main:NEAR
PUBLIC 	    __acrtused		    ; trick to force in startup
			__acrtused = 9876h	; funny value not easily matched in SYMDEB

STCK SEGMENT PARA STACK 'STACK' USE16
	DB 100 DUP(0)
STCK ENDS

DATA SEGMENT PUBLIC 'DATA' USE16

DATA ENDS

CODE SEGMENT PUBLIC 'CODE' USE16
	ASSUME CS:CODE, DS:DATA, ES:DATA, SS:STCK
	
	START PROC
	
		MOV			AX, DATA
		MOV			DS, AX
		CALL		_main
		MOV			AX, 4C00h
		INT			21h
		
	START ENDP
	
CODE ENDS

END START
