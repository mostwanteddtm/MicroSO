#make_COM#

; COM file is loaded at CS:0100h
ORG 100h

;*******************************
;*   Programa: MENSAGEM4.ASM   *
;*******************************

.MODEL small
.STACK 512d

.DATA
  mensagem1 DB 'Mensagem 1', 0Dh, 0Ah, 024h
  mensagem2 DB 'Mensagem 2', 0Dh, 0Ah, 024h
  mensagem3 DB 'Mensagem 3', 0Dh, 0Ah, 024h

.CODE
  JMP   salto3

  salto1: 
    LEA   DX, mensagem1
    CALL  escreva
    JMP   saida

  salto2:
    LEA   DX, mensagem2
    CALL  escreva
    JMP   salto1

  salto3: 
    LEA   DX, mensagem3
    CALL  escreva
    JMP   salto2

  saida:
    INT 020h

  escreva PROC NEAR
    MOV   AH, 09h
    INT   021h
    RET
  escreva ENDP
