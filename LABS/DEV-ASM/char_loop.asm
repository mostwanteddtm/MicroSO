org 100h

.data 
msg db "Paula e Marcos Apaixonados!" 
msglen dw $-msg 

.code
    
    ;lea si,msg
    mov cx,msglen
    
    c:  
        ;mov al,[si]
        mov al,msg [si] 
        
        mov ah,0Eh
        Int 10h
        
        inc si
        
    loop c 
    
    mov ax, 4c00h
    int 21h  
    
end




