.386 
.MODEL SMALL

EXTERN DEBUGRMODE:PROC
;======================================================================================|
;	PUBLIC METHOD FOR DEBUG ON REAL MODE                                               |
;                                                                                      |
;	DEBUGRMODE:                                                                        |
;	IN:                                                                                |
;		CX = SIZE OF BUFFER TO BE COPIED                                               |
;		DS:SI = ORIGIN OF THE CONTENT TO BE COPIED TO THE BUFFER                       |
;		AX, BX, CX, DX, SI, DI, BP, SP, DS, ES, SS = VALUE DEFINED ON MAIN PROGRAM     |
;                                                                                      |
;	OUT: BUFFER = COPIED FROM CONTENT LOADED IN MEMORY                                 |
;		 SHOW REGISTERS VALUES (AX, BX, CX, DX, SI, DI, BP, SP, CS, DS, ES, SS)        |
;======================================================================================| 

EXTERN          KEYPRESSED:BYTE
EXTERN          BUFFER:WORD

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

STACK SEGMENT STACK 'STACK'
    DB      100h  DUP(0) 
    TOPS    LABEL BYTE
STACK ENDS

DATA SEGMENT PUBLIC 'DATA' USE16
    
    PCICONFIG 		DD 	80000000h

	TOTALDEVICES	DB	20h
	TOTALBUS		DB 	255
	
	BUSNUMBER		DD	0

    CONTENTLOADED	DD	3Fh DUP(?)
	
	ETHDEVICE		DD 	813910ECh						; NETWORK CARD REALTEK 8139
	DEVICEID		DD 	?

    BASE            DB 10h
    
    IOBase          DW 00h

    ALIGN           16
    FRAME      	    DB  40h DUP(0FFh)
					DB	60h DUP(00h)
					
	ALIGN			16
	RXBUFFER		DB	1024 DUP(0)

DATA ENDS

;==================================================================================

CODE SEGMENT PUBLIC 'CODE' USE16
    ASSUME CS:CODE, DS:DATA, ES:DATA
    
    MAIN PROC

        MOV 	AX, DATA	
        MOV 	DS, AX	
        MOV 	ES, AX

        CALL    CLS
	
	@@: MOV		DH, 17h									; ROW 23d
		MOV		DL, 0									; COL 0
		XOR		BX, BX	
		MOV		AH, 02h									; SET CURSOR POSITION
		INT		10h	

		MOV     EAX, PCICONFIG							; CHECK PCI ENABLE BIT 80000000h
        MOV     DX, CONFIG_ADDRESS						; PCI CONFIG REGISTER 0CF8h
        OUT     DX, EAX									; SELECT PCICONFIG TO GET DATA
			
        IN      EAX, DX									; GET CONFIG REGISTER 0CF8h
        CMP     EAX, PCICONFIG							; PCI IS ENABLE ?
        JNE     EOF										; IF NO GOTO END
			
		CALL	FINDDEVICE								; FIND ALL PCI DEVICES
		JC		@f	

        CALL    GETIOBASE                               ; GET I/O ADDRESS									
			
		MOV		EAX, PCICONFIG							; PCICONFIG = BUS, DEVICE, FUNCTION
		MOV		DX, CONFIG_ADDRESS						; GET CONFIG REGISTER 0CF8h
		OUT		DX, EAX									; SELECT FIRST REGISTER IN PCICONFIG
			
		MOV		ECX, 3Fh	
		MOV     SI, OFFSET CONTENTLOADED	
			
	NEXTREG:	
			
		PUSH	EAX	
			
        MOV     DX, CONFIG_DATA							; PCI DATA REGISTER 0CFCh
        IN      EAX, DX									; GET DATA FROM PCI REGISTER
	
		CMP		ECX, 3Fh								; (3Fh X 4h) + 4h = FFh (TOTAL PCI REGISTERS) 
		JNE		EBXOK	
		MOV		EBX, EAX	
			
	EBXOK:	
	
        MOV     [SI], EAX								; MOV PCI DATA TO BUFFER 
			
		POP		EAX	
			
		ADD		EAX, 4									; FOR EVERY INTERACTION 4 BYTES DATA
		ADD		SI, 4	
			
		MOV		DX, CONFIG_ADDRESS						; PCI CONFIG REGISTER 0CF8h 
		OUT		DX, EAX									; SELECT PCICONFIG TO GET DATA
		
		LOOP	NEXTREG

	@@: XOR     EDX, EDX	
        MOV		DX, WORD PTR IOBase
		MOV     SI, OFFSET RXBUFFER						; SI = BUFFER TO PRINT DATA	
		ADD		SI, 4									; FIRST 4 BYTES ??? SEARCH ABOUT
		MOV		CX, 0FFh								; TOTAL DATA TO PRINT
		
		CALL	DEBUGRMODE								; PRINT DATA
		CALL    ENABLEBUSMASTERING
        CALL    RESET 
        ;CALL    ISSUECMD

		; set 1 million microseconds interval (1 second)
		MOV     CX, 0Fh
		MOV     DX, 4240h
		MOV     AH, 86h
		INT     15h
		
		;XOR		AX, AX									; GET KEY PRESS
		;INT		16h
		
		;CMP		AH, 01h									; KEY PRESSED ESC
		;JE		EOF
		;CMP		AH, 1Ch									; KEY PRESSED ENTER
		;JE		EOF
		;
		;MOV		KEYPRESSED, AH
		
		JMP		@b
		
    EOF:  
        MOV     AX, 4C00h
        INT     21h    
    
    MAIN ENDP

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
        XOR     AX, 0B800h
        MOV     ES, AX 
        XOR     DI, DI

        MOV     CX, 0F00h
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
    
    RESET PROC 

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
        
    RESET ENDP  

    ;==================================================================================
    
    ISSUECMD PROC
          
        CLI
		
		XOR     EAX, EAX
        XOR     ESI, ESI
        MOV     AX, DATA
        SHL     EAX, 4
        MOV     SI, OFFSET FRAME
        ADD     EAX, ESI

        MOV     DX, IOBase
        ADD     DX, TSAD0
        OUT     DX, EAX

        MOV     DX, IOBase
        ADD     DX, TSD0
        MOV     EAX, 40h                                ; PACKET LENGHT
        OUT     DX, EAX
        STI 
         
        RET
        
    ISSUECMD ENDP

    ;==================================================================================
	
CODE ENDS

END MAIN