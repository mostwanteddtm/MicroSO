;-------------------------------------;
; Keyboard hardware interrupt handler ;
;-------------------------------------;

KEYBOARD_HANDLER PROC NEAR
        @PUSH   <DS, EAX>
        MOV     AX, DS_DESC
        MOV     DS, AX

        IN      AL, PORT_KBD_A
        MOV     AH, AL
        AND     AL, 07FH

        MOV     DS:[KEY_SCAN_CODE], AL

;        IN      AL, PORT_KBD_B                  ; ³       0
;        OR      AL, 080H                        ; ³
;        OUT     PORT_KBD_B, AL                  ; ÀÄÄÄÄ¿
;        IN      AL, PORT_KBD_B                  ;      ³  1
;        AND     AL, 07FH                        ;      ³
;        OUT     PORT_KBD_B, AL                  ; ÚÄÄÄÄÙ
;                                                ; ³       0
        MOV     AL, EOI
        OUT     PORT_8259M, AL
        @POP    <EAX, DS>
        IRETD
KEYBOARD_HANDLER ENDP
