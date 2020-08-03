
; You may customize this and other start-up templates; 
; The location of this template is c:\emu8086\inc\0_com_template.txt

.MODEL smal
.STACK 512d

.DATA
    a DW 6d
    b DW 2d
    X DW 0, 24h
    
.CODE
    MOV AX, @DATA
    MOV DS, AX
    
    STC ;altera o estado do registrador de estado CF de 0 para 1
    MOV AX, a
    ADC AX, b ;soma a+b+CF
    MOV x, ax
    
    ADD x, 30h
    MOV DX, OFFSET x  
    
    MOV AH, 09h
    INT 21h
    
    MOV AH, 4Ch ; é a mesma função de 20h; retorna o controle da cpu para o S.O após executar a linha abaixo 
    INT 21h
    
ret




