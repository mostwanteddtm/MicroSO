.model small
.stack 100h
.data
    msg1 db 'Entre com o valor de (0 a 8): ', 24h
    msg2 db 0dh, 0ah, 'Fatorial de ', 24h
    msg3 db ' equivale a ', 24h
    msg4 db 0dh, 0ah, 'Valor invalido', 24h
    
.code 
    mov ax, @data
    mov ds, ax

    msg msg1
    call entrada
    push ax
    
    msg msg2
    pop ax
    mov dl, al
    mov ah, 0eh
    int 10h
    sub al, 30h
    mov cl, al
    
    msg msg3
    call fatorial
    call valor
    
    fim:
        int 20h
        
    msg macro mensagem
        mov dx, offset mensagem
        mov ah, 09h
        int 21h
    endm
    
    entrada proc near
        mov ah, 01h
        int 21h
        cmp al, 30h
        jl erro
        cmp al, 39h
        jge erro
        jmp fim_validacao
        erro:
            msg msg4
            jmp fim
        fim_validacao:
        ret
    entrada endp
    
    fatorial proc near
        mov ax, 01h
        cmp cx, 0h
        je fim_laco
        repita1:
            mul cx
            loope repita1
        fim_laco:  
        ret
    fatorial endp
    
    valor proc near
        push ax
        mov bx, 0ah
        sub cx, cx
        repita2:
            sub dx, dx
            div bx
            push dx
            inc cx
            cmp ax, 0h
            jnz repita2
        saida:
            pop ax
            add al, 30h
            mov dl, al
            mov ah, 0eh
            int 10h
            dec cx
            jnbe saida
            pop dx
            ret
   valor endp
        

ret




