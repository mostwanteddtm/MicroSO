
; You may customize this and other start-up templates; 
; The location of this template is c:\emu8086\inc\0_com_template.txt

org 100h

MOV AH,02h
MOV BL,98h  ;=byte 10011000
MOV CX,0008 ;loop de 8 repeticoes
while: 
RCL BL,01h    ;passa bit-a-bit dentro do registrador
ADC DL,30h   ;soma o valor 30h(ascii 0) ao valor do bit de estado de CF
INT 21h 
MOV DX,0h  
LOOP while
INT 20h  

ret




