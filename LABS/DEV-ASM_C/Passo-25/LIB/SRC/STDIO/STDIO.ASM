INCLUDE CRT0.INC 

_TEXT SEGMENT

    printf PROTO C, pointer:PTR BYTE
    ;*************************************************************************************************************;
    ;                                                                                                             ;
    ; printf: CALLING BY C++                                                                                      ;
    ;   IN:     SI -> STRING POINTER                                                                              ;
    ;   OUT:    DISPLAY STRING ON SCREEN                                                                          ;
    ;                                                                                                             ;
    ;**************************************************************************************************************
    printf PROC C pointer:PTR BYTE
    
        MOV		SI, pointer
    @@: LODSB
        CMP		AL, 0
        JE		@f
        MOV		AH, 0Eh
        INT		10h
        JMP		@b
        
    @@: RET
            
    printf ENDP

    ;*************************************************************************************************************;
    ;                                                                                                             ;
    ; PRINTSTR: PRINT HEXADECIMAL                                                                                 ;
    ;   IN:     SI -> STRING OFFSET                                                                               ;
    ;   OUT:    DISPLAY STRING ON SCREEN                                                                          ;
    ;                                                                                                             ;
    ;**************************************************************************************************************
    PRINTSTR PROC

        MOV     AH, 0Eh
    @@: LODSB 
        CMP     AL, 0
        JE      @f
        INT     10h
        JMP     @b

    @@: RET

    PRINTSTR ENDP

    ;*************************************************************************************************************;
    ;                                                                                                             ;
    ; PRINT HEXADECIMAL                                                                                           ;
    ;   IN:     HEXPOINTER -> OFFSET OF BYTES TO PRINT                                                            ;
    ;           HEXBYTES   -> TOTAL BYTES TO PRINT                                                                ;
    ;   OUT:    PRINT BYTES ON SCREEN                                                                             ;
    ;                                                                                                             ;
    ;************************************************************************************************************** 
    PRINTHEX PROC C HEXPOINTER:PTR BYTE, HEXBYTES:WORD
        
        PUSH    DS
        PUSH    ES 
        
        MOV     CX, HEXBYTES
        MOV     SI, HEXPOINTER
        
        IFDEF   __EXE__
        MOV     AX, _TEXT
        ELSE
        MOV     AX, CS
        ENDIF

        MOV     ES, AX
        MOV     DI, OFFSET _TEXT:PRINTHEXBUFFER
        REP     MOVSB
        
        MOV     CX, HEXBYTES
        
        IFDEF   __EXE__
        MOV     AX, _TEXT
        ELSE
        MOV     AX, CS
        ENDIF

        MOV     DS, AX
        MOV     SI, OFFSET _TEXT:PRINTHEXBUFFER
        
        MOV     DX, CX
        DEC     DX
        MOV     BX, OFFSET _TEXT:TAB
        ADD     SI, DX

    @@: MOV     AH, 0Eh 
        LODSB
        MOV     DL, AL
        SHR     AL, 4
        XLATB
        INT     10h
        MOV     AL, DL
        AND     AL, 0Fh
        XLATB
        INT     10h
        SUB     SI, 2
        LOOP    @b 
        
        POP     ES
        POP     DS

        RET 

    PRINTHEX ENDP

    TAB             DB  '0123456789ABCDEF'
    PRINTHEXBUFFER  DB 512 DUP(0)

_TEXT ENDS

END