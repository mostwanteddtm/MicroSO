_TEXT SEGMENT

    ;*************************************************************************************************************;
    ;                                                                                                             ;
    ; PRINTSTR: PRINT HEXADECIMAL                                                                                 ;
    ;   IN:     SI -> STRING OFFSET                                                                               ;
    ;   OUT:    DISPLAY STRING ON SCREEN                                                                          ;
    ;                                                                                                             ;
    ;**************************************************************************************************************
    EXTERNDEF PRINTSTR:NEAR

    ;*************************************************************************************************************;
    ;                                                                                                             ;
    ; PRINT HEXADECIMAL                                                                                           ;
    ;   IN:     HEXPOINTER -> OFFSET OF BYTES TO PRINT                                                            ;
    ;           HEXBYTES   -> TOTAL BYTES TO PRINT                                                                ;
    ;   OUT:    PRINT BYTES ON SCREEN                                                                             ;
    ;                                                                                                             ;
    ;**************************************************************************************************************
    PRINTHEX PROTO C HEXPOINTER:PTR BYTE, HEXBYTES:WORD

_TEXT ENDS