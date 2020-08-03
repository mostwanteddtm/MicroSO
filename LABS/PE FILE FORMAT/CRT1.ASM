.386p

BGCOLOR EQU 07h 

STACK SEGMENT STACK 'STACK'
    DB      100h  DUP(0) 
STACK ENDS

DATA SEGMENT DWORD PUBLIC 'DATA' USE32  
	MESSAGE DB 'Microsoft Macro Assembly 6.15 COFF - Portable Executable File Format!', 0 
DATA ENDS

CODE SEGMENT PARA PUBLIC 'CODE' USE32 
    ASSUME CS:CODE  
    
	_main PROC NEAR
    
        MOV		AX, 50h
		MOV		DS, AX
		MOV 	ES, AX
		
		MOV		AH, BGCOLOR
		
		MOV 	EDI, 0B8000h
		MOV		ESI, OFFSET MESSAGE
		
	@@:	LODSB
		CMP		AL, 0
		JE		@f

		STOSW
		
		JMP		@b
		
	@@:	JMP $
 
    _main ENDP  
    
CODE ENDS

END _main