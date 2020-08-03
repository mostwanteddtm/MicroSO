.MODEL SMALL
.386

outpdw  PROTO C PORT:WORD, WRCMD:DWORD

.CODE

    outpdw PROC C PORT:WORD, WRCMD:DWORD

        MOV     DX, WORD PTR PORT
        MOV     EAX, DWORD PTR WRCMD
        OUT     DX, EAX
        RET

    outpdw ENDP

END