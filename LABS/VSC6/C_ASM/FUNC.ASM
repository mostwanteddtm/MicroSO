.386
.MODEL FLAT, C

PUBLIC getvalue		;case sensitive
PUBLIC sum

.STACK
.DATA
.CODE

	getvalue	PROC

		MOV		EAX, 813910ECh
		RET

	getvalue	ENDP

	sum			PROC VAL1:DWORD, VAL2:DWORD

		MOV		EAX, DWORD PTR VAL1
		ADD		EAX, DWORD PTR VAL2
		RET

	sum			ENDP

END