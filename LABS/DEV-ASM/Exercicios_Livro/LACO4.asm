#make_COM#

; COM file is loaded at CS:0100h
ORG 100h

;*******************************
;*     Programa: LACO4.ASM     *
;*******************************

.MODEL small
.STACK 512d

.DATA
  msg1 DB 'Entre valor decimal positivo (de 0 ate 8): ', 024h
  msg2 DB 0Dh, 0Ah, 'Fatorial de ', 024h
  msg3 DB ' equivale a ', 024h
  msg4 DB 0Dh, 0Ah, 'Valor invalido', 024h
  
.CODE
  msg   msg1
  CALL  entrada
  PUSH  AX

  msg   msg2
  POP   AX
  MOV   DL, AL
  MOV   AH, 0Eh
  INT   010h
  SUB   AL, 030h  
  MOV   CL, AL         

  msg   msg3
  CALL  fatorial
  CALL  valor

  fim:
    INT   020h

msg MACRO mensagem
      LEA   DX, mensagem
      MOV   AH, 09h
      INT   021h
    ENDM

entrada PROC NEAR
  MOV    AH, 01h
  INT    021h
  CMP    AL, 030h
  JL     erro
  CMP    AL, 039h
  JGE    erro
  JMP    fim_validacao
  erro:
    msg    msg4
    JMP    fim
  fim_validacao:  
  RET  
entrada ENDP

fatorial PROC NEAR
  MOV    AX, 01h
  CMP    CX, 0h
  JE     fim_laco
  repita1:
    MUL    CX
    LOOPNE repita1
  fim_laco:
  RET
fatorial ENDP

valor PROC NEAR
  PUSH   AX
  MOV    BX, 0Ah
  SUB    CX, CX
  repita2:
    SUB    DX, DX
    DIV    BX
    PUSH   DX
    INC    CX
    CMP    AX, 0h
    JNZ    repita2
  saida:
    POP    AX
    ADD    AL, 030h
    MOV    DL, AL
    MOV    AH, 0Eh
    INT    010h
    DEC    CX
    JNBE   saida
    POP    DX
  RET
valor ENDP
