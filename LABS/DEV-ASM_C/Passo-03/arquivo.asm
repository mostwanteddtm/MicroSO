.286 
.model small
.stack

_Text SEGMENT PUBLIC USE16 
extern				_letra:near	

.code 
    
main: 
           
    call _letra
    
    mov ah,0eh
    int 10h 
        
    mov ah,00h
    int 16h
    
    int 2h
       
end main 

