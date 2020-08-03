
; You may customize this and other start-up templates; 
; The location of this template is c:\emu8086\inc\0_com_template.txt

org 100h

MOV AH,02h
MOV DL,msg
INT 21h 
INT 20h

msg db 'A$' 

ret




