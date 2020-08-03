;-----------;
; Fills GDT ;
;-----------;

        MOV     AX, DATA
        MOV     DL, AH
        XOR     DH, DH
        SHL     AX, 4
        SHR     DX, 4
        MOV     SI, AX
        MOV     DI, DX

; GDT GOES HERE

        LEA     BX, GDT_GDT
        MOV     AX, SI
        MOV     DX, DI
        ADD     AX, OFFSET GDT
        ADC     DX, 0
        @SET_GDT_ENTRY

; 16-BIT REAL/PROTECTED MODE MAIN TASK CODE GOES HERE

        LEA     BX, GDT_CS16
        MOV     AX, CS
        XOR     DH, DH
        MOV     DL, AH
        SHL     AX, 4
        SHR     DX, 4
        @SET_GDT_ENTRY

; COMMON DATA SEGMENT GOES HERE

        LEA     BX, GDT_DS
        MOV     AX, SI
        MOV     DX, DI
        @SET_GDT_ENTRY

; STACK FOR 16/32 REAL/PROTECTED MODE MAIN TASK GOES HERE

        LEA     BX, GDT_SS
        MOV     AX, SS
        XOR     DH, DH
        MOV     DL, AH
        SHL     AX, 4
        SHR     DX, 4
        @SET_GDT_ENTRY

; 32-BIT PROTECTED MODE MAIN TASK CODE GOES HERE

        LEA     BX, GDT_CS32
        MOV     AX, CODE32
        XOR     DH, DH
        MOV     DL, AH
        SHL     AX, 4
        SHR     DX, 4
        @SET_GDT_ENTRY
        OR      [BX][S_DESC.ATTRIBS], 40H            ; 32-BIT STUFF

; IDT GOES HERE

        LEA     BX, GDT_IDT
        MOV     AX, SI
        MOV     DX, DI
        ADD     AX, OFFSET IDT
        ADC     DX, 0
        @SET_GDT_ENTRY
        MOV     IDTR.IDT_L, AX
        MOV     IDTR.IDT_H, DX

; TASKS' CODES GO HERE

        LEA     BX, GDT_CS_0
        MOV     AX, CODE_0
        XOR     DH, DH
        MOV     DL, AH
        SHL     AX, 4
        SHR     DX, 4
        @SET_GDT_ENTRY
        OR      [BX][S_DESC.ATTRIBS], 40H            ; 32-BIT STUFF

        LEA     BX, GDT_CS_1
        MOV     AX, CODE_1
        XOR     DH, DH
        MOV     DL, AH
        SHL     AX, 4
        SHR     DX, 4
        @SET_GDT_ENTRY
        OR      [BX][S_DESC.ATTRIBS], 40H            ; 32-BIT STUFF

; TASKS' STACKS GO HERE

        LEA     BX, GDT_SS_0
        MOV     AX, STCK_0
        XOR     DH, DH
        MOV     DL, AH
        SHL     AX, 4
        SHR     DX, 4
        @SET_GDT_ENTRY

        LEA     BX, GDT_SS_1
        MOV     AX, STCK_1
        XOR     DH, DH
        MOV     DL, AH
        SHL     AX, 4
        SHR     DX, 4
        @SET_GDT_ENTRY

; TSSs GO HERE

        LEA     BX, GDT_TSS_MAIN
        MOV     AX, SI
        MOV     DX, DI
        ADD     AX, OFFSET TSS_MAIN
        ADC     DX, 0
        @SET_GDT_ENTRY

        LEA     BX, GDT_TSS_0
        MOV     AX, SI
        MOV     DX, DI
        ADD     AX, OFFSET TSS_0
        ADC     DX, 0
        @SET_GDT_ENTRY

        LEA     BX, GDT_TSS_1
        MOV     AX, SI
        MOV     DX, DI
        ADD     AX, OFFSET TSS_1
        ADC     DX, 0
        @SET_GDT_ENTRY
