;----------------------------------;
; SERVICE SOFTWARE INTERRUPT (30H) ;
;----------------------------------;

SERVICE_INTERRUPT PROC NEAR
        PUSHAD
        AND     EBX, 0FF00H                     ; BH = FUNCTION CODE
        SHR     EBX, 8
        CMP     EBX, 3
        JNC     SERV_INT_END                    ; ONLY 3 FUNCTIONS AVAILABLE
        SHL     EBX, 2                          ; ADDRESS OFFSET TABLE
        CALL    DWORD PTR CS:[FUNC_TAB+EBX]
SERV_INT_END:
        POPAD
        IRETD

F_00 LABEL NEAR
        JMP     CLRSCR                          ; CLEAR SCREEN

F_01 LABEL NEAR
        JMP     W_ASCIIZ                        ; OUT ASCIIZ STRING

F_02 LABEL NEAR
        JMP     W_EAX                           ; OUT 32-BIT EAX AS HEX

FUNC_TAB LABEL DWORD
        DD      F_00, F_01, F_02
SERVICE_INTERRUPT ENDP
