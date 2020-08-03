;----------------------;
; Exception handler(s) ;
;----------------------;

M       =       0
IRPC            N, 0123456789ABCDEF
EXC_0&N LABEL WORD
        CLI
        PUSH            EBP
        MOV             EBP, ESP
        PUSHAD
        MOV             EAX, M
        M       =       M+1
        JMP             EXC_HANDLER
ENDM

M       =       010H
IRPC            N, 0123456789ABCDEF
EXC_1&N LABEL WORD
        CLI
        PUSH            EBP
        MOV             EBP, ESP
        PUSHAD
        MOV             EAX, M
        M       =       M+1
        JMP             EXC_HANDLER
ENDM

EXC_HANDLER     PROC    NEAR
        PUSH    DS

        MOV     BX, DS_DESC
        MOV     DS, BX

;        CALL    CLRSCR
        LEA     ESI, MSG_EXC
        MOV     EDI, 40*2
        CALL    W_ASCIIZ                        ; "EXCEPTION: "
        ADD     EDI, 11*2
        CALL    W_EAX                           ; EXCEPTION NUMBER
        SUB     EDI, 11*2

        MOV     EBX, EBP
        ADD     EBX, 4                          ; EBX = ^CS:EIP

        MOVZX   EAX, BYTE PTR DS:[EXC_ERR+EAX]
        OR      EAX, EAX
        JZ      EXC_HANDLER_NO_ERR_CODE         ; THE EXCEPTION HAS NO ERROR CODE

        ADD     EBX, 4                          ; CORRECT EBX

        LEA     ESI, MSG_EXC_ERR
        ADD     EDI, 80*2
        CALL    W_ASCIIZ                        ; "ERROR CODE: "

        MOV     EAX, SS:[EBP+4]
        AND     EAX, 0FFFFH
        ADD     EDI, 12*2
        CALL    W_EAX
        SUB     EDI, 12*2
        SUB     EDI, 80*2

EXC_HANDLER_NO_ERR_CODE:
        LEA     ESI, MSG_CSEIP
        ADD     EDI, 2*80*2
        CALL    W_ASCIIZ                        ; "CS=XXXXXXXX EIP=XXXXXXXX"
        ADD     EDI, 3*2
        MOVZX   EAX, WORD PTR SS:[EBX+4]
        CALL    W_EAX                           ; CS
        ADD     EDI, 13*2
        MOV     EAX, SS:[EBX]
        CALL    W_EAX                           ; EIP
        SUB     EDI, (3+13)*2

;        jmp     $                               ; INFINITE LOOP

        MOV     AX, SS_DESC
        MOV     SS, AX
        MOV     ESP, DS:[ESP32]
        @RETF

        IRETD
EXC_HANDLER     ENDP
