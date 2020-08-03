#make_COM#

; COM file is loaded at CS:0100h
ORG 100h

;*******************************
;*    Programa: DIVIDE3.ASM    *
;*******************************

.MODEL small
.STACK 512d

.DATA
  a DW -9d 
  b DB 2d
  x DB 0, '$'

.CODE
   MOV   AX, @DATA
   MOV   DS, AX

   MOV   AX, a
   MOV   BL, b
   IDIV  BL

   MOV   x, AL
   SUB   BX, BX
   MOV   BL, x

   MOV   AH, 02h
   MOV   DL, BL
   MOV   CL, 04h
   SHR   DL, CL
   ADD   DL, 030h
   CMP   DL, 039h
   JLE   valor1
   ADD   DL, 07h

valor1:
   INT   021h

   MOV   DL, BL
   AND   DL, 0Fh
   ADD   DL, 030h
   CMP   DL, 039h
   JLE   valor2
   ADD   DL, 07h

valor2:
   INT   021h

   MOV   AH, 04Ch
   INT   021h
