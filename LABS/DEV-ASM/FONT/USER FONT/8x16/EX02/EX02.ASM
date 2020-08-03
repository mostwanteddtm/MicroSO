;http://www.fysnet.net/modex.htm

.286
.MODEL SMALL
.STACK 100H

INCLUDE DEFS.INC
INCLUDE EX02.INC
    
DATASEG16 SEGMENT USE16

	MESSAGE DB  'Microsoft Assembly v6.15!!', 0 	
    
DATASEG16 ENDS
            
CODESEG16 SEGMENT USE16
	ASSUME CS:SEGS16,DS:SEGS16
	
	START PROC

		MOV		AX, SEGS16
		MOV		DS, AX
		MOV		ES, AX

        CALL	SET_VIDEO_MODE

        MOV     SI, OFFSET MESSAGE 
		MOV		AX, 0B800h
		MOV		ES, AX
		XOR		DI, DI

LOADCHAR:
        LODSB  
        CMP		AL, 0
		JE		SAIR
		MOV		AH, 07h
		STOSW
		JMP		LOADCHAR
        
SAIR:
        MOV     AX, 4C00h
        INT     21h 
		
	START ENDP
	
CODESEG16 ENDS

END START