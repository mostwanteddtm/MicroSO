
; You may customize this and other start-up templates; 
; The location of this template is c:\emu8086\inc\0_com_template.txt

org 100h

MOV AX,0003h ;testar com o valor 0001h
MOV BX,0002h
MOV DX,OFFSET Msg2 
CMP AX,BX ;faz comparação subtraindo a-b
JG SALTO  ;para usar JG, precisa do CMP, e compara se A > B
MOV DX,OFFSET Msg1
SALTO: 
MOV AH,09h
INT 21h
INT 20h

Msg1 db 'AX menor que BX$' 
Msg2 db 'AX maior que BX$'

ret




