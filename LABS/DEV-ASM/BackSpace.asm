.model tiny
.stack 512d
.data 
    msg db 'teste'
    msgLen dw $-msg 
    curX db 00h
    curY db 00h
.code   
main: 

    lea si, msg 
    mov cx, msgLen
    while:
        mov al, [si]
        mov ah, 0Eh
        int 10h
        inc si
    loop while 
    
    mov ah, 02h
    mov dl, curX
    inc curY
    mov dh, curY
    int 10h 
    
    i:
        mov ah, 00h
        int 16h
        
        cmp al, 08h
        je call back
        jge call avancaCursor
        
        ;ah armazena o keyboard scan code (seta para direita) 
        ;buffer do teclado esta em segment 0h, offset 1054h (41E hex)
        cmp ah, 4dh  ;seta para direita
        je call seta
        cmp ah, 4bh  ;seta para esquerda
        je call seta
        continue: 
        
        mov ah, 0Eh
        int 10h
    loop i
    
    back proc near
       dec curX 
       mov ah, 0eh
       mov al, 08h
       int 10h		;backspace on the screen
     
       mov al, 20h
       int 10h		;blank character out
     
       mov al, 08h
       int 10h      ;backspace
        
       jmp i
    back endp 
    
    seta proc near
        cmp ah, 4dh ;seta para direita
        je addCur
        cmp ah, 4bh  ;seta para esquerda
        je removeCur    
        return:
        mov dl, curX
        mov dh, curY
        mov bh, 00h
        mov ah, 02h
        int 10h 
        jmp i
    seta endp

    avancaCursor proc near
        inc curX 
        jmp continue
    avancaCursor endp  
    
    addCur proc near
        inc curX
        jmp return
    addCur endp
    
    removeCur proc near
        dec curX
        jmp return
    removeCur endp
 
    ret    
end main    