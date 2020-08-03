org 100h

mov ah,02h
mov dl,41h
mov cl,03h

voltar:
    int 21h
    dec cl ;subtrai 1
    jnz voltar ;funciona como loop
    ;enquanto cl nao for = 0
    
add dl,01h
int 21h

ret




