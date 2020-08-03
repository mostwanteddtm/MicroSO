
; You may customize this and other start-up templates; 
; The location of this template is c:\emu8086\inc\0_com_template.txt

org 100h

MOV AH,09h
CALL Procedimento
INT 21h
INT 20h


Procedimento: MOV DX,OFFSET mensagem
              RET

mensagem db "0123456789", 24h

ret




