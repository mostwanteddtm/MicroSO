.286 
.model small
.stack

kernel segment at 0800h
org 0000h
start label far
kernel ends

_Text SEGMENT PUBLIC USE16 

extern				_letra:near	

.code 
    
main: 
    
    push cs
    pop ds 
        
    texto:
    
        mov ah,00h
        int 16h
        
        cmp al,1bh
        je sair 
        
        call _letra
        
        mov ah,0eh
        int 10h 
        
    loop texto
        
    sair:
    
    mov ah,0eh
    mov al,0dh
    int 10h
      
    jmp kernel:start 
     
end main