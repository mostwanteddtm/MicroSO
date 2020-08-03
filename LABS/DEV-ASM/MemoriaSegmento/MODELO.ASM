org 100h

EntryPoint:

    jmp main
    msg db "Teste"
    len dw $-msg
    
main:
                  
    mov ax, 0800h
    mov es, ax
    mov bx, 0000h 

    mov cx, len
    
    while:
        mov al, msg[bx] 
        mov es:[bx], al
        inc bx
    loop while 
    
    int 20h                        

End                                        