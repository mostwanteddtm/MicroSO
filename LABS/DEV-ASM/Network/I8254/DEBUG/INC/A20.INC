CODESEG16 SEGMENT USE16

	ENABLEA20 PROC                    			; HARDWARE ENABLE GATE A20
	
		CLI
		PUSHA
		
		CALL    WAIT_INPUT
        MOV     AL, 0ADh
        OUT     64h, AL							; DISABLE KEYBOARD
        CALL    WAIT_INPUT

        MOV     AL, 0D0h
        OUT     64h, AL							; TELL CONTROLLER TO READ OUTPUT PORT
        CALL    WAIT_OUTPUT

        IN      AL, 60h
        PUSH    EAX								; GET OUTPUT PORT DATA AND STORE IT
        CALL    WAIT_INPUT

        MOV     AL, 0D1h
        OUT     64h, AL							; TELL CONTROLLER TO WRITE OUTPUT PORT
        CALL    WAIT_INPUT

        POP     EAX
        OR      AL, 2							; SET BIT 1 (ENABLE A20)
        OUT     60h, AL							; WRITE OUT DATA BACK TO THE OUTPUT PORT

        CALL    WAIT_INPUT
        MOV     AL, 0AEh						; ENABLE KEYBOARD
        OUT     64h, AL

        CALL    WAIT_INPUT
		POPA
        STI
        RET

	WAIT_INPUT:									; WAIT FOR INPUT BUFFER TO BE CLEAR
        IN      AL, 64h
        TEST    AL, 2
        JNZ     WAIT_INPUT
        RET

	WAIT_OUTPUT:								; WAIT FOR OUTPUT BUFFER TO BE CLEAR
        IN      AL, 64h
        TEST    AL, 1
        JZ      WAIT_OUTPUT
        RET
		
	ENABLEA20 ENDP

CODESEG16 ENDS