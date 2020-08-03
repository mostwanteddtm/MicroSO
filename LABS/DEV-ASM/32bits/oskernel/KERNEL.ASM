;---------------------------------------------------;
;      TINY OS KERNEL (C) BY ALEXEI A. FROUNZE      ;
;                28th OF MAY, 2000                  ;
;                                                   ;
;       !!! ABSOLUTELY NO ANY WARRANTIES !!!        ;
;                                                   ;
; ! AUTHOR CAN NOT BE RESPONSIBLE FOR ANY DAMAGE, ! ;
;           ! DATA OR HEALTH/LIFE LOSS !            ;
;                                                   ;
; E-Mail:   alexfru@chat.ru                         ;
; Homepage: http://www.chat.ru/~alexfru             ;
; Mirror:   http://members.xoom.com/alexfru         ;
;                                                   ;
; FEATURES:                                         ;
;   - 32-BIT PROTECTED MODE PROGRAMMING WITH 386+   ;
;   - EXCEPTIONS HANDLING                           ;
;   - TIMER & KEYBOARD HARDWARE INTERRUPTS HANDLING ;
;   - TASK SWITCHING (RING 0 AND RING 3)            ;
;                                                   ;
; SYSTEM REQUIREMENTS:                              ;
;   - 386 OR BETTER COMPUTER                        ;
;   - EGA/VGA OR BETTER COLOR VIDEO SYSTEM          ;
;   - DOS 5.0 OR BETTER (WITHOUT ANY MEMORY         ;
;     MANAGERS SUCH AS EMM386.EXE) OR               ;
;     WINDOWS 9x LOADED IN COMMAND PROMPT ONLY MODE ;
;---------------------------------------------------;

        .386P
        .MODEL   LARGE

        INCLUDE MACROSES.INC                    ; MAIN DEFINITIONS

SIZE_STACK      EQU     1000H

;-----------------------------------------;
; 16-BIT REAL/PROTECTED NODE CODE SEGMENT ;
;-----------------------------------------;

CODE16  SEGMENT PARA USE16
CODE16_BEGIN    =       $
        ASSUME          CS:CODE16,DS:DATA,ES:DATA
START:
        MOV     AX, DATA
        MOV     DS, AX
        MOV     ES, AX                          ; LOAD DATA SEGMENTS

        LEA     DX, MSG_STARTUP
        MOV     AH, 9
        INT     21H

;        MOV     EAX, CR0                       ; DOESN'T WORK UNDER WIN :(
        SMSW    AX                              ; BUT THIS WORKS PERFECTLY :)
        TEST    AL, 1                           ; IS PROTECTED MODE ACTIVE?
        JZ      START_NO_PM                     ; NO, IT ISN'T
        LEA     DX, MSG_VM
        MOV     AH, 9
        INT     21H
        JMP     START_EXIT                      ; YES, IT IS. EXITING...

START_NO_PM:
        MOV     EAX, 3
        CALL    delayRTC

        @ENABLE_A20                             ; ENABLE A20 LINE
        IN      AL, PORT_INT_MASK_M
        MOV     INT_MASK_M, AL                  ; SAVE MASK OF HARDWARE INTS AT MASTER CNTRLR
        IN      AL, PORT_INT_MASK_S
        MOV     INT_MASK_S, AL                  ; SAVE MASK OF HARDWARE INTS AT SLAVE CNTRLR
        CLI                                     ; DISABLE MASKABLE INTS
        @DISABLE_NMI                            ; DISABLE NON-MASKABLE INTS

        INCLUDE SETUPGDT.INC                    ; FILL GDT
        INCLUDE SETUPIDT.INC                    ; FILL IDT
        LGDT    FWORD PTR GDT_GDT               ; LOAD GDTR
        LIDT    FWORD PTR IDTR                  ; LOAD IDTR

        MOV     EAX, CR0
        OR      AL, 1
        MOV     CR0, EAX                        ; SET UP PROTECTED MODE

        @JUMP                                   ; OVERLOAD CODE SELECTOR
        MOV     AX, DS_DESC
        MOV     DS, AX                          ; LOAD DS WITH DATA SELECTOR
        MOV     ES, AX                          ; LOAD ES WITH DATA SELECTOR
        MOV     AX, SS_DESC
        MOV     SS, AX                          ; LOAD SS WITH STACK SELECTOR

        XOR     AX, AX
        MOV     FS, AX                          ; LOAD FS WITH 0
        MOV     GS, AX                          ; LOAD GS WITH 0
        LLDT    AX                              ; LOAD LDTR WITH 0

        MOVZX   ESP, SP                         ; EXPAND SP TO ESP
        PUSH    CS                              ; PREPARE FOR RETURNING BACK
        PUSH    OFFSET START_BACK_TO_16         ; TO 16-BIT PM CODE
        MOV     DS:[ESP32], ESP

        LEA     EDI, ENTER_32
        MOV     EAX, CS32_DESC
        PUSH    EAX
        PUSH    EDI                             ; PUSH 32-BIT CODE ADDRESS

        INCLUDE SETUPTSS.INC                    ; FILL TSSs
        MOV     AX, TSS_MAIN_DESC
        LTR     AX                              ; LOAD TR REGISTER

        @SET_INT_CTRLR 20H, 28H                 ; REINITIALISE MASTER & SLAVE INT CONTROLLERS
        MOV     AL, 0                           ; MASK = 0
        OUT     PORT_INT_MASK_M, AL             ; UNMASK INTS
        OUT     PORT_INT_MASK_S, AL             ; UNMASK INTS
        @ENABLE_NMI                             ; ENABLE NON-MASKABLE INTS
        STI                                     ; ENABLE MASKABLE INTS

        @RETF                                   ; "RETURN" TO 32-BIT CODE

START_BACK_TO_16:
        CLI                                     ; DISABLE MASKABLE INTS
        @DISABLE_NMI                            ; DISABLE NON-MASKABLE INTS
        MOV     AX, DS_DESC
        MOV     DS, AX                          ; SAFETY IS WHAT WE NEED!!!

        INCLUDE SET_RM1.INC                     ; BACK TO REAL MODE

        MOV     AL, INT_MASK_M
        OUT     PORT_INT_MASK_M, AL             ; RESTORE MASK OF HARDWARE INTS AT MASTER CNTRLR
        MOV     AL, INT_MASK_S
        OUT     PORT_INT_MASK_S, AL             ; RESTORE MASK OF HARDWARE INTS AT SLAVE CNTRLR
        @ENABLE_NMI                             ; ENABLE NON-MASKABLE INTS
        STI                                     ; ENABLE MASKABLE INTS
        @DISABLE_A20                            ; DISABLE A20 LINE

START_EXIT:
        MOV     EAX, 3
        CALL    delayRTC

        MOV     AX, 3
        INT     10H

        LEA     DX, MSG_CONTACT
        MOV     AH, 9
        INT     21H
        MOV     AX, 4C00H
        INT     21H                             ; EXIT TO DOS

delayRTC PROC NEAR
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Input : eax = number of seconds for delay ;;
;; Output: None, registers are preserved     ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        PUSH            EAX
        PUSH            EBX
        PUSH            ECX

        MOV             ECX, EAX
        XOR             AL, AL
        OUT             70H, AL
        JMP             DRL1
DRL1:
        IN              AL, 71H
        MOV             BL, AL
DRLL:
        XOR             AL, AL
        OUT             70H, AL
        JMP             DRL2
DRL2:
        IN              AL, 71H
        CMP             AL, BL
        JE              DRLL
        MOV             BL, AL
        LOOP            DRLL

        POP             ECX
        POP             EBX
        POP             EAX
        RET
delayRTC ENDP
SIZE_CSEG16     =       ($ - CODE16_BEGIN)
CODE16  ENDS

;------------------------------------;
; 32-BIT PROTECTED MODE CODE SEGMENT ;
;------------------------------------;

CODE32  SEGMENT PARA USE32
CODE32_BEGIN    =       $
        ASSUME          CS:CODE32,DS:DATA,ES:DATA

;--------------------;
; MAIN TASK (RING 0) ;
;--------------------;

ENTER_32:
        CALL    CLRSCR
        XOR     EDI, EDI

        LEA     ESI, MSG_TASK_MAIN
        CALL    W_ASCIIZ
        ADD     EDI, 80*2
        LEA     ESI, MSG_SCAN_CODE
        CALL    W_ASCIIZ
        ADD     EDI, 15*2

ENTER_32_WAIT_KEY:
        MOV     BL, KEY_SCAN_CODE
        MOVZX   EAX, BL
        CALL    W_EAX

        ADD     EDI, (80-15)*2
        MOV     EAX, ESP
        CALL    W_EAX                           ; VISUAL TEST OF ESP
        SUB     EDI, (80-15)*2

        CMP     BL, 1                           ; ESC?
        JNE     ENTER_32_WAIT_KEY               ; NOT ESC

;        MOV     ECX, 0FFFFFFFH
;        LOOP    $                               ; DOES A FEW SECOND DELAY ON MY P233

        @RETF                                   ; BACK TO 16-BIT CODE

;----------------------------------------------;
; MAIN ROUTINES AND HANDLERS ARE INCLUDED HERE ;
;----------------------------------------------;

        INCLUDE SCREENIO.INC                    ; SCREEN I/O ROUTINES
        INCLUDE EXC.INC                         ; EXCEPTION HANDLER
        INCLUDE IRET.INC                        ; TIMER INTERRUPT HANDLER
        INCLUDE TIMER.INC                       ; KEYBOARD INTERRUPT HANDLER
        INCLUDE KEYBOARD.INC                    ; ROUTINE FOR DISPLAYING TSS
        INCLUDE SHOW_TSS.INC                    ; SERVICE INTERRUPT
        INCLUDE SERVICE.INC
SIZE_CSEG32     =       ($ - CODE32_BEGIN)
CODE32  ENDS

;-----------------------------------------;
; COMMON REAL/PROTECTED MODE DATA SEGMENT ;
;-----------------------------------------;

DATA    SEGMENT PARA USE16
DATA_BEGIN      =       $
        INCLUDE GDT.INC                         ; GDT TABLE
        INCLUDE IDT.INC                         ; IDT TABLE
        INCLUDE TSS.INC                         ; TSS TABLES

MSG_STARTUP     DB      "Tiny OS Kernel by Alexei A. Frounze (C) 2000",13,10,"$"
MSG_CONTACT     DB      "Contact information:",13,10
                DB      "E-mail  : alexfru@chat.ru",13,10
                DB      "Homepage: http://alexfru.chat.ru",13,10
                DB      "Mirror  : http://members.xoom.com/alexfru",13,10,"$"
MSG_VM  DB              "PROCESSOR IS ALREADY IN PROTECTED MODE.",13,10
        DB              "PROBABLY WINDOWS OR EMM386.EXE IS LOADED.",13,10
        DB              "LOAD PURE DOS OR WINDOWS IN COMMAND PROMPT ONLY MODE.",13,10
        DB              "EXITING...",13,10,"$"
HEX_TAB DB              "0123456789ABCDEF"

EXC_ERR DB              0,0,0,0,0,0,0,0, 1,0,1,1,1,1,1,0, 0,1
MSG_EXC DB              "EXCEPTION: ",0
MSG_EXC_ERR DB          "ERROR CODE: ",0
MSG_CSEIP DB            "CS=XXXXXXXX EIP=XXXXXXXX",0

INT_MASK_M DB           ?
INT_MASK_S DB           ?
ESP32   DD              ?

TIMER_CNT DW            0
KEY_SCAN_CODE DB        0

MSG_TASK_MAIN DB        "MAIN TASK",0
MSG_SCAN_CODE DB        "KBD SCAN CODE: ",0
MSG_TASK_0 DB           "TASK #0",0
MSG_TASK_1 DB           "TASK #1",0

MSG_TSS LABEL BYTE
        DB "CR3  = XXXXXXXX FLAGS= XXXXXXXX",0
        DB "EIP  = XXXXXXXX CS   = XXXXXXXX",0
        DB "ESP  = XXXXXXXX SS   = XXXXXXXX",0
        DB "DS   = XXXXXXXX ES   = XXXXXXXX",0
        DB "FS   = XXXXXXXX GS   = XXXXXXXX",0
        DB "EAX  = XXXXXXXX EBX  = XXXXXXXX",0
        DB "ECX  = XXXXXXXX EDX  = XXXXXXXX",0
        DB "ESI  = XXXXXXXX EDI  = XXXXXXXX",0
        DB "EBP  = XXXXXXXX LINK = XXXXXXXX",0
        DB "ESP0 = XXXXXXXX SS0  = XXXXXXXX",0
        DB "ESP1 = XXXXXXXX SS1  = XXXXXXXX",0
        DB "ESP2 = XXXXXXXX SS2  = XXXXXXXX",0
        DB "LDTR = XXXXXXXX IO/T = XXXXXXXX",0

OFFS_TSS LABEL DWORD
        DD 1CH, 24H
        DD 20H, 4CH
        DD 38H, 50H
        DD 54H, 48H
        DD 58H, 5CH
        DD 28H, 34H
        DD 2CH, 30H
        DD 40H, 44H
        DD 3CH, 00H
        DD 04H, 08H
        DD 0CH, 10H
        DD 14H, 18H
        DD 60H, 64H
SIZE_DSEG       =       ($ - DATA_BEGIN)
DATA    ENDS

;-----------------------------------;
; REAL/PROTECTED MODE STACK SEGMENT ;
;-----------------------------------;

SSTACK  SEGMENT PARA STACK
        DB      SIZE_STACK DUP (?)
SSTACK  ENDS

;-----------------------------;
; 2 ADDITIONAL TASKS (RING 3) ;
;-----------------------------;

        INCLUDE TASKS.INC

END     START
