#make_COM#

; COM file is loaded at CS:0100h
ORG 100h

;*******************************
;*    Programa: CONDIC4.ASM    *
;*******************************

.MODEL small
.STACK 512d

.DATA
  msg1 DB 'Entre valor decimal 1 (de 0 ate 9): ', 024h
  msg2 DB 0Dh, 0Ah, 'Entre valor decimal 2 (de 0 ate 9): ', 024h
  msg3 DB 0Dh, 0Ah, 'Soma = ', 024h
  msg4 DB 0Dh, 0Ah, 'Caractere invalido', 024h

.CODE
  LEA   DX, msg1
  CALL  escreva
  CALL  leia
  MOV   BH, AL

  LEA   DX, msg2
  CALL  escreva
  CALL  leia
  MOV   BL, AL

  LEA   DX, msg3 
  CALL  escreva
  XCHG  AX, BX

  ADD   AL, AH
  SUB   AH, AH
  AAA
  MOV   DX, AX
  MOV   AH, 0Eh
  CMP   DH, 0h
  JE    nao_zero
  OR    DH, 30h
  MOV   AL, DH
  INT   010h
  nao_zero:
  OR    DL, 30h
  MOV   AL, DL
  INT   010h
  INT   020h

escreva PROC NEAR
  MOV   AH, 09h
  INT   021h
  RET
escreva ENDP

leia PROC NEAR
  MOV   AH, 01h
  INT   021h
  CMP   AL, 030h
  JL    erro
  CMP   AL, 03Ah
  JGE   erro
  SUB   AL, 030h  
  RET
  erro:
    LEA   DX, msg4
    CALL  escreva
    INT   020h
  RET
leia ENDP
