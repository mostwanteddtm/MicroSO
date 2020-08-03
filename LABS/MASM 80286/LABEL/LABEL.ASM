#MASM#
.286 

DESC STRUC
    VAL1    DB 0
    VAL2    DW 0
    VAL3    DB 0
DESC ENDS 


DATA SEGMENT PARA PUBLIC 'DATA' USE16 
    
    PONTO LABEL DWORD                   ; A DIRETIVA LABEL, DEFINE UM PONTEIRO COM INTERVALO DE TAMANHO
                                        ; NESSE CASO UM ARRAY DE DUAS POSICOES (SELEC1 E SELEC2)
    SELEC1 EQU $-PONTO                  ; CADA UM COM 4 BYTES CADA
    DESC <12h, 3456h, 0>
    
    SELEC2 EQU $-PONTO                  ; A DIRETIVA LABEL NAO OCUPA ESPACO EM MEMORIA
    DESC <78h, 9111h, 0>                ; O COMPILADOR USA APENAS COMO REFERENCIA DE ENDERECO

    VALUES DESC <6,7, 0> 
    
    TAB LABEL WORD
        DW SELEC1
        DW SELEC2 
        
    LTAB EQU ($-TAB) / 2 
    
    PKEY DB "PRESS ANY KEY...$"

DATA ENDS

STACK SEGMENT STACK 'STACK'
    DW   128  DUP(0)
STACK ENDS

CODE SEGMENT PARA PUBLIC 'CODE' USE16 
    ASSUME CS:CODE, DS:DATA, ES:DATA  
    
    MAIN PROC NEAR
    
        MOV AX, DATA
        MOV DS, AX
        MOV ES, AX               
                                       
        MOV SI, OFFSET TAB
        MOV CX, LTAB
     R: LODSW  
        MOV DI, AX
        MOV BL, ES:[DI]                ; COMO A DIRETIVA LABEL SERVE COMO REFERENCIA DE ENDERECO
        MOV DX, ES:[DI][1]             ; EU POSSO BUSCAR PELO INDICE DO ARRAY
        LOOP R                         ; DESC <[0], [1], [2]>
        
        LEA DX, PKEY
        MOV AH, 9
        INT 21H        
       
        MOV AH, 1
        INT 21H
        
        MOV AX, 4C00H
        INT 21H
        
    MAIN ENDP  
    
CODE ENDS

END MAIN