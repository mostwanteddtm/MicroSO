org 100h  

EntryPoint: 

    jmp main
        valor db 5 dup (0)  
        decimal dw 10 
        
main:
    
    mov ax, 000FFh       
    xor bx, bx
    
    c:
        xor dx, dx
        div [decimal]
        add dl, 30h 
        mov [valor+bx], dl
        inc bx
        cmp al, 9
        ja c
    
    continue: 
        xor dx, dx
        xchg dl, al
        add dl, 30h 
        mov [valor+bx], dl 
        mov cx, bx 
        inc cx
   
    mov si, offset valor
    add si, bx
    print: 
        mov ah, 0eh
        mov al, [si]
        int 10h
        dec si
    loop print
            
    int 20h

end




