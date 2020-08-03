.286
.model tiny
.code

org 100h

main:

    mov     ax, 0800h
    mov     ds, ax
    mov     dx, 0041h   ;estou movendo o valor 41h
    mov     bx, 0010h   ;direto para o endereco de memoria
    mov     [bx], dx    ;0800:0010 - sintaxe MASM 
    
    mov     ah, 02h
    mov     al, 1
    mov     ch, 0
    mov     cl, 1
    mov     dh, 0
    mov     dl, 0
    mov     bx, 0800h
    mov     es, bx
    mov     bx, 0100h
    int     13h
    
    push    0800h       ;Deve-se sempre alinhar a memoria com o programa a ser carregado
    push    0100h       ;neste exemplo, o programa deve utilizar org 100h
    retf

end




