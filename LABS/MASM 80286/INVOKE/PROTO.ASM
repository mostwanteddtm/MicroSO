#MASM#
;*******************************************************************************************************************************************|
;                                                        								                                                    |
;       				                       TEMPLATE PARA COMPILACAO COM MASM 6.15 .EXE           				                        |
;     				                           FACIMENTE TESTADO NO EMU8086 COM A DIRETIVA        				                            |
;                       			                            #MASM#                           			                                |
;                                                        								                                                    |
;*******************************************************************************************************************************************|  

.286 

TESTE PROTO NEAR C, VAR1:WORD

STACK SEGMENT
    DB      100h  DUP(0) 
    TOPS    LABEL BYTE
STACK ENDS

DATA SEGMENT PUBLIC 'DATA' USE16    
     
DATA ENDS

CODE SEGMENT PUBLIC 'CODE' USE16 
    ASSUME CS:CODE, DS:DATA, ES:DATA, SS:STACK  
    
    MAIN PROC NEAR
    
        MOV 	AX, DATA
        MOV 	DS, AX
        MOV 	ES, AX
        
        INVOKE  TESTE, 202h 

        MOV 	AX, 4C00H
        INT 	21H
        
    MAIN ENDP  
    
    TESTE PROC NEAR C VAR1:WORD 
        
        MOV     AX, VAR1
        RET
        
    TESTE ENDP
    
CODE ENDS

END MAIN
