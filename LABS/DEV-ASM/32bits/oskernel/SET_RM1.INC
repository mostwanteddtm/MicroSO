;--------------------------------------------------------------------------;
; Sets Real Mode using CR0, overloading segs and reprogramming PIC         ;
; Ver 1: Unfortunately, works quite buggy. I don't know why. :((           ;
; Ver 2: It seems to be everything is OK after changing order of the       ;
;          @SET_INT_CTRLR 08H, 70H and                                     ;
;          LIDT FWORD PTR IDTR                                             ;
;        instructions                                                      ;
; Ver 3: unchanged vesrsion 2, but it doesn't work again when the task     ;
;        switching is enabled                                              ;
; Ver 4: added a "CLTS" instructio. Every DPMI-based program, that I tried ;
;        to run immediately after quitting from this program, just hanged  ;
;        with nonzero "task switched" flag. The solution is inside this    ;
;        simple instruction. Viola! it works!                              ;
;--------------------------------------------------------------------------;

        CLTS                                    ; THE SOLUTION!!! ;-)

        @SET_INT_CTRLR 08H, 70H                 ; REINITIALISE MASTER & SLAVE INT CONTROLLERS

        MOV     GDT_CS16.LIMIT, 0FFFFH          ; CODE SEGMENT HAS 64KB LIMIT
        MOV     GDT_DS.LIMIT, 0FFFFH            ; DATA SEGMENT HAS 64KB LIMIT
        MOV     GDT_SS.LIMIT, 0FFFFH            ; STACK SEGMENT HAS 64KB LIMIT
;        LGDT    FWORD PTR GDT_GDT               ; LOAD GDTR

        @JUMP                                   ; OVERLOAD CODE SELECTOR
        MOV     AX, DS_DESC
        MOV     DS, AX                          ; OVERLOAD DATA SELECTOR
        MOV     ES, AX                          ; OVERLOAD DATA SELECTOR
        MOV     FS, AX                          ; OVERLOAD DATA SELECTOR
        MOV     GS, AX                          ; OVERLOAD DATA SELECTOR
        MOV     AX, SS_DESC
        MOV     SS, AX                          ; OVERLOAD STACK SELECTOR

        MOV     EAX, CR0
        AND     AL, 0FEH
        MOV     CR0, EAX                        ; BACK TO THE REAL MODE

        @JUMPR                                  ; RESTORE RM CODE SEGMENT
        MOV     AX, SSTACK
        MOV     SS, AX                          ; RESTORE RM STACK SEGMENT
        MOV     AX, DATA
        MOV     DS, AX                          ; RESTORE RM DATA SEGMENT
        MOV     ES, AX
        XOR     AX, AX
        MOV     FS, AX
        MOV     GS, AX

        MOV     IDTR.LIMIT, 3FFH                ; REAL MODE INTERRUPT TABLE SIZE
        MOV     DWORD PTR IDTR+2, 0             ; REAL MODE INTERRUPT TABLE ADDRESS
        LIDT    FWORD PTR IDTR                  ; LOAD REAL MODE INT TABLE
