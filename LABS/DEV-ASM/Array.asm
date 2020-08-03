org 100h

main:
    
    mov cl, len
    xor bx, bx
    
    c:
        mov al, texto[bx]
        mov ah, 0eh
        int 10h 
               
        inc bx               
               
    loop c
    
    int 20h
    
    texto db "Marcos"
    len db $-texto
    
end  
    