;--------------------------------;
; Sets Real Mode using CPU reset ;
; Works perfectly. :))           ;
;--------------------------------;

        MOV     ESP32, ESP
        MOV     AX, BIOS_DESC
        MOV     ES, AX
        MOV     WORD PTR ES:[067H], OFFSET SHUTDOWN_RET
        MOV     WORD PTR ES:[069H], CODE16
        MOV     AL, 5
        OUT     PORT_CMOS+1, AL

;        MOV     AL, SHUT_DOWN
;        OUT     PORT_STATUS, AL
;START_RESET:
;        HLT
;        JMP     START_RESET
        LIDT    [DUMMY_IDT]
        INT     0

SHUTDOWN_RET    LABEL FAR
        MOV     AX, DATA
        MOV     DS, AX
        MOV     ES, AX
        MOV     AX, SSTACK
        MOV     SS, AX
        MOV     ESP, ESP32
        XOR     AX, AX
        MOV     FS, AX
        MOV     GS, AX
