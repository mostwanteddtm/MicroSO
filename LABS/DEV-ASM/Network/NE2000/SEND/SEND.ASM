.286
.MODEL SMALL

PUBLIC BASEADDR
PUBLIC MACADDR
PUBLIC BUFFER
PUBLIC DATALEN
PUBLIC PACKET
PUBLIC TAB

EXTERN RESETNIC:PROC
EXTERN PRINTMEM:PROC
EXTERN PRINTSTR:PROC
EXTERN PUTNIC:PROC

FILELEN     EQU 04h

STACK SEGMENT STACK 'STACK'
    DW 100h DUP(0)
STACK ENDS

_DATA SEGMENT PUBLIC 'DATA'

    FILENAME        DB 'BASE.CFG', 0
    FILEHANDLE      DW 00h
    FILEBUFFER      DB FILELEN DUP(0)
    FILEERRORMSG    DB 'ERROR OPEN FILE BASE.CFG :(', 0

    TAB             DB '0123456789ABCDEF'

    CBUFFER         DB 00h  
    BASEADDR        DW 00h

    DATALEN         DW 00h
    MACADDR         DB 06h DUP(0)

    ALIGN 2
    PACKET          DB 64h DUP(0FFh)
    LENPACKET       EQU $-PACKET

    ALIGN 2
    BUFFER          DB 0Ch DUP(0)

_DATA ENDS

_TEXT SEGMENT PUBLIC 'CODE'
    ASSUME CS:_TEXT, DS:_DATA, ES:_DATA

    MAIN PROC

        MOV     AX, _DATA
        MOV     DS, AX
        MOV     ES, AX

        CALL    READFILE

        MOV     SI, OFFSET FILEBUFFER
        MOV     CX, FILELEN
        CALL    STRTOHEX

        MOV     WORD PTR DATALEN, 0Ch
        CALL    RESETNIC

        MOV     SI, OFFSET _DATA:MACADDR
        MOV     CX, 06h
        CALL    PRINTMEM

        MOV     SI, OFFSET _DATA:PACKET
        MOV     WORD PTR DATALEN, LENPACKET
        CALL    PUTNIC

        MOV     AX, 4C00h
        INT     21h

    MAIN ENDP

    ;==============================================================================================================

    READFILE PROC

        MOV     AH, 3Dh                     ; DOS 2+ - OPEN - OPEN EXISTING FILE  
        MOV     AL, 0 
        MOV     DX, OFFSET DS:FILENAME
        INT     21h
        JC      FILEERROR

        MOV     WORD PTR FILEHANDLE, AX

        MOV     AH, 3Fh                     ; DOS 2+ - READ - READ FROM FILE OR DEVICE
        MOV     BX, FILEHANDLE
        XOR     CX, CX
        MOV     CL, FILELEN
        MOV     DX, OFFSET DS:FILEBUFFER
        INT     21h
        JC      FILEERROR

        MOV     AH, 3Eh
        MOV     BX, WORD PTR FILEHANDLE
        INT     21h

        RET

    FILEERROR:

        MOV     SI, OFFSET DS:FILEERRORMSG
        MOV     AX, _DATA
        MOV     DS, AX

        CALL    PRINTSTR        

    @@: STC
        RET

    READFILE ENDP

    ;*************************************************************************************************************;
    ;                                                                                                             ;
    ; CONVERT STRING TO HEXADECIMAL                                                                               ;
    ;   IN:     SI -> OFFSET STRING VALUE                                                                         ;
    ;   OUT:    BASEADDR HEXADECINAL VALUE                                                                        ;
    ;                                                                                                             ;
    ;************************************************************************************************************** 

    STRTOHEX PROC 
        
        MOV     BYTE PTR CBUFFER, 03h

    @@: LODSB

        CMP     AL, 40h
        JL      ISNUMBER
        CMP     AL, 47h
        JL      ISUPPER
        CMP     AL, 67h
        JL      ISLOWER
        JMP     ENDSTRTOHEX

    ISNUMBER:
        SUB     AL, 30h
        JMP     SETHEX

    ISUPPER:
        SUB     AL, 37h
        JMP     SETHEX

    ISLOWER:
        SUB     AL, 57h
       
    SETHEX: 
        XOR     CX, CX
        XOR     AH, AH
        MOV     DL, AL
        MOV     AL, 4
        MUL     BYTE PTR CBUFFER
        MOV     CL, AL
        MOV     AL, DL
        SHL     AX, CL
        ADD     WORD PTR BASEADDR, AX
        CMP     BYTE PTR CBUFFER, 0
        JE      ENDSTRTOHEX  
        DEC     BYTE PTR CBUFFER
        JMP     @b

    ENDSTRTOHEX:
        RET

    STRTOHEX ENDP  

_TEXT ENDS

END MAIN
