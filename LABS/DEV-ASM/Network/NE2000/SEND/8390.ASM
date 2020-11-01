.286
.MODEL SMALL

MACLEN  EQU 6                   ;/* Ethernet (MAC) address length */
CRCLEN  EQU 4                   ;/* Ethernet hardware CRC length */
MAXNETS EQU 4                   ;/* Max net interfaces, must be power of 2 */
NETNUM_MASK EQU (MAXNETS-1)     ;/* Mask for network number */

MINFRAME    EQU 60              ;/* Minimum frame size (excl CRC) */
MAXFRAME    EQU 1514            ;/* Maximum frame size (excl CRC) */
MINFRAMEC   EQU 64              ;/* Minimum frame size (incl CRC) */
MAXFRAMEC   EQU 1518            ;/* Maximum frame size (incl CRC) */

WORDMODE    EQU 1               ;/* Set to zero if using 8-bit XT-bus cards */

;/* NE2000 definitions */
DATAPORT    EQU 10h
NE_RESET    EQU 1fh

;/* 8390 Network Interface Controller (NIC) page0 register offsets */
CMDR        EQU 00h            ;/* command register for read & write */
PSTART      EQU 01h            ;/* page start register for write */
PSTOP       EQU 02h            ;/* page stop register for write */
BNRY        EQU 03h            ;/* boundary reg for rd and wr */
TPSR        EQU 04h            ;/* tx start page start reg for wr */
TBCR0       EQU 05h            ;/* tx byte count 0 reg for wr */
TBCR1       EQU 06h            ;/* tx byte count 1 reg for wr */
ISR         EQU 07h            ;/* interrupt status reg for rd and wr */
RSAR0       EQU 08h            ;/* low byte of remote start addr */
RSAR1       EQU 09h            ;/* hi byte of remote start addr */
RBCR0       EQU 0Ah            ;/* remote byte count reg 0 for wr */
RBCR1       EQU 0Bh            ;/* remote byte count reg 1 for wr */
RRCR        EQU 0Ch            ;/* rx configuration reg for wr */
TCR         EQU 0Dh            ;/* tx configuration reg for wr */
DCR         EQU 0Eh            ;/* data configuration reg for wr */
IMR         EQU 0Fh            ;/* interrupt mask reg for wr */

;/* NIC page 1 register offsets */
PAR0        EQU 01h            ;/* physical addr reg 0 for rd and wr */
CURR        EQU 07h            ;/* current page reg for rd and wr */
MAR0        EQU 08h            ;/* multicast addr reg 0 for rd and WR */

;/* Buffer Length and Field Definition Info */
TXSTART     EQU 40h                 ;/* Tx buffer start page */
TXPAGES     EQU 06h                 ;/* Pages for Tx buffer */
RXSTART     EQU (TXSTART+TXPAGES)   ;/* Rx buffer start page */
IF WORDMODE
RXSTOP      EQU 7Eh             ;/* Rx buffer end page for word mode */
DCRVAL      EQU 49h             ;/* DCR values for word mode */
ELSE
RXSTOP      EQU 5fh             ;/* Ditto for byte mode */
DCRVAL      EQU 48h
ENDIF
STARHACK    EQU 00h             ;/* Set non-zero to enable Starlan length hack */

EXTERN MACADDR: PTR
EXTERN BASEADDR: WORD
EXTERN DATALEN:WORD
EXTERN TAB:PTR

PUBLIC RESETNIC
PUBLIC PRINTMEM
PUBLIC PRINTSTR

_DATA SEGMENT PUBLIC 'DATA'
_DATA ENDS

_TEXT SEGMENT PUBLIC 'CODE'
    ASSUME CS:_TEXT, DS:_DATA

    ;*************************************************************************************************************;
    ;                                                                                                             ;
    ; RESET NE 2000 CARD                                                                                          ;
    ;   IN:     BASE PORT ADDRES - DEFAULT 0x300                                                                  ;
    ;   OUT:    NONE                                                                                              ;
    ;                                                                                                             ;
    ;**************************************************************************************************************

    RESETNIC PROC 

        MOV     DX, BASEADDR
        ADD     DX, CMDR
        MOV     AL, 21h
        OUT     DX, AL

        MOV     DX, BASEADDR
        ADD     DX, DCR
        MOV     AL, DCRVAL
        OUT     DX, AL

        MOV     DX, BASEADDR
        ADD     DX, RBCR0
        MOV     AL, 00h
        OUT     DX, AL

        MOV     DX, BASEADDR
        ADD     DX, RBCR1
        MOV     AL, 00h
        OUT     DX, AL

        MOV     DX, BASEADDR
        ADD     DX, RRCR
        MOV     AL, 20h
        OUT     DX, AL

        MOV     DX, BASEADDR
        ADD     DX, TCR
        MOV     AL, 02h
        OUT     DX, AL

        MOV     DX, BASEADDR
        ADD     DX, TPSR
        MOV     AL, TXSTART
        OUT     DX, AL

        MOV     DX, BASEADDR
        ADD     DX, PSTART
        MOV     AL, RXSTART
        OUT     DX, AL

        MOV     DX, BASEADDR
        ADD     DX, PSTOP
        MOV     AL, RXSTOP
        OUT     DX, AL

        MOV     DX, BASEADDR
        ADD     DX, BNRY
        MOV     AL, RXSTOP-1
        OUT     DX, AL

        MOV     DX, BASEADDR
        ADD     DX, ISR
        MOV     AL, 0FFh
        OUT     DX, AL

        MOV     DX, BASEADDR
        ADD     DX, IMR
        MOV     AL, 00h
        OUT     DX, AL

        MOV     DX, BASEADDR
        ADD     DX, CMDR
        MOV     AL, 22h
        OUT     DX, AL

        CALL    GETNIC

        RET 

    RESETNIC ENDP

    ;*************************************************************************************************************;
    ;                                                                                                             ;
    ; GET DATA ON NE 2000 CARD                                                                                    ;
    ;   IN:     DATA LENGHT                                                                                       ;
    ;   OUT:    WORDS RECEIVED ON DATAPOR                                                                         ;
    ;                                                                                                             ;
    ;**************************************************************************************************************

    GETNIC PROC

        MOV     DX, BASEADDR
        ADD     DX, ISR
        MOV     AL, 40h
        OUT     DX, AL

        MOV     DX, BASEADDR
        ADD     DX, RBCR0
        MOV     AX, WORD PTR DATALEN
        AND     AL, 0FFh
        OUT     DX, AL

        MOV     DX, BASEADDR
        ADD     DX, RBCR1
        MOV     AX, WORD PTR DATALEN
        SHR     AX, 8
        OUT     DX, AL

        MOV     DX, BASEADDR
        ADD     DX, RSAR0
        MOV     AX, 0
        AND     AL, 0FFh
        OUT     DX, AL

        MOV     DX, BASEADDR
        ADD     DX, RSAR1
        MOV     AX, 0
        SHR     AL, 8
        OUT     DX, AL

        MOV     DX, BASEADDR
        ADD     DX, CMDR
        MOV     AL, 0Ah
        OUT     DX, AL

        MOV     CX, WORD PTR DATALEN
        SHR     CL, 1

        MOV     DX, BASEADDR
        ADD     DX, DATAPORT
        MOV     SI, OFFSET _DATA:MACADDR

    @@: IN      AX, DX
        MOV     DS:[SI], AX
        ADD     SI, 2
        LOOP    @b

        RET

    GETNIC ENDP

    ;*************************************************************************************************************;
    ;                                                                                                             ;
    ; PRINT CHAR ARRAY                                                                                            ;
    ;   IN:     SI -> BUFFER OFFSET                                                                               ;
    ;   OUT:    DISPLAY CHAR ARRAY ON SCREEN                                                                      ;
    ;                                                                                                             ;
    ;**************************************************************************************************************

    PRINTSTR PROC

        MOV     AH, 0Eh
    @@: LODSB
        CMP     AL, 0
        JE      @f
        INT     10h
        LOOP    @b

    @@: RET
            
    PRINTSTR ENDP

    ;*************************************************************************************************************;
    ;                                                                                                             ;
    ; PRINT HEXADECIMAL                                                                                           ;
    ;   IN:     SI -> BUFFER OFFSET                                                                               ;
    ;           CX -> NUMBER OF BYTES PRINT                                                                       ;
    ;   OUT:    DISPLAY HEXADECIMAL VALUE O SCREEN                                                                ;
    ;                                                                                                             ;
    ;**************************************************************************************************************                     
    PRINTHEX PROC

        MOV     DX, CX
        DEC     DX
        MOV     BX, OFFSET _DATA:TAB
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

        RET
      
    PRINTHEX ENDP

    ;*************************************************************************************************************;
    ;                                                                                                             ;
    ; PRINT MEMORY                                                                                                ;
    ;   IN:     SI -> BUFFER OFFSET                                                                               ;
    ;           CX -> NUMBER OF BYTES PRINT                                                                       ;
    ;   OUT:    DISPLAY MEMORY BYTES ON SCREEN                                                                    ;
    ;                                                                                                             ;
    ;**************************************************************************************************************                     
    PRINTMEM PROC

        MOV     BX, OFFSET _DATA:TAB

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
        MOV     AL, 20h
        INT     10h
        LOOP    @b

        RET
      
    PRINTMEM ENDP

_TEXT ENDS

END