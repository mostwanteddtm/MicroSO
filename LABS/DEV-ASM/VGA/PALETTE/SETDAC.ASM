org 100h 

mov         ax, 3
int         10h

;mov     dx, 03C8h 
;mov     ax, 1  
;out     dx, ax 
;        
;mov     dx, 03C9h              ; green
;mov     ax, 63 
;out     dx, ax 
;        
;mov     dx, 03C9h              ; blue
;mov     ax, 0 
;out     dx, ax 
;        
;mov     dx, 03C9h 
;mov     ax, 0 
;out     dx, ax 
;   

mov     ax, 1010h
mov     bx, 1 
mov     cl, 20                  ; blue
mov     ch, 63                  ; green
mov     dh, 63                  ; red
int     10h

mov     al, 1h
mov     ch, 0
mov     cl, 0
mov     bh, 1Fh 
mov     dh, 0                     ;18h = 24d, numero de linhas do video
mov     dl, 78                        ;4fh = 84d, numero de colunas
mov     ah, 06h
int     10h 

xor     ax, ax
int     16h

mov     ah, 0eh
int     10h


int 20h 
