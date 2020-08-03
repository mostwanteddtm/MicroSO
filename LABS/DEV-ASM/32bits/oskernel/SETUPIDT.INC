;-----------;
; Fills IDT ;
;-----------;

IRPC            N, 0123456789ABCDEF                     ; 00...0F
        LEA     EAX, EXC_0&N
        MOV     IDT_0&N.OFFS_L, AX
        SHR     EAX, 16
        MOV     IDT_0&N.OFFS_H, AX
ENDM
IRPC            N, 0123456789ABCDEF                     ; 10...1F
        LEA     EAX, EXC_1&N
        MOV     IDT_1&N.OFFS_L, AX
        SHR     EAX, 16
        MOV     IDT_1&N.OFFS_H, AX
ENDM

        LEA     EAX, TIMER_HANDLER                      ; 20
        MOV     IDT_TIMER.OFFS_L, AX
        SHR     EAX, 16
        MOV     IDT_TIMER.OFFS_H, AX

        LEA     EAX, KEYBOARD_HANDLER                   ; 21
        MOV     IDT_KEYBOARD.OFFS_L, AX
        SHR     EAX, 16
        MOV     IDT_KEYBOARD.OFFS_H, AX

IRPC            N, 234567                               ; 22...27
        LEA     EAX, DUMMY_IRET0
        MOV     IDT_2&N.OFFS_L, AX
        SHR     EAX, 16
        MOV     IDT_2&N.OFFS_H, AX
ENDM
IRPC            N, 89ABCDEF                             ; 28...2F
        LEA     EAX, DUMMY_IRET1
        MOV     IDT_2&N.OFFS_L, AX
        SHR     EAX, 16
        MOV     IDT_2&N.OFFS_H, AX
ENDM

        LEA     EAX, SERVICE_INTERRUPT                  ; 30
        MOV     IDT_SERVICE.OFFS_L, AX
        SHR     EAX, 16
        MOV     IDT_SERVICE.OFFS_H, AX
