#masm# 
.model tiny
.code
org 100h 

EntryPoint:

    mov dl, 41h
    mov cs:[0150h], dl
    mov al, dl
    mov ah, 0eh
    int 10h
           
    int 20h    
end