;----------------------------------;
; Timer hardware interrupt handler ;
;----------------------------------;

TIMER_HANDLER PROC NEAR
        @PUSH   <DS, ES>
        PUSHAD
        MOV     AX, DS_DESC
        MOV     DS, AX
        MOV     AX, BIOS_DESC
        MOV     ES, AX
        INC     DWORD PTR ES:[06CH]             ; UPDATE BIOS TICK COUNTER

        MOV     AX, DS:[TIMER_CNT]              ; INTERNAL TICK COUNTER
        INC     AX
        CMP     AX, 9                           ; IS TIME FOR "*" OR " "?
        JNE     TIMER_END                       ; NO, IT ISN'T

        MOV     AX, TEXT_DESC
        MOV     ES, AX
        MOV     AL, ES:[2*79]
        MOV     BYTE PTR ES:[2*79], 0           ; " " <-> "*"
        CMP     AL, '*'
        JE      TIMER_FLAG
        MOV     BYTE PTR ES:[2*79], '*'         ; "*" <-> " "

TIMER_FLAG:
        XOR     AX, AX
TIMER_END:                                      ; UPDATE INTERNAL TICK COUNTER
        MOV     DS:[TIMER_CNT], AX

        MOV     AL, EOI
        OUT     PORT_8259M, AL                  ; ACKNOWLEDGE HANDLING OF INTERRUPT

; LOOKING FOR THE NEXT TASK BEING CONTINUED

        MOVZX   EAX, DS:[TASK_INDEX]
        ADD     DS:[TASK_INDEX], 2
        MOVZX   EAX, DS:[TASK_LIST+EAX]
        OR      EAX, EAX                        ; END OF TASK LIST?
        JNZ     TIMER_NEXT_TASK                 ; NOT END, RUNNING NEXT TASK
        MOVZX   EAX, DS:[TASK_LIST]
        MOV     DS:[TASK_INDEX], 2              ; END, RUNNING FIRST TASK

TIMER_NEXT_TASK:
        MOV     WORD PTR DS:[TASK_ADDR+4], AX   ; FAR POINTER TO TSS

        JMP     FWORD PTR DS:[TASK_ADDR]        ; SWITCH TO ANOTHER TASK :)

        POPAD
        @POP    <ES, DS>
        IRETD
TIMER_HANDLER ENDP
