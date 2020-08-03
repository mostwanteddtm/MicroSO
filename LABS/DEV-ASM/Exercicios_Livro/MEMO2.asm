#make_COM#

; COM file is loaded at CS:0100h
ORG 100h

;*****************************
;*    Programa: MEMO2.ASM    *
;*****************************

.MODEL small
.STACK 512d

.DATA
  valor DB 05d, 04d, 03d, 02d, 01d

.CODE

  MOV   CX, 05h
  LEA   BX, valor
  laco:
    MOV   AL, [BX]
    ADD   AL, 030h
    MOV   AH, 0Eh
    INT   010h     
    INC   BX
  LOOP  laco  
  HLT

END
