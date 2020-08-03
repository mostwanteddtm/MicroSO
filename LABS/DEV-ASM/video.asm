
; You may customize this and other start-up templates; 
; The location of this template is c:\emu8086\inc\0_com_template.txt

org 100h

; add your code here 

.MODEL small
.STACK 512d
.DATA
.CODE
    MOV AH, 00h
    MOV AL, 13h
    INT 10h
    
    MOV ES, startaddr 
    MOV DI, 5
    MOV AL, 5
    MOV CX, 100
    I: 
    MOV ES:[DI],AL
    INC DI  ;horizontal
    ADD DI, 320 ; vertical
    LOOP I
     
    INT 20h 
    
    startaddr	dw	0a000h

ret




