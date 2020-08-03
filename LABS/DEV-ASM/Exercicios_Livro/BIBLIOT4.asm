#make_COM#

; COM file is loaded at CS:0100h
ORG 100h

;********************************
;*    Programa: BIBLIOT4.ASM    *
;********************************

INCLUDE 'emu8086.inc'

.MODEL small
.STACK 512d


.CODE

  PRINTN       'Alo Mundo 1'
  PRINTN       'Alo Mundo 2'
  PRINT        'Alo Mundo 3'
  PRINT        'Alo Mundo 4'
  INT        020h

END
