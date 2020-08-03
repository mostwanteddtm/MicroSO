
; You may customize this and other start-up templates; 
; The location of this template is c:\emu8086\inc\0_com_template.txt

org 100h 

mov ah, 00h  
mov al, 03h ;modo de video 25 linhas, 80 colunas
int 10h

mov al, 0
mov bh, 10011111b 
mov ch, 0
mov cl, 0
mov dh, 18h ;18h = 24d, numero de linhas do video
mov dl, 4fh ;4f = 84d, numero de colunas
mov ah, 06h
int 10h 

mov dx, 0
 
I: 
mov ax, 0
int 16h

cmp al, 13
je CALL PULAR_LINHA 

cmp al, 27
je SAIR
 
CONTINUAR:
mov ah, 0eh
int 10h 

Loop I
  
SAIR:
int 20h  

PULAR_LINHA:   
    mov dl, 0h
    mov bh, 0
    add dh, 1
    mov ah, 02h 
    int 10h
    jmp CONTINUAR
    

ret




