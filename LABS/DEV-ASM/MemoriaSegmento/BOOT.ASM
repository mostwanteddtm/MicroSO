org 7C00h  

EntryPoint: 

    jmp main
        msg db "Teste", 0
        
main:

    push cs
    pop ds
    
    mov ax, 0800h
    mov es, ax
    mov bx, 0000h 

    while:
        mov al, msg[bx] 
        cmp al, 0
        je Continue
        mov es:[bx], al
        inc bx
    loop while
    
    Continue: 
    
    mov ah, 00h
    mov al, 03h
    int 10h 
    
    mov ah, 02h
    mov al, 01h
    mov ch, 00h
    mov dh, 00h
    mov cl, 02h
    mov dl, 00h
    mov bx, 0800h
    mov es, bx
    mov bx, 0100h
    int 13h 
    
    xor ax, ax
    int 16h
           
    push 0800h
    push 0100h
    retf  
    
    db (510-($-EntryPoint)) dup (0)
    dw 0AA55h

End 