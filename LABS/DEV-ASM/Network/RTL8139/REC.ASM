.386 
.MODEL SMALL

; PCI REGISTERS
CONFIG_ADDRESS  EQU 0CF8h
CONFIG_DATA     EQU 0CFCh 

; PCI BITS:  	(BUS 23~16 | DEVICE 15~11 | FUNCTION 10~8 | REGISTER 7~0)
FIRSTDEVICE		EQU 80000000h
LASTDEVICE		EQU 80FFF800h

; 5.Register Descriptions
TSD0            EQU 10h
TSAD0           EQU 20h
RBSTART         EQU 30h
CR              EQU 37h
TCR             EQU 40h
RRCR            EQU 44h									; RCR REGSTER
IMR             EQU 3Ch 
ISR				EQU 3Eh

ISR_ROK			EQU 1
ISR_RER			EQU 2
ISR_RXOVW		EQU 10h
ISR_FIFOOVW		EQU 40h

; 5.1 	Transmit Configuration Register 				(Offset 0040-0043h,R/W) 
TCR_MXDMA1      EQU 200h
TCR_MXDMA2      EQU 400h
TCR_IFG0        EQU 1000000h 
TCR_IFG1        EQU 2000000h 

; 5.3 	Interrupt Status(mask) Register        			(Offset 003e-003fh,R/W)
R39_INTERRUPT_MASK EQU 7Fh

; 5.5   Media Status Register                   		(Offset 0058	  ,R/W)
; 5.6   Receive Configuration Register          		(Offset 0044-0047h,R/W)
RCR_APM         EQU 02h
RCR_AM          EQU 04h
RCR_AB          EQU 08h               
RCR_MXDMA1      EQU 200h
RCR_MXDMA2      EQU 400h
RCR_RBLEN0      EQU 800h

; 5.9   ERSR:Early Rx Status Register           		(Offset 0036h     ,R)
; 5.10  Command Register 
CR_TE           EQU 04h
CR_RE           EQU 08h
CR_RST          EQU 10h  

HEADERCOLOR 	EQU 0Fh
VIDEOCOLOR		EQU 07h
OPTIONSCOLOR	EQU 0Eh 

SPACE			EQU 20h
;========================================|
;                                        |
;	0      0000      black               |
;	1      0001      blue                |
;	2      0010      green               |
;	3      0011      cyan                |
;	4      0100      red                 |
;	5      0101      magenta             |
;	6      0110      brown               |
;	7      0111      light gray          |
;	8      1000      dark gray           |
;	9      1001      light blue          |
;	A      1010      light green         |
;	B      1011      light cyan          |
;	C      1100      light red           |
;	D      1101      light magenta       |
;	E      1110      yellow              |
;	F      1111      white               |
;                                        |
;========================================|                             

STACK SEGMENT STACK 'STACK'
    DB      1024h  DUP(0) 
    TOPS    LABEL BYTE
STACK ENDS

DATA SEGMENT PUBLIC 'DATA' USE16

	HEADER      	DB 	'   00 01 02 03 04 05 06 07 08 09 0A 0B 0C 0D 0E 0F', 0
	
	TAB         	DB	'0123456789ABCDEF'
	
	ROW				DW 	0
	
	NEWLINE			DW  0
	
	PACKETSTR		DB	'PACKET: ', 0
	OFFSETSTR		DB	'OFFSET: ', 0
	LENGTHSTR		DB	'LENGTH: ', 0
    
    PCICONFIG 		DD 	80000000h

	TOTALDEVICES	DB	20h
	TOTALBUS		DB 	255
	
	BUSNUMBER		DD	0
	
	ETHDEVICE		DD 	813910ECh						; NETWORK CARD REALTEK 8139
	DEVICEID		DD 	?

    IOBase          DW 00h
	
	PACKETOFFSET	DW 0
					
	LENPACK			DW 0
					
	QTDEPACK		DW 0
					
	ALIGN			16
	RXBUFFER		DB	8192 DUP(0)

DATA ENDS

;==================================================================================

CODE SEGMENT PUBLIC 'CODE' USE16
    ASSUME CS:CODE, DS:DATA, ES:DATA
    
    MAIN PROC

        MOV 	AX, DATA	
        MOV 	DS, AX	
        MOV 	ES, AX

        CALL    CLS
	
	@@: MOV     EAX, PCICONFIG							; CHECK PCI ENABLE BIT 80000000h
        MOV     DX, CONFIG_ADDRESS						; PCI CONFIG REGISTER 0CF8h
        OUT     DX, EAX									; SELECT PCICONFIG TO GET DATA
			
        IN      EAX, DX									; GET CONFIG REGISTER 0CF8h
        CMP     EAX, PCICONFIG							; PCI IS ENABLE ?
        JNE     EOF										; IF NO GOTO END
			
		CALL	FINDDEVICE								; FIND ALL PCI DEVICES
		JC		@f	

        CALL    GETIOBASE                               ; GET I/O ADDRESS									
			
		CALL    ENABLEBUSMASTERING
        CALL    RESETNIC 
		
		CALL	GETPACKETOFFSET							; GET PACKET OFFSET ON RXBUFFER
		CALL	SHOWPACKET								; DUMP PACKET

	@@:	XOR     EDX, EDX	
		XOR		EAX, EAX
        MOV		DX, WORD PTR IOBase
		ADD		DX, ISR
		IN		AX, DX
		
		CMP		AX, 0
		JE		@b
		
		XOR		EDX, EDX
		XOR		EAX, EAX
		MOV		DX, WORD PTR IOBase
		ADD		DX, ISR
		MOV		AX, ISR_ROK OR ISR_RER OR ISR_RXOVW OR ISR_FIFOOVW
		OUT		DX, AX
		
		XOR		EAX, EAX
		MOV		DX, WORD PTR IOBase
		ADD		DX, 3Ah									; REGISTER CBR -> (DW) 003Ah-003Bh (R/W) CURRENT ADDRESS OF PACKET 
		IN		AX, DX									; THE INITIAL VALUE IS 0000h. IT REFLECTS TOTAL 
														; RECEIVED BYTE-COUNT IN THE RX BUFFER
														
		SUB		AX, PACKETOFFSET						; CALC LENGTH OF PACKET
		MOV		WORD PTR LENPACK, AX

		INC		QTDEPACK								; COUNT PACKET RECEIVED
		CALL	CLS										; GET PACKET OFFSET ON RXBUFFER
		CALL	GETPACKETOFFSET
		CALL	SHOWPACKET								; DUMP PACKET
		
	
		JMP		@b
		
    EOF:  
        MOV     AX, 4C00h
        INT     21h    
    
    MAIN ENDP
	
	;==================================================================================
	
	GETPACKETOFFSET PROC
	
		MOV		AX, DATA
		MOV		DS, AX
	
		XOR		EAX, EAX
		MOV		DX, WORD PTR IOBase
		ADD		DX, 3Ah									; REGISTER CBR -> (DW) 003Ah-003Bh (R/W) CURRENT ADDRESS OF PACKET 
		IN		AX, DX									; THE INITIAL VALUE IS 0000h. IT REFLECTS TOTAL 
														; RECEIVED BYTE-COUNT IN THE RX BUFFER
														
														
		CMP		AX, WORD PTR LENGTHOF RXBUFFER			; BUFFER IS FULL ?
		JGE		RESETALL								; RESET NIC AND VARS
		
		MOV		WORD PTR PACKETOFFSET, AX
		
		RET
		
	RESETALL:
	
		CALL	RESETNIC
		MOV		WORD PTR PACKETOFFSET, 0
		MOV		WORD PTR LENPACK, 0
		
		RET
		
	GETPACKETOFFSET ENDP
	
	;==================================================================================

    GETIOBASE PROC

        MOV		EAX, PCICONFIG							; PCICONFIG = BUS, DEVICE, FUNCTION 
        ADD     EAX, 10h
		MOV		DX, CONFIG_ADDRESS						; GET CONFIG REGISTER 0CF8h
		OUT		DX, EAX									; SELECT PCICONFIG TO GET DATA
		
		MOV		DX, CONFIG_DATA							; PCI DATA REGISTER 0CFCh
		IN		EAX, DX									; GET DATA FROM PCI REGISTER

        AND     AL, 0FEh                                ; MASK ADDRESS
        MOV     WORD PTR IOBase, AX

        RET

    GETIOBASE ENDP

    ;==================================================================================

    CLS PROC

        PUSH    ES
        MOV     AX, 0B800h
        MOV     ES, AX 
        XOR     DI, DI

        MOV     CX, 80 * 25								; 80 COL * 25 ROW
        MOV     AX, 720h

    @@: MOV     ES:[DI], AX
        ADD     DI, 2
        LOOP    @b

        POP     ES

        RET

    CLS ENDP  

    ;==================================================================================

    FINDDEVICE PROC

		XOR		ECX, ECX
		MOV 	CL, TOTALDEVICES						; TOTAL DEVICES 0~31 = 32	
		
	@@: MOV		EAX, PCICONFIG							; PCICONFIG = BUS, DEVICE, FUNCTION 
		MOV		DX, CONFIG_ADDRESS						; GET CONFIG REGISTER 0CF8h
		OUT		DX, EAX									; SELECT PCICONFIG TO GET DATA
		
		MOV		DX, CONFIG_DATA							; PCI DATA REGISTER 0CFCh
		IN		EAX, DX									; GET DATA FROM PCI REGISTER

		MOV		DI, OFFSET DEVICEID						; ADDRESS TO STORE PCI DATA
		STOSD											; COPY DATA TO DEVICEID ADDRESS
		PUSH	ECX
		MOV		ECX, 4
		MOV		SI, OFFSET ETHDEVICE
		MOV		DI, OFFSET DEVICEID	
		REPE	CMPSB									; CMP PCIDEVICE WITH ETHDEVICE
		JE		DEVICEFOUND								; IF EQUAL, DEVICE FOUND
		POP		ECX
		ADD		DWORD PTR PCICONFIG, 800h				; ADD DEVICE
		LOOP	@b
		
		CMP		DWORD PTR PCICONFIG, LASTDEVICE			; CMP LAST BUS AND LAST DEVICE = 80FFFF00h
		JGE		NODEVICE								; IF EQUAL OR GREATER ETHDEVICE NOT FOUND
		
		MOV		DWORD PTR PCICONFIG, FIRSTDEVICE		; START PCI BUS 80000000h
		ADD		DWORD PTR BUSNUMBER, 10000h				; NEXT PCI BUS
		
		MOV		ECX, DWORD PTR BUSNUMBER
		ADD		DWORD PTR PCICONFIG, ECX				; PCI DEVICE = PCICONFIG + BUSNUMBER
		
		JMP		FINDDEVICE

	NODEVICE:
	
		STC												; SET CARRY FLAG IF NOT FOUND DEVICE
		RET
		
	DEVICEFOUND:

		POP		ECX
		RET
		
	FINDDEVICE ENDP

    ;==================================================================================

    ENABLEBUSMASTERING PROC

        MOV     EAX, PCICONFIG                          ; PCICONFIG = BUS, DEVICE, FUNCTION 
        ADD     AL, 04h                                 ; PCI COMMAND
        MOV		DX, CONFIG_ADDRESS						; GET CONFIG REGISTER 0CF8h
		OUT		DX, EAX									; SELECT PCICONFIG TO GET DATA

        MOV		DX, CONFIG_DATA							; PCI DATA REGISTER 0CFCh
		IN		EAX, DX									; GET DATA FROM PCI REGISTER

        OR      AL, 04h                                 ; ENABLE BUS MASTERING
        MOV     EBX, EAX                                ; SAVE EAX

        MOV     EAX, PCICONFIG                          ; PCICONFIG = BUS, DEVICE, FUNCTION 
        ADD     AL, 04h                                 ; PCI COMMAND
        MOV		DX, CONFIG_ADDRESS						; GET CONFIG REGISTER 0CF8h
		OUT		DX, EAX									; SELECT PCICONFIG TO GET DATA

        MOV     EAX, EBX
        MOV		DX, CONFIG_DATA							; PCI DATA REGISTER 0CFCh
        OUT     DX, AX

        RET

    ENABLEBUSMASTERING ENDP

    ;==================================================================================
    
    RESETNIC PROC 

        MOV     DX, IOBase
        ADD     DX, CR
        MOV     AL, CR_RST
        OUT     DX, AL

        MOV     DX, IOBase
        ADD     DX, CR
        MOV     AL, CR_RE + CR_TE
        OUT     DX, AL

        MOV     DX, IOBase
        ADD     DX, TCR
        MOV     EAX, TCR_IFG0 OR TCR_IFG1 OR TCR_MXDMA2 OR TCR_MXDMA1 
        OUT     DX, EAX

        MOV     DX, IOBase
        ADD     DX, RRCR
        MOV     EAX, RCR_RBLEN0 OR RCR_MXDMA2 OR RCR_MXDMA1 OR RCR_AB OR RCR_AM OR RCR_APM 
        OUT     DX, EAX
		
		XOR     EAX, EAX
        XOR     ESI, ESI
        MOV     AX, DATA
        SHL     EAX, 4
        MOV     SI, OFFSET RXBUFFER
        ADD     EAX, ESI

        MOV     DX, IOBase
        ADD     DX, RBSTART
        OUT     DX, EAX

        MOV     DX, IOBase
        ADD     DX, IMR
        MOV     AL, R39_INTERRUPT_MASK 
        OUT     DX, AL  
        
        RET
        
    RESETNIC ENDP  
	
	;======================================================================================
	;	SHOW PACKET
	;======================================================================================
	
	SHOWPACKET PROC
	
		PUSH	ES
		MOV		AX, DATA
		MOV		DS, AX
		MOV		AX, 0B800h
		MOV		ES, AX
		
		MOV		DI, 6
		MOV		SI, OFFSET HEADER
		CALL	PRINTSTR 
		
		MOV		ROW, WORD PTR 0
		
		CALL    PRINTBUFFER
		
		ADD		DI, 0A0h
		
		MOV		SI, OFFSET PACKETSTR
		CALL	PRINTSTR 

		MOV		SI, OFFSET QTDEPACK
		CALL	PRINTVALUE
		
		ADD		DI, 86h
		
		MOV		SI, OFFSET OFFSETSTR
		CALL	PRINTSTR
		
		MOV		SI, OFFSET PACKETOFFSET
		CALL	PRINTVALUE
		
		ADD		DI, 86h
		
		MOV		SI, OFFSET LENGTHSTR
		CALL	PRINTSTR
		
		MOV		SI, OFFSET LENPACK
		CALL	PRINTVALUE
		
		POP		ES
		RET
	
	SHOWPACKET ENDP
	
	;======================================================================================
	;	PRINT HEADER OF REAL MODE DEBUG
	;======================================================================================
    
    PRINTSTR PROC
            
    @@: LODSB
        CMP     AL, 0
        JE      @f
        CMP     AL, '$'
        JE      @f
        MOV     AH, HEADERCOLOR
        STOSW
        JMP     @b
        
    @@: RET
    
    PRINTSTR ENDP 
	
	;======================================================================================
	;	PRINT MEMORY BUFFER
	;====================================================================================== 
    
    PRINTBUFFER PROC

		XOR		EAX, EAX
		MOV		DX, WORD PTR IOBase
		ADD		DX, 3Ah									; REGISTER CBR -> (DW) 003Ah-003Bh (R/W) CURRENT ADDRESS OF PACKET 
		IN		AX, DX									; THE INITIAL VALUE IS 0000h. IT REFLECTS TOTAL 
														; RECEIVED BYTE-COUNT IN THE RX BUFFER
														
		SUB		AX, WORD PTR LENPACK					; LENGTH OF PACKET = (CURRENT OFFSET PACKET - LAST OFFSET PACKET)

		MOV		SI, OFFSET RXBUFFER						; START OFFSET OF BUFFER
		ADD		SI, AX									; + LAST OFFSET PACKET
		ADD		SI, 4									; IGNORE CRC

		MOV     DI, 140h 
		MOV		WORD PTR ROW, 0
		
    @@: MOV		AX, WORD PTR LENPACK					
		CMP		AX, 0									; LENGTH OF PACKET = 0?
		JE		ZEROLEN									; DUMP 8 ROWS
		
		MOV		AX, WORD PTR ROW						; DUMP ROWS OF PACKET
		CMP		AX, WORD PTR LENPACK
		JG		@f
		
	ZEROLEN:
		CMP     ROW, 80h                                ; ROW - 00h~08h
        JGE     @f
		
        MOV     CX, 10h                                 ; COL - 00h~0Fh 
        CALL    HEADERBUFFER
    
	CROW:
	
        LODSB
        MOV     DL, AL
        RCR     AL, 4
		AND		AL, 0Fh
        XLATB
        MOV     AH, VIDEOCOLOR
        STOSW
        
        MOV     AL, DL
        AND     AL, 0Fh
        XLATB   
        STOSW
        
        MOV     AL, SPACE
        STOSW
		
		LOOP	CROW
		
		ADD		DI, 34h										; LINE FEED
		ADD		ROW, 10h

        JMP     @b    

    @@: ADD		DI, NEWLINE									; NEW LINE
		RET
        
    PRINTBUFFER ENDP
	
	;======================================================================================
	;	PRINT HEADER OF BUFFER 0000: ~ 00F0:
	;======================================================================================
    
    HEADERBUFFER PROC
	
		PUSH	DX
        
		MOV		BX, OFFSET TAB
		
        MOV     AH, HEADERCOLOR

        MOV     DX, ROW
		
		MOV		AL, DH
        RCR     AL, 4
		AND		AL, 0Fh
        XLATB
        MOV     AH, HEADERCOLOR
        STOSW
        MOV     AL, DH
        AND     AL, 0Fh
        XLATB   
        STOSW
		
		MOV		AL, DL
        RCR     AL, 4
		AND		AL, 0Fh
        XLATB
        MOV     AH, HEADERCOLOR
        STOSW
        MOV     AL, DL
        AND     AL, 0Fh
        XLATB   
        STOSW
        
        MOV     AL, ':'
        STOSW
        
        MOV     AL, SPACE 
        STOSW
		
		POP		DX
        
        RET
        
    HEADERBUFFER ENDP
	
	;======================================================================================
	;	QTDE PACKECT RECEIVE
	;======================================================================================
	
	PRINTVALUE PROC
	
		MOV		CX, 2								
		ADD		SI, CX
		DEC		SI
		
	@@: LODSB
        MOV     DL, AL
        RCR     AL, 4
		AND		AL, 0Fh
        XLATB
        MOV     AH, VIDEOCOLOR
        STOSW
        
        MOV     AL, DL
        AND     AL, 0Fh
        XLATB   
        STOSW
		
		SUB		SI, 2
		
		LOOP	@b
		
		MOV		AL, 'h'
		STOSW

		RET
	
	PRINTVALUE ENDP
	
CODE ENDS

END MAIN