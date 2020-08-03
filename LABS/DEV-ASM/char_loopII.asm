
; You may customize this and other start-up templates; 
; The location of this template is c:\emu8086\inc\0_com_template.txt

org 100h

push cs
    pop ds
    
    mov ah,03h
    mov row,dh
    int 10h  
    
    mov cx,msglen

    voltar:  
        ;mov al,[si]
        mov al,msg [si] 
        
        mov ah,0Eh
        Int 10h
        
        inc si
        
        cmp cx,0
        je texto
        
    loop voltar
    
    texto:
    
        mov ah,00h
        int 16h
        
        cmp al,0dh
        je sair 
        
        mov ah,0eh
        int 10h
        
    loop texto
        
    sair: 
    
    inc dh
    mov ah,02h
    mov bh,00h
    int 10h
       
    mov ah,00h
    int 16h
      

ret    
    
row db 0    
msg db "Paula e Marcos Apaixonados!" 
msglen dw $-msg






