.386P 

INCLUDE DEFS.INC
INCLUDE IRQ0.INC
INCLUDE GDT.INC
INCLUDE IDT.INC

DATASEG16 SEGMENT USE16 

	PRG_BASE16 		DD ?    						
	PRG_BASE32 		DD ? 

	OLD_INT15H 		DD ?                    ;OLD RMODE INT 15H HANDLER
	OLD_INT21H 		DD ?                    ;OLD RMODE INT 21H HANDLER	

DATASEG16 ENDS

DATASEG32 SEGMENT USE32
	TIMER DB 0
DATASEG32 ENDS

CODESEG16 SEGMENT USE16  						; START THE 16BIT CODE SEGMENT
	ASSUME CS:SEGS16,DS:SEGS16

	START16 PROC

		CLD

		MOV		AX, CS
		MOV		DS, AX 
		MOV		ES, AX
		
		MOV		AX, 03h
		INT		10h
		
		MOV 	AX, 3515H
		INT 	21H            					;GET INT 15H
		MOV 	WORD PTR[OLD_INT15H+2], ES
		MOV 	WORD PTR[OLD_INT15H+0], BX
		PUSH 	DS
		POP 	ES

		MOV 	AX, 2515H
		MOV 	DX, OFFSET INT15H
		INT 	21H 

		MOV 	AX, 3521H
		INT 	21H            					;GET INT 21H
		MOV 	WORD PTR[OLD_INT21H+2], ES
		MOV 	WORD PTR[OLD_INT21H+0], BX		

		XOR 	EAX, EAX						; SETUP SOME OTHER VARIABLES
		MOV 	AX, CS
		SHL 	EAX, 4    						; LINEAR ADDR
		MOV 	PRG_BASE16,EAX

		XOR 	EAX, EAX
		MOV 	AX, SEGS32
		SHL 	EAX, 4
		MOV 	PRG_BASE32, EAX  				; WE WILL NEED THIS LATER

		CALL	INSTALL_GDT

		MOV 	EAX, PRG_BASE16					; SETUP GDT AND IDT BASE
		ADD 	EAX, GDT_START
		MOV 	GDT_ADDR, EAX
		
		MOV 	EAX, PRG_BASE16
		ADD 	EAX, IDT_START
		MOV 	IDT_ADDR, EAX
												; WE ARE NOW READY TO MOVE TO 16BIT PMODE 
		CLI   									; NO MORE IRQS ALLOWED PAST THIS POINT

		LIDT 	[IDTR]
		LGDT 	[GDTR]

		MOV 	EAX, CR0						; GOTO PMODE!
		OR 		AL, 1           				; SET PM BIT
		MOV 	CR0, EAX       					; WE ARE NOW IN 16BIT PMODE
		
		DB 		0EAh, 0h, 0h, SELCODEDESC32, 0h ; jmp to PMODE and execute
		
		;PUSHFD
		;PUSH 	DWORD PTR SELCODEDESC32
		;PUSH 	DWORD PTR OFFSET START32
		;IRETD   								; GOTO 32BIT SEGMENT
	
	START16 ENDP
	
	INT09h PROC

		IN 		AL, 60H
		PUSH 	AX
		IN 		AL, 61H
		OR 		AL, 80H
		OUT 	61H, AL
		AND 	AL, 7FH
		OUT 	61H, AL
		POP 	AX
		TEST 	AL, 80H
		JZ 		@f
		IRETD
		
	@@:	ASSUME DS:SEGS16
		DB 		0EAh, 0h, 2h, SELCODEDESC32, 0h ; jmp to PMODE and execute
		
	INT09h ENDP
	
	INT15H PROC                       			; THIS IS THE NEW INT 15H HANDLER
	  JMP 	CS:[OLD_INT15H]
	INT15H ENDP

CODESEG16 ENDS

CODESEG32 SEGMENT USE32
	ASSUME CS:SEGS32,DS:SEGS32
	
	START32 PROC

		MOV 	AX, SELDATADESC32				; RELOAD ALL SEGMENT REGS WITH 32BIT SELECTORS
		MOV 	DS, AX
		MOV 	FS, AX
		MOV 	GS, AX
		MOV 	AX, SELVIDEODESC32
		MOV 	ES, AX
		
		MOV		ECX, 0FFFFFh
		LOOP	$

		STI
		
		JMP		$

		ORG		200h

		HLT
		
		;DB      66					
		;DB      0EAh
		;DD      STARTRM
		;DW      SELCODEDESC16  
		
	START32 ENDP
	
CODESEG32 ENDS

CODESEGRM SEGMENT PUBLIC USE16 'CODE'
    ASSUME CS:SEGS16, DS:SEGS16
	
	STARTRM PROC

        MOV 	AX, SELDATADESC16         			; CHANGE SEGMENTS BACK TO HAVE VALID
        MOV 	ES, AX          					;  REAL MODE ATTRIBUTES.
        MOV 	DS, AX
        MOV 	FS, AX
        MOV 	EAX,CR0
        AND 	EAX, 07FFFFFFEh
        MOV 	CR0,EAX               				; ENTER REAL MODE
        JMP 	FAR PTR FLUSHRL       				; FLUSH QUEUE
		
 FLUSHRL:
		MOV 	AX, 0B800h        					; ADDRESS SCREEN MEMORY FROM REAL MODE
		MOV		ES, AX
		MOV		AX, SEGS16							; GET DATA SEGMENT ADDRESS
		MOV		DS, AX								; PUT IN DS
		MOV		AX, STK0							; GET STACK SEGMENT ADDRESS
		MOV		SS, AX								; PUT IN SS
		MOV		SP, OFFSET STK0_LIMIT				; SET STACK POINTER

; SETP 21: SET IDTR TO DOS INTERRUPT TABLE
		LIDT	[POLD]								; LOAD DOS INTERRUPT VECTOR
		
		STI
		
		MOV		DI, 0A0h
		
		MOV		AX, 0752h
		STOSW
		
		MOV		AX, 074Dh
		STOSW
		
		MOV 	DH, 1
		MOV 	DL, 0
		MOV 	BH, 0
		MOV 	AH, 2
		INT 	10h

        MOV 	AH, 04Ch                    				;  DOS termination
        MOV 	AL, 01h
        INT 	21h
		
	STARTRM ENDP
	
CODESEGRM ENDS

END START16     								; START PROGRAM IN CODEDESC16:START
