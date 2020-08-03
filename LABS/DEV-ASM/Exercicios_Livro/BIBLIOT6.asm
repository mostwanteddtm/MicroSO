#make_COM#

; COM file is loaded at CS:0100h
ORG 100h

;********************************
;*    Programa: BIBLIOT6.ASM    *
;********************************

INCLUDE 'emu8086.inc'

.MODEL small
.STACK 512d


.DATA
  tamanho  EQU 30d + 1d
  buffer   DB  tamanho DUP ('x')
  msg1     DB  'Entre seu nome: ', 0
  msg2     DB  'Ola, ', 0


.CODE
  LEA     SI, msg1
  CALL    PRINT_STRING

  LEA     DI, buffer
  MOV     DX, tamanho
  CALL    GET_STRING
  PUTC    13d
  PUTC    10d 

  LEA     SI, msg2
  CALL    PRINT_STRING

  MOV     SI, DI
  CALL    PRINT_STRING

  INT     020h

  DEFINE_PRINT_STRING
  DEFINE_GET_STRING
END
