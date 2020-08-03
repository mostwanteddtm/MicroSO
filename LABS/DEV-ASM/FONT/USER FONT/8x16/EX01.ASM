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

		MOV		BP, OFFSET FONT	
		MOV		CX, 0FFh			; TOTAL CHARS 255 ASCII
		MOV		DX, 0				; FIRST CHAR 0
		MOV		BH, 16				; 16 BYTES PER CHAR
		XOR		BL, BL				; RAM BLOCK
		MOV		AX, 1100h			; CHANGE FONT TO OUR FONT
		INT		10h					; VIDEO INTERRUPT

        MOV     SI, OFFSET MESSAGE 
        
LOADCHAR:
        LODSB  
        CMP		AL, 0
		JE		SAIR
		JMP		LOADCHAR
        
SAIR:
        MOV     AX, 4C00h
        INT     21h 

_TEXT ENDS

END