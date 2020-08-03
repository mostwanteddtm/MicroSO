.286
.model tiny
.data
.code
org 100h
.STARTUP

	MOV		AX, CS
	MOV		DS, AX
	PUSH	ES
	
	MOV		AX, 90h
	MOV		ES, AX
	XOR		DI, DI
	MOV		SI, OFFSET INT8h
	MOV		CX, LEN
	REP		MOVSB
	
	MOV     AL, 8H                         ;MULTIPLY 20H BY 4, STORE RESULT IN AX:    
	
	MOV     BL, 4H       		            ;RESULT IS 0000:0080 
	MUL     BL          
	MOV     BX, AX
	
	XOR		AX, AX
	MOV		ES, AX
	
	XOR		SI, SI
	MOV     ES:[BX], SI
	ADD     BX, 2   
		
	MOV     AX, 90h                          ;copy segment into interrupt vector:     
	MOV     ES:[BX], AX

	POP		ES  
	
	INT 	20h
	
INT8h:
	PUSH	DS
	PUSH	ES
	MOV		AX, CS
	MOV		DS, AX
	MOV		ES, AX
	
	MOV		AL, NOT BIT
	ADD		AL, 30h
	MOV		AH, 0Eh
	INT		10h
	
	POP		ES
	POP		DS
	
	MOV 	AL, 20H						; INFORMA O FIM DA INSTRUCAO DE INTERRUPCAO
	OUT 	20H, AL
	
	IRET
	
	BIT		EQU 		1
	LEN		EQU			$-INT8h
	
END
	