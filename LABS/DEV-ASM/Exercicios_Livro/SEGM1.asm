#make_COM#

; COM file is loaded at CS:0100h
ORG 100h

;***************************
;*   Programa: SEGM1.ASM   *
;***************************

.MODEL small
.STACK 512d

.DATA
  mensagem DB 'Ola, Mundo$'

.CODE
  LEA DX, mensagem
  MOV AH, 09h
  INT 21h
  INT 20h
