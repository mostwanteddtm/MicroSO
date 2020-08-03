#make_COM#

; COM file is loaded at CS:0100h
ORG 100h

;*******************************
;*     Programa: LACO1.ASM     *
;*******************************

.MODEL small
.STACK 512d

.DATA
  msg DB 'Alo Mundo!', 13d, 12o, 24h

.CODE
  LEA   DX, msg
  MOV   CX, 5d
  MOV   AH, 09h
  laco:
    INT   021h
    LOOP  laco
  INT 20h
