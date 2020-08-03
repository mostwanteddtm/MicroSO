
; You may customize this and other start-up templates; 
; The location of this template is c:\emu8086\inc\0_com_template.txt

org 100h
     
   MOV AH, 02h
   MOV CX, 0007h
   MOV BL, 016h ;DEFINIMOS O VALOR DO REGISTRADOR D4h=212d=11010100b
   INICIO:    
       RCL BL, 01h ;RCL PERCORRE BIT A BIT DO VALOR DO REGISTRADOR 
       CALL PRINT_VALUE
   LOOP INICIO
   
   PRINT_VALUE:
       ;ADICIONA O VALOR DO REGISTRADOR DE ESTADO
       ;CARRY FLAG, QUE É SETADO COM O BIT DO REGISTRADOR DL
       ADC DL, 30h 
       INT 21h
       MOV DX, 00h
       RET
      
ret




