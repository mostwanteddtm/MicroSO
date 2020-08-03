.386

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

EXTERN KEYPRESSED:BYTE
EXTERN BUFFER:WORD

CONFIG_ADDRESS  EQU 0CF8h
CONFIG_DATA     EQU 0CFCh 

FIRSTDEVICE		EQU 80000000h
LASTDEVICE		EQU 80FFF800h

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
     
DATA ENDS

CODE SEGMENT PUBLIC 'CODE' USE16 
    ASSUME CS:CODE, DS:DATA, ES:DATA, SS:STACK  
    
    MAIN PROC NEAR
	
		MOV		AX, 03h									; SET VIDEO MODE 80x25
		INT		10h
	
	@@: MOV		DH, 17h									; ROW 23d
		MOV		DL, 0									; COL 0
		XOR		BX, BX	
		MOV		AH, 02h									; SET CURSOR POSITION
		INT		10h	
			
        MOV 	AX, DATA	
        MOV 	DS, AX	
        MOV 	ES, AX	
	
		MOV     EAX, PCICONFIG							; CHECK PCI ENABLE BIT 80000000h
        MOV     DX, CONFIG_ADDRESS						; PCI CONFIG REGISTER 0CF8h
        OUT     DX, EAX									; SELECT PCICONFIG TO GET DATA
			
        IN      EAX, DX									; GET CONFIG REGISTER 0CF8h
        CMP     EAX, PCICONFIG							; PCI IS ENABLE ?
        JNE     EOF										; IF NO GOTO END
			
		CALL	FINDDEVICE								; FIND ALL PCI DEVICES
		JC		@f										
			
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
		
	@@:	MOV		EDX, DWORD PTR PCICONFIG
		MOV     SI, OFFSET CONTENTLOADED				; SI = BUFFER TO PRINT DATA		
		MOV		CX, 0FFh								; TOTAL DATA TO PRINT
		
		CALL	DEBUGRMODE								; PRINT DATA
		
		XOR		AX, AX									; GET KEY PRESS
		INT		16h
		
		CMP		AH, 01h									; KEY PRESSED ESC
		JE		EOF
		CMP		AH, 1Ch									; KEY PRESSED ENTER
		JE		EOF
		
		MOV		KEYPRESSED, AH
		JMP		@b
		
	EOF:												; END OF PROGRAM	
        MOV 	AX, 4C00H
        INT 	21H
        
    MAIN ENDP 
	
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
    
CODE ENDS

END MAIN