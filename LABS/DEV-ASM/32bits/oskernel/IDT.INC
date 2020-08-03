;-----------;
; IDT Table ;
;-----------;

IDTR    R_IDTR  <SIZE_IDT,0,0>
DUMMY_IDT       DF 0

IDT     LABEL           WORD
IDT_BEGIN       =       $
IRPC            N, 0123456789ABCDEF
        IDT_0&N         I_DESC <0, CS32_DESC, 0, ACS_TRAP, 0>   ; 00...0F
ENDM
IRPC            N, 0123456789ABCDEF
        IDT_1&N         I_DESC <0, CS32_DESC, 0, ACS_TRAP, 0>   ; 10...1F
ENDM
        IDT_TIMER       I_DESC <0, CS32_DESC, 0, ACS_INT, 0>    ; 20
        IDT_KEYBOARD    I_DESC <0, CS32_DESC, 0, ACS_INT, 0>    ; 21
IRPC            N, 23456789ABCDEF
        IDT_2&N         I_DESC <0, CS32_DESC, 0, ACS_INT, 0>    ; 22...2F
ENDM
        IDT_SERVICE     I_DESC <0, CS32_DESC, 0, ACS_TRAP+ACS_DPL_3, 0>   ; 30
SIZE_IDT        =       ($ - IDT_BEGIN)
