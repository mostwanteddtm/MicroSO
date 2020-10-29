INCLUDE BASE.INC
INCLUDE PRINT.INC

_DATA SEGMENT

    MESSAGE     DB 'Hello World!', CR, LF, 0

    VALUE       DW 1234h
    LENVALUE    EQU $-VALUE

_DATA ENDS

_TEXT SEGMENT
    ASSUME CS:_TEXT, DS:_DATA

    MAIN PROC 

        MOV     AX, _DATA
        MOV     DS, AX
        MOV     ES, AX

        MOV     SI, OFFSET _DATA:MESSAGE
        CALL    PRINTSTR

        INVOKE  PRINTHEX, OFFSET _DATA:VALUE, LENVALUE

        MOV     AX, 4C00h
        INT     21h

    MAIN ENDP

_TEXT ENDS

END MAIN