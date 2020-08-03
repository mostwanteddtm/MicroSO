.MODEL TINY 
.386 
.DATA 
Count           DD 0                      ; The count of "timer ticks: 
Semaphore       DB 0                      ; The semaphore to be set when done 
.CODE 
 
Begin:         
        MOV     AX, 8301h                 ; INT 15h Func 83h Subfunc 01h: 
        INT     15h                       ;  Cancel any pending RTC stuff 
        CLI 
        XOR     AX, AX                    ; } 
        MOV     DS, AX                    ; } 
        MOV     CX, CS                    ; } 
        LEA     AX, Int70                 ; } 
        MOV     BX, 01C0h                 ;  Point INT 70h to my ISR 
        MOV     WORD PTR [BX], AX         ; } 
        ADD     BX, 2                     ; } 
        MOV     WORD PTR [BX], CX         ; } 
        STI 
        MOV     AX, 08300h                ; INT 15h Func 83h Subfunc 00h 
        MOV     CX, 01234h                ; Some random value to count down 
        MOV     DX, 05678h 
        LEA     BX, Semaphore             ; ES:BX = pointer to semaphore flag 
        INT     15h                       ; Call event wait function 
Repeat1:         
        AND     BYTE PTR [Semaphore], 80h 
        JZ      Repeat1                    ; Wait 'til semaphore flag is set 
        INT     20h 
Int70   PROC 
        CLI 
        PUSH    AX                        ; 
        PUSH    BX                        ; 
        PUSH    DI                        ; Save all used registers 
        PUSH    DS                        ; 
        INC     DWORD PTR CS:[Count]      ; Increment the counter 
        MOV     AX, 0B800h                ; 
        MOV     DS, AX                    ; DS=ptr to video memory 
        MOV     AX, WORD PTR CS:[Count]   ; BX:AX = Count 
        MOV     BX, WORD PTR CS:[Count+2] ; 
        XOR     DI, DI                    ; 
        MOV     [DI], BH                  ; 
        ADD     DI, 2                     ; 
        MOV     [DI], BL                  ; 
        ADD     DI, 2                     ; Display "number" on screen 
        MOV     [DI], AH                  ; 
        ADD     DI, 2                     ; 
        MOV     [DI], AL                  ; 
        MOV     AL, 20h                 
        OUT     0A0h, AL                  ; Send EOI to slave PIC 
        OUT     020h, AL                  ; Send EOI to master PIC 
        POP     DS                        ; 
        POP     DI                        ; 
        POP     BX                        ; Restore all used registers 
        POP     AX                        ; 
        STI                               ; Reenable interupts 
        IRET 
Int70   ENDP 
        END     Begin 
		END