org 100h

;80*25
mov ax,3
int 10h
;load 8*8 font
mov ax,1112h
mov bl,0
int 10h
;enable double scan
mov dx,3d4h
mov al,9h
out dx,al
inc dx
in al,dx
or al,80h
out dx,al
;set cell width to 8
mov dx,3c4h
mov ax,101h
out dx,ax
;update mem
xor ax,ax
mov es,ax
mov byte ptr es:[484h],24
mov word ptr es:[485h],8

mov ah, 4ch
int 21h
