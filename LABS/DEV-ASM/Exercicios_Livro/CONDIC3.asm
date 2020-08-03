#make_COM#

; COM file is loaded at CS:0100h
ORG 100h

;*******************************
;*    Programa: CONDIC3.ASM    *
;*******************************

.MODEL small
.STACK 512d

.DATA
  msg1 DB 'Entre um valor numerico positivo (de 0 ate 9): ', 024h
  msg2 DB 0Dh, 0Ah, 'Valor impar', 024h
  msg3 DB 0Dh, 0Ah, 'Valor par', 024h
  msg4 DB 0Dh, 0Ah, 'Caractere invalido', 024h
  
.CODE
  LEA   DX, msg1
  CALL  escreva

  MOV   AH, 01h
  INT   021h

  CMP   AL, 030h
  JL    erro

  CMP   AL, 03Ah
  JGE   erro

  SUB   AL, 030h  
  AND   AL, 01h
  JPE   par
  JPO   impar

  par:
    LEA   DX, msg3
    CALL  escreva
    JMP   saida
      
  impar: 
    LEA   DX, msg2
    CALL  escreva
    JMP   saida

  erro:
    LEA   DX, msg4
    CALL  escreva
    JMP   saida

  saida:
    INT 020h

escreva PROC NEAR
  MOV   AH, 09h
  INT   021h
  RET
escreva ENDP
