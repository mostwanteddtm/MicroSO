;http://www.fysnet.net/modex.htm

.286
.MODEL TINY
.STACK 100H

INCLUDE EX01.INC

_TEXT SEGMENT PUBLIC USE16 
    
.DATA 

		MESSAGE DB  'Hello World!!', 0        
    
.CODE
            
        ORG 100H
        
.STARTUP

		MOV		AX, CS
		MOV		DS, AX

		MOV   	AX, 1110h
		MOV   	BX, 0800h
		MOV   	CX, 0FFh
		XOR		DX, DX
		MOV   	BP, OFFSET FONT
		INT   	10H

        MOV     SI, OFFSET MESSAGE 
        
LOADCHAR:
        LODSB  
        CMP		AL, 0
		JE		SAIR
		MOV 	AH, 0Eh
		INT 	10h
		JMP		LOADCHAR
        
SAIR:
        MOV     AX, 4C00h
        INT     21h 

_TEXT ENDS

END