org 100h

    mov al, 01h
    mov bh, 00h
    mov bl, 0fh
    mov cx, (msgEnd - 1) - offset msg
    mov dl, 00h
    mov dh, 00h
    push cs
    pop es
    mov bp, offset msg
    mov ah, 13h
    int 10h 
    
    mov ah, 0eh   
    mov al, 00h
    int 10h
    
    mov ah, 00h
    int 16h
    
ret
    
    msg dw "hello, world!"
    msgEnd:
 
