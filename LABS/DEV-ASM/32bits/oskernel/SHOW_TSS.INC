; IN: EAX = TSS OFFSET
SHOW_TSS PROC NEAR
        PUSH    DS
        PUSHAD
        MOV     EBX, EAX
        MOV     AX, DS_DESC
        MOV     DS, AX

        MOV     EDI, 10*80*2
        LEA     ESI, MSG_TSS
        LEA     EDX, OFFS_TSS
        MOV     ECX, 13
SHOW_TSS_CYCLE:
        CALL    W_ASCIIZ
        ADD     ESI, 32

        ADD     EBX, DS:[EDX]
        MOV     EAX, DS:[EBX]
        SUB     EBX, DS:[EDX]
        ADD     EDI, 7*2
        CALL    W_EAX
        ADD     EDX, 4

        ADD     EBX, DS:[EDX]
        MOV     EAX, DS:[EBX]
        SUB     EBX, DS:[EDX]
        ADD     EDI, 16*2
        CALL    W_EAX
        ADD     EDX, 4

        ADD     EDI, (80-7-16)*2
        LOOP    SHOW_TSS_CYCLE
        POPAD
        POP     DS
        RET
SHOW_TSS ENDP
