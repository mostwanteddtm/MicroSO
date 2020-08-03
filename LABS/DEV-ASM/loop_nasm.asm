org 07c00h

section .text

mov cx,02h
 
loop:

mov ah,02h
mov dl, [schar] 
int 21h 
inc byte [schar]
dec cx
jnz loop

ret 

section .data
schar db 30h





