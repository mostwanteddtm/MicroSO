
; You may customize this and other start-up templates; 
; The location of this template is c:\emu8086\inc\0_com_template.txt

.model small
.stack 512d

.data
    a dw 5d
    b db 3d
    x db 0, 24h
    
.code
    mov ax, @data
    mov ds, ax
    
    mov ax, a
    mov bl, b
    mul bl
    
    mov x, al
    sub bx, bx
    mov bl, x
    
    mov ah, 02h
    
    mov dl, bl
    mov cl, 04h
    shr dl, cl
    add dl, 30h
    cmp dl, 39h
    jle call SecondChar
    add dl, 07h
    
SecondChar proc near
    int 21h
    
    mov dl, bl
    and dl, 0fh
    add dl, 30h
    cmp dl, 39h
    jle call Fim
    add dl, 07h  
    
SecondChar endp
    
Fim proc near
    int 21h
    
    mov ah, 04ch
    int 21h 

Fim endp

ret




