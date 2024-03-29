.386P 

CODESEG16 SEGMENT USE16 'CODE'
CODESEG16 ENDS

DATASEG16 SEGMENT USE16
DATASEG16 ENDS

STACKSEG32 SEGMENT STACK USE32 'STACK'
	DB 1024 DUP (?)
STACKSEG32 ENDS

SEGS16 GROUP CODESEG16, DATASEG16

INCLUDE FAT12.INC
INCLUDE A20.INC
INCLUDE GDT.INC
INCLUDE IDT.INC
INCLUDE IRQ0.INC
INCLUDE KERNEL32.INC

DATASEG16 SEGMENT USE16 

	KERNEL32   		DB	"KERNEL32EXE"           			
	LENKERNEL32		DB	?							; TOTAL SECTORS OF KERNEL

DATASEG16 ENDS

DATASEG32 SEGMENT USE32

	X 				DD 0     						; COORDS OF CURSOR ON SCREEN
	Y 				DD 0
	TIMER 			DB 0
		
	CHAR			DB 4
		
	TOTALSECTORS	DB ?
	IMAGESIG		DB 'PE'
	
	ERRORMESSAGE	DB 'ERROR LOAD KERNEL 32!', 0

DATASEG32 ENDS

CODESEG16 SEGMENT USE16  							; START THE 16BIT CODE SEGMENT
	ASSUME CS:SEGS16, DS:SEGS16

	START16 PROC

		CLD
		
		MOV		AX, 3h
		INT		10h

		MOV		AX, SEGS16
		MOV		DS, AX           

		CALL	LOADKERNEL32						; FAT12.INC
		
		CALL	COPYSECTORS
		
		CLI
													; ENABLE THE A20 SO WE CAN ACCESS RAM ABOVE 1MB.
		CALL 	ENABLEA20							; A20.INC
		
		CALL	INSTALLGDT							; GDT.INC
		
		CALL	INSTALLIDT							; IDT.INC

		MOV 	EAX, CR0							; GOTO PMODE!
		OR 		AL, 1           					; SET PM BIT
		MOV 	CR0, EAX       						; WE ARE NOW IN 16BIT PMODE
		
		DB 		66h
		DB 		0EAh
		PM 		DD ?								; PM - PROTECTED MODE 32 BITS OFFSET - START32 PROC
		DW 		SELCODEDESC32						; SELECT DESCRIPTOR 32 BITS CODE

	START16 ENDP
	
	COPYSECTORS PROC
	
		PUSH	ES
		MOV		AX, DATASEG32
		MOV		ES, AX
		MOV		SI, OFFSET LENKERNEL32
		MOV		DI, OFFSET TOTALSECTORS
		MOVSB
		POP		ES
		RET
	
	COPYSECTORS ENDP

CODESEG16 ENDS

CODESEG32 SEGMENT USE32
	ASSUME CS:CODESEG32,DS:DATASEG32
	
	START32 PROC

		CALL	GOTOKERNEL32
	
		ERROREXECUTE:	
	
		CALL	SHOWERROR
		
		HLT

	START32 ENDP
	
	SHOWERROR PROC
	
		MOV		AX, SELDATADESC32
		MOV		DS, AX
		
		MOV		AX, SELVIDEODESC32
		MOV		ES, AX
		
		XOR		EDI, EDI
		XOR		ESI, ESI
		
		MOV		SI, DATASEG32
		SHL		ESI, 4
		ADD  	ESI, OFFSET ERRORMESSAGE
		
	@@:
		LODSB
		CMP		AL, 0
		JE		@f
		MOV		AH, 0Fh
		STOSW
		JMP		@b
		
	@@:
		
		RET
	
	SHOWERROR ENDP

CODESEG32 ENDS

END START16     					
