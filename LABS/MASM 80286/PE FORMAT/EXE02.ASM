.286P 

DSEG SEGMENT WORD USE16 'DATA'
         MESSAGE DB "OLA, MUNDO!", 0
DSEG ENDS


SSEG SEGMENT STACK 'STACK'
         DW 0100H DUP(?)
SSEG ENDS

CSEG01 SEGMENT WORD USE16 'CODE'
  ASSUME CS:CSEG01, DS:DSEG, SS:SSEG

    START PROC FAR

        CALL    PRINT
        
        MOV     AH, 04Ch
        INT     021h
        RET
        
    START ENDP
  
CSEG01 ENDS 

END START

PUBLIC PRINT

CSEG02 SEGMENT WORD PUBLIC USE16 'CODE'
	ASSUME CS:CSEG02, DS:DSEG, SS:SSEG
	
    PRINT PROC FAR 

		MOV     AX, DSEG
        MOV     DS, AX
        MOV     ES, AX
		
        MOV     SI, OFFSET MESSAGE
        MOV     AH, 0EH
CONT:   LODSB 
        CMP     AL, 0
        JE      FIM
        INT     10H
        JMP     CONT
        
FIM:    RET        
        
    PRINT ENDP    
       
CSEG02 ENDS

END PRINT