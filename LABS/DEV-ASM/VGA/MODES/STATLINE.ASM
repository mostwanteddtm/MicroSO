;-----------------------------------------------------------------------;
; STATLINE, by John Socha, Copyright 1986 Ziff-Davis Publishing Co.	;
;									;
; Here are the two interrupt vectors that we take over.  The first	;
; interrupt, INT 9, is the hardware interrupt for the keyboard, and	;
; it's called every time you push or release a key.			;
;									;
; The other interrupt, INT 10h, points to the ROM BIOS routines that	;
; handle all of the screen I/O.  We intercept it so that we can watch	;
; for commands to change the display mode.  Since STATLINE only works	;
; in 80x25 text modes, STATLINE turns itself off as long as the screen	;
; is in a different mode.						;
;-----------------------------------------------------------------------;
VECTORS		SEGMENT AT 0h
	ORG	9h*4
KEYBOARD_INT_VECTOR	LABEL	DWORD	;Keyboard interrupt
	ORG	10h*4
VIDEO_IO_VECTOR		LABEL	DWORD	;ROM BIOS Video I/O function calls
VECTORS		ENDS


;-----------------------------------------------------------------------;
; STATLINE uses the following flags from the ROM BIOS's data area to	;
; control the screen.							;
;-----------------------------------------------------------------------;
ROM_BIOS_DATA	SEGMENT AT 40h
	ORG	10h
EQUIP_FLAG	DB	?		;Equipment installed
	ORG	17h
KBD_FLAG	DB	?		;Used to determine display type
	ORG	4Eh
CRT_START	DW	?		;Starting address in buffer
	ORG	63h
ADDR_6845	DW	?		;3x8 register, where x is B or D
ROM_BIOS_DATA	ENDS


;-----------------------------------------------------------------------;
; This section of the ROM in a COMPAQ contains the 6 bytes 'COMPAQ'	;
; which we can use to identify a COMPAQ computer.  COMPAQ computers	;
; have a display adapter that uses the monochrome display, but with	;
; registers and memory the same as a color graphics adapter.		;
;-----------------------------------------------------------------------;
COMPAQ_CO	EQU	4F43h		;ASCII code of 'CO'

COMPAQ_SEG	SEGMENT AT 0F000h
	ORG	0FFEAh
COMPAQ_ID	DW	?		;We should find 'CO' (4F43h) here
COMPAQ_SEG	ENDS


;-----------------------------------------------------------------------;
; Here is the STATLINE's entry point.  It jumps to the initialization	;
; routine which is at the very end so that we can throw it out of	;
; memory after we've used it.						;
;-----------------------------------------------------------------------;
CODE_SEG	SEGMENT
	ASSUME	CS:CODE_SEG, DS:CODE_SEG
	ORG	100h		;Reserve for DOS Program Segment Prefix
BEGIN:	JMP	INIT_VECTORS

AUTHOR_STRING		DB	"Installed Statline, by John Socha"
			DB	0Dh, 0Ah, '$'

OLD_KBD_FLAG		DB	0	;Most recent upper nibble of status
VIDEO_MODE		DB	?	;Current video mode
STATUS_LINE_ENABLED	DB	1	;0 when we're in graphics modes

;-----------------------------------------------------------------------;
; The following table contains the character/attribute pairs for the	;
; states of the Scroll Lock, Num Lock, and Caps Lock keys.		;
;									;
; The first word contains the address for the character, and the second	;
; word contains the character/attribute pair.				;
;-----------------------------------------------------------------------;
ENTRY	STRUC
OFFSET_FROM_TOP		DW	?	;Offset from start of display memory
ATTRIBUTE_CHARACTER	DB	?	;Attribute and character code
ENTRY	ENDS

FLAG_CHARACTER_TABLE	LABEL	WORD
	ENTRY	<4084,' '>		;Scroll Lock, ' '
	ENTRY	<4084,12h>		;Scroll Lock, double-ended arrow
	ENTRY	<4080,' '>		;Num Lock, ' '
	ENTRY	<4080,23h>		;Num lock, '#'
	ENTRY	<4076,' '>		;Caps Lock, ' '
	ENTRY	<4076,18h>		;Caps Lock, up arrow

ROM_KEYBOARD_INT	DD	?
ROM_VIDEO_IO_INT	DD	?

;-----------------------------------------------------------------------;
; This procedure sends control off to the ROM BIOS routine, then checks	;
; the shift-lock flags on return and writes the new flag characters to	;
; the screen.								;
;-----------------------------------------------------------------------;
INTERCEPT_KEYBOARD_INT	PROC	FAR
	ASSUME	CS:CODE_SEG, DS:NOTHING
	PUSHF				;Simulate INT with PUSHF and CALL
	CALL	ROM_KEYBOARD_INT	;Let ROM do the work
	CMP	STATUS_LINE_ENABLED,1	;See if Status line enabled.
	JNE	NO_STATUS_LINE		;Not enabled.
	CALL	CHECK_STATUS_FLAGS	;Check flags and update status line
NO_STATUS_LINE:
	IRET
INTERCEPT_KEYBOARD_INT	ENDP


;-----------------------------------------------------------------------;
; This procedure checks the current setting of KBD_FLAGS against the	;
; last setting, and if the flags have changed, it updates the status	;
; line display.  Check_status_flags also updates Old_kbd_flag.		;
;-----------------------------------------------------------------------;
CHECK_STATUS_FLAGS	PROC	NEAR
	PUSH	AX			;Save all the registers we use
	PUSH	BX
	PUSH	CX
	PUSH	DX
	PUSH	SI
	PUSH	DI
	PUSH	DS
	PUSH	ES
	ASSUME	CS:CODE_SEG, DS:ROM_BIOS_DATA
	MOV	AX,ROM_BIOS_DATA	;Set DS so it points to BIOS data area
	MOV	DS,AX
	MOV	DX,ADDR_6845		;Get the base address for the 6845
	MOV	AX,0B800h		;Segment address of graphics adapter
	CMP	DX,3D0h			;Is this the color graphics adapter?
	JAE	IS_COLOR_BOARD      ;It's a color board, so don't change AX
	MOV	AX,0B000h           ;Segment address for monochrome adapter
IS_COLOR_BOARD:
	MOV	ES,AX			;Use extra segment for display memory

	ADD	DX,03DAh-03D4h		;Point to status register
	MOV	BL,KBD_FLAG		;Get flag information
	MOV	CL,4	            ;Put shift lock flags into lower nibble
	SHR	BL,CL
	ASSUME	CS:CODE_SEG, DS:CODE_SEG
	MOV	AX,CS			;Set DS to the local data (in CS)
	MOV	DS,AX
	CMP	BL,OLD_KBD_FLAG		;Have any of the status flags changed?
	JE	FLAGS_HAVENT_CHANGED	;No, then do nothing
	MOV	OLD_KBD_FLAG,BL	    ;Flags have changed, update status line
	MOV	SI,Offset FLAG_CHARACTER_TABLE

	MOV	CX,3			;Repeat for three shift lock keys
SHIFT_LOCK_LOOP:
	PUSH	SI
	SHR	BL,1			;Get next flag in carry
	JNC	READ_OFFSET		;Flag was 0, SI Ok
	ADD	SI,3			;Skip over information
READ_OFFSET:
	MOV	DI,[SI]			;Get Offset
	MOV	AL,[SI+2]		;Get character for this flag
	
	PUSH	CX			;Save the CX register
	MOV	CL,AL			;Save the character in CL
WAIT_FOR_NON_RETRACE:
	IN	AL,DX			;Read status
	TEST	AL,8			;In vertical retrace?
	JNZ	WAIT_FOR_NON_RETRACE	;Wait for vertical retrace to finish
WAIT_FOR_RETRACE:
	IN	AL,DX			;Read status
	TEST	AL,8			;In vertical retrace?
	JZ	WAIT_FOR_RETRACE	;No, then wait for vertical retrace
	MOV	AL,CL			;Get the character we want to write
	STOSB				;Write character to the screen
	POP	CX			;Recover the old value of CX

	POP	SI
	ADD	SI,6			;Skip to next pair of entries
	LOOP	SHIFT_LOCK_LOOP

FLAGS_HAVENT_CHANGED:
	POP	ES
	POP	DS
	POP	DI
	POP	SI
	POP	DX
	POP	CX
	POP	BX
	POP	AX
	RET
CHECK_STATUS_FLAGS	ENDP


;-----------------------------------------------------------------------;
; This procedure reprograms the 6845 whenever a program switches modes	;
; into an 80x25 text mode.						;
;-----------------------------------------------------------------------;
INTERCEPT_VIDEO_IO	PROC	FAR
	ASSUME	CS:CODE_SEG, DS:NOTHING
	OR	AH,AH			;Check if called for SET MODE
	JZ	SET_MODE		;It's a SET MODE call
	JMP	ROM_VIDEO_IO_INT	;Not a SET MODE, call ROM BIOS
SET_MODE:
	MOV	VIDEO_MODE,AL		;Save new video mode
	MOV	STATUS_LINE_ENABLED,AH	;Disable STATLINE during mode change
	PUSHF				;Simulate INT with PUSHF, CALL
	CALL	ROM_VIDEO_IO_INT	;Let ROM BIOS change video mode
	CALL	REPROGRAM_6845		;Create 26th line again
	MOV	OLD_KBD_FLAG,0		;Flags will be clear in new mode
	CALL	CHECK_STATUS_FLAGS	;Make sure we show current flags
	IRET
INTERCEPT_VIDEO_IO	ENDP



;-----------------------------------------------------------------------;
; The following tables describe how to reprogram the 6845 registers.	;
; Each pair describes how to change one register.  The first number is	;
; the register that we want to reprogram, while the second number is	;
; the new value for that register.  Reprogram_6845 stops when it sees	;
; a 0 for the register number.						;
;-----------------------------------------------------------------------;
MONOCHROME_TABLE	LABEL	BYTE
	DB	4,26			;Vertical total, 26 lines
	DB	5,3			;Vertical total adjust, scan lines
	DB	6,26			;Vertical displayed, 26 lines
	DB	7,26			;Vertical sync position, lines
	DB	0			;End of Monochrome table
	
COLOR_GRAPHICS_TABLE:
	DB	6,26			;Vertical displayed
	DB	0			;End of color graphics adapter table

;-----------------------------------------------------------------------;
; This procedure reprograms the 6845 so that it will show 26 rather	;
; than 25 lines.  It uses the values from one of the tables above.	;
;									;
; This procedure also handles the COMPAQ, which is a special case.  The	;
; COMPAQ uses a monochrome-type display, so it needs to be reprogrammed	;
; like a monochrome display, yet writes should be to 3Dxh registers	;
; rather than the 3Bxh registers used for an IBM monochrome display.	;
;									;
; F000:FFEA holds the word 'COMPAQ' on COMPAQ computers, so we can tell	;
; when we're running on a COMPAQ.					;
;-----------------------------------------------------------------------;
REPROGRAM_6845	PROC	NEAR
	ASSUME	CS:CODE_SEG, DS:CODE_SEG
	PUSH	AX
	PUSH	CX
	PUSH	DX
	PUSH	SI
	PUSH	DS
	MOV	AX,CS
	MOV	DS,AX			;Set up Data Seg
	MOV	STATUS_LINE_ENABLED,0	;Initially disable status line
	MOV	AL,VIDEO_MODE		;Check video mode
	CMP	AL,1			;In graphics mode?
	JLE	GRAPHICS_MODE		;Yes, don't reprogram 6845
	CMP	AL,3			;Is display in a text mode?
	JLE	TEXT_MODE		;Yes, then we can reprogram 6845
	CMP	AL,7			;Is it in the monochrome mode?
	JNE	GRAPHICS_MODE		;No, then don't reprogram 6845
TEXT_MODE:				;Yes, reprogram 6845
	MOV	STATUS_LINE_ENABLED,1	;Enable status line in text modes
	MOV	SI,Offset MONOCHROME_TABLE
	MOV	DX,3B4h			;6845 registers for monochrome display
	PUSH	DS
	MOV	AX,ROM_BIOS_DATA	;Read equipment flag from low memory
	MOV	DS,AX
	ASSUME	CS:CODE_SEG, DS:ROM_BIOS_DATA
	MOV	AL,EQUIP_FLAG
	AND	AL,30h			;Isolate CRT switches
	CMP	AL,30h			;Is it the monochrome display?
	POP	DS
	JE	SET_REGISTERS		;Yes, the registers are correct
	MOV	DX,3D4h		    ;No, set registers for graphics adapter
	PUSH	DS
	MOV	AX,COMPAQ_SEG		;Now check to see if this is a COMPAQ
	MOV	DS,AX
	ASSUME	CS:CODE_SEG, DS:COMPAQ_SEG
	CMP	COMPAQ_ID, COMPAQ_CO	;Is this the 'CO' from COMPAQ?
	POP	DS			;Restore old DS
	ASSUME	CS:CODE_SEG, DS:CODE_SEG
	JE	SET_REGISTERS		;Is a COMPAQ, use monochrome data
	MOV	SI,Offset COLOR_GRAPHICS_TABLE	;No, use color graphics data

SET_REGISTERS:
	CLD				;Clear direction flag for increment
ADAPTER_LOOP:
	LODSB				;Get register number
	OR	AL,AL			;Are we at the end of the table?
	JZ	END_OF_ADAPTER_TABLE	;Yes, we're almost done
	OUT	DX,AL			;No, select this register
	INC	DX			;Point to data register
	LODSB				;Get new register value
	OUT	DX,AL			;Set the register to its new value
	DEC	DX			;Point back to address register
	JMP	ADAPTER_LOOP		;Get the next register/value pair

END_OF_ADAPTER_TABLE:
GRAPHICS_MODE:
	POP	DS
	POP	SI
	POP	DX
	POP	CX
	POP	AX
	RET
REPROGRAM_6845	ENDP


;-----------------------------------------------------------------------;
; This procedure initializes the interrupt vectors and the 6845		;
; registers.  It initializes both the Monochrome and color graphics	;
; adapter address so it will work on the COMPAQ as well as IBM PCs	;
;-----------------------------------------------------------------------;
INIT_VECTORS	PROC	NEAR
	ASSUME	CS:CODE_SEG, DS:CODE_SEG
	LEA	DX,AUTHOR_STRING	;Print out the author notice
	MOV	AH,9			;Display this string
	INT	21h

	MOV	AH,15			;Check current video mode
	INT	10h			;Call VIDEO_IO ROM BIOS routine
	MOV	VIDEO_MODE,AL
	CALL	REPROGRAM_6845
	CALL	CHECK_STATUS_FLAGS	;Display any flags now on

	ASSUME	CS:CODE_SEG, DS:VECTORS
	MOV	AX,VECTORS		;Set up the data segment for vectors
	MOV	DS,AX
	CLI				;Don't allow interrupts

	MOV	AX,Word Ptr KEYBOARD_INT_VECTOR
	MOV	Word Ptr ROM_KEYBOARD_INT,AX
	MOV	AX,Word Ptr KEYBOARD_INT_VECTOR[2]
	MOV	Word Ptr ROM_KEYBOARD_INT[2],AX
	MOV	Word Ptr KEYBOARD_INT_VECTOR, Offset INTERCEPT_KEYBOARD_INT
	MOV	Word Ptr KEYBOARD_INT_VECTOR[2],CS

	MOV	AX,Word Ptr VIDEO_IO_VECTOR
	MOV	Word Ptr ROM_VIDEO_IO_INT,AX
	MOV	AX,Word Ptr VIDEO_IO_VECTOR[2]
	MOV	Word Ptr ROM_VIDEO_IO_INT[2],AX
	MOV	Word Ptr VIDEO_IO_VECTOR, Offset INTERCEPT_VIDEO_IO
	MOV	Word Ptr VIDEO_IO_VECTOR[2],CS
	
	STI				;Allow interrupts again
	MOV	DX,Offset INIT_VECTORS	;End of resident portion
	INT	27h			;Terminate but stay resident
INIT_VECTORS	ENDP


CODE_SEG	ENDS

	END	BEGIN
