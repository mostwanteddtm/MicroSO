;--------------------------------;
; Fills TSSs of additional tasks ;
;--------------------------------;

        OR      TSS_0.R_EFLAGS, 3200H           ; IOPL=3, ENABLED INTERRUPTS
        MOV     TSS_0.R_CS, CS_0_DESC
        MOV     TSS_0.R_EIP, OFFSET TASK_0
        MOV     TSS_0.R_SS, SS_0_DESC
        MOV     TSS_0.R_ESP, SIZE_STACK
        MOV     AX, 0
        MOV     TSS_0.R_DS, AX
        MOV     TSS_0.R_ES, AX
        MOV     TSS_0.R_FS, AX
        MOV     TSS_0.R_GS, AX
        MOV     TSS_0.SS0, SS_DESC
        MOV     TSS_0.ESP0, SIZE_STACK SHR 1

        OR      TSS_1.R_EFLAGS, 3200H           ; IOPL=3, ENABLED INTERRUPTS
        MOV     TSS_1.R_CS, CS_1_DESC
        MOV     TSS_1.R_EIP, OFFSET TASK_1
        MOV     TSS_1.R_SS, SS_1_DESC
        MOV     TSS_1.R_ESP, SIZE_STACK
        MOV     AX, 0
        MOV     TSS_1.R_DS, AX
        MOV     TSS_1.R_ES, AX
        MOV     TSS_1.R_FS, AX
        MOV     TSS_1.R_GS, AX
        MOV     TSS_1.SS0, SS_DESC
        MOV     TSS_1.ESP0, SIZE_STACK SHR 2
