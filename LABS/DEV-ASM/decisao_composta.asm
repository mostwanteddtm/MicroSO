.model small

org 100h

.data
    a db 1d
    b db 9d 
    menor db "Menor", 24h
    maior db "Maior", 24h
    
.code  
    
    mov ax, @data
    mov ds, ax
    
    mov al, a
    mov bl, b
             
    mov ah, 09h
             
    cmp al, bl
    jg call msg_maior
    jl call msg_menor  
    
msg_menor proc
    mov dx, offset menor
    int 21h
    jmp sair
msg_menor endp  

msg_maior proc
    mov dx, offset maior
    int 21h 
    jmp sair
msg_maior endp 
   
sair:   
mov ah, 4ch
    int 21h
    
    
    
    




