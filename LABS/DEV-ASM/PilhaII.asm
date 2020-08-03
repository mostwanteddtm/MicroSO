
; You may customize this and other start-up templates; 
; The location of this template is c:\emu8086\inc\0_com_template.txt

org 100h 

        jmp     start
msg     db      "Hello World!", 0    
    
start:

        mov     dx, OFFSET msg
        push    dx
    
        call    sub1 
        int     20h
    
sub1    proc    near
    
        push    bp
        mov     bp, sp
        mov     si, [bp+4]
        
cont:   lodsb        
        cmp     al, 0
        je      sair
        mov     ah, 0eh
        int     10h
        jmp     cont
sair:
        ret 
        
sub1    endp

ret




