#masm#
.286 
.model tiny
.code
    org 07C00h

EntryPoint:  jmp short main

    msg db "ASPEN kernel v0.01", 0ah, 0dh  
    msglen dw $-msg 

main: 
    push CS
    pop  DS
    
    mov al, 03h
    mov ah, 0
    int 10h 
    
    mov si, OFFSET msg
    mov cx, msglen 
    
    get: 
    
        mov al, [si]
        mov bh, 00h
        mov ah, 0eh
        int 10h
        
        inc si 
        
    loop get
    
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
     
    push 0800h
    push 0000h
    retf

    db (510-($-EntryPoint)) dup (0)
    dw 0AA55h  

END EntryPoint