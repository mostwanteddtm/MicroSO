;Program BOOTSEC.ASM: Display contents of disk A's boot sector (with ASCII).
;E mostra mensagesn de erro de acordo com o valor de AH.

PILHA           SEGMENT PARA STACK 'STACK'

                DW  100 DUP(?)

                TOP_PILHA LABEL WORD        
PILHA           ENDS


DADOS           SEGMENT PARA 'DATA'

BMSG    DB    'Boot sector for diskette in drive A:',0DH,0AH,0DH,0AH,'$'
EMSG1   DB    'Error! Can not reset diskette system.',0DH,0AH,'$'
EMSG2   DB    'Error! Can not read boot sector.',0DH,0AH,'$'


ERR01	DB  'funcao invalida $'
ERR02	DB  'adress mark nao encontrado $'
ERR03	DB  'tentativa de escrita em disco protegido $'
ERR04	DB  'setor nao encontrado $'
ERR08	DB  'falha no controlador de DMA $'
ERR09	DB  'buffer estourou fronteira $'
ERR10	DB  'setor com erro $'
ERR20	DB  'falha no controlador de disco $'
ERR40	DB  'trilha nao encontrada $'
ERR80	DB  'timeout $'

BLANK   DB    ' $'
PRESS   DB    0DH,0AH,'Press any key for next 256 bytes...'
CRLF    DB    0DH,0AH,'$'
DBUF    DB    512 DUP(0)

DADOS ENDS

CODIGO          SEGMENT PARA 'CODE'
                ASSUME CS:CODIGO,SS:PILHA,DS:DADOS,ES:DADOS

INICIO          PROC   FAR
                 
                MOV    AX,DADOS
                MOV    DS,AX 
		MOV    ES,AX             ;INICIALIZA REGISTROS DE SEGMENTO.    

        MOV   AX,DS
        MOV   ES,AX       ;set up extra segment
        MOV   AH,0        ;reset disk function
        MOV   DL,0        ;drive A
        INT   13H         ;BIOS call
        JNC   OK
        call verificaerro

OK:     CALL  READ        ;read boot sector, first try
        JNC   OBM
        CALL  READ        ;read boot sector, second try
        JNC   OBM
        CALL  READ        ;read boot sector, last try
        JNC   OBM

        JMP   verificaerro         ;go process error

OBM:    LEA   DX,BMSG     ;set up pointer to boot message
        MOV   AH,9        ;display string function
        INT   21H         ;DOS call
        SUB   SI,SI       ;clear index pointer
        CALL  SHOWDTA     ;show first half of DTA
        LEA   DX,PRESS    ;set up pointer to press message
        MOV   AH,9        ;display string function
        INT   21H         ;DOS call
        MOV   AH,1        ;read keyboard function
        INT   21H         ;DOS call
        LEA   DX,CRLF     ;set up pointer to crlf string
        MOV   AH,9        ;display string function
        INT   21H         ;DOS call
        CALL  SHOWDTA     ;show second half of DTA
        
        .exit

verificaerro proc near

        cmp ah, 01
        je erro1
        cmp ah, 02
        je erro2
        cmp ah, 03
        je erro3
        cmp ah, 04
        je erro4
        cmp ah, 08
        je erro8
        cmp ah, 09
        je erro9
        cmp ah, 10
        je erro10
        cmp ah, 20
        je erro20
        cmp ah, 40
        je erro40
        cmp ah, 80
        je erro80
        
verificaerro endp
        
erro1:  LEA   DX, ERR01 ;set up pointer to error message        
        MOV   AH,9        ;display string function
        INT   21H         ;DOS call
        JMP   EXIT
        
erro2:  LEA   DX, ERR02 ;set up pointer to error message        
        MOV   AH,9        ;display string function
        INT   21H         ;DOS call
        JMP   EXIT
        
erro3:  LEA   DX, ERR03 ;set up pointer to error message        
        MOV   AH,9        ;display string function
        INT   21H         ;DOS call
        JMP   EXIT

erro4:  LEA   DX, ERR04 ;set up pointer to error message        
        MOV   AH,9        ;display string function
        INT   21H         ;DOS call
        JMP   EXIT

erro8:  LEA   DX, ERR08 ;set up pointer to error message        
        MOV   AH,9        ;display string function
        INT   21H         ;DOS call
        JMP   EXIT

erro9:  LEA   DX, ERR09 ;set up pointer to error message        
        MOV   AH,9        ;display string function
        INT   21H         ;DOS call
        JMP   EXIT

erro10:  LEA   DX, ERR10 ;set up pointer to error message        
        MOV   AH,9        ;display string function
        INT   21H         ;DOS call
        JMP   EXIT

erro20:  LEA   DX, ERR20 ;set up pointer to error message        
        MOV   AH,9        ;display string function
        INT   21H         ;DOS call
        JMP   EXIT

erro40:  LEA   DX, ERR40 ;set up pointer to error message        
        MOV   AH,9        ;display string function
        INT   21H         ;DOS call
        JMP   EXIT

erro80:  LEA   DX, ERR80 ;set up pointer to error message        
        MOV   AH,9        ;display string function
        INT   21H         ;DOS call
        JMP   EXIT

EXIT:   MOV AH,4CH
        INT 21H

READ    PROC  NEAR
        LEA   BX,DBUF     ;set of pointer to DTA
        MOV   AH,2        ;read disk sectors function
        MOV   AL,1        ;read one sector
        MOV   DL,0        ;from drive A
        MOV   DH,0        ;head 0
        MOV   CX,1        ;sector 1
        INT   13H         ;BIOS call
        RET
READ    ENDP

SHOWDTA PROC  NEAR
        MOV   CX,16       ;load line counter
NLYN:   PUSH  CX          ;save line counter
        MOV   AX,SI       ;load pointer address
        CALL  DISPHEX2    ;output hex address
        MOV   DL,':'      ;load colon
        MOV   AH,2        ;display character function
        INT   21H         ;DOS call
        MOV   CX,16       ;load byte counter
NBYT:   LEA   DX,BLANK    ;set up pointer to blank string
        MOV   AH,9        ;display string function
        INT   21H         ;DOS call
        MOV   AL,ES:DBUF[SI] ;get next byte
        CALL  DISPHEX     ;output it
        INC   SI          ;advance pointer
        LOOP  NBYT        ;repeat for next byte
        CALL  SHOWASC     ;output ASCII equivalents
        LEA   DX,CRLF     ;set up pointer to crlf string
        MOV   AH,9        ;display string function
        INT   21H         ;DOS call
        POP   CX          ;get line counter back
        LOOP  NLYN        ;and repeat until done
        RET
SHOWDTA ENDP

SHOWASC  PROC  NEAR
         LEA   DX,BLANK    ;set up pointer to blank string
         MOV   AH,9        ;display string function
         INT   21H         ;DOS call
         LEA   DX,BLANK    ;set up pointer to blank string
         MOV   AH,9        ;display string function
         INT   21H         ;DOS call
         SUB   SI,16       ;adjust pointer
         PUSH  CX          ;save current counter
         MOV   CX,16       ;load character counter
GCHR:    MOV   DL,ES:DBUF[SI]  ;get next byte
         INC   SI          ;advance pointer
         AND   DL,7FH      ;convert to 7-bit ASCII
         CMP   DL,20H      ;is it printable?
         JC    BLNK        ;no, go output a blank
         CMP   AL,80H      ;is it still printable?
         JNC   BLNK
AOUT:    MOV   AH,2        ;display character function
         INT   21H         ;DOS call
         LOOP  GCHR        ;repeat until done
         POP   CX          ;get counter back
         RET
BLNK:    MOV   DL,20H      ;load blank character
         JMP   AOUT
SHOWASC  ENDP


DISPHEX PROC NEAR
        PUSH AX           ;save number
        SHR  AL,1         ;shift upper nybble down
        SHR  AL,1
        SHR  AL,1
        SHR  AL,1
        CMP  AL,10        ;is nybble value less than 10?
        JC   NHA1         ;yes, go convert and display
        ADD  AL,7         ;add alpha bias
NHA1:   ADD  AL,30H       ;add ASCII bias
        MOV  DL,AL        ;load character
        MOV  AH,2         ;display character function
        INT  21H          ;DOS call
        POP  AX           ;get number back
        AND  AL,0FH       ;work with lower nybble
        CMP  AL,10        ;is it less than 10?
        JC   NHA2         ;yes, go convert and display
        ADD  AL,7         ;add alpha bias
NHA2:   ADD  AL,30H       ;add ASCII bias
        MOV  DL,AL        ;load character
        MOV  AH,2         ;display character function
        INT  21H          ;DOS call
        RET
DISPHEX ENDP

DISPHEX2 PROC  NEAR
         PUSH  AX         ;save number
         XCHG  AH,AL      ;get upper byte
         CALL  DISPHEX    ;output it
         POP   AX         ;get number back
         CALL  DISPHEX    ;output lower byte
         RET
DISPHEX2 ENDP

CODIGO ENDS

         END INICIO

