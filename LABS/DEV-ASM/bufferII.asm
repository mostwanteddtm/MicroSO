org 100h 

EntryPoint:

    jmp main
        buffer db 7 dup (0)
        ; buffer db "Marcos", 0
main:

    xor bx, bx 
    mov cx, 6
    c:
        xor ax, ax
        int 16h
        
        pop bx
        mov [buffer+bx], al 
        inc bx
        push bx
    loop c 
    
    mov si, 0102h
    while:
        lodsb
        cmp al, 0
        je fim
        mov ah, 0eh
        int 10h
    jmp while
    
    fim:
    
    int 20h 
               
end