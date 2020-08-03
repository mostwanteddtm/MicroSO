
; You may customize this and other start-up templates; 
; The location of this template is c:\emu8086\inc\0_com_template.txt

;O PROGRAMA EXIBE OS VALORES HEXADECIMAIS
org 100h

MOV AH,02 
MOV BL,30h
MOV DL,BL  
WHILE:
ADD DL,01h ;ADICIONA 01h EM DL
CMP DL,39h ;COMPARA O VALOR ENTRE DL E 39H
INT 21h
JGE SAIR_LOOP  ;SE O VALOR FOR MAIOR OU IGUAL, SAI DO LOOP
LOOP WHILE 
SAIR_LOOP:
ADD DL,07h
I: 
ADD DL,01h 
CMP DL,46h 
INT 21h
JGE SAIR
LOOP I
SAIR:
INT 20h

ret




