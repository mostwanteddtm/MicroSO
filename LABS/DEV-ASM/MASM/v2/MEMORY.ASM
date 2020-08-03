; Esse codigo so roda, a partir da chamada do programa JUMP.COM
; Utilizo essa imagem como FLOPPY_0 
org 100h

main:

    push cs
    pop ds
    
    mov si, offset msg 
    
    while:
        lodsb 
        cmp al, 0
        je fim
        mov ah, 0eh
        int 10h
    jmp while 
     
    fim:
    int 20h  

    msg db "Marcos", 0
        
end main




