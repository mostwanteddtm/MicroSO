
; You may customize this and other start-up templates; 
; The location of this template is c:\emu8086\inc\0_com_template.txt

org 100h

MOV AH,09h
MOV DX,OFFSET mensagem
INT 21h
INT 20h

mensagem DB 'HELLO WORLD!!', 24h ;pode ser tmb 'hello world$' 24h=$ascii

ret




