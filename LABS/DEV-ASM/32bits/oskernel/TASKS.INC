;-----------------------------;
; 2 ADDITIONAL TASKS (RING 3) ;
;-----------------------------;

;----------------------;
; TASK #0 CODE SEGMENT ;
;----------------------;

CODE_0  SEGMENT PARA USE32
        ASSUME  CS:CODE_0
CS_0_BEGIN      =       $
TASK_0  PROC NEAR
        MOV     AX, DS_DESC
        MOV     DS, AX
        MOV     ES, AX
        LEA     ESI, MSG_TASK_0
        MOV     EDI, 5*80*2
        MOV     BH, 1
        INT     30H
        MOV     EAX, 0
        ADD     EDI, 80*2
TASK_0_L:
        MOV     BH, 2
        INT     30H
        INC     EAX

        MOV     EDX, EAX

        ADD     EDI, 80*2
        MOV     EAX, ESP
        MOV     BH, 2
        INT     30H                             ; VISUAL TEST OF ESP

        SUB     EDI, 80*2
        MOV     EAX, EDX

        JMP     TASK_0_L
TASK_0  ENDP
SIZE_CS_0       =       ($ - CS_0_BEGIN)
CODE_0  ENDS

;----------------------;
; TASK #1 CODE SEGMENT ;
;----------------------;

CODE_1  SEGMENT PARA USE32
        ASSUME  CS:CODE_1
CS_1_BEGIN      =       $
TASK_1  PROC NEAR
        MOV     AX, DS_DESC
        MOV     DS, AX
        MOV     ES, AX
        LEA     ESI, MSG_TASK_1
        MOV     EDI, 5*80*2+10*2
        MOV     BH, 1
        INT     30H
        MOV     EAX, -1
        ADD     EDI, 80*2
TASK_1_L:
        MOV     BH, 2
        INT     30H
        DEC     EAX

        MOV     EDX, EAX

        ADD     EDI, 80*2
        MOV     EAX, ESP
        MOV     BH, 2
        INT     30H                             ; VISUAL TEST OF ESP

        SUB     EDI, 80*2
        MOV     EAX, EDX

        JMP     TASK_1_L
TASK_1  ENDP
SIZE_CS_1       =       ($ - CS_1_BEGIN)
CODE_1  ENDS

;-----------------------;
; TASK #0 STACK SEGMENT ;
;-----------------------;

STCK_0  SEGMENT PARA
        DB      SIZE_STACK DUP (?)
STCK_0  ENDS

;-----------------------;
; TASK #1 STACK SEGMENT ;
;-----------------------;

STCK_1  SEGMENT PARA
        DB      SIZE_STACK DUP (?)
STCK_1  ENDS
