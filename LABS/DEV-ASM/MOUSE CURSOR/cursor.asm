org 100H 

start:

        mov     ax, 4f02h                  
	    mov		bx, 103h
        int     10h
        
        mov     ax, 4F05h 
        mov     dx, 3                           ; bank                      
        mov     bx, 0
        int     10h                             
         
        mov     es, videmem
        mov     di, mousebase
        mov     si, offset startm  
        mov     cx, lenm
        xor     dx, dx             

mo:     
        lodsb   
        mov     es:[di], al 
        
        cmp     dx, mpixel
        je      nextline
        
        inc     di
        inc     dx
        jmp     contline
        
nextline:
        
        xor     dx, dx                          ; pular linha
        add     di, pline                    
                                           
contline: 
         
        loop    mo
        
        xor     ax, ax
        int     16h
        
        mov     ax, 3
        int     10h
        
        int     20h 
        
        
        videmem         dw  0A000h
        mousebase       dw  3000 
        
        m               equ 0Fh                 ; 1 pixel branco
        mpixel          equ 0Bh                 ; total de pixel por linha 
         
        hpixels         EQU 800
        pline           DW  (hpixels - mpixel)  ; 800 pixel horizontal - 12 (0Bh) pixels por linha 
        
        startm:
        
        ;  0  1  2  3  4  5  6  7  8  9  A  B
        DB m, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
        DB m, m, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0  
        DB m, m, m, 0, 0, 0, 0, 0, 0, 0, 0, 0
        DB m, m, m, m, 0, 0, 0, 0, 0, 0, 0, 0
        DB m, m, m, m, m, 0, 0, 0, 0, 0, 0, 0
        DB m, m, m, m, m, m, 0, 0, 0, 0, 0, 0
        DB m, m, m, m, m, m, m, 0, 0, 0, 0, 0
        DB m, m, m, m, m, m, m, m, 0, 0, 0, 0
        DB m, m, m, m, m, m, m, m, m, 0, 0, 0
        DB m, m, m, m, m, m, m, m, m, m, 0, 0
        DB m, m, m, m, m, m, m, m, m, m, m, 0
        DB m, m, m, m, m, m, m, m, m, m, m, m
        DB m, m, m, 0, m, m, m, 0, 0, 0, 0, 0
        DB m, m, 0, 0, 0, m, m, 0, 0, 0, 0, 0
        DB m, 0, 0, 0, 0, 0, m, m, 0, 0, 0, 0
        DB 0, 0, 0, 0, 0, 0, m, m, 0, 0, 0, 0
        DB 0, 0, 0, 0, 0, 0, 0, m, m, 0, 0, 0
        DB 0, 0, 0, 0, 0, 0, 0, m, m, 0, 0, 0
        
        lenm            equ $-startm 
        
      
        ; 100000000000
        ; 110000000000  
        ; 111000000000
        ; 111100000000
        ; 111110000000
        ; 111111000000
        ; 111111100000
        ; 111111110000
        ; 111111111000
        ; 111111111100
        ; 111111111110
        ; 111111111111
        ; 111011100000
        ; 110001100000
        ; 100000110000
        ; 000000110000
        ; 000000011000
        ; 000000011000 
        
        ; 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
        ; 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0  
        ; 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0
        ; 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0
        ; 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0
        ; 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0
        ; 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0
        ; 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0
        ; 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0
        ; 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0
        ; 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0
        ; 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1
        ; 1, 1, 1, 0, 1, 1, 1, 0, 0, 0, 0, 0
        ; 1, 1, 0, 0, 0, 1, 1, 0, 0, 0, 0, 0
        ; 1, 0, 0, 0, 0, 0, 1, 1, 0, 0, 0, 0
        ; 0, 0, 0, 0, 0, 0, 1, 1, 0, 0, 0, 0
        ; 0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 0, 0 
        ; 0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 0, 0
   
        