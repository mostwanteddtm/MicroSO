ESCREVA  MACRO 
  PUSH  AX
  MOV   AH, 09h
  INT   021h     
  POP   AX
ENDM

POSICAO  MACRO linha, coluna
  PUSH  AX
  PUSH  DX
  MOV   AH, linha
  MOV   AL, coluna
  DEC   AH
  DEC   AL
  MOV   DX, AX
  MOV   AH, 02h
  INT   010h    
  POP   DX
  POP   AX
ENDM

TECLE  MACRO
  PUSH  AX
  MOV   AH, 0h
  INT   016h
  POP   AX
ENDM

CURSORG  MACRO
  PUSH  AX
  PUSH  CX
  MOV   AX, 0100h
  MOV   CX, 000Ah
  INT   010h
  POP   CX
  POP   AX
ENDM

CURSORP  MACRO
  PUSH  AX
  PUSH  CX
  MOV   AX, 0100h
  MOV   CX, 0506h
  INT   010h
  POP   AX
  POP   CX
ENDM
