org 100h

        xor     ax, ax
        mov     al, 13h
        int     10h

        mov     ax, 0A000h
        mov     es, ax
        mov     di, 0 
        
        mov     si, offset message 
        
loadchar:
        lodsb  
        push    si 
        
        mov     byte ptr fontoff, al
        xor     ah, ah
        
        mov     si, offset font
        mov     dx, lenfy               ; loop das 16 linhas 
        mul     dx
        add     si, ax 
        xor     bx, bx
        
        mov     dx, lenfy               ; loop das 16 linhas 
        
nextline:
        lodsb 
        
        mov     cx, lenfx 
invertbits:
        sal     al, 1
        rcr     bl, 1

        loop invertbits 
        
        xchg    al, bl

        mov     cx, lenfx               ; loop dos 8 bits 
printrow:
        mov     bl, al
        and     al, 1
        cmp     al, 1
        jne     controw
        mov     al, 0fh
        mov     es:[di], al
controw: 
        inc     di
        ror     bl, 1
        mov     al, bl
        loop printrow 
        
        cmp     dx, 1
        je      sair
        add     di, 312
        dec     dx
        jmp     nextline        
        
sair:
        xor     ax, ax
        int     16h
        
        mov     ax, 3
        int     10h
        
        mov     ax, 4c00h
        int     21h


lenfx   equ 8                   ; total de bits da font, por linha
lenfy   equ 16                  ; total de bytes da font 8x16
fontoff db  0                   ; offset da font a ser impressa  

message db  1, 0


font    db 00000000b            ; offset 0
        db 00000000b
        db 01100110b
        db 01000010b
        db 00000000b
        db 01000010b
        db 01000010b
        db 01000010b
        db 00000000b
        db 01000010b
        db 01000010b
        db 01100110b
        db 00000000b
        db 00000000b
        db 00000000b
        db 00000000b

        db 00000000b            ; offset 1
        db 00000000b
        db 00111100b
        db 01000010b
        db 01000010b
        db 01000010b
        db 01000010b
        db 01111110b
        db 01000010b
        db 01000010b
        db 01000010b
        db 01000010b
        db 00000000b
        db 00000000b
        db 00000000b
        db 00000000b