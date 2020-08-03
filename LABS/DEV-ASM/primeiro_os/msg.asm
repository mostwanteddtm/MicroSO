org 0000h 

start:

    push cs
    pop ds 
    
    mov ah, 00h
    mov al, 03h
    int 10h
    
    mov al, 00h
	mov ch, 00h
	mov cl, 00h
	mov dh, 18h ;18h = 24d, numero de linhas do video
	mov dl, 4fh ;4fh = 84d, numero de colunas
	mov bh, 01011111b
	mov ah, 06h
	int 10h
	
	;HEX    BIN       COLOR
	;0      0000      black				- preto
	;1      0001      blue				- azul  
	;2      0010      green				- verde
	;3      0011      cyan				- ciano
	;4      0100      red				- vermelho
	;5      0101      magenta			- magenta
	;6      0110      brown				- marrom
	;7      0111      light gray		- cinza claro 
	;8      1000      dark gray			- cinza escuro
	;9      1001      light blue		- azul claro
	;A      1010      light green		- verde claro
	;B      1011      light cyan		- ciano claro
	;C      1100      light red			- vermelho claro
	;D      1101      light magenta		- magenta claro
	;E      1110      yellow			- amarelo
	;F      1111      white				- branco
	;Bit 8-5 BackGround | Bit 4-1 ForeColor 
	
	
    
    lea si,msg
    mov cx,msglen
    
    while:  
    
        mov al,[si]
        mov ah,0eh
        int 10h
        
        inc si
        
        push cx
        
        mov     cx, 03h
        mov     dx, 1220h
        mov     ah, 86h
        int     15h
        
        pop cx
        
    loop while 
    
    jmp 0800h:0000h
    
    
    msg db "MEU BEM!!", 0ah, 0dh, 0ah, 0dh
        db "Gosto muito de voce. Estou procurando uma maneira bem legal de demonstrar. ", 0ah, 0dh
        db "Ontem foi uma demonstracao, de que podemos fazer varias coisas gostosas juntos e "
        db "que a gente possa ficar mais uns 75 anos bem juntinhos e curtindo o frio e o calor tmb!! ..rs. ", 0ah, 0dh
        db "CLARO QUE NO CALOR ---- CAAAAAAAAAMMMMMMMPINNNNNNNGGGGGGGG..... :) :) :)", 0ah, 0dh, 0ah, 0dh  
        db "Vamos ser muito felizes juntos!!", 0ah, 0dh, 0ah, 0dh
        db "BEIJOS e mais BEIJOS do......do....", 0ah, 0dh, 0ah, 0dh
        db "SEU BEM", 0ah, 0dh 
    msglen dw $-msg
    
    ;vetor db 1022 - ($ - start) dup (0)
    ;dw 0aa55h

end