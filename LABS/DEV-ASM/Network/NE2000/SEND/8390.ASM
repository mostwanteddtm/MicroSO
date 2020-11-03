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

EXTERN BUFFER: BYTE
EXTERN PACKET: BYTE
EXTERN BASEADDR: WORD
EXTERN MACADDR: BYTE
EXTERN DATALEN:WORD
EXTERN TAB:BYTE

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
    ;           CX -> DATA LENGHT (FOR GET AN SET MAC ADDRESS)                                                    ;
    ;   OUT:    NONE                                                                                              ;
    ;                                                                                                             ;
    ;**************************************************************************************************************

    RESETNIC PROC 

        MOV     DX, WORD PTR BASEADDR           
        ADD     DX, CMDR
        MOV     AL, 21h                         ; /* Stop, DMA abort, page 0 */
        OUT     DX, AL

        MOV     DX, WORD PTR BASEADDR
        ADD     DX, DCR
        MOV     AL, DCRVAL
        OUT     DX, AL

        MOV     DX, WORD PTR BASEADDR           
        ADD     DX, RBCR0
        MOV     AL, 00h                         ; /* Clear remote byte count */
        OUT     DX, AL

        MOV     DX, WORD PTR BASEADDR
        ADD     DX, RBCR1
        MOV     AL, 00h
        OUT     DX, AL

        MOV     DX, WORD PTR BASEADDR           
        ADD     DX, RRCR
        MOV     AL, 20h                         ; /* Rx monitor mode */
        OUT     DX, AL

        MOV     DX, WORD PTR BASEADDR           
        ADD     DX, TCR
        MOV     AL, 02h                         ; /* Tx internal loopback */ 
        OUT     DX, AL

        MOV     DX, WORD PTR BASEADDR           
        ADD     DX, TPSR
        MOV     AL, TXSTART                     ; /* Set Tx start page */
        OUT     DX, AL

        MOV     DX, WORD PTR BASEADDR           
        ADD     DX, PSTART
        MOV     AL, RXSTART                     ; /* Set Rx start, stop, boundary */
        OUT     DX, AL

        MOV     DX, WORD PTR BASEADDR
        ADD     DX, PSTOP
        MOV     AL, RXSTOP
        OUT     DX, AL

        MOV     DX, WORD PTR BASEADDR
        ADD     DX, BNRY
        MOV     AL, RXSTOP-1
        OUT     DX, AL

        MOV     DX, WORD PTR BASEADDR           
        ADD     DX, ISR
        MOV     AL, 0FFh                        ; /* Clear interrupt flags */
        OUT     DX, AL

        MOV     DX, WORD PTR BASEADDR           
        ADD     DX, IMR
        MOV     AL, 00h                         ; /* Mask all interrupts */
        OUT     DX, AL

        MOV     DX, WORD PTR BASEADDR           
        ADD     DX, CMDR
        MOV     AL, 22h                         ; /* Start NIC, DMA abort */
        OUT     DX, AL

        CALL    GETNIC                          ; /* Get 12-byte addr */

        MOV     CX, WORD PTR DATALEN
        SHR     CX, 1                           ; /* Convert addr words to bytes */
        MOV     SI, OFFSET _DATA:BUFFER
        MOV     DI, OFFSET _DATA:MACADDR        

    @@: MOVSB                                   ; /* Save Mac Address */
        INC     SI
        LOOP    @b

        MOV     DX, WORD PTR BASEADDR
        ADD     DX, CMDR
        MOV     AL, 61h                         ; /* Stop, DMA abort, page 1 */
        OUT     DX, AL

        XOR     BX, BX
        MOV     DI, OFFSET _DATA:MACADDR
        MOV     CX, WORD PTR DATALEN
        SHR     CX, 1

    @@: LODSB    
        MOV     DX, WORD PTR BASEADDR
        ADD     DX, PAR0
        ADD     DX, BX
        OUT     DX, AL                          ; /* Set Phys addr */
        INC     BX
        LOOP    @b

        XOR     BX, BX
        MOV     CX, 8

    @@: MOV     AL, 0FFh    
        MOV     DX, WORD PTR BASEADDR
        ADD     DX, MAR0
        ADD     DX, BX
        OUT     DX, AL                          ; /* Multicast accept-all */
        INC     BX
        LOOP    @b

        MOV     DX, WORD PTR BASEADDR
        ADD     DX, CURR
        MOV     AL, RXSTART+1                   ; /* Set current Rx page */
        OUT     DX, AL

        MOV     DX, WORD PTR BASEADDR
        ADD     DX, CMDR
        MOV     AL, 20h                         ; /* DMA abort, page 0 */
        OUT     DX, AL

        MOV     DX, WORD PTR BASEADDR
        ADD     DX, RRCR
        MOV     AL, 14h                         ; /* Allow broadcasts, maybe all pkts */
        OUT     DX, AL

        MOV     DX, WORD PTR BASEADDR
        ADD     DX, TCR
        MOV     AL, 00h                         ; /* Normal Tx operation */
        OUT     DX, AL

        MOV     DX, WORD PTR BASEADDR
        ADD     DX, ISR
        MOV     AL, 0FFh                        ; /* Clear interrupt flags */
        OUT     DX, AL

        MOV     DX, WORD PTR BASEADDR
        ADD     DX, CMDR
        MOV     AL, 22h                         ; /* Start NIC */
        OUT     DX, AL

        RET 

    RESETNIC ENDP

    ;*************************************************************************************************************;
    ;                                                                                                             ;
    ; GET DATA ON NE 2000 CARD                                                                                    ;
    ;   IN:     CX -> DATA LENGHT                                                                                 ;
    ;   OUT:    WORDS RECEIVED ON DATAPORT                                                                        ;
    ;                                                                                                             ;
    ;**************************************************************************************************************

    GETNIC PROC

        MOV     DX, WORD PTR BASEADDR
        ADD     DX, ISR
        MOV     AL, 40h                         ; /* Clear remote DMA interrupt flag */
        OUT     DX, AL

        MOV     DX, WORD PTR BASEADDR
        ADD     DX, RBCR0
        MOV     AX, WORD PTR DATALEN
        AND     AL, 0FFh                        ; /* Byte count */
        OUT     DX, AL

        MOV     DX, WORD PTR BASEADDR
        ADD     DX, RBCR1
        MOV     AX, WORD PTR DATALEN
        SHR     AX, 8
        OUT     DX, AL

        MOV     DX, WORD PTR BASEADDR
        ADD     DX, RSAR0
        MOV     AX, 0
        AND     AL, 0FFh                        ; /* Data addr */
        OUT     DX, AL

        MOV     DX, WORD PTR BASEADDR
        ADD     DX, RSAR1
        MOV     AX, 0
        SHR     AL, 8
        OUT     DX, AL

        MOV     DX, WORD PTR BASEADDR
        ADD     DX, CMDR
        MOV     AL, 0Ah                         ; /* Start, DMA remote read */
        OUT     DX, AL

        MOV     CX, WORD PTR DATALEN
        SHR     CL, 1

        MOV     DX, WORD PTR BASEADDR
        ADD     DX, DATAPORT
        MOV     SI, OFFSET _DATA:BUFFER

    @@: IN      AX, DX                          ; /* Get words */
        MOV     DS:[SI], AX
        ADD     SI, 2
        LOOP    @b

        RET

    GETNIC ENDP

    ;*************************************************************************************************************;
    ;                                                                                                             ;
    ; SET DATA ON NE 2000 CARD                                                                                    ;
    ;   IN:     CX -> DATA LENGHT                                                                                 ;
    ;           SI -> PACKET OFFSET                                                                               ;
    ;   OUT:    WORDS TRANSMIT ON DATAPORT                                                                        ;
    ;                                                                                                             ;
    ;**************************************************************************************************************

    PUTNIC PROC

        MOV     DX, WORD PTR BASEADDR
        ADD     DX, ISR
        MOV     AL, 0Ah                         ; /* Clear interrupt flags */
        OUT     DX, AL 

        MOV     DX, WORD PTR BASEADDR
        ADD     DX, TBCR0
        MOV     AX, WORD PTR DATALEN
        AND     AL, 0FFh                        ; /* Set Tx length regs */
        OUT     DX, AL 
         
        MOV     DX, WORD PTR BASEADDR
        ADD     DX, TBCR1
        MOV     AX, WORD PTR DATALEN
        SHR     AL, 08h
        OUT     DX, AL 

        MOV     DX, WORD PTR BASEADDR
        ADD     DX, ISR
        MOV     AL, 40h                         ; /* Clear remote DMA interrupt flag */
        OUT     DX, AL

        MOV     DX, WORD PTR BASEADDR
        ADD     DX, RBCR0
        MOV     AX, WORD PTR DATALEN
        AND     AL, 0FFh                        ; /* Byte count */
        OUT     DX, AL 
         
        MOV     DX, WORD PTR BASEADDR
        ADD     DX, RBCR1
        MOV     AX, WORD PTR DATALEN
        SHR     AL, 08h
        OUT     DX, AL 

        MOV     DX, WORD PTR BASEADDR
        ADD     DX, RSAR0
        MOV     AL, 00h                         ; /* Data addr */
        OUT     DX, AL

        MOV     DX, WORD PTR BASEADDR
        ADD     DX, RSAR1
        MOV     AL, 40h
        OUT     DX, AL

        MOV     DX, WORD PTR BASEADDR
        ADD     DX, CMDR
        MOV     AL, 12h                         ; /* Start, DMA remote write */
        OUT     DX, AL

        MOV     SI, OFFSET _DATA:PACKET
        MOV     CX, WORD PTR DATALEN
        SHR     CX, 01h

    @@: LODSW
        MOV     DX, WORD PTR BASEADDR
        ADD     DX, DATAPORT
        OUT     DX, AX                          ; /* Copy words to buffer card */
        LOOP    @b

        MOV     CX, 10000
    @@: MOV     DX, WORD PTR BASEADDR
        ADD     DX, ISR
        IN      AL, DX
        AND     AL, 40h
        CMP     AL, 0                           ; /* Done: must ensure DMA complete */
        JE      @f 
        LOOP    @b

    @@: MOV     DX, WORD PTR BASEADDR
        ADD     DX, CMDR
        MOV     AL, 24h                         ; /* Transmit the packet */
        OUT     DX, AL

        RET

    PUTNIC ENDP

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
        CMP     CX, 1
        JE      ENDPMEM
        MOV     AL, ':'
        INT     10h
    ENDPMEM:
        LOOP    @b

        RET
      
    PRINTMEM ENDP

_TEXT ENDS

END