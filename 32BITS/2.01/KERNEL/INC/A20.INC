CODESEG16 SEGMENT USE16

	ENABLE_A20 PROC                    			; HARDWARE ENABLE GATE A20
	
		PUSHF
		PUSH 	FS
		PUSH 	GS
		CLI

		XOR 	AX, AX                       	; SET A20 TEST SEGMENTS 0 AND 0FFFFH
		MOV 	FS, AX
		DEC 	AX
		MOV 	GS, AX

		CALL 	ENABLEA20TEST              		; IS A20 ALREADY ENABLED?
		JZ 		SHORT ENABLEA20DONE          	; IF YES, DONE

		IN 		AL, 92H                       	; PS/2 A20 ENABLE
		OR 		AL, 2
		JMP 	SHORT $+2
		JMP 	SHORT $+2
		JMP 	SHORT $+2
		OUT 	92H, AL

		CALL 	ENABLEA20TEST              		; IS A20 ENABLED?
		JZ 		SHORT ENABLEA20DONE          	; IF YES, DONE

		CALL 	ENABLEA20KBWAIT            		; AT A20 ENABLE
		JNZ 	SHORT ENABLEA20F0

		MOV 	AL, 0D1H
		OUT 	64H, AL

		CALL 	ENABLEA20KBWAIT
		JNZ 	SHORT ENABLEA20F0

		MOV 	AL, 0DFH
		OUT 	60H, AL

		CALL 	ENABLEA20KBWAIT

	ENABLEA20F0:                      			; WAIT FOR A20 TO ENABLE
		MOV 	CX, 800H                     	; DO 800H TRIES

	ENABLEA20L0:
		CALL 	ENABLEA20TEST              		; IS A20 ENABLED?
		JZ 		ENABLEA20DONE                	; IF YES, DONE

		IN 		AL, 40H                       	; GET CURRENT TICK COUNTER
		JMP 	SHORT $+2
		JMP 	SHORT $+2
		JMP 	SHORT $+2
		IN 		AL, 40H
		MOV 	AH, AL

	ENABLEA20L1:                      			; WAIT A SINGLE TICK
		IN 		AL, 40H
		JMP 	SHORT $+2
		JMP 	SHORT $+2
		JMP 	SHORT $+2
		IN 		AL, 40H
		CMP 	AL, AH
		JE 		ENABLEA20L1

		DEC 	CX
		JNZ 	ENABLEA20L0                 	; LOOP FOR ANOTHER TRY

		MOV 	AX, -1                    		; ERROR, A20 DID NOT ENABLE
		RET

	ENABLEA20DONE:
		POP 	GS
		POP 	FS
		POPF
		XOR 	AX, AX
		RET

	ENABLEA20KBWAIT:                  			; WAIT FOR SAFE TO WRITE TO 8042
		XOR 	CX, CX
	ENABLEA20KBWAITL0:
		JMP 	SHORT $+2
		JMP 	SHORT $+2
		JMP 	SHORT $+2
		IN 		AL, 64H                       	; READ 8042 STATUS
		TEST 	AL, 2                       	; BUFFER FULL?
		LOOPNZ 	ENABLEA20KBWAITL0        		; IF YES, LOOP
	RET

	ENABLEA20TEST:                    			; TEST FOR ENABLED A20
		MOV 	AL, FS:[0]                   	; GET BYTE FROM 0:0
		MOV 	AH, AL                       	; PRESERVE OLD BYTE
		NOT 	AL                          	; MODIFY BYTE
		XCHG 	AL, GS:[10H]                	; PUT MODIFIED BYTE TO 0FFFFH:10H
		CMP 	AH, FS:[0]                   	; SET ZERO IF BYTE AT 0:0 NOT MODIFIED
		MOV 	GS:[10H], AL                 	; PUT BACK OLD BYTE AT 0FFFFH:10H
		RET                             		; RETURN, ZERO IF A20 ENABLED
		
	ENABLE_A20 ENDP

CODESEG16 ENDS