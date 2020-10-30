INCLUDE CRT0.INC
INCLUDE STDIO.INC

CR  EQU 0Dh
LF  EQU 0Ah

_TEXT SEGMENT

    ORG 100h

    MAIN PROC 

        JMP     @f

        MESSAGE     DB 'It is a MS-DOS .com file extension!', CR, LF, 0
        VALUE       DW 1234h
        LENVALUE    EQU $-VALUE
    
    @@: MOV 	AX, CS
        MOV 	DS, AX
        MOV 	ES, AX

        MOV     SI, OFFSET CS:MESSAGE
        CALL    PRINTSTR

        INVOKE  PRINTHEX, OFFSET CS:VALUE, LENVALUE

        MOV     AX, 4C00h
        INT     21h

    MAIN ENDP

_TEXT ENDS

END MAIN