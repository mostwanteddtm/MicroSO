org 07C00h

EntryPoint:

    xor ax, ax ;zero ax
    mov ds, ax ;pois nao da pra zerar direto ds (data segment)
    
    mov al, 03h
    mov ah, 0
    int 10h 
    
    lea si, msg
    mov cx, msglen 
    
    while: 
    
        mov al, [si]
        mov bh, 00h
        mov ah, 0eh
        int 10h
        
        inc si 
        
    loop while
    
    mov ah, 02h ;leitura do disco
    mov al, 01h ;numero de setores
    mov ch, 00h ;trilha
    mov cl, 02h ;setor
    mov dh, 00h ;cabeca
    mov dl, 00h ;drive (0 = disquete)
    mov bx, 0800h
    mov es, bx
    mov bx, 00h
    int 13h
    
    jmp 0800h:0000h
            
    msg db "ASPEN kernel v0.01", 0ah, 0dh  
    msglen dw $-msg 

    db (510 - ($ - EntryPoint)) dup (0) 
    dw 0AA55h
    
end
    