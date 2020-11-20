.286
.MODEL SMALL

EXTERN PACKET: BYTE
EXTERN PACKETHEADER:DWORD
EXTERN CURRENTPACKET:WORD
EXTERN CURPOS:BYTE
EXTERN CURRADDR:WORD
EXTERN BASEADDR: WORD
EXTERN MACADDR: BYTE
EXTERN DATALEN:WORD
EXTERN TAB:BYTE

PUBLIC RESETNIC
PUBLIC PRINTMAC
PUBLIC PRINTSTR
PUBLIC PRINTHEX
PUBLIC PRINTMEM
PUBLIC GETETHERNE

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

        MOV     WORD PTR CURRADDR, 00h
        CALL    GETNIC                          ; /* Get 12-byte addr */

        MOV     CX, WORD PTR DATALEN
        SHR     CX, 1                           ; /* Convert addr words to bytes */
        MOV     SI, OFFSET _DATA:PACKET
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

        MOV     WORD PTR CURRENTPACKET, RXSTART+1

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
        MOV     AX, WORD PTR CURRENTPACKET
        AND     AL, 0FFh                        ; /* Data addr */
        OUT     DX, AL

        MOV     DX, WORD PTR BASEADDR
        ADD     DX, RSAR1
        MOV     AX, WORD PTR CURRENTPACKET
        SHR     AX, 8
        OUT     DX, AL

        MOV     DX, WORD PTR BASEADDR
        ADD     DX, CMDR
        MOV     AL, 0Ah                         ; /* Start, DMA remote read */
        OUT     DX, AL

        MOV     CX, WORD PTR DATALEN
        SHR     CL, 1

        MOV     DX, WORD PTR BASEADDR
        ADD     DX, DATAPORT
        MOV     SI, OFFSET _DATA:PACKET

    @@: IN      AX, DX                          ; /* Get words */
        MOV     DS:[SI], AX
        ADD     SI, 2
        LOOP    @b

        RET

    GETNIC ENDP

    GETETHERNE PROC

        MOV     DX, WORD PTR BASEADDR
        ADD     DX, ISR
        MOV     AL, 01h
        OUT     DX, AL                          ; /* Clear interrupt flag */

        MOV     DX, WORD PTR BASEADDR
        ADD     DX, CMDR
        MOV     AL, 60h                         ; /* DMA abort, page 1 */
        OUT     DX, AL

        XOR     AX, AX
        MOV     DX, WORD PTR BASEADDR
        ADD     DX, CURR
        IN      AL, DX

        MOV     WORD PTR CURRADDR, AX

        MOV     DX, WORD PTR BASEADDR
        ADD     DX, CMDR
        MOV     AL, 20h
        OUT     DX, AL

        MOV     AX, WORD PTR CURRADDR           ; /* Contains number of next packet
        CMP     AX, WORD PTR CURRENTPACKET      ; /* Contains number of current packet
        JE      @f                              ; /* Compares if a new package has arrived 

        CALL    CLEANPREVIOUSPACKET             ; /* Celan Screen a previous packet

        MOV     WORD PTR DATALEN, 4
        SHL     WORD PTR CURRENTPACKET, 8

        CALL    GETNIC                          ; /* Get Packet Header

        MOV     SI, OFFSET _DATA:PACKET
        MOV     DI, OFFSET _DATA:PACKETHEADER
        MOV     CX, 2
        REP     MOVSW                           ; /* Move Header to Packet Header Buffer                         

        MOV     SI, OFFSET _DATA:PACKETHEADER   ; /* Packet Header: 1 - Byte Status, 2 - Byte Next Packet, 3 - Word Len
        ADD     SI, 2
        LODSW
        MOV     WORD PTR DATALEN, AX

        CALL    GETNIC                          ; /* Get Packet 

        XOR     AX, AX
        MOV     SI, OFFSET _DATA:PACKETHEADER
        INC     SI
        LODSB
        MOV     WORD PTR CURRENTPACKET, AX

        CALL    NICWRAP

        MOV     AH, 02h
        MOV     DL, 00h
        MOV     DH, BYTE PTR CURPOS
        MOV     BH, 0
        INT     10h

        MOV     SI, OFFSET _DATA:PACKET
        ADD     SI, 4
        MOV     CX, WORD PTR DATALEN
        SUB     CX, 4
        CALL    PRINTMEM

    @@: RET

    GETETHERNE ENDP

    ;*************************************************************************************************************;
    ;                                                                                                             ;
    ; NICWRAP                                                                                                     ;
    ;   IN:     NONE                                                                                              ;
    ;   OUT:    NONE                                                                                              ;
    ;                                                                                                             ;
    ;**************************************************************************************************************

    NICWRAP PROC

        MOV     AX, WORD PTR CURRENTPACKET
        DEC     AX

        CMP     AX, RXSTOP
        JGE     PMORE
        CMP     AX, RXSTART
        JL      PMIN
        JMP     ENDPAGE
        PMORE:
        ADD     AX, RXSTART - RXSTOP
        JMP     ENDPAGE
        PMIN:
        ADD     AX, RXSTOP - RXSTART
        ENDPAGE:

        MOV     DX, WORD PTR BASEADDR
        ADD     DX, BNRY
        OUT     DX, AL

        RET

    NICWRAP ENDP

    ;*************************************************************************************************************;
    ;                                                                                                             ;
    ; CLEAN PREVIOUS PACKET ON SCRENN                                                                             ;
    ;   IN:     NONE                                                                                              ;
    ;   OUT:    NONE                                                                                              ;
    ;                                                                                                             ;
    ;**************************************************************************************************************

    CLEANPREVIOUSPACKET PROC

        MOV     AH, 02h
        MOV     DL, 00h
        MOV     DH, BYTE PTR CURPOS
        MOV     BH, 0
        INT     10h

        XOR     AX, AX
        MOV     AL, 24
        SUB     AL, BYTE PTR CURPOS
        MOV     BX, 80
        MUL     BX
        MOV     CX, AX

        MOV     AH, 0Eh
        MOV     AL, 20h
    @@: INT     10h
        LOOP    @b

        RET 

    CLEANPREVIOUSPACKET ENDP

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
    ; PRINT MAC ADDRESS                                                                                           ;
    ;   IN:     SI -> BUFFER OFFSET                                                                               ;
    ;           CX -> NUMBER OF BYTES PRINT                                                                       ;
    ;   OUT:    DISPLAY MEMORY BYTES ON SCREEN                                                                    ;
    ;                                                                                                             ;
    ;**************************************************************************************************************                     
    PRINTMAC PROC

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
        JE      ENDPMAC
        MOV     AL, ':'
        INT     10h
    ENDPMAC:
        LOOP    @b

        MOV     AL, 0Dh
        INT     10h
        MOV     AL, 0Ah
        INT     10h

        RET
      
    PRINTMAC ENDP

    ;*************************************************************************************************************;
    ;                                                                                                             ;
    ; PRINT MEMORY                                                                                                ;
    ;   IN:     SI -> BUFFER OFFSET                                                                               ;
    ;           CX -> NUMBER OF BYTES PRINT                                                                       ;
    ;   OUT:    DISPLAY MEMORY BYTES ON SCREEN                                                                    ;
    ;                                                                                                             ;
    ;**************************************************************************************************************                     
    PRINTMEM PROC

        XOR     DI, DI
        MOV     BX, OFFSET _DATA:TAB

    @@: CMP     DI, 10h
        JNE     CPMEM
        CALL    @f
        XOR     DI, DI
    CPMEM:
        INC     DI
        MOV     AH, 0Eh 
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

    @@: MOV     AH, 0Eh
        MOV     AL, 0Dh
        INT     10h

        MOV     AL, 0Ah
        INT     10h

        RET
      
    PRINTMEM ENDP

_TEXT ENDS

END