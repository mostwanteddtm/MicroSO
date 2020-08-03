org 100h 

mov         ax, 3
int         10h 


co:
mov     al, 1h
mov     ch, value
mov     cl, 0
mov     bh, value 
shl     bh, 4
or      bh, 00001111b
mov     dh, value                     ;18h = 24d, numero de linhas do video
mov     dl, 78                        ;4fh = 84d, numero de colunas
mov     ah, 06h
int     10h 
inc     value
cmp     value, 10h
je      continue
loop    co
              
continue:

mov     cx, 5  

co2:

xor     ax, ax
int     16h

mov     ah, 0eh
int     10h

loop    co2

int 20h 

value       db 0