
; You may customize this and other start-up templates; 
; The location of this template is c:\emu8086\inc\0_com_template.txt

org 0 

main: 

    loops:
        xor ax, ax
        int 16h
      
        mov ah, 0eh
        int 10h
        
    jmp loops

end




