
; You may customize this and other start-up templates; 
; The location of this template is c:\emu8086\inc\0_com_template.txt

org 100h

SUB DX,DX
CALL VALIDA_DIGITO 
MOV DL,AL
MOV CL,04h
SHL DL,CL
CALL VALIDA_DIGITO
INT 20h

VALIDA_DIGITO: 
    PUSH DX
    MOV AH,08h ;faz a leitura do teclado, sem apresentar a tecla pressionada 
    EXIBIR:
    INT 21h 
    CMP AL,30
    JL EXIBIR
    CMP AL,46h
    JG EXIBIR  
    CMP AL,39h
    JG NAO_EXIBIR
    CALL EXIBIR_CARACTERE
    SUB AL,30h
    POP DX
    JMP SAIR_SUB
    NAO_EXIBIR:
    CMP AL,41h
    JL EXIBIR
    CALL EXIBIR_CARACTERE  
    SUB AL,37h
    POP DX 
    SAIR_SUB:
    RET
       
    
EXIBIR_CARACTERE: 
    MOV AH,02h
    MOV DL,AL
    INT 21h
    RET
              

ret




