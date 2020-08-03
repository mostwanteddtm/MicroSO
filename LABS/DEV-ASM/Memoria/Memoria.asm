
; You may customize this and other start-up templates; 
; The location of this template is c:\emu8086\inc\0_com_template.txt

org 100h

    mov bx, 0800h
    mov ds, bx
    mov ds:[0001h], 41h
    

ret




