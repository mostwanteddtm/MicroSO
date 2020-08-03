#make_COM#

; COM file is loaded at CS:0100h
ORG 100h

;*****************************
;*    Programa: MEMO1.ASM    *
;*****************************

.MODEL small
.STACK 512d

.CODE

  MOV    AL, 5d
  MOV    DS:[010Ch], AL
  
  SUB    AX, AX
  MOV    AL, DS:[010Ch]

  HLT
  
END
