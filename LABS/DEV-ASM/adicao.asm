
; You may customize this and other start-up templates; 
; The location of this template is c:\emu8086\inc\0_com_template.txt

org 100h

MOV AH,02h
MOV BL,20h
MOV BH,21h
ADD BH,BL  ;soma
MOV DL,BH
INT 21h 
INT 20h

ret




