;========================================= MACRO AREA ==========================================================

	PRINT_REG_STR16 MACRO REG
		MOV 	AX, REG
		XCHG	AL, AH
		MOV		AH, 00001111b
		STOSW
		MOV		AX, REG
		MOV		AH, 00001111b
		STOSW
		MOV		AL, 3Ah
		MOV		AH, 00001111b
		STOSW
		MOV		AL, 20h
		MOV		AH, 00001111b
		STOSW
		MOV		AL, 20h
		MOV		AH, 00001111b
		STOSW
	ENDM

	PRINT_REG_STR32 MACRO REG
		MOV 	EAX, REG
		SHR		EAX, 16
		MOV		AH, 00001111b
		STOSW
		MOV		EAX, REG
		XCHG	AL, AH
		MOV		AH, 00001111b
		STOSW
		MOV		EAX, REG
		MOV		AH, 00001111b
		STOSW
		MOV		AL, 3Ah
		MOV		AH, 00001111b
		STOSW
		MOV		AL, 20h
		MOV		AH, 00001111b
		STOSW
	ENDM
	
;================================================================================================================