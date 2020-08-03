.286
.model tiny
.stack 07c00h

.code 
    .startup
    mov ah,00h
    mov al,03h
    int 10h
    
    mov ah,02h
    mov dh,00h
    mov dl,00h
    int 10h
    
    while:
      mov ah,00h
      int 16h
      
      mov ah,0eh
      int 10h
    loop while 
    .exit
end
