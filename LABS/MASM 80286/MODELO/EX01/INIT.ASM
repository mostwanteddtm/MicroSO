.386
.MODEL SMALL

INCLUDE DEFS.INC
INCLUDE PRINT.INC
INCLUDE MAIN.INC

PUBLIC MAINMSG

STACK SEGMENT STACK 'STACK'
	DW	100h DUP(0)
STACK ENDS

INITDSEG SEGMENT PUBLIC 'DATA' USE16
	STARTMSG 	DB 'This is a Start Segment!', CR, LF, 0 
	MAINMSG		DB 'Now in Main Segment!!', 0
INITDSEG ENDS

INITCSEG SEGMENT PARA PUBLIC 'CODE' USE16
	ASSUME CS:INITCSEG, DS:INITDSEG, ES:INITDSEG

	START PROC
	
		MOV		AX, INITDSEG
		MOV		DS, AX
		MOV		ES, AX
		
		MOV		SI, OFFSET STARTMSG
		CALL	PRINTSTR

		MOV		SI, OFFSET MAINMSG
		
		JMP		MAINCSEG:MAIN
		
	START ENDP

	RETURN PROC FAR

		RET

	RETURN ENDP
	
INITCSEG ENDS

END START