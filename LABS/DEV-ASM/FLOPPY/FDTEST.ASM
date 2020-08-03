STACK	SEGMENT PARA STACK 'STACK' 
	DB	256 DUP(0) 
STACK	ENDS 
DATA	SEGMENT PARA PUBLIC 'DATA' 
ER1	DB	'ST0: D7D6=01 (FDC Bad)',0DH,0AH,'$' 
ER2	DB	'ST1: D7=1 (FDC intend access over EOT)',0DH,0AH,'$' 
ER3	DB	'ST1: D5=1 (FDC find CRC error)',0DH,0AH,'$' 
ER4	DB	'ST1: D4=1 (FDC not be operated by CPU within ' 
	DB	'designated time in transmitting datas)',0DH,0AH,'$' 
ER5	DB	'ST1: D2=1 (FDC read ID field error)',0DH,0AH,'$' 
ER6	DB	'ST1: D1=1 (FDC detect FDD writing protected)' 
	DB	0DH,0AH,'$' 
ER7	DB	'ST1: D0=1 (FDC can`t find ID address mark)' 
	DB	0DH,0AH,'$' 
ER8	DB	'ST0: D6D5=11 (Don`t normally end in seeking)' 
	DB	0DH,0AH,'$' 
ER9	DB	'Seeking error',0DH,0AH,'$' 
ER10	DB	'FDC hasn`t ready (FDC is bad)',0DH,0AH,'$' 
ER11	DB	'Over the time in transmitting command bytes' 
	DB	0DH,0AH,'$' 
ER12	DB	'No disk interrupting occur',0DH,0AH,'$' 
ER13	DB	'FDC bad',0DH,0AH,'$' 
ER14	DB	'Bad command (transmitting isn`t from FDC to CPU)' 
	DB	0DH,0AH,'$' 
ER15	DB	'FDC don`t ready in designated time',0DH,0AH,'$' 
DATA	ENDS 
CODE	SEGMENT PARA PUBLIC 'CODE' 
START	PROC FAR 
	ASSUME	CS:CODE 
	ASSUME	DS:DATA 
	PUSH	DS 
	MOV	AX,0 
	PUSH	AX 
	MOV	AX,DATA 
	MOV	DS,AX 
	MOV	AX,0040H 
	MOV	ES,AX 
	; 
	MOV	AL,046H 
	CALL	DMA_SETUP 
	; 
	MOV	AH,0E6H 
	MOV	CX,0001;	Cylinder No.:00, 1st Secter No.:01 
	MOV	DL,00H;		Driver No.:00 
	MOV	DH,00;		Head number:00 
	PUSH	AX 
	PUSH	CX 
	PUSH	DX 
	PUSH	DS 
	MOV	AX,0040H 
	MOV	DS,AX 
	MOV	CL,DL 
	MOV	AL,01H 
	SAL	AL,CL 
	CLI 
	MOV	SI,0040H 
	MOV	BYTE PTR [SI],04FH;	Set the initial value of over- 
				  ;	time counter for closing driver 
	DEC	SI 
	TEST	AL,[SI] 
	JNZ	R1 
	AND	BYTE PTR [SI],0F0H 
	OR	[SI],AL 
	STI 
	MOV	AL,10H 
	SAL	AL,CL 
	OR	AL,DL 
	OR	AL,0CH 
	MOV	DX,03F2H 
	OUT	DX,AL 
R1:	STI 
	POP	DS 
	POP	DX 
	POP	CX 
	PUSH	DX 
	CALL	SEEK 
	POP	DX 
	; 
	POP	AX;		Reading command code 
	JC	P9 
	MOV	BH,AH 
	CALL	NECOUT 
	PUSH	CX;	¿ 
	PUSH	DX;	³ 
	MOV	AL,DH;	³ 
	MOV	CL,2;	³ 
	ROL	AL,CL;	³ 
	AND	AL,4;	Ã	generate head and driver number 
	OR	AL,DL;	³	(2nd byte of reading command column) 
	MOV	AH,AL;	³ 
	POP	DX;	³ 
	POP	CX;	Ù 
	CALL	NECOUT 
	MOV	AH,CH;		Cylinder number 
	CALL	NECOUT 
	MOV	AH,DH;		Head number 
	CALL	NECOUT 
	MOV	AH,CL;		Start secter number 
	CALL	NECOUT 
	MOV	AH,02H;		Value of N 
	CALL	NECOUT 
	MOV	AH,0FH;		EOT 
	CALL	NECOUT 
	MOV	AH,2AH;		GPL 
	CALL	NECOUT 
	MOV	AH,0FFH;	DTL 
	CALL	NECOUT 
	CALL	WATINT 
	CALL	RESLT 
	JC	E10 
	MOV	SI,0042H 
	MOV	AL,ES:[SI] 
	AND	AL,0C0H 
	JZ	R2 
	CMP	AL,40H 
	JNZ	E1 
	INC	SI 
	MOV	AL,ES:[SI] 
	SAL	AL,01H 
	JC	E2 
	SAL	AL,01H 
	SAL	AL,01H 
	JC	E3 
	SAL	AL,01H 
	JC	E4 
	SAL	AL,01H 
	SAL	AL,01H 
	JC	E5 
	SAL	AL,01H 
	JC	E6 
	SAL	AL,01H 
	JC	E7 
R2:	RET 
P9:	JMP	E9 
E1:	MOV	DX,OFFSET ER1 
	JMP	DSP 
E2:	MOV	DX,OFFSET ER2 
	JMP	DSP 
E3:	MOV	DX,OFFSET ER3 
	JMP	DSP 
E4:	MOV	DX,OFFSET ER4 
	JMP	DSP 
E5:	MOV	DX,OFFSET ER5 
	JMP	DSP 
E6:	MOV	DX,OFFSET ER6 
	JMP	DSP 
E7:	MOV	DX,OFFSET ER7 
	JMP	DSP 
E9:	MOV	DX,OFFSET ER9 
	JMP	DSP 
E10:	MOV	DX,OFFSET ER10 
DSP:	MOV	AH,09H 
	INT	21H 
	RET 
NECOUT	PROC NEAR 
	PUSH	DX 
	PUSH	CX 
	MOV	DX,03F4H 
	MOV	BL,05H;		Set waiting time for transmitting 
		      ;		command code 
	XOR	CX,CX 
N1:	IN	AL,DX 
	TEST	AL,40H 
	JZ	N3 
	LOOP	N1 
	DEC	BL 
	JNZ	N1 
	STC 
	JMP	E11 
N3:	XOR	CX,CX 
	MOV	BL,05H;		Set waiting time for transmitting 
		      ;		command code 
N4:	IN	AL,DX 
	TEST	AL,80H 
	JNZ	N5 
	LOOP	N4 
	DEC	BL 
	JNZ	N4 
	STC 
	JMP	E11 
N5:	MOV	AL,AH 
	MOV	DL,0F5H 
	OUT	DX,AL 
	CLC 
	POP	CX 
	POP	DX 
	RET 
E11:	MOV	DX,OFFSET ER11 
	MOV	AH,09H 
	INT	21H 
	STC 
	POP	CX 
	POP	DX 
	RET 
NECOUT	ENDP 
CHKSTA	PROC NEAR 
	PUSH	DX 
	PUSH	CX 
	CALL	WATINT 
	JC	C1 
	MOV	AH,08H 
	CALL	NECOUT 
	CALL	RESLT 
	JC	C1 
	MOV	SI,0042H 
	MOV	AL,ES:[SI] 
	AND	AL,60H 
	CMP	AL,60H 
	JZ	E8 
	CLC 
C1:	POP	CX 
	POP	DX 
	RET 
E8:	MOV	DX,OFFSET ER8 
	MOV	AH,09H 
	INT	21H 
	STC 
	POP	CX 
	POP	DX 
	RET 
CHKSTA	ENDP 
WATINT	PROC NEAR 
	PUSH	DX 
	PUSH	CX 
	CLC 
	MOV	BL,08H;		Waiting time for interrupt 
	XOR	CX,CX 
	MOV	SI,003EH 
	MOV	DI,003EH 
W7:	MOV	AL,ES:[SI] 
	TEST	AL,80H 
	JNZ	W8 
	LOOP	W7 
	DEC	BL 
	JNZ	W7 
	MOV	DX,OFFSET ER12 
	MOV	AH,09H 
	INT	21H 
	STC 
W8:	PUSHF 
	AND	AL,00H 
	MOV	ES:[DI],AL 
	POPF 
	POP	CX 
	POP	DX 
	RET 
WATINT	ENDP 
RESLT	PROC NEAR 
	CLD 
	MOV	DI,0042H 
	MOV	BL,07H 
R9:	XOR	CX,CX 
	MOV	AH,04H;		Waiting time for FDC ready 
	MOV	DX,03F4H 
R10:	IN	AL,DX 
	TEST	AL,80H 
	JNZ	R11 
	LOOP	R10 
	DEC	AH 
	JNZ	R10 
	MOV	DX,OFFSET ER15 
	MOV	AH,09H 
	INT	21H 
	STC 
	RET 
R11:	IN	AL,DX 
	TEST	AL,40H 
	JNZ	R12 
	JMP	E14 
R12:	INC	DX;		Point to Data Register(DR) 
	IN	AL,DX 
	MOV	ES:[DI],AL 
	INC	DI 
	MOV	CX,0AH 
R13:	LOOP	R13 
	DEC	DX;		Point to MSR 
	IN	AL,DX 
	TEST	AL,10H 
	JZ	R14;		MSR: D4=0, show the all state columns 
		   ;		have been read over 
	DEC	BL 
	JNZ	R9;		Read the next state byte 
	MOV	DX,OFFSET ER13 
	JMP	E13 
E14:	MOV	DX,OFFSET ER14 
E13:	MOV	AH,09H 
	INT	21H 
R14:	CLC 
	RET 
RESLT	ENDP 
SEEK PROC NEAR 
	MOV	AX,0040H 
	MOV	ES,AX 
	MOV	AL,01H 
	PUSH	CX 
	MOV	CL,DL 
	ROL	AL,CL 
	POP	CX 
	MOV	SI,003EH 
	TEST	AL,ES:[SI] 
	JNZ	S1 
	OR	ES:[SI],AL 
	MOV	AH,07H 
	CALL	NECOUT 
	MOV	AH,DL 
	CALL	NECOUT 
	CALL	CHKSTA 
S1:	MOV	AH,0FH 
	CALL	NECOUT 
	MOV	AH,DL 
	CALL	NECOUT 
	MOV	AH,CH 
	CALL	NECOUT 
	CALL	CHKSTA 
	PUSHF 
	MOV	AH,0FFH;	Head stilling time 
	PUSH	CX 
S2:	MOV	CX,0226H 
	OR	AH,AH 
	JZ	S4 
S3:	LOOP	S3 
	DEC	AH 
	JMP	S2 
S4:	POP	CX 
	POPF 
	RET 
SEEK	ENDP 
DMA_SETUP PROC NEAR 
	CLI 
	OUT	0CH,AL 
	OUT	0BH,AL 
	MOV	AX,5000H;	RAM buffer segment address 
	MOV	CL,04H 
	ROL	AX,CL 
	MOV	CH,AL 
	AND	AL,0F0H 
	MOV	BX,0000H;	RAM buffer offset 
	ADD 	AX,BX 
	JNC	D1 
	INC	CH 
D1:	PUSH	AX 
	OUT	04H,AL 
	MOV	AL,AH 
	OUT	04H,AL 
	MOV	AL,CH 
	AND	AL,0FH 
	OUT	81H,AL 
	MOV	AX,9090;	Bytes number of all 15 secters, and 
		       ;	606 bytes per secter(not contain GAP1) 
	DEC	AX;		Be requred by DMA controller 
	PUSH	AX 
	OUT	05H,AL 
	MOV	AL,AH 
	OUT	05H,AL 
	STI 
	POP	CX 
	POP	AX 
	ADD	AX,CX 
	MOV	AL,02H 
	OUT	0AH,AL 
	RET 
DMA_SETUP	ENDP 
START	ENDP 
CODE	ENDS 
	END	START