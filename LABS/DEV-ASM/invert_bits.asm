org 100h

mov al, val1
mov cx, 8   
mov bx, 0     

loop1:
sal al, 1
rcr bl, 1

loop loop1 

int 20h

val1 db 10101110b
; bl =  01110101b