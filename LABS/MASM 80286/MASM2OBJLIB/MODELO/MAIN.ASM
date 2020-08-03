
;*******************************************************************************************************************************************|
;                                                        								                                                    |
;       				                       TEMPLATE PARA COMPILACAO COM MASM 6.15 .EXE           				                        |
;     				                           FACIMENTE TESTADO NO EMU8086 COM A DIRETIVA        				                            |
;                       			                            #MASM#                           			                                |
;                                                        								                                                    |
;*******************************************************************************************************************************************|  

.286

INCLUDE COMMON.INC 

PRINTF 	PROTO C, extMessage:BYTE

EXTERN 	DESC:DESCRIPTOR

CRLF	EQU 0D0Ah

STACK SEGMENT STACK 'STACK'
    DB      100h  DUP(0) 
    TOPS    LABEL BYTE
STACK ENDS

DATA SEGMENT PUBLIC 'DATA' USE16
     
    MAINMSG     DB 'Main Message!!', 0 
     
DATA ENDS

CODE SEGMENT PUBLIC 'CODE' USE16 
    ASSUME CS:CODE, DS:DATA, ES:DATA, SS:STACK  

    MAIN PROC NEAR
    
        MOV 	AX, DATA
        MOV 	DS, AX
        MOV 	ES, AX
        
        MOV     SI, OFFSET MAINMSG
        INVOKE  PRINTF, 0
		
		CALL	NEWLINE
		
		MOV		DESC.VALUE, 3031h
		
		MOV		SI, OFFSET DESC.STRING
		INVOKE	PRINTF, 1

        MOV 	AX, 4C00H
        INT 	21H
        
    MAIN ENDP  
	
	NEWLINE PROC
	
		XOR		AX, AX
		MOV		DX, CRLF
		MOV		AH, 0Eh
		XCHG	AL, DL
		INT		10h
		XCHG	AL, DH
		INT		10h
		
		RET
		
	NEWLINE ENDP
    
CODE ENDS

END MAIN
