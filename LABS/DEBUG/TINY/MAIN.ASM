.286
.MODEL TINY
.STACK 100

EXTERN DEBUGTINY:PROC

;======================================================================================|
;	PUBLIC METHOD FOR DEBUG ON REAL MODE                                               |
;                                                                                      |
;	DEBUGRMODE:                                                                        |
;	IN:                                                                                |
;		CX = SIZE OF BUFFER TO BE COPIED                                               |
;		DS:SI = ORIGIN OF THE CONTENT TO BE COPIED TO THE BUFFER                       |
;		AX, BX, CX, DX, SI, DI, BP, SP, DS, ES, SS = VALUE DEFINED ON MAIN PROGRAM     |
;                                                                                      |
;	OUT: BUFFER = COPIED FROM CONTENT LOADED IN MEMORY                                 |
;		 SHOW REGISTERS VALUES (AX, BX, CX, DX, SI, DI, BP, SP, CS, DS, ES, SS)        |
;======================================================================================| 

EXTERN KEYPRESSED:BYTE
EXTERN BUFFER:WORD
EXTERN FULLBUFFER:BYTE

CODE	SEGMENT WORD PUBLIC
	ASSUME	CS:CODE, DS:CODE

	ORG 100h

	start	PROC

		PUSH	CS
		POP		DS
		@@:
		MOV		AH, 02h
		MOV		DH, 17h
		MOV		DL, 0
		XOR		BX, BX
		INT		10h
		
        MOV 	AX, CS
        MOV 	DS, AX
        MOV 	ES, AX
		
		MOV		SI, OFFSET CONTENTLOADED					; COPY LOCAL MEMORY TO BUFFER, FOR DEBUG
		MOV		AX, 4321h									; SET VALUE FOR DEBUG USE TO DEBUG
		MOV		CX, 4
		MOV		BYTE PTR FULLBUFFER, 0						; IF FULLBUFFER = 0 THEN CX DEFINE NOW MANY BYTES WILL BE COPIED
		STC													; SET CARRY FLAG
		
		CALL	DEBUGTINY
		XOR		AX, AX
		INT		16h
		
		CMP		AH, 01h
		JE		@f
		CMP		AH, 1Ch
		JE		@f
		
		MOV		KEYPRESSED, AH
		JMP		@b
		
	@@:	
        MOV 	AX, 4C00H
        INT 	21H

		CONTENTLOADED	DD	12345678h

	start ENDP
	
CODE ENDS

END start