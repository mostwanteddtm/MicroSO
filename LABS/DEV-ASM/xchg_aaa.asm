.model small
.stack 100h
.data
    msg1 db 'Entre com o valor decimal 1 (de 0 a 9): ', 24h
    msg2 db 0dh, 0ah, 'Entre com o valor decimal 2 (de 0 a 9): ', 24h
    
    msg3 db 0dh, 0ah, 'Soma = ', 24h
    msg4 db 0dh, 0ah, 'Caractere invalido', 24h
    
.code 
    mov ax, @data
    mov ds, ax

    mov dx, offset msg1
    call escreva
    call leia
    mov bh, al
    mov dx, offset msg2
    call escreva
    call leia
    mov bl, al
    
    mov dx, offset msg3
    call escreva
    xchg ax, bx ;inverte os valores entre os registradores
    
    add al, ah
    sub ah, ah
    aaa         ;altera o valor do registrador al, para um valor decimal valido
    mov dx, ax
    mov ah, 0eh
    cmp dh, 0h
    je nao_zero
    or dh, 30h
    mov al, dh
    int 10h
    
    nao_zero:
        or dl, 30h
        mov al, dl
        int 10h
        int 20h
        
    escreva proc near
        mov ah, 09h
        int 21h
        ret
    escreva endp
    
    leia proc near
        mov ah, 01h
        int 21h
        cmp al, 30h
        jl erro  ;jump se for < 30h (ascii 0)
        cmp al, 3ah
        jge erro ;jump se >= 3ah (ascii :)
        sub al, 30h
        ret
        erro:
            mov dx, offset msg4
            call escreva
            int 20h
        ret
    leia endp

ret




