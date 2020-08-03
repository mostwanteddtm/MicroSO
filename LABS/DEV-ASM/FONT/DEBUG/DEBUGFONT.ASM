#masm#
;--------------------------------------------------------|
;                                                        |
;       Template para compilacao com MASM 6.15           |
;     Facimente testado no EMU8086 com a diretiva        |
;                       #masm#                           |
;                                                        |
;--------------------------------------------------------|  

.286
.MODEL TINY
.STACK 100					   
_Text SEGMENT PUBLIC USE16
.DATA
        hello db 'A',0  
        font  db 256*16 dup (0)              
.CODE 

ORG 100h 

main:
        mov     ax,13h                   ;Mode 13h, 320x200 256 colors 
        int     10h                      ;^^^^ 

        mov     ax,1130h                 ;GET FONT INFORMATION (EGA, MCGA, VGA) 
        mov     bh,6                     ;06h ROM 8x16 font (MCGA, VGA) 

        ;int     10h                     ;Return: ES:BP = specified pointer 
                                         ;Also returned, but not used here: 
                                         ;CX    = bytes/character of on-screen font (not the requested font!) 
                                         ;DL    = highest character row on screen 


        ;mov     word ptr [font_data],bp      ;Fill the variable with the pointer to the specified font(8x16). 
        ;mov     word ptr [font_data+2],es    ;^^^^^^^^ 
        
        mov     ah, 02h
        mov     al, 8
        mov     ch, 0                       ; Cylinder
        mov     dh, 0                       ; Head
        mov     cl, 1                       ; Sector
        mov     dh, 0
        mov     dl, 0
        mov     bx, OFFSET font
        mov     bp, bx
        int     13h

        push    0A000h                   ;Setup es for writing to the screen(A000h = start of screen buffer). 
        pop     es                       ;^^^^ 
        mov     di,320*64+48             ;Start location to start writing pixels. 64 lines down and 48 across. 
        mov     si, offset hello                ;Set si up with location of the "Hello, World!" string. 
  draw_text:  
        lodsb                            ;Load a byte of the string into al. 
        test    al,al                    ;Is it zero? 
        jz      done                     ;If so, we're done. 
        push    ds 
        push    si                    ;If not, push ds and si 
        mov     si, OFFSET font           ;Load DS:SI the font data SEGMENT:OFFSET.So now DS points to the font segment, and SI is the offset. 
        xor     ah,ah                    ;zero out the top of ax 
        shl     ax,4                     ;Multiply the current byte of the string by 16(hint, the font is 8x16, stored as 8 pixels per byte) 
        add     si,ax                    ;Add that to the start offset of the font data. SI now points to the start of the pixel data for the current character.
        mov     bx,16  
   draw_character:  
        mov     dl,[si]  
        mov     cx,8  
    draw_row:  
        shl     dl,1  
        jnc     next_point  
        mov     ax,cx                    ;This all just draws it out fancy, I'm too lazy to continue.... 
        sub     ax,bx  
        and     ax,1111b  
        add     ax,29  
        mov     es:[di+321],al  
        mov     es:[di],al  
      next_point:  
        add     di,2  
        loop    draw_row  
        inc     si  
        add     di,(320-8)*2  
        dec     bx  
        jnz     draw_character  
        sub     di,320*2*16-(8+1)*2  
        pop     si 
        pop     ds  
        jmp     draw_text  
  done: 
        xor     ah,ah                    ; 
        int     16h                      ;Wait for a keypress 

        mov     ax,3                     ;Set mode 3, the normal console mode 
        int     10h                      ;^^^^^^^^^^^ 
        ret                              ;And....exit. 
    
_Text ENDS
end main
