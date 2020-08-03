.386

EXTERN DEBUGRMODE:PROC
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

STACK SEGMENT STACK 'STACK'
    DB      100h  DUP(0) 
    TOPS    LABEL BYTE
STACK ENDS

DATA SEGMENT PUBLIC 'DATA' USE16

	CONTENTLOADED	DD	12345678h
     
DATA ENDS

CODE SEGMENT PUBLIC 'CODE' USE16 
    ASSUME CS:CODE, DS:DATA, ES:DATA, SS:STACK  
    
    MAIN PROC NEAR
	
	@@:
		MOV		AH, 02h
		MOV		DH, 17h
		MOV		DL, 0
		XOR		BX, BX
		INT		10h
		
        MOV 	AX, DATA
        MOV 	DS, AX
        MOV 	ES, AX
		
		MOV		SI, OFFSET CONTENTLOADED					; COPY LOCAL MEMORY TO BUFFER, FOR DEBUG
		MOV		EAX, 87654321h								; SET VALUE FOR DEBUG USE TO DEBUG
		MOV		ECX, 4
		STC													; SET CARRY FLAG
		
		CALL	DEBUGRMODE
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
        
    MAIN ENDP 
    
CODE ENDS

END MAIN