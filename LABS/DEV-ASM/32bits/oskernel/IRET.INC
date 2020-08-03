;-------------------------------------;
; Dummy IRets for hardware interrupts ;
;-------------------------------------;

DUMMY_IRET0 PROC NEAR
        PUSH    EAX
        MOV     AL, EOI
        OUT     PORT_8259M, AL
        POP     EAX
        IRETD
DUMMY_IRET0 ENDP

DUMMY_IRET1 PROC NEAR
        PUSH    EAX
        MOV     AL, EOI
        OUT     PORT_8259M, AL
        OUT     PORT_8259S, AL
        POP     EAX
        IRETD
DUMMY_IRET1 ENDP
