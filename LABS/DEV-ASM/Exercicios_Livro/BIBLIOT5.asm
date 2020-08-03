#make_COM#

; COM file is loaded at CS:0100h
ORG 100h

;********************************
;*    Programa: BIBLIOT5.ASM    *
;********************************

INCLUDE 'emu8086.inc'

.MODEL small
.STACK 512d


.CODE

  CURSOROFF
  PRINTN       'Sem cursor - tecle algo'

  MOV        AH, 00h
  INT        016h

  CURSORON
  PRINTN       'Com Cursor - tecle algo'

  MOV        AH, 00h
  INT        016h

  INT        020h

END
