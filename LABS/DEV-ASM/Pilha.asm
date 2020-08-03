org 100h 

main:

    mov ax, 05h
    push ax
    mov ax, 06h
    push ax
    
    xor ax, ax
    
    mov bx, 0FFFCh
    mov sp, bx  
    
    pop ax
    
    int 20h
    
end