org 100h 

mov ah,02h 
mov cl,03h

while:

mov dl,41h

jz sair ;quando cl=0 sair
int 21h
  
;com o loop cl=(3,2,1,0)[AAAB]
loop while

sair:
add dl,01h
int 21h

ret




