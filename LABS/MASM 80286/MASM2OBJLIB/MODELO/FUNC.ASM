
;*******************************************************************************************************************************************|
;                                                        								                                                    |
;       				                       TEMPLATE PARA COMPILACAO COM MASM 6.15 .EXE           				                        |
;     				                           FACIMENTE TESTADO NO EMU8086 COM A DIRETIVA        				                            |
;                       			                            #MASM#                           			                                |
;                                                        								                                                    |
;*******************************************************************************************************************************************|  

.286 

INCLUDE COMMON.INC

PUBLIC 	PRINTF
PUBLIC 	DESC

TRUE	EQU 1
FALSE	EQU NOT TRUE

DATA SEGMENT PUBLIC 'DATA' USE16
     
    IMESSAGE    DB 'Default Message!!', 0 
	DESC		DESCRIPTOR <?, 'Microsoft Macro Assembly 6.15!!$'>
     
DATA ENDS

CODE SEGMENT PUBLIC 'CODE' USE16 
    ASSUME CS:CODE, DS:DATA 
	
	;===============================================|
	;												|
	;				PRINTF PROCEDURE				|
	;	PARAMETER - extMessage (EXTERNAL MESSAGE)	|
	;		  TRUE = PRINT DEFINED MESSAGE			|
	;		 FALSE = PRINT DEFAULT MESSAGE			|
	;												|
	;===============================================|
    
    PRINTF PROC NEAR C, extMessage:BYTE 
        
        PUSH    DS
        
        MOV     AX, DATA
        MOV     DS, AX 
        
        MOV     AH, 0Eh 
        CMP     extMessage, TRUE
        JE      @f
		PUSH	AX
		MOV		AX, DATA
		MOV		DS, AX
		POP		AX
        MOV     SI, OFFSET IMESSAGE 
        
    @@: LODSB
        CMP     AL, 0
        JE      @f
		CMP		AL, '$'
		JE		@f
        INT     10h
        JMP     @b
        
    @@: POP     DS
        RET    
        
    PRINTF ENDP  
    
CODE ENDS

END PRINTF
