
; You may customize this and other start-up templates; 
; The location of this template is c:\emu8086\inc\0_com_template.txt

.model small
.stack 521d

.data
    a db 5h ;testar com o valor 6h
    
.code 
    mov bl, a
    and bl, 5h ;compara um valor, se nao estiver correto, assume o valor informado
    mov dl, bl
    add dl, 30h
    
    mov ah, 02h
    int 21h
    
    mov ah, 04ch
    int 21h

ret




