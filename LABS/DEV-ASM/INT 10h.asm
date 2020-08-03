
; You may customize this and other start-up templates; 
; The location of this template is c:\emu8086\inc\0_com_template.txt

org 100h

INICIO:
mov ax, 0
int 16h 

cmp al, 13
je CALL PROXIMA_LINHA 

CONTINUAR: 

cmp al, 27
je SAIR

mov ah, 0eh
int 10h 
LOOP INICIO

PROXIMA_LINHA:
    mov dl, 0h
    add dh, 1
    mov ah, 02h  ;a tabela de interrupção de vídeo vai de AH=00h à AH=0Fh
    int 10h 
    jmp CONTINUAR
    
SAIR: 


ret




