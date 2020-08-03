;--------------------------------------------------------------------;
; Macroses that define useful structures, constants and other things ;
;--------------------------------------------------------------------;

; Pushes several registers to the stack
@PUSH   MACRO   REGLIST
        IRP     REG, <REGLIST>
                PUSH    REG
        ENDM
ENDM

; Popes several registers from the stack
@POP    MACRO   REGLIST
        IRP     REG, <REGLIST>
                POP     REG
        ENDM
ENDM

; Sets up GDT table entry
@SET_GDT_ENTRY  MACRO
        MOV             [BX][S_DESC.BASE_L], AX
        MOV             [BX][S_DESC.BASE_M], DL
        MOV             [BX][S_DESC.BASE_H], DH
ENDM

; Segment Descriptor structure
S_DESC  STRUC
        LIMIT           DW      0
        BASE_L          DW      0
        BASE_M          DB      0
        ACCESS          DB      0
        ATTRIBS         DB      0
        BASE_H          DB      0
S_DESC  ENDS

; Interrupt Descriptor structure
I_DESC  STRUC
        OFFS_L          DW      0
        SEL             DW      0
        PARAM_CNT       DB      0
        ACCESS          DB      0
        OFFS_H          DW      0
I_DESC  ENDS

; IDTR register structure
R_IDTR  STRUC
        LIMIT           DW      0
        IDT_L           DW      0
        IDT_H           DW      0
R_IDTR  ENDS

; Task State Segment structure
S_TSS   STRUC
        LINK            DW      0, 0    ;  0
        ESP0            DD      0       ;  4
        SS0             DW      0, 0    ;  8
        ESP1            DD      0       ; 0C
        SS1             DW      0, 0    ; 10
        ESP2            DD      0       ; 14
        SS2             DW      0, 0    ; 18
        R_CR3           DD      0       ; 1C
        R_EIP           DD      0       ; 20
        R_EFLAGS        DD      0       ; 24
        R_EAX           DD      0       ; 28
        R_ECX           DD      0       ; 2C
        R_EDX           DD      0       ; 30
        R_EBX           DD      0       ; 34
        R_ESP           DD      0       ; 38
        R_EBP           DD      0       ; 3C
        R_ESI           DD      0       ; 40
        R_EDI           DD      0       ; 44
        R_ES            DW      0, 0    ; 48
        R_CS            DW      0, 0    ; 4C
        R_SS            DW      0, 0    ; 50
        R_DS            DW      0, 0    ; 54
        R_FS            DW      0, 0    ; 58
        R_GS            DW      0, 0    ; 5C
        R_LDTR          DW      0, 0    ; 60
        TRACE           DW      0       ; 64
        IO_MAP_ADDR     DW      68H     ; 66
        IO_MAP          DB      (400H SHR 3) DUP (0) ; 400H PORTS AVAILABLE
S_TSS   ENDS

; DIFFERENT CONSTANTS AND FLAGS FOR PM
SIZE_TSS        EQU     68H + (400H SHR 3)

; Access byte's flags
ACS_PRESENT     EQU             10000000B
ACS_CSEG        EQU             00011000B
ACS_DSEG        EQU             00010000B
ACS_EXPDOWN     EQU             00000100B
ACS_CONFORM     EQU             00000100B
ACS_READ        EQU             00000010B
ACS_WRITE       EQU             00000010B

ACS_CODE        =               ACS_PRESENT OR ACS_CSEG; OR ACS_CONFORM
ACS_DATA        =               ACS_PRESENT OR ACS_DSEG OR ACS_WRITE
ACS_STACK       =               ACS_PRESENT OR ACS_DSEG OR ACS_WRITE OR ACS_EXPDOWN

ACS_INT_GATE    EQU             00001110B
ACS_TRAP_GATE   EQU             00001111B
ACS_IDT         EQU             ACS_DATA
ACS_INT         EQU             ACS_PRESENT OR ACS_INT_GATE
ACS_TRAP        EQU             ACS_PRESENT OR ACS_TRAP_GATE
ACS_TSS         EQU             ACS_PRESENT OR 00001001B

ACS_DPL_0       EQU             00000000B
ACS_DPL_1       EQU             00100000B
ACS_DPL_2       EQU             01000000B
ACS_DPL_3       EQU             01100000B

RPL_0           EQU             0
RPL_1           EQU             1
RPL_2           EQU             2
RPL_3           EQU             3

; CONSTANTS FOR BIOS DATA AREA
SEG_BIOS        EQU             00040H
SIZE_BIOS       EQU             00300H
LOW_BIOS        EQU             00400H
HIGH_BIOS       EQU             0

; CONSTANTS FOR TEXT VIDEO MODES
SEG_TEXT        EQU             0B800H
SIZE_TEXT       EQU             02000H            ; > 80*50*2
LOW_TEXT        EQU             08000H
HIGH_TEXT       EQU             0BH

; CONSTANTS FOR GRAPHICS VIDEO MODES
SEG_GRAPH       EQU             0A000H
SIZE_GRAPH      EQU             10000H
LOW_GRAPH       EQU             0
HIGH_GRAPH      EQU             0AH

; DIFFERENT CONSTANTS FOR PORT I/O
PORT_CMOS       EQU             070H
PORT_6845       EQU             00063H
PORT_TEXT       EQU             003D4H
PORT_STATUS     EQU             064H
SHUT_DOWN       EQU             0FEH
MODE_VIRTUAL    EQU             00001H
PORT_A20        EQU             0D1H
A20_ON          EQU             0DFH
A20_OFF         EQU             0DDH
PORT_KBD_A      EQU             060H
PORT_KBD_B      EQU             061H
PORT_INT_MASK_M EQU             021H
PORT_INT_MASK_S EQU             0A1H

EOI             EQU             020H
PORT_8259M      EQU             020H
PORT_8259S      EQU             0A0H

PORT_COM_REG    EQU             043H
PORT_CHANNEL2   EQU             042H

; Enables A20 line
@ENABLE_A20      MACRO
        MOV             AL, PORT_A20
        OUT             PORT_STATUS, AL
        MOV             AL, A20_ON
        OUT             PORT_KBD_A, AL
ENDM

; Disables A20 line
@DISABLE_A20     MACRO
        MOV             AL, PORT_A20
        OUT             PORT_STATUS, AL
        MOV             AL, A20_OFF
        OUT             PORT_KBD_A, AL
ENDM

; Enables non-maskable interrupts
@ENABLE_NMI     MACRO
        MOV             AL, 0DH
        OUT             PORT_CMOS, AL
        JMP             $+2
ENDM

; Disables non-maskable interrupts
@DISABLE_NMI    MACRO
        MOV             AL, 8FH
        OUT             PORT_CMOS, AL
        JMP             $+2
ENDM

; This macro reprograms PIC (master and slave) to other interrupt vectors
@SET_INT_CTRLR  MACRO   INT_MASTER, INT_SLAVE
        MOV     AL, 11H                 ; START 8259 INITIALIZATION
        OUT     PORT_8259M, AL
        OUT     PORT_8259S, AL
        MOV     AL, INT_MASTER          ; BASE INTERRUPT VECTOR
        OUT     PORT_8259M+1, AL
        MOV     AL, INT_SLAVE
        OUT     PORT_8259S+1, AL
        MOV     AL, 1 SHL 2             ; BITMASK FOR CASCADE ON IRQ 2
        OUT     PORT_8259M+1, AL
        MOV     AL, 2                   ; CASCADE ON IRQ 2
        OUT     PORT_8259S+1, AL
        MOV     AL, 1                   ; FINISH 8259 INITIALIZATION
        OUT     PORT_8259M+1, AL
        OUT     PORT_8259S+1, AL

        MOV     AL, 0FFH                ; MASK ALL INTERRUPTS
        OUT     PORT_INT_MASK_M, AL
        OUT     PORT_INT_MASK_S, AL
ENDM

@JUMP   MACRO           ; OVERLOADS CODE SELECTOR AFTER CHANGING ITS DESCRIPTOR
        DB      0EAH
        DW      $+4
        DW      CS16_DESC
ENDM

@JUMPR  MACRO           ; OVERLOADS CODE SEGMENT
        DB      0EAH
        DW      $+4
        DW      CODE16
ENDM

@RETF   MACRO           ; FAR RETURN FROM 16-BIT TO 32-BIT CODE & VICE VERSA
        DB      66H
        RETF
ENDM
