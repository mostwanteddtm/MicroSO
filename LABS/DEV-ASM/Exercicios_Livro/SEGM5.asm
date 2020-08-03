TITLE   Teste de Segmento 5

#MAKE_EXE#

INCLUDE 'biblio.inc'

DADOS  SEGMENT 'DATA'
         msg0 DB "Tecle algo para prosseguir", 0Dh, 0Ah, 024h
         msg1 DB "Ola, Mundo 1", 0Dh, 0Ah, 024h
         msg2 DB "Ola, Mundo 2", 0Dh, 0Ah, 024h
         msg3 DB "Ola, Mundo 3", 0Dh, 0Ah, 024h
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
    ESCREVA
    MOV     DX, OFFSET msg0
    ESCREVA
    TECLE
    
    POSICAO 03, 05
    MOV     DX, OFFSET msg2
    ESCREVA
    MOV     DX, OFFSET msg0
    ESCREVA
    TECLE
    
    MOV     DX, OFFSET msg3
    ESCREVA
    MOV     DX, OFFSET msg0
    ESCREVA
    CURSORG
    TECLE
    CURSORP

    MOV     AH, 04Ch
    INT     021h
    RET
  INICIO ENDP
CODIGO ENDS 
END INICIO
