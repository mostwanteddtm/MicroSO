EXIBIR MACRO a, b 
    ;macro usa os registradores ax, dx
    ;caso haja valores importantes nos mesmos
    ;ao iniciar a macro, ela armazena os valores na pilha
    push ax
    push dx
    mov dx, offset a
    mov ah, 09h
    int 21h 
    
    mov dx, offset b
    mov ah, 09h
    int 21h 
    
    ;usa os registradores ax, dx
    ;repoe os valores dos registradores
    pop ax
    pop dx
ENDM
    