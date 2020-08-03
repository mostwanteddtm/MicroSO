.MODEL small
.STACK 512d   

.DATA
    A DW 9d
    B DW 2d  ; variável de 16 bits
    ;B DB 2d ;variável de 8 bits
    X DB 0, 24h
    
.CODE 
    MOV AX, @DATA
    MOV DS, AX
    
    MOV AX, A
   ;MOV AL, A
    MOV BX, B
   ;MOV BL, B
    DIV BX  ;divisão sempre usará AX/BX
   ;DIV BL
    
    MOV X, AL
    ADD X, 30h
    MOV DX, OFFSET X
    
    MOV AH, 09h
    INT 21h
    
    MOV AH, 04Ch
    INT 21h

ret




