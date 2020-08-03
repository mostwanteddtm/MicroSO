TITLE   Teste de Segmento 6

#MAKE_EXE#

DADOS  SEGMENT 'DATA'
  msg1 DB 'Entre valor 1 (de 0 a 9) .....: ', 024h
  msg2 DB 0Dh, 0Ah, 'Entre valor 2 (de 0 a 9) .....: ', 024h
  msg3 DB 0Dh, 0Ah, 'Resultado ....................: ', 024h
  msg4 DB 0Dh, 0Ah, 'Valor invalido', 024h
DADOS  ENDS


PILHA  SEGMENT STACK 'STACK'
  DW 0100h DUP(?)
PILHA  ENDS


CODIGO SEGMENT 'CODE'
  INICIO PROC FAR
    MOV     AX, DADOS
    MOV     DS, AX
    MOV     ES, AX

    MOV     DX, OFFSET msg1
    MSG
    CALL    entrada
    MOV     BH, AL

    MOV     DX, OFFSET msg2
    MSG
    CALL    entrada
    MOV     BL, AL

    MOV     DX, OFFSET msg3
    MSG
    SUB     BH, BL
    JS      negativo
    JGE     positivo
    
    negativo:
    NEG     BH
    MOV     AL, 02Dh ; - 
    MOV     AH, 0Eh
    INT     010h
    JMP     mostra
    
    positivo:
    JMP     mostra
    
    mostra:
    MOV     AL, BH
    MOV     DL, AL
    ADD     AL, 030h  
    MOV     AH, 0Eh
    INT     010h
    FIM
    RET
  INICIO ENDP
CODIGO ENDS 

  fim  MACRO
    MOV     AH, 04Ch
    INT     021h
  ENDM

  msg  MACRO
    MOV     AH, 09h
    INT     021h
  ENDM

  entrada PROC NEAR
    MOV     AH, 01h
    INT     021h
    CMP     AL, 030h
    JL      erro
    CMP     AL, 040h
    JGE     erro
    JMP     fim_validacao
    erro:
      LEA     DX, msg4
      MSG
      FIM
    fim_validacao:
    SUB     AL, 030h
    RET  
  entrada ENDP

END INICIO