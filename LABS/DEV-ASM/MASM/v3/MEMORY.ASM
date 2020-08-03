.286
.model tiny
.code

org 100h

main:

        push    cs
        pop     ds
        
        mov     ax, 0800h
        mov     ds, ax
        mov     si, 0010h 
        xor     ax, ax
        mov     ax, ds:[si]
        
        mov     ah, 0eh
        int     10h
        
        xor     ax, ax
        int     16h
        
        int     20h

end




