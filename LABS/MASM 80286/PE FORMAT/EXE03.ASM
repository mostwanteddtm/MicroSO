#MASM#  

.286

SSEG SEGMENT STACK 'STACK'
     
     DW 0100h DUP(0)
     
SSEG ENDS

DSEG SEGMENT PARA PUBLIC 'DATA' USE16 
     
     MESSAGE DD 1
     
DSEG ENDS

CSEG SEGMENT PARA PUBLIC 'CODE' USE16  
    ASSUME CS:CSEG, DS:DSEG,SS:SSEG
    
    ORG 0500h               ; E POSSIVEL DEFINIR OFFSET PARA O SEGMENTO 
    
    START PROC FAR
    
        MOV     AX, DSEG
        MOV     DS, AX
        
        ;MOV     AX, PSEG
        ;SHL     AX, 4
        ;ADD     AX, OFFSET PMODE
        ;MOV     WORD PTR CS:PM_ENTRY_OFF, AX

        DB      0EAh
		DW      PMODE   	 
        DW      PSEG

        ;PM_ENTRY_OFF DW ?   
        ; DW    0   
         
    START ENDP
    
CSEG ENDS


PSEG SEGMENT PARA PUBLIC 'CODE' USE16
    ASSUME CS:PSEG,DS:DSEG,SS:SSEG
    
    ORG 0200h               ; E POSSIVEL DEFINIR OFFSET PARA O SEGMENTO
    
    PMODE PROC FAR
    
        MOV     AH, 4CH
        INT     21H    
        
    PMODE ENDP
    
PSEG ENDS

END START