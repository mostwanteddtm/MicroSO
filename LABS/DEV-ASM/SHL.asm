
; You may customize this and other start-up templates; 
; The location of this template is c:\emu8086\inc\0_com_template.txt

org 100h

MOV AH,01h ;interrupção para entrada de dados
INT 21h
MOV DL,AL
SUB DL,30h
CMP DL,09h
JLE SALTO1
SUB DL,07h
SALTO1:
MOV CL,04h
SHL DL,CL ;move para esquerda um nible o valor do registrador DL, SHR move para direita
INT 21h
SUB AL,30h
CMP AL,09h
JLE SALTO2
SUB AL,07h
SALTO2:
ADD DL,AL
INT 20h

ret




