PRINTCSEG SEGMENT PARA PUBLIC 'CODE' USE16

    ;*************************************************************************************************************;
    ;                                                                                                             ;
    ; PRINTSTR: PRINT HEXADECIMAL                                                                                 ;
    ;   IN:     SI -> STRING OFFSET                                                                               ;
    ;   OUT:    DISPLAY STRING ON SCREEN                                                                          ;
    ;                                                                                                             ;
    ;************************************************************************************************************** 
	EXTERNDEF PRINTSTR:FAR

PRINTCSEG ENDS