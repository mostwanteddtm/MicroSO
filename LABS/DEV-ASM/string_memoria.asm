
; You may customize this and other start-up templates; 
; The location of this template is c:\emu8086\inc\0_com_template.txt

.model tiny
.stack 512d
.data
    
.code    
    
I:
    mov ax, 0
    int 16h
    
    cmp al, 0dh
    je escrever 
    
    mov [di], al
    inc di 
    
loop I 

escrever:
    mov di, 0
    pop di 
    
print_char:    
    mov al, [di]
    cmp al, 0
    je sair
    inc di
    mov ah, 0eh
    int 10h
    jmp print_char
    
   
sair:
    int 20h




