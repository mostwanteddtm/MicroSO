
; You may customize this and other start-up templates; 
; The location of this template is c:\emu8086\inc\0_com_template.txt

org 100h

; add your code here
; set default video mode 80x25:
mov     ah, 00h
mov     al, 03h
int     10h

mov     al, 40h
mov     ds, ax          ; for getting screen parameters.  
mov     al, 0           ; scroll all lines!
mov     bh, 10011111b   ; attribute for new lines.
mov     ch, 0           ; upper row.
mov     cl, 0           ; upper col.
mov     di, 84h         ; rows on screen -1,
mov     dh, [di]        ; lower row (byte).
mov     di, 4ah         ; columns on screen,
mov     dl, [di]
dec     dl              ; lower col.
mov     ah, 06h         ; scroll up function id.
int     10h  
 
I:  
mov     ax, 0  
int     16h

mov     ah, 0eh
int     10h
cmp     al, 13
je      SAIR:
loop    I 
SAIR: 
      
ret




