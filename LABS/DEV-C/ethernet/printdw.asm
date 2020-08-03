;.386 SE DEIXAR AQUI: fatal error L1123: _TEXT : segment defined both 16- and 32-bit 
.MODEL SMALL
.386                           

printdw PROTO C VALUE:DWORD

.CODE
                
    printdw PROC C VALUE:DWORD 

        MOV     ESI, DWORD PTR VALUE

        PUSH    ES
        PUSH    DS

        MOV     AX, CS
        MOV     DS, AX
        MOV     ES, AX

        MOV     DI, OFFSET BUFFER
        MOV     EAX, ESI
        STOSD

        CALL    PRINTHEADER

        MOV     BX, OFFSET TAB
        MOV     SI, OFFSET BUFFER
        MOV     ECX, 4
        ADD     ESI, 3

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

        CALL    CRLF

        POP     DS
        POP     ES

        RET
                    
    printdw ENDP

    PRINTHEADER PROC

        MOV     AH, 0Eh
        MOV     AL, '0'
        INT     10h

        MOV     AL, 'x'
        INT     10h

        RET

    PRINTHEADER ENDP

    CRLF PROC

        MOV     AH, 0Eh
        MOV     AL, 0Ah
        INT     10h

        MOV     AL, 0Dh
        INT     10h

        RET

    CRLF ENDP

    BUFFER  DD  ?
    TAB     DB  '0123456789ABCDEF'

END