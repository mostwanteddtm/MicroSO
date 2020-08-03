.386P 
;======================================================================================|
;																					   |
;	PUBLIC METHOD FOR DEBUG ON PROTECTED MODE                                          |
;                                                                                      |
;	DEBUGPMODE:                                                                        |
;	IN:                                                                                |
;		ECX = SIZE OF BUFFER TO BE COPIED                                              |
;		DS:ESI = ORIGIN OF THE CONTENT TO BE COPIED TO THE BUFFER                      |
;		EAX, EBX, ECX, EDX, ESI, EDI, EBP, ESP,										   | 
;		DS, ES, SS = VALUE DEFINED ON MAIN PROGRAM     								   |
;                                                                                      |
;	OUT: BUFFER = COPIED FROM CONTENT LOADED IN MEMORY                                 |
;		 SHOW REGISTERS (EAX, EBX, ECX, EDX, ESI, EDI, EBP, ESP, CS, DS, ES, SS)       |
;																					   |
;======================================================================================| 

INCLUDE START.INC

;======================================================================================|
;	ETHPOOL
;		IN: NOTHING
;		OUT: EAX 		   	= BITS RTL8139_REG_COMMAND
;			 DEVICEIOADDR  	= IO BASE ADDRESS
;			 CONTENTLOADED 	= BUFFER (3Fh DWORD) TO PCI DEVICE REGISTERS
;			 EDX 			= DEVICE FOUND (PCICONFIG)
;
;		ERR: EDX 			= DEVICE NOT FOUND (PCICONFIG)
;======================================================================================|
ETHPOOL			PROTO C
EXTERN			DEVICEID:DWORD					; IF DEVICE FOUND, CONTAINS VENDOR AND DECIVE ID 
EXTERN			DEVICEIOADDR:DWORD				
EXTERN			CONTENTLOADED:DWORD
EXTERN			PCICONFIG:DWORD

BUFFERSIZE		EQU 0FFh

DATASEG32 SEGMENT USE32
 
	TIMER			DB 0
	RTC				DB 0
	DATA			DQ ?
	
	TESTE			DD 3Fh DUP(?)

DATASEG32 ENDS

CODESEG32 SEGMENT USE32
	ASSUME CS:SEGS32,DS:SEGS32
	
	START32 PROC
	
		MOV 	AX, SELDATADESC32				; RELOAD ALL SEGMENT REGS WITH 32BIT SELECTORS
		MOV 	DS, AX
		MOV		AX, SELVIDEODESC32
		MOV		ES, AX
		
		INVOKE	ETHPOOL

		MOV		EBX, DWORD PTR PCICONFIG
		MOV		ESI, OFFSET CONTENTLOADED
		MOV		ECX, BUFFERSIZE

		STI

		DB		0EAh
		DD		DEBUGPMODE
		DW		SELDEBUGDESC32

	START32 ENDP
	
	;======================================================================================|
	;	CHECKKEYPRESS
	;		IRQ 01h - INT 21h
	;======================================================================================|
	
	CHECKKEYPRESS PROC
	
		MOV 	AX, SELDATADESC32			
		MOV 	DS, AX
	
		MOV 	BYTE PTR KEYPRESSED, 0
	@@: CMP		BYTE PTR KEYPRESSED, 0
		JE		@b

		INVOKE	ETHPOOL

		MOV		EBX, DWORD PTR PCICONFIG
		MOV		ESI, OFFSET CONTENTLOADED
		MOV		ECX, BUFFERSIZE

		DB		0EAh
		DD		DEBUGPMODE
		DW		SELDEBUGDESC32
	
	CHECKKEYPRESS ENDP
	
CODESEG32 ENDS

END START16     								; START PROGRAM IN CODEDESC16:START