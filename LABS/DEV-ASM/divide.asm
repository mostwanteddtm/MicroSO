
; You may customize this and other start-up templates; 
; The location of this template is c:\emu8086\inc\0_com_template.txt

.model small
.stack 512d

.data
    a dw 10d
    b dw 2d
    x dw 0, 24h
    
.code
    mov ax, @data
    mov ds, ax
    
    mov ax, a
    mov bx, b
    div bl
    
    mov x, ax
    add x, 30h
    mov dx, offset x
    
    mov ah, 09h
    int 21h
    
    mov ah, 4ch
    int 21h

ret




