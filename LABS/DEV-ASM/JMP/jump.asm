
; You may customize this and other start-up templates; 
; The location of this template is c:\emu8086\inc\0_com_template.txt
.model tiny

org 100h

.code

    jmp main
    pointer dw 0000h
            dw 0800h

main: 
     
    mov ah, 02h
    
    mov al, 1 ;Setores para ler
    mov dl, 0 ;Floppy A:\
    
    mov ch, 0 ;C
    mov dh, 0 ;H
    mov cl, 1 ;S
    
    mov bx, 0800h    
    mov es, bx
    mov bx, 0h
    int 13h 
    
    ;push 0800h
    ;push 0000h 
    ;retf 
    
    jmp 0800h:0000h 
     

end




