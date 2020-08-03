
; You may customize this and other start-up templates; 
; The location of this template is c:\emu8086\inc\0_com_template.txt

org 100h

   mov     ah, 09h           ; Imprime "Escreva alguma coisa: "
   mov     dx, offset msg1        ;
   int     21h            ;
 
   mov     ah, 0Ah         ; Coleciona as teclas digitadas
   mov     dx, buf         ;    armazenando-as no buffer
   int     21h            ;
 
   mov     ax, 4C00h      ; Termina o programa
   int     21h            ;
 
msg1    db      'Escreva alguma coisa: $'
 
; Este é o buffer de entrada
buf:
max     db      20
count   db      0
data    db      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0

ret




