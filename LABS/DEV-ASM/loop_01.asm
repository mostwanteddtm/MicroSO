org 100h 

.data
schar db 2fh

.code
mov ah,00h
mov al,01h
int 10h

mov dl,00h  
 
i: 

mov ah,02h
mov dh,00h 
int 10h

add dl,01h 
cmp dl,0bh
je completar_hexadecimal

voltar:

cmp dl,11h
je sair

mov ah,0ah
add schar, 01h
mov al,schar
mov cx,01h
int 10h 

mov cx,02h

loop i

sair:
ret

completar_hexadecimal:
add schar,07h 
jmp voltar




