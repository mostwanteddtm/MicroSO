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

DATASEG32 SEGMENT USE32
 
	TIMER			DB 0
	RTC				DB 0
	DATA			DD 12345678h

DATASEG32 ENDS

CODESEG32 SEGMENT USE32
	ASSUME CS:SEGS32,DS:SEGS32
	
	START32 PROC

		MOV 	AX, SELDATADESC32				; RELOAD ALL SEGMENT REGS WITH 32BIT SELECTORS
		MOV 	DS, AX
		MOV		AX, SELVIDEODESC32
		MOV		ES, AX
		
		STI

		MOV		EAX, 12345678h
		MOV		ECX, SIZEOF DATA
		MOV		ESI, OFFSET DATA
		STC										; SET CARRY FLAG

		DB		0EAh
		DD		DEBUGPMODE
		DW		SELDEBUGDESC32

	START32 ENDP
	
	CHECKKEYPRESS PROC
	
		MOV 	AX, SELDATADESC32			
		MOV 	DS, AX
	
		MOV 	BYTE PTR KEYPRESSED, 0
	@@: CMP		BYTE PTR KEYPRESSED, 0
		JE		@b
		
		MOV		EAX, 87654321h
		MOV		ECX, SIZEOF DATA
		MOV		ESI, OFFSET DATA
		
		DB		0EAh
		DD		DEBUGPMODE
		DW		SELDEBUGDESC32
	
	CHECKKEYPRESS ENDP
	
CODESEG32 ENDS

END START16     								; START PROGRAM IN CODEDESC16:START