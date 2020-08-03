;---------------------------------;
; Subroutines for screen text I/O ;
;---------------------------------;

; FUNCTION: CLEARS THE SCREEN
; IN:  NONE
; OUT: NONE, ALL REGS ARE SAVED
CLRSCR  PROC NEAR
        PUSH    ES
        PUSHAD
        MOV     AX, TEXT_DESC
        MOV     ES, AX
        XOR     EDI, EDI
        MOV     ECX, 80*25
        MOV     AX, 700H;1B00H
        REP     STOSW
        POPAD
        POP     ES
        RET
CLRSCR  ENDP

; FUNCTION: PRINTS THE EAX VALUE TO THE SCREEN
; IN:  EAX = 32-BIT VALUE, EDI = SCREEN OFFSET
; OUT: NONE, ALL REGS ARE SAVED
W_EAX   PROC NEAR
        @PUSH    <DS,ES>
        PUSHAD
        MOV     DX, DS_DESC
        MOV     DS, DX
        MOV     DX, TEXT_DESC
        MOV     ES, DX
        MOV     ECX, 8
        LEA     ESI, HEX_TAB
W_EAX_1:
        ROL     EAX, 4
        MOVZX   EBX, AL
        AND     BL, 0FH
        MOV     BL, DS:[ESI+EBX]
        MOV     ES:[EDI], BL
        ADD     EDI, 2
        LOOP    W_EAX_1
        POPAD
        @POP    <ES,DS>
        RET
W_EAX   ENDP

; FUNCTION: PRINTS ASCIIZ STRING TO THE SCREEN
; IN:  DS:ESI -> STRING, EDI = SCREEN OFFSET
; OUT: NONE, ALL REGS ARE SAVED
W_ASCIIZ PROC NEAR
        PUSH    ES
        PUSHAD
        MOV     AX, TEXT_DESC
        MOV     ES, AX
W_ASCIIZ_1:
        LODSB
        OR      AL, AL
        JZ      W_ASCIIZ_2
        STOSB
        INC     EDI
        JMP     W_ASCIIZ_1
W_ASCIIZ_2:
        POPAD
        POP     ES
        RET
W_ASCIIZ ENDP
