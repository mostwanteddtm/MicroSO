; Esse codigo so roda, a partir da chamada do programa JUMP.COM
; Utilizo essa imagem como FLOPPY_0 
org 150h
    
    push cs
    pop ds
    
    ; Como estou utilizando org 150h ou seja OFFSET 150h
    ; A mensagem inicia no endereco 162h
    ; Se eu colocasse a mensagem no inicio a linha abaixo ficaria:
    ; mov si, 0150h 
    mov si, 0162h  ; Endereco da mensagem na memoria
    
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
        
ret




