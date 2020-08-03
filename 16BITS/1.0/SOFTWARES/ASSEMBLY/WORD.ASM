include "DEFINIRCORES.INC"

org 100h   

EntryPoint: 

    push cs
    pop ds
    
    jmp main
        curX db 00h
        curY db 00h 
        
        CorFundo db 0Fh
        CorFonte db 00h
        
        msgFundo db "Selecione o VALOR para cor de fundo que deseja usar: ", 0h
        msgFonte db "Selecione o VALOR para cor de fonte que deseja usar: ", 0h
        
        Colors db "VALOR    COR           ", 0Ah, 0Dh
               db "0        PRETO         ", 0Ah, 0Dh
               db "1        AZUL          ", 0Ah, 0Dh
               db "2        VERDE         ", 0Ah, 0Dh        
               db "3        CIANO         ", 0Ah, 0Dh
               db "4        VERMELHO      ", 0Ah, 0Dh
               db "5        MAGENTA       ", 0Ah, 0Dh
               db "6        MARRON        ", 0Ah, 0Dh
               db "7        CINZA CLARO   ", 0Ah, 0Dh
               db "8        CINZA ESCURO  ", 0Ah, 0Dh
               db "9        AZUL CLARO    ", 0Ah, 0Dh
               db "A        VERDE CLARO   ", 0Ah, 0Dh
               db "B        CIANO CLARO   ", 0Ah, 0Dh
               db "C        VERMELHO CLARO", 0Ah, 0Dh
               db "D        MAGENTA CLARO ", 0Ah, 0Dh
               db "E        AMARELO       ", 0Ah, 0Dh
               db "F        BRANCO        ", 0Ah, 0Dh, 0h  
                  
main:  

    mov ah, 00h
    mov al, 03h
    int 10h

    mov ah, 02h
    mov dh, 0Ah
	mov dl, 00h
	mov bh, 00h
	int 10h
	
	mov si, offset Colors
	whileColors:
	    lodsb
	    cmp al, 0h
	    je SairColors
	    mov ah, 0eh
	    int 10h
	jmp whileColors
	
	SairColors:

    SelecionarCores 
    
    mov ah, 02h
    mov dh, 00h
	mov dl, 00h
	mov bh, 00h
	int 10h
	
    i:
        mov ah, 00h
        int 16h
        
        cmp al, 1Bh
        je fim
        
        cmp al, 08h
        je call back 
        cmp al, 13
        je addLinha
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
       dec curY 
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
        mov dl, curY
        mov dh, curX
        mov bh, 00h
        mov ah, 02h
        int 10h 
        jmp i
    seta endp

    avancaCursor proc near
        inc curY 
        jmp continue
    avancaCursor endp  
    
    addCur proc near
        inc curY
        jmp return
    addCur endp
    
    removeCur proc near
        dec curY
        jmp return
    removeCur endp 
    
    addLinha proc near
        inc curX
        mov curY, 0
        jmp return
    addLinha endp 
    
    fim:
    int 20h  
    
    mov dx, 0
    push 0800h
    push 0000h
    retf

end