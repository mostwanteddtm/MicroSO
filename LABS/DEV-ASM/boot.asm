org 07C00h

.code
    mov ah,00h
	mov al,03h
	int 10h
	
	mov ah,02h
	mov dh,00h
	mov dl,00h
	int 10h
	
	mov ah,06h
	mov al,00h
	mov bh,0001_1111b
	mov ch,00h
	mov cl,00h
	mov dh,18h
	mov dl,4fh
	int 10h 
	
	mov dh,00h
	
	while:
	
	    voltar:
	
    	mov ah,00h
    	int 16h
    	
    	cmp al,13
    	je call Linha
    	
    	mov ah,0eh
    	int 10h 
    	
    loop while
    
    Linha proc near
        mov dl,00h
        mov bh,00h
        add dh,01h
        mov ah,02h 
        int 10h
    	jmp voltar
    Linha endp	
	        
end