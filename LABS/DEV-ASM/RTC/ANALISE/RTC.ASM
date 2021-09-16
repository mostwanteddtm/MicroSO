ORG 100h  

    CMOS_PORT 	EQU 70H ;Base Port for CMOS Chip 
    CR 			EQU 0DH
	LF 			EQU 0AH

START: 

    CALL 		UPD_IN_PR ;CHECK FOR UPDATE IN PROCESS
	JNC 		RTC_2A ;GO AROUND IF OK
	JMP 		ERROR ;IF ERROR
	RTC_2A: 	CLI ;INTERRUPTS OFF DURING READ
	MOV 		DL,-2 ;-2 goes to 0 for PORT_INC_2
	CALL 		PORT_INC_2 ;SET ADDRESS OF SECONDS
	IN 			AL,CMOS_PORT+1 ;Get BCD value returned
	MOV 		DH, AL ;SAVE IN DH
	CALL 		PORT_INC_2 ;SET ADDRESS OF MINUTES
	IN 			AL,CMOS_PORT+1 ;Get BCD value returned
	MOV 		CL,AL ;SAVE IN CL
	CALL 		PORT_INC_2 ;SET ADDRESS OF HOURS
	IN 			AL,CMOS_PORT+1 ;Get BCD value returned
	MOV 		CH,AL ;SAVE
	MOV 		DL,0 ;SET DL TO ZERO
	STI
	CALL 		DisplayTime
	
	
ERROR:
	MOV         AX, 4C00h
	INT         21h

UPD_IN_PR:      ;Check we are ready to read clock
	
	PUSH 		CX
	MOV 		CX,600 ;SET LOOP COUNT
	
	UPDATE:
	MOV 		AL,0AH ;ADDRESS OF [A] REGISTER
	OUT 		CMOS_PORT,AL
	JMP 		$+2 ;I/O TIME DELAY
	IN 			AL,CMOS_PORT+1 ;READ IN REGISTER [A]
	TEST 		AL,80H ;IF 8XH--> UIP BIT IS ON (CANNOT READ TIME)
	JZ 			UPD_IN_PREND
	LOOP 		UPDATE ;Try again
	XOR 		AX,AX ;
	STC 		;SET CARRY FOR ERROR
	UPD_IN_PREND:
	POP 		CX
	RET 		;RETURN 
	
PORT_INC_2:
	ADD 		DL,2 ;INCREMENT ADDRESS
	MOV 		AL,DL
	OUT 		CMOS_PORT,AL
	RET 
	
;Display time
	; Arrive with CH = HOURS IN BCD
	; CL = Minutes in BCD
	; DH = Seconds in BCD
	DisplayTime:
	PUSH 		BX
	PUSH 		DX
	PUSH 		CX
	PUSH 		CX
	LEA 		BX,Time_Msg
	CALL 		PRINT_STRING
	POP 		CX
	MOV 		AL,CH
	CALL 		PRINT_REG ;Hours. Convert BCD to ASCII
	MOV 		CL,':'
	CALL 		CO
	POP 		CX
	MOV 		AL,CL
	CALL 		PRINT_REG ;Minutes. Convert BCD to ASCII
	MOV 		CL,':'
	CALL 		CO
	POP 		DX
	MOV 		AL,DH
	CALL 		PRINT_REG ;Seconds. Convert BCD to ASCII
	LEA 		BX,Time1_Msg
	CALL 		PRINT_STRING
	POP 		BX
	RET
	
PRINT_STRING: ;Use CS over-ride so it will splice into 8086 BIOS easily
	push 		cx
	print1:	 	mov al,CS:[bx] ;Note this routine does NOT assume DS = CS here.
	inc 		bx ;By using the CS over-ride we will always have
	cmp 		al,'$' ;a valid pointer to messages at the end of this monitor
	jz 			print2
	cmp 		AL,0 ;Also terminate with 0's
	JZ 			print2
	mov 		cl,al
	call 		CO
	jmp 		print1
	print2: 	pop cx
	ret 
	
PRINT_REG: ;Print BCD in [AL]
	PUSH 		AX
	MOV 		CL,4
	RCR 		AX,CL
	AND 		AL,0FH
	ADD 		AL,30H
	MOV 		CL,AL ;Write high byte mins to CRT
	CALL 		CO
	POP 		AX
	AND 		AL,0FH
	ADD 		AL,30H
	MOV 		CL,AL
	CALL 		CO
	RET 
	
CO: ;Character in CL
	PUSH 		DX
	MOV 		DL,CL
	MOV 		AH,02H
	INT 		21H
	POP 		DX
	RET    
	
    Time_Msg 			DB CR,LF,LF,'Time=',0
	Time1_Msg 			DB CR,LF,' ',0
