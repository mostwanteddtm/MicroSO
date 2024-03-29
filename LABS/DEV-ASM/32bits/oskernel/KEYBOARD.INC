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

;        IN      AL, PORT_KBD_B                  ; �       0
;        OR      AL, 080H                        ; �
;        OUT     PORT_KBD_B, AL                  ; ����Ŀ
;        IN      AL, PORT_KBD_B                  ;      �  1
;        AND     AL, 07FH                        ;      �
;        OUT     PORT_KBD_B, AL                  ; ������
;                                                ; �       0
        MOV     AL, EOI
        OUT     PORT_8259M, AL
        @POP    <EAX, DS>
        IRETD
KEYBOARD_HANDLER ENDP
