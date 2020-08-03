;----------------------------------------------------------------
; RAMVIEW: A memory-resident memory-viewer.
; Frank Dever & David Thomas, WindowDOS Associates
;----------------------------------------------------------------
; scan codes
;----------------------------------------------------------------
U_ARR		EQU	72			;up arrow
D_ARR		EQU	80			;down arrow
PGUP		EQU	73			;page up
PGDN		EQU	81			;page down
L_ARR		EQU	75			;left arrow
R_ARR		EQU	77			;right arrow
HOME		EQU	71			;home
END_KEY		EQU	79			;end
INT9_BUSY	EQU	1
INT10_BUSY	EQU	2
INT16_BUSY	EQU	4
SHIFT_MASK	EQU	8			;Alt
HOTKEY		EQU	13H			;R

CR		EQU	0DH
LF		EQU	0AH

_TEXT	SEGMENT	PARA	PUBLIC	'CODE'
	ASSUME	CS:_TEXT,DS:_TEXT
		ORG 100H
START:
		JMP	RES

INSTALLED	DB      "RAMVIEW 1.00 (c) 1988, Ziff Communications Co."
                DB      CR,LF,"PC Magazine ",254," Frank Dever & David Thomas"
                DB      CR,LF,"Hotkey is Alt-R",CR,LF,"$",1AH
UNINSTALLED     DB	"RAMVIEW Uninstalled",CR,LF,"$"

DISABLE         DB	0     ;flag for inapropriate de-installation

LABEL0  	DB	" ABS  SEG  OFF   0  1  2  3  4  5  6  7"
		DB	"  8  9  A  B  C  D  E  F       ASCII",0

START_DISPLAY	DB	" GOTO ADDRESS: 0000:0000",0

COMMANDLINE	DB	"(G)oto   (H)ex Search   (A)scii Search   (N)ext"
		DB	"     ",24," ",25," PgUp PgDn Home End Esc ",0

CURSOR_POS	DW	0
CURSOR_TYPE	DW	0607H			;for turning cursor on/off
START_OFFSET        DW	0			;top addr shown on screen
START_SEGMENT       DW	0
END_OFFSET          DW	0FH			;last segment in search
END_SEGMENT         DW	0FFFFH			;fixed to ffff:f
SEARCH_SEGMENTS     DW	0			;# segments to search
SEARCH_BYTES        DW	0			;# bytes left after search
HEX_SIEVE           DB	" "			;hex with space
ADDR_SIEVE          DB	"01234567890ABCDEF"     ;hex without space
CHAR_SIEVE          DB 0			;all characters
ASCII_SEARCH_PROMPT	DB "ASCII Search String: ",0   ;ascii search prompt
HEX_SEARCH_PROMPT	DB "HEX Search String: ",0     ;hex search prompt
ASCII_SEARCH_AREA	DB 20 DUP (" "),0              ;ascii search string
HEX_SEARCH_AREA		DB 20 DUP (" "),0	;hex search string
LAST_SEARCH_STRING  DW 0			;pointer to last string
LAST_STRING_LENGTH  DW 0			;last string length
OUR_SS              DW 0
OUR_SP              DW 0
THEIR_SS            DW 0
THEIR_SP            DW 0
ADDR_INT9H          DD 0
ADDR_INT10H         DD 0
BUSY                DB 0
BIOS_SEG            DW 40H
DIFF		    DW 0			;# of chars on a line > 80
ROW                 DW 0			;display row counter
FLICKER_FREE        DB 0			;snowy monitor flag

;-----------------------------------------------------------------
;  code relating to residency
;-----------------------------------------------------------------
RES		PROC	NEAR

		CLD
		CALL	PROGRAM_ALREADY_IN
		JNZ	NOT_IN			;else, it's ok to install
		CALL	UNINSTALL			
		MOV	AX,4C01H		;terminate with error code
		INT	21H
NOT_IN:
		MOV	OUR_SS,CS		;set stack seg
		MOV	OUR_SP,OFFSET LAST_BYTE+4000+256	; and pointer
		CALL	INSTALL
		MOV	DX,OFFSET INSTALLED	;already in
		MOV	AH,9
		INT	21H
						;program, screen buf, stack
		MOV	DX,(OFFSET LAST_BYTE-OFFSET _TEXT+4000+256+15) SHR 4
		MOV	AX,3100H		;stay resident
		INT	21H
RES ENDP
;----------------------------------------------------------------------
INT10H PROC FAR
		OR	CS:BUSY,INT10_BUSY	;recursion protection
		PUSHF
		CALL	CS:ADDR_INT10H
		PUSHF
		AND	CS:BUSY,NOT(INT10_BUSY)
		POPF
		RET	2			;preserve flags
INT10H ENDP
;----------------------------------------------------------------------
INT9H PROC FAR
		STI
		PUSH	AX			;save working register
		CMP	CS:DISABLE,-1		;if disabled, do nothing
		JE	NOT_US
		IN	AL,60H			;get key from keyboard port
		CMP	AL,HOTKEY		;is it our hotkey?
		JNE	NOT_US			;if not, exit
		MOV	AH,2			;otherwise
		INT	16H			;get shift status
		AND	AL,0FH
		CMP	AL,SHIFT_MASK		;test the shift status
		JNE	NOT_US			;if not shift combo, exit
		IN	AL,61H			;These instructions reset
		MOV	AH,AL			; the keyboard.
		OR	AL,80H
		OUT	61H,AL
		MOV	AL,AH
		JMP	SHORT $+2		;I/O delay for fast AT's
		OUT	61H,AL
		CLI				;Disable interrupts and
		MOV	AL,20H			;reset the int controller
		OUT	20H,AL
		STI
		CMP	CS:BUSY,0		;recursion protection
		JNE	WE_ARE_BUSY		;dont allow re-entrancy
		OR	CS:BUSY,INT9_BUSY	;set flag for protection
		CALL	ADJUST_FOR_VIDEO_MODE
		JC	CANT_POP_UP
		CALL	MEM			;call our program
CANT_POP_UP:
		CLI				;disable kbd momentarily
		AND	CS:BUSY,NOT(INT9_BUSY)	;reset protection
WE_ARE_BUSY:
		POP	AX			;restore working register
		IRET				;return to foreground
NOT_US:
		POP	AX			;restore working register
		CLI
		JMP	CS:ADDR_INT9H		;let ROM code do its work
INT9H ENDP

;-----------------------------------------------------------------
;check for text modes and set offset
;for lines > than 80 characters in length
;-----------------------------------------------------------------
ADJUST_FOR_VIDEO_MODE PROC NEAR

		PUSH	BX
		MOV	AH,15			;get present mode
		INT	10H

		CMP	AH,80
		JB	BAD_MODE

		MOV	BYTE PTR CS:DIFF,AH	;calc the # of chars > 80
		SUB	CS:BYTE PTR DIFF,80	;on the line & save in diff
		CMP	AL,7			;7 is mono
		JNE	TRY_COLOR
MODE_OK:
		CLC
		POP	BX
		RET
TRY_COLOR:
		CMP	AL,3			;3 is color 80x25
		JBE	MODE_OK
BAD_MODE:
		STC				;not good mode
		POP	BX
		RET

ADJUST_FOR_VIDEO_MODE ENDP

;-----------------------------------------------------------------
;main routine called by pressing hot key
;-----------------------------------------------------------------
MEM PROC NEAR
		CALL	SWAPIN			;new stack
		MOV	AX,CS			;our data segment
		MOV	DS,AX
		CALL	FLICKER			;determine presence of snow
		CALL	SAVE_CURSOR		;save cursor
		CALL	CURSOR_OFF		;turn cursor off
		CALL	SAVE_SCREEN		;save screen
		CALL	CLEAR_SCREEN		;clear screen
		CALL	PROGRAM			;do our program
		CALL	RESTORE_SCREEN		;put screen back
		CALL	CURSOR_ON		;turn cursor on
		CALL	RESTORE_CURSOR
		CALL	SWAPOUT			;put stack back
		RET				;that's all
MEM ENDP

PROGRAM PROC NEAR
		XOR	AX,AX			;row 0
		MOV	BX,AX			;col 0
		MOV	SI,OFFSET LABEL0	;bottom line
		CALL	DISPLAY_STRING		;show header line
NEXT_SCREEN:
		CALL	BODY			;put hex display up
		MOV	AX,24			;last row
		XOR	BX,BX			;column 0
		MOV	SI,OFFSET COMMANDLINE	;command line
		CALL	DISPLAY_STRING		;show it
		CALL	MENU			;go get keystroke
		JNC	NEXT_SCREEN		;until esc is pressed
EXIT:
		RET
PROGRAM ENDP

;-----------------------------------------------------------------
;cursor routines				          
;-----------------------------------------------------------------
SAVE_CURSOR PROC NEAR
		MOV	ES,BIOS_SEG
		MOV	AX,ES:[60H]		;get present cursor type
		MOV	CURSOR_TYPE,AX		;save it
		CALL	GETPOS
		MOV	CURSOR_POS,DX
		RET
SAVE_CURSOR ENDP
;----------------------------------------------------------------------
RESTORE_CURSOR PROC NEAR
		MOV	DX,CURSOR_POS
		CALL	SETPOS
		RET
RESTORE_CURSOR ENDP
;----------------------------------------------------------------------
SETPOS PROC NEAR
		MOV	AH,2			;set cursor position
		XOR	BH,BH			;active page
		INT	10H			;set cursor position to dx
		RET
SETPOS ENDP
;----------------------------------------------------------------------
GETPOS PROC NEAR
		MOV	AH,3			;get cursor position
		XOR	BH,BH			;active page
		INT	10H			;get cursor position in dx
		RET
GETPOS ENDP
;----------------------------------------------------------------------
CURSOR_OFF PROC NEAR
		PUSH	CX
		MOV	CX,2B0CH		;turn off cursor value
		CALL	SETCUR
		POP	CX
		RET
CURSOR_OFF ENDP
;----------------------------------------------------------------------
CURSOR_ON PROC NEAR
		PUSH	CX
		MOV	CX,CURSOR_TYPE		;turn on cursor value
		CALL	SETCUR
		POP	CX
		RET
CURSOR_ON ENDP
;----------------------------------------------------------------------
SETCUR PROC NEAR
		PUSH	AX
		MOV	AH,1			;function to set cursor shape
		INT	10H			;do it
		POP	AX
		RET				;that's all
SETCUR  ENDP
;-----------------------------------------------------------------
;screen routines
;-----------------------------------------------------------------
SAVE_SCREEN PROC NEAR
		CALL	TURN_OFF_CRT
		PUSH	DS			;save data segment
		XOR	AX,AX
		MOV	BX,AX
		CALL	CALC_SCRN_ADDR		;address of (0,0)
		MOV	SI,OFFSET LAST_BYTE	;buffer is past end of prog
		PUSH	DS			;exchange
		PUSH	ES			;ds and es
		POP	DS
		POP	ES
		XCHG	DI,SI			;exchange source,destination
		MOV	BX,25
SAVE_NEXT_LINE:
		MOV	CX,80			;save 2000
		REP	MOVSW			;words
		ADD	SI,CS:DIFF		;go to next
		ADD	SI,CS:DIFF		;line
		DEC	BX			;25 lines
		JNZ	SAVE_NEXT_LINE
		POP	DS			;restore data segment
		CALL	TURN_ON_CRT
		RET
SAVE_SCREEN ENDP
;-----------------------------------------------------------------
CLEAR_SCREEN PROC NEAR
		CALL	TURN_OFF_CRT
		XOR	AX,AX
		MOV	BX,AX
		CALL	CALC_SCRN_ADDR		;address of (0,0)
		MOV	AX,0720H		;space with normal attribute
		MOV	BX,24
CLEAR_NEXT_LINE:
		MOV	CX,80
		REP	STOSW			;words
		ADD	DI,CS:DIFF		;go to next
		ADD	DI,CS:DIFF		;line
		DEC	BX			;24 lines
		JNZ	CLEAR_NEXT_LINE
		CALL	TURN_ON_CRT
		RET
CLEAR_SCREEN ENDP
;-----------------------------------------------------------------
RESTORE_SCREEN PROC NEAR
		CALL	TURN_OFF_CRT
		XOR	AX,AX
		MOV	BX,AX
		CALL	CALC_SCRN_ADDR		;address of (0,0)
		MOV	SI,OFFSET LAST_BYTE	;buffer past end of program
		MOV     BX,25
RESTORE_NEXT_LINE:
		MOV	CX,80			;save 2000
		REP	MOVSW			;words
		ADD	DI,CS:DIFF		;go to next
		ADD	DI,CS:DIFF		;line
		REP	MOVSW			;words
		DEC	BX			;25 lines
		JNZ	RESTORE_NEXT_LINE
		CALL	TURN_ON_CRT
		RET
RESTORE_SCREEN ENDP
;-----------------------------------------------------------------
TURN_ON_CRT PROC NEAR
		CMP	CS:FLICKER_FREE,-1	;is it flicker free?
		JZ	NOSNOW			;if so, dont turn crt_on
		PUSH	AX
		PUSH	DX
		PUSH	ES
		CALL	WAIT_VERT
		MOV	DX,3D8H
		MOV	ES,BIOS_SEG
		MOV	AL,ES:BYTE PTR[65H]	;get crt mode setting
		OUT	DX,AL			;set crt back to previous mode
		POP	ES
		POP	DX
		POP	AX
NOSNOW:
		RET
TURN_ON_CRT ENDP
;-----------------------------------------------------------------
FLICKER PROC NEAR
		MOV	FLICKER_FREE,0		;assume snowy monitor
		MOV	AX,1A00H
		INT	10H			;Use PC Magazine's method
		CMP	AL,1AH			;of determining
		JZ	FLICKFREE		;vga or mda active
		MOV	AH,12H
		MOV	BL,10H
		INT	10H
		CMP	BL,10H
		JNZ	FLICKFREE		;if bl changed, its ega
		MOV	AX,40H
		MOV	ES,AX
		TEST	ES:BYTE PTR[63H],40H	;check for mda (= no flicker)
		JNZ	ITS_CGA
FLICKFREE:
		MOV	FLICKER_FREE,-1
ITS_CGA:
		RET
FLICKER ENDP
;-----------------------------------------------------------------
TURN_OFF_CRT PROC NEAR
		CMP	CS:FLICKER_FREE,-1	;is it flicker free?
		JZ	NO_SNOW
		PUSH	DX
		PUSH	AX
		CALL	WAIT_VERT
		MOV	AL,25H			;mask to turn off crt
		MOV	DX,3D8H
		OUT	DX,AL			;turn it off
		POP	AX
		POP	DX
NO_SNOW:
		RET
TURN_OFF_CRT ENDP
;-----------------------------------------------------------------
WAIT_VERT PROC NEAR
		CMP	CS:FLICKER_FREE,-1	;is it flicker free?
		JZ	NOWAIT
		PUSH	AX
		PUSH	DX
		MOV	DX,3DAH			;color status port
WAIT0:
		IN	AL,DX
		TEST	AL,8
		JNZ	WAIT0			;wait for vertical off
WAIT1:
		IN	AL,DX
		TEST	AL,8
		JZ	WAIT1			;wait for verical on
		POP	DX
		POP	AX
NOWAIT:
		RET
WAIT_VERT ENDP

;-----------------------------------------------------------------
;stack routines
;-----------------------------------------------------------------
RETADDR DW 0
SWAPIN PROC NEAR
		POP	CS:RETADDR		;save callers address
		MOV	CS:THEIR_SS,SS		;save their stack
		MOV	CS:THEIR_SP,SP
		MOV	SS,CS:OUR_SS		;switch to our stack
		MOV	SP,CS:OUR_SP
		PUSH	AX			;save all registers
		PUSH	BX
		PUSH	CX
		PUSH	DX
		PUSH	SI
		PUSH	DI
		PUSH	ES
		PUSH	DS
		PUSH	BP
		JMP	CS:RETADDR		;return to caller
SWAPIN ENDP
;-----------------------------------------------------------------
SWAPOUT PROC NEAR
		POP	CS:RETADDR		;save callers address
		POP	BP			;restore all registers
		POP	DS
		POP	ES
		POP	DI
		POP	SI
		POP	DX
		POP	CX
		POP	BX
		POP	AX
		MOV	SS,CS:THEIR_SS		;restore callers stack
		MOV	SP,CS:THEIR_SP
		JMP	CS:RETADDR		;return to caller
SWAPOUT ENDP

;-----------------------------------------------------------------          
;clears last line
;-----------------------------------------------------------------
CLEAR_LAST_LINE PROC NEAR
		CALL	WAIT_VERT
		MOV	AX,24			;row 24
		XOR	BX,BX			;col 0
		CALL	CALC_SCRN_ADDR		;get es:di for that address
		MOV	CX,80			;80 words
		MOV	AX,0720H		;normal attribute spaces
		REP	STOSW			;clear it
		RET				;that's all
CLEAR_LAST_LINE ENDP

;-----------------------------------------------------------------
;menu accept and key input
;-----------------------------------------------------------------
MENU PROC NEAR
NEXT_MENU_KEY:
		CALL	GETKEY			;input a key
		CMP	AH,2			;if scan code is less than 2
		JBE	QUIT_EXIT		; the key is Esc
NOT_ESC:
		AND	AL,0DFH			;make all ascii caps
		CMP	AL,"G"			;G)o
		JNZ	NOT_GOTO
		CALL	GOTO_ADDR			;get start addr
		JMP	MENU_EXIT
NOT_GOTO:
		CMP	AL,"A"			;A)scii search
		JNZ	NOT_ASCII_SEARCH
		CALL	ASCII_SEARCH		;find ascii string
		JMP	MENU_EXIT
NOT_ASCII_SEARCH:
		CMP	AL,"H"			;H)ex search
		JNZ	NOT_HEX_SEARCH
		CALL	HEX_SEARCH		;find hex string
		JMP	MENU_EXIT
NOT_HEX_SEARCH:
		CMP	AL,"N"			;N)ext search
		JNZ	NOT_NEXT_SEARCH
		CALL	NEXT_SEARCH		;find next string
		JMP	MENU_EXIT
NOT_NEXT_SEARCH:
		CMP	AH,U_ARR		;up arrow
		JNZ	NOT_UP
		MOV	AX,-10H
		JMP	SHORT MOVEIT
NOT_UP:
		CMP	AH,HOME			;go to beginning of memory
		JNZ	NOT_HOME
		MOV	START_OFFSET,0
		MOV	START_SEGMENT,0
		JMP	SHORT MENU_EXIT
NOT_HOME:
		CMP	AH,END_KEY		;go to end of memory
		JNZ	NOT_END
		MOV	START_OFFSET,0FE90H	;top of last page
		MOV	START_SEGMENT,0F000H
		JMP	SHORT MENU_EXIT
NOT_END:
		CMP	AH,D_ARR		;down arrow
		JNZ	NOT_DOWN
		MOV	AX,10H
		JMP	SHORT MOVEIT
NOT_DOWN:
		CMP	AH,PGUP			;page up
		JNZ	NEXT_CHECK
		MOV	AX,-170H
		JMP	SHORT MOVEIT
NEXT_CHECK:
		CMP	AH,PGDN			;page down
		MOV	AX,170H
		JZ	MOVEIT
		JMP	NEXT_MENU_KEY
MOVEIT:
		CALL	MOVE
MENU_EXIT:
		CLC				;clear carry for exit
QUIT_EXIT:
		RET				;that's all
MENU ENDP

;-----------------------------------------------------------------          
;sets starting segment and offset for display
;-----------------------------------------------------------------
MOVE PROC NEAR
		OR	AX,AX			;is the movement signed
		JNS	ADDIT			;no-add to seg:off
		NEG	AX			;otherwise make positive
		SUB	START_OFFSET,AX		;subtract from offset
		JNC	MOVE_EXIT		;if no carry, done
		SUB	START_SEGMENT,1000H	;else wrap segment
		JMP	SHORT MOVE_EXIT
ADDIT:
		ADD	START_OFFSET,AX		;add movement to offset
		JNC	MOVE_EXIT		;if no carry, done
		ADD	START_SEGMENT,1000H	;else wrap segment
MOVE_EXIT:
		RET
MOVE ENDP

;-----------------------------------------------------------------
;ascii search routine
;-----------------------------------------------------------------
ASCII_SEARCH PROC NEAR
		CALL	CLEAR_LAST_LINE		;clear line for input
		MOV	AX,24			;last row
		XOR	BX,BX			;first col
		MOV	SI,OFFSET ASCII_SEARCH_PROMPT	;prompt
		CALL	DISPLAY_STRING		;show the prompt
		CALL	STRLEN			;find out how long prompt is
		MOV	DL,CL			;dl = col after prompt
		MOV	DH,24			;dx = row col
		MOV	SI,OFFSET ASCII_SEARCH_AREA	;
		MOV	CX,20			;size of the string
		CALL	CLEAR_BUF
		MOV	DI,OFFSET CHAR_SIEVE	;pointer to sieve
		MOV	BX," "			;get
			;dx=row col,cx=size,bl=replace,si=prompt,di=sieve
		CALL	INPUT
		MOV	SI,OFFSET ASCII_SEARCH_AREA ;pointer to search string
		MOV	LAST_SEARCH_STRING,SI	;save ptr to str for next
		CALL	STRLEN			;how long?
		MOV	LAST_STRING_LENGTH,CX	;save length for next
		JCXZ	NO_SEARCH		;if not, dont search
		CALL	SEARCH_MEM		;cx=length si=string
NO_SEARCH:
		RET				;that's all
ASCII_SEARCH ENDP

;-----------------------------------------------------------------
;find next occurrence
;-----------------------------------------------------------------
NEXT_SEARCH PROC NEAR
		MOV	SI,LAST_SEARCH_STRING	;get address of last string
		MOV	CX,LAST_STRING_LENGTH
		JCXZ	NO_NEXT			;dont search
		ADD	START_OFFSET,1		;move over one to start
		JNC	NOS_WRAP		;if it causes wrap,
		ADD	START_SEGMENT,1000H	;wrap segment
NOS_WRAP:
		CALL	SEARCH_MEM		;search for next string
NO_NEXT:
		RET				;that's all
NEXT_SEARCH ENDP

;-----------------------------------------------------------------
;hex search routine
;-----------------------------------------------------------------
HEX_SEARCH PROC NEAR
		CALL	CLEAR_LAST_LINE		;clear line for input
		MOV	SI,OFFSET HEX_SEARCH_PROMPT	;prompt
		MOV	AX,24			;last row
		XOR	BX,BX			;first col
		CALL	DISPLAY_STRING		;show the prompt
		CALL	STRLEN			;find out how long prompt is
		MOV	DL,CL			;dl = col after prompt
		MOV	DH,24			;dx = row col
		MOV	SI,OFFSET HEX_SEARCH_AREA	;
		MOV	CX,20			;size of the string
		CALL	CLEAR_BUF
		MOV	DI,OFFSET HEX_SIEVE	;pointer to sieve
		MOV	BX," "			;replacement char
			;dx=row col,cx=size,bx=replace,si=prompt,di=sieve
		CALL	INPUT
		MOV	SI,OFFSET HEX_SEARCH_AREA ;pointer to search string
		CALL	STRLEN
		CMP	CL,1			;must be at least two digits
		JBE	NO_SEARCH		;otherwise search fails
		MOV	LAST_SEARCH_STRING,SI	;save it
		MOV	LAST_STRING_LENGTH,CX	;save length
		CALL	ELIMINATE_BLANKS	;eliminate blanks in input
		CALL	CONVERT_ASCII_HEX_TO_HEX_STRING	;string into hex
		MOV	LAST_STRING_LENGTH,CX	;save length
		CALL	SEARCH_MEM		;find it
NOSEARCH:
		RET				;that's all
HEX_SEARCH ENDP

;-----------------------------------------------------------------
;clear ds:[si] with (cx) spaces
;-----------------------------------------------------------------
CLEAR_BUF PROC NEAR
		PUSH	CX
		PUSH	SI
CLEARIT:
		MOV	BYTE PTR [SI]," "
		INC	SI
		LOOP	CLEARIT
		POP	SI
		POP	CX
		RET
CLEAR_BUF ENDP

;-----------------------------------------------------------------
;translate ascii hex string to binary string, return size in cx
;-----------------------------------------------------------------
CONVERT_ASCII_HEX_TO_HEX_STRING PROC NEAR
		PUSH	SI			;save si for use in main
		MOV	DI,SI			;duplicate si
		MOV	BX,SI			;for later use
NEXTC:
		LODSW				;get two ascii digits
		OR	AL,AL			;are we at the end
		JZ	C_EXIT			;if so, string is converted
		OR	AH,AH			;in case wrong # digits
		JZ	C_EXIT			;string is converted
		CALL	ASCII_HEX_TO_HEX	;translate ascii to binary
		STOSB				;put back in string
		JMP	NEXTC			;get next two characters
C_EXIT:
		XOR	AL,AL			;clear al
		STOSB				;put terminator after this
		SUB	DI,BX			;find out how many bytes
		LEA	CX,[DI-1]		;we have converted
		POP	SI			;restore important register
		RET				;that's all
CONVERT_ASCII_HEX_TO_HEX_STRING ENDP

;-----------------------------------------------------------------
;close up blanks in a string
;-----------------------------------------------------------------
ELIMINATE_BLANKS PROC NEAR
		PUSH	SI			;save si for main
		PUSH	DS			;set ds:si and es:di to same
		POP	ES
		MOV	DI,SI
NEXT_SQ:
		LODSB				;get character
		CMP	AL," "			;if space
		JZ	NEXT_SQ			;skip it
		STOSB				;otherwise store it
		OR	AL,AL			;if zero
		JNZ	NEXT_SQ			;done whole string
SQUOZE:
		POP	SI			;restore important register
		RET				;that's all
ELIMINATE_BLANKS ENDP

;-----------------------------------------------------------------
;go to command
;-----------------------------------------------------------------
GOTO_ADDR PROC NEAR
		CALL	CLEAR_LAST_LINE		;clear line for input
		MOV	AX,24			;row
		XOR	BX,BX			;col
		MOV	SI,OFFSET START_DISPLAY	;prompt
		CALL	DISPLAY_STRING		;show it
		MOV	DX,180FH		;row col
		MOV	SI,OFFSET START_DISPLAY+15	;destination
		MOV	CX,9			;size
		MOV	DI,OFFSET ADDR_SIEVE	;sieve
		MOV	BX,"0"			;replace char
			;dx=row col,cx=size,bx=replace,si=prompt,di=sieve
		CALL	INPUT
		MOV	SI,OFFSET START_DISPLAY+15	;ascii address
		MOV	DI,OFFSET START_SEGMENT	;destination
		CALL	CONVERT_ADDR		;32 bit ascii address to ptr
		CLC
		RET
GOTO_ADDR ENDP

;-----------------------------------------------------------------
;convert ascii to binary segment and offset
; si=ascii  di= pointer to destination
;-----------------------------------------------------------------
CONVERT_ADDR PROC NEAR
		PUSH	DS
		POP	ES			;set es for stos
		INC	DI
		CALL	CONVERT_BYTE		;segment
		CALL	CONVERT_BYTE
		INC	SI			;colon
		CALL	CONVERT_BYTE		;offset
		CALL	CONVERT_BYTE
		RET				;that's all
CONVERT_ADDR ENDP
;-----------------------------------------------------------------
CONVERT_BYTE PROC NEAR
		LODSW				;get two chars
		CALL	ASCII_HEX_TO_HEX	;make hex
		MOV	[DI],AL			;put in destination
		DEC	DI			;set up for next character
		RET				;that's all
CONVERT_BYTE ENDP

;-----------------------------------------------------------------
;display main screen
;-----------------------------------------------------------------
BODY PROC NEAR
		CALL	TURN_OFF_CRT		;turn off monitor if necessary
		PUSH	BP			;use the
		MOV	BP,SP			;stack
		SUB	SP,8			;for temporary variables
		PUSH	DS			;save ds for main routine
		LES	BX,DWORD PTR START_OFFSET	;get start pointer
		MOV	[BP-2],BX		;save on stack
		MOV	[BP-4],ES		;for later use
		CALL	NORMALIZE		;change es:bx so 10h <= bx >=0
		MOV	[BP-6],BX		;save value on stack
		MOV	[BP-8],ES		;for later use
		MOV	DS,[BP-4]		;get pointer
		MOV	SI,[BP-2]		;to memory to display
		MOV	CS:ROW,0		;initialize row counter
NEXT_LINE:
		INC	CS:ROW			;next display row
		MOV	AX,CS:ROW		;row
		XOR	BX,BX			;col
		CALL	CALC_SCRN_ADDR		;get es:di for that address
		MOV	CX,[BP-8]		;hi part of norm 20 bit desc
		CALL	WORD_OUT		;print it
		INC	WORD PTR[BP-8]		;add 1 to seg = 16 bytes
		MOV	AL,[BP-6]		;get lo part
		CALL	HEX_TO_ASCII_HEX	;convert to ascii
		XCHG	AL,AH			;lowest significant nybble
		CALL	CHAR_OUT		;print lo part of 'ABS' value
		CALL	SPACE_OUT		;put separator
		MOV	CX,[BP-4]		;segment being displayed
		CALL	WORD_OUT		;print it
		MOV	AL,":"			;followed
		CALL	CHAR_OUT		;by a colon
		MOV	CX,[BP-2]		;offset this line
		CALL	WORD_SPACE		;print offset/space
		MOV	CX,16			;# characters to print
		MOV	DX,SI			;save ptr to present line
HEX_PART:
		LODSB				;get character
		CALL	BYTE_OUT		;print two hex nybbles
		CALL	SPACE_OUT		;print space
		LOOP	HEX_PART		;all 16 hex digits
		MOV	SI,DX			;get ptr to present line
		MOV	CX,16			;all 16 hex digits
		MOV	AL,70H			;reverse the ascii part
ASCII_PART:
		MOVSB				;print the ascii part
		STOSB				;reverse attribute on it
		LOOP	ASCII_PART		;all 16 ascii chars
		ADD	WORD PTR[BP-6],10H	;'ABS' + 16
		ADC	WORD PTR[BP-8],0	;
		ADD	WORD PTR[BP-2],10H	;'SEG:OFF' + 16
		JNC	NO_WRAP			;if it wraps
		ADD	WORD PTR[BP-4],1000H	;wrap the segment
		MOV	DS,[BP-4]		;get the data segment
NO_WRAP:
		CMP	CS:ROW,23		;if not completely done
		JB	NEXT_LINE		;do another
		POP	DS			;restore ds for main routine
		ADD	SP,8			;clean off temporary variables
		POP	BP			;restore bp
		CALL	TURN_ON_CRT		;turn on monitor if necessary
		RET				;that's all
BODY ENDP

WORD_SPACE LABEL NEAR
		CALL	WORD_OUT		;output two nybbles from cx
SPACE_OUT LABEL NEAR				;then
		MOV	AL," "			;output a space
		JMP	SHORT CHAR_OUT
WORD_OUT LABEL NEAR
		MOV	AL,CH			;get high nybble
		CALL	BYTE_OUT		;print it
		MOV	AL,CL			;get low nybble
BYTE_OUT LABEL NEAR
		CALL	HEX_TO_ASCII_HEX	;cvt hex to two char nybbles
		STOSB				;print highest order nybble
		INC	DI			;skip attribute
		MOV	AL,AH			;get low order nybble
CHAR_OUT LABEL NEAR
		STOSB				;print it
		INC	DI			;skip attribute
		RET				;that's all

END_MINUS_START PROC NEAR
		LES	BX,DWORD PTR START_OFFSET	;get end segment
		CALL	NORMALIZE		;change es:bx so 10h <= bx >=0
		MOV	AX,ES			;save normalized result
		MOV	CX,BX			;for later use
		LES	BX,DWORD PTR END_OFFSET	;get end address
		CALL	NORMALIZE		;change es:bx so 10h <= bx >=0
		MOV	DX,ES			;get end segment
		SUB	DX,AX			;calculate segments to search
		MOV	SEARCH_SEGMENTS,DX
		MOV	SEARCH_BYTES,BX		;# bytes in final segment
		MOV	ES,AX			;set es:bx to
		MOV	BX,CX			;start address
		RET				;that's all
END_MINUS_START ENDP

;-----------------------------------------------------------------
;make 20 bit pointer in es:bx from segment:offset in es:bx
;-----------------------------------------------------------------
NORMALIZE PROC NEAR
		PUSH	AX			;save these registers
		PUSH	CX			;for main routine
		PUSH	DX			;
		MOV	AX,BX			;get the offset
		MOV	CL,4			;make into
		SHR	AX,CL			;number of paragraphs
		MOV	DX,ES			;get segment
		ADD	DX,AX			;add in number of paragraphs
		MOV	ES,DX			;back into segment
		SHL	AX,CL			;calc offset into segment
		SUB	BX,AX			;paras - paras mod 16
		POP	DX			;retstore registers
		POP	CX			;for main routine
		POP	AX
		RET				;that's all
NORMALIZE ENDP

;-----------------------------------------------------------------
;si = string  cx = string_size
;search for match of string beginning at start_segment
;-----------------------------------------------------------------
SEARCH_MEM  PROC NEAR
		MOV	DI,CX			;save string size
		CALL	END_MINUS_START		;calculate search length
LOOK_AGAIN:
		CMP	SEARCH_SEGMENTS,1000H	;more than or equal 64k?
		JAE	MORE_THAN_ENOUGH	;if so, search 64k
		MOV	AX,SEARCH_SEGMENTS	;otherwise, get what's left
		MOV	CL,4			;
		SHL	AX,CL			;segs*16 = bytes to search
		ADD	AX,SEARCH_BYTES		;add in the last few bytes
		JMP	SHORT LOOK		;and go look
MORE_THAN_ENOUGH:
		MOV	AX,-1			;64k search
LOOK:		               
		SUB	AX,BX			;subtract initial offset
		JC	SEARCH_NOT_FOUND	;offset < search size?
		SUB	AX,DI			;subtract off string size
		JBE	SEARCH_NOT_FOUND	;less than search size?
		CMP	AX,DI			;amount left to search
		JB	SEARCH_NOT_FOUND	;less than search size?
		MOV	DX,AX			;dx gets search size
		MOV	CL,4			;
		SHR	DX,CL			;number of segments to search
		SUB	SEARCH_SEGMENTS,DX	;decrease the amount to search
						;si = string  di = string size
		CALL	SEARCH			;es:bx=ptr,ax=bytes to search
		JZ	SEARCH_FOUND		;if zero flag, string is found
		ADD	AX,1			;next character after fail
		MOV	BX,AX			;into es:bx
		JNC	NOWR			;if offset rolls over
		MOV	AX,ES			;add 64k
		ADD	AX,1000H		;to the
		MOV	ES,AX			;offset
NOWR:
		CALL	NORMALIZE		;set to start at the top of
		JMP	LOOK_AGAIN		;a new segment
SEARCH_NOT_FOUND:
		XOR	AX,AX			;start over
		MOV	ES,AX
		CMP	AL,1			;clear zero flag
SEARCH_FOUND:
		MOV	START_SEGMENT,ES	;set page
		MOV	START_OFFSET,AX		;address of found string
		RET				;that's all
SEARCH_MEM ENDP

;-----------------------------------------------------------------
;si = string di = string size es:bx = pointer to buffer to search
;ax = number of bytes in buffer to search. Zero flag set if found
;-----------------------------------------------------------------
SEARCH PROC NEAR				;si points at string
		PUSH	BX
		PUSH	DI
		PUSH	SI
		XCHG	BX,DI		;string size, ptr to data area
		MOV	CX,AX		;# chars in segment to search
BYTE_ADD:
		LODSB			;char for first part of search
NEXT_SRCH:
		REPNZ	SCASB		;is first char in string in buffer
		JNZ	NOT_FOUND	;if not, no match
		PUSH	DI		;save against cmpsb
		PUSH	SI
		PUSH	CX
		LEA	CX,[BX-1]	;# chars in string - 1
		JCXZ	ONE_CHAR	;if one char search, we have found it
		REP	CMPSB		;otherwise compare rest of string
ONE_CHAR:
		POP	CX		;restore for next cmpsb
		POP	SI
		POP	DI
		JNZ	NEXT_SRCH	;if zr = 0 then string not found
NOT_FOUND:
		 LEA	AX,[DI-1]	;ptr to last first character found
		 POP	SI
		 POP	DI
		 POP	BX
		 RET			;that's all
SEARCH ENDP

;------------------------------------------------------------------
;dx=row:col,cx=max len,bx=replace character,si=prompt,di=sieve
;------------------------------------------------------------------
INPUT PROC NEAR
		PUSH	BP			;create stack frame
		MOV	BP,SP
		SUB	SP,6
		CALL	CURSOR_ON
		MOV	[BP-2],CX		;save size of destination
		MOV	[BP-4],SI
		MOV	[BP-6],DX
		XOR	CX,CX			;clear count of chars entered
NEXT_DISPLAY:
		PUSH	BX			;save replace char
		PUSH	SI
		MOV	AL,[BP-5]		;row
		CBW				;into ax
		MOV	BL,[BP-6]		;col
		XOR	BH,BH			;into bx
		MOV	SI,[BP-4]
		CALL	DISPLAY_STRING		;show string at si
		POP	SI
		POP	BX			;restore replace char
		PUSH	DS			;set up string addressing
		POP	ES
NEXT_KEY:
		CMP	BYTE PTR[SI],":"	;skip colon in destination
		JNZ	NOT_COLON
		INC	CX			;next count
		INC	DL			;next col
		INC	SI			;point to next char
NOT_COLON:
		CALL	SETPOS			;set cursor position
		CALL	GETKEY			;get next key
		CMP	AH,1			;if scan = 1
		JZ	END_OF_INPUT;then it's esc
		CMP     AH,1CH			;if scan = 1ch
		JZ	END_OF_INPUT		;then it's carriage return
		CMP	AH,L_ARR		;if it's left arrow
		JZ	BACK_SPACE		;or
		CMP	AH,0EH			;if it's backspace key
		JNZ	NOT_BACK_SPACE		;then back up
BACK_SPACE:
		JCXZ	NEXT_KEY		;if count 0 can't back up
		DEC	CX			;decrement count
		DEC	DL			;decrement column
		DEC	SI			;decrement pointer to chars
		CMP	BYTE PTR[SI],":"	;if pointer is to colon,
		JZ	BACK_SPACE		;then back up again
		MOV	BYTE PTR[SI],BL		;put replace character in
		JMP	NEXT_DISPLAY		;show line again
NOT_BACK_SPACE:
		CMP	CX,[BP-2]		;is count = max count
		JZ	NEXT_KEY		;if so, can't put in buffer
NEXT_INPUT:
		CALL	VERIFY			;ax = char di = sieve
		JNZ	NEXT_KEY		;if illegal char get new key
		MOV	[SI],AL			;otherwize put in buffer
		INC	CX			;next count
		INC	SI			;pointer to next char
		INC	DL			;next column
		JMP	NEXT_DISPLAY		;show line again
END_OF_INPUT:
		CMP	BL,"0"			;if replace char is "0"
		JZ	NO_ZERO			;dont put terminator in
		MOV	BYTE PTR[SI],0		;terminate string
NO_ZERO:
		CALL	CURSOR_OFF
		ADD	SP,6			;clean off stack
		POP	BP			;
		RET				;that's all
INPUT ENDP

GETKEY PROC NEAR
		XOR	AH,AH			;getkey function number
		INT	16H			;go get a key
		RET				;return it
GETKEY ENDP

;------------------------------------------------------------------
;ax = row  bx = col        displays string at ds:si
;------------------------------------------------------------------
DISPLAY_STRING PROC NEAR
		PUSH	SI			;save si for main routines
		PUSH	DI
		CALL	CALC_SCRN_ADDR		;get es:di for row col
		MOV	AH,7			;get normal attribute
		CALL	WAIT_VERT
NEXT_CHAR:
		LODSB				;get char from string
		OR	AL,AL			;test for zero
		JZ	LAST_CHAR	;if zero, string has been printed
		STOSW			;put char and attribute on screen
		JMP	NEXT_CHAR	;until string has been printed
LAST_CHAR:
		POP	DI
		POP	SI			;restore si for main routines
		RET				;that's all
DISPLAY_STRING ENDP

;------------------------------------------------------------------
;ax = row bx= col, returns es:di pointing to the screen address
;------------------------------------------------------------------
CALC_SCRN_ADDR PROC NEAR
		PUSH	CX
		PUSH	DX			;mul destroys dx
		PUSH	AX			;save ax for later
		MOV	ES,CS:BIOS_SEG		;into es
		MOV	AX,0B800H		;screen seg = b800h
		CMP	ES:BYTE PTR[49H],7	;if 40:49 == 7
		JNZ	COLOR			;then
		MOV	AH,0B0H			;screen seg = b000h
COLOR:
		MOV	ES,AX			;into es
		POP	CX			;get row
		MOV	AX,160			;160 bytes to a row of text
		ADD	AX,CS:DIFF		;# characters > 80
		ADD	AX,CS:DIFF		;# of attribute bytes > 80
		MUL	CX			;row * 160 + diff*2
		ADD	AX,BX			;+col
		ADD	AX,BX			;row*160 + col*2
		MOV	DI,AX			;es:di points to right address
		POP	DX			;restore dx
		POP	CX
		RET				;that's all
CALC_SCRN_ADDR ENDP

;------------------------------------------------------------------
;ax = char di = sieve
;------------------------------------------------------------------
VERIFY PROC NEAR
		PUSH	CX		;save registers for main routines
		PUSH	DI
		PUSH	SI
		PUSH	DS
		POP	ES
		MOV	SI,DI			;si = sieve address
		CALL	STRLEN			;how many chars in sieve (cx)
		JCXZ	ANY_KEY			;get key if no chars in sieve
		CMP	AL,"A"			;if lower case
		JB	NOT_SMALL		;
		AND	AL,0DFH			;make upper case
NOT_SMALL:
		REPNZ	SCASB			;search for char in the sieve
ANY_KEY:					;set zero flag to indicate it
		POP	SI			;restore registers
		POP     DI
		POP	CX
		RET				;that's all
VERIFY ENDP
;----------------------------------------------------------------------
STRLEN PROC NEAR
		PUSH	SI			;save si for main routines
		PUSH	AX
		MOV	CX,-1			;count for string length
NEXTS:
		INC	CX			;next count
		LODSB				;next char
		OR	AL,AL			;is it a zero
		JNZ	NEXTS			;if not get next char
		POP	AX
		POP	SI			;restore si for main routines
		RET				;thats all
STRLEN ENDP

;------------------------------------------------------------------
;input: al = ascii lsb ah = ascii msb
;   example: if hex is '3F', ah = '3' al = 'F'  result: al = 3Fh
;output: al = hex byte
;------------------------------------------------------------------
ASCII_HEX_TO_HEX PROC NEAR
		TEST	AH,40H			;if "A" - "F"
		JZ	AH_EXIT			;
		SUB	AH,"A"-10		;make 10-15
AH_EXIT:
		TEST	AL,40H			;if "A" - "F"
		JZ	AL_EXIT			;
		SUB	AL,"A"-10		;make 10-15
AL_EXIT:
		AND	AX,0F0FH		;if "0" - "9"   make 0-9
		SHL	AL,1			;
		SHL	AL,1			;
		SHL	AL,1			;	
		SHL	AL,1			;
		OR	AL,AH			;combine msn and lsn
		RET				;that's all
ASCII_HEX_TO_HEX ENDP

;------------------------------------------------------------------
;input: al = char to be translated:
;    example: if hex is '3F', al = '3' ah = 'F'
;output: al = msb of translation, ah = lsb of translation
;------------------------------------------------------------------
HEX_TO_ASCII_HEX PROC NEAR
		DB	0D4H,10H		;div AL/16-remainder in al
		OR	AX,3030H		;make ascii
		CMP	AL,"9"
		JBE	ALEXIT
		ADD	AL,7			;if a - f make "A" - "F"
ALEXIT:
		CMP	AH,"9"
		JBE	AHEXIT
		ADD	AH,7			;if a - f make "A" - "F"
AHEXIT:
		XCHG	AL,AH
		RET				;that's all
HEX_TO_ASCII_HEX ENDP

LAST_BYTE LABEL BYTE			;marks end of resident code and
					;start of memory used to save screen

INSTALLED_SEGMENT DW 0
DISABLED	DB	CR,LF,"RAMVIEW IS DISABLED",CR,LF,"$"
ENABLED		DB	CR,LF,"RAMVIEW IS RE-ENABLED",CR,LF,"$"

;------------------------------------------------------------------
;determine if vectors have changed since program was installed
;------------------------------------------------------------------
HOOKED_VECTORS_SAME? PROC NEAR
		MOV	CX,INSTALLED_SEGMENT	;get executing segment
		XOR	AX,AX			;interrupt table segment
		MOV	ES,AX			;into the extra segment
		CMP	CX,ES:[10H*4+2]		;see if int 10h points at us
		JNZ	VECTOR_CHANGED
		CMP	CX,ES:[9*4+2]		;see if int 9 points at us
VECTOR_CHANGED:
		RET
HOOKED_VECTORS_SAME? ENDP

;------------------------------------------------------------------
;determine if program is already installed
;------------------------------------------------------------------
PROGRAM_ALREADY_IN  PROC NEAR
		NOT	WORD PTR START		;only srch for active copy
		MOV	START_SEGMENT,60H	;start after dos
		MOV	START_OFFSET,0		;
		MOV	END_SEGMENT,CS		;stop looking before you
		MOV	END_OFFSET,0		; get to this program
		MOV	SI,OFFSET START		;start at modified byte
		MOV	CX,25			;enough of a match
		CALL	SEARCH_MEM		;use our search
		PUSHF				;save zr flag
		MOV	AX,START_SEGMENT	;get address of find
		MOV	INSTALLED_SEGMENT,AX	;save in installed address
		MOV	AX,START_OFFSET
		MOV	CL,4
		SHR	AX,CL
		SUB	AX,10H			;adjust for psp
		ADD	INSTALLED_SEGMENT,AX
		MOV	START_SEGMENT,0		;reset starting address
		MOV	START_OFFSET,0
		MOV	END_OFFSET,0FH		;reset ending address
		MOV	END_SEGMENT,0FFFFH
		POPF				;restore flgs from search
		RET
PROGRAM_ALREADY_IN  ENDP

;------------------------------------------------------------------
;uninstall routines
;------------------------------------------------------------------
UNINSTALL PROC NEAR
		CALL	HOOKED_VECTORS_SAME?	;if all vectors still hooked
		JZ	UNINSTALL_OK		;go ahead and dis installed

		NOT	WORD PTR START
		MOV	ES,INSTALLED_SEGMENT	;else, change the disable flag
		NOT	ES:DISABLE		;in the installed program
		MOV	DX,OFFSET ENABLED	;get the message corresponding
		CMP	ES:DISABLE,-1		;to the action that causes
		JNZ	ITS_DISABLED		;
		MOV	DX,OFFSET DISABLED	;
ITS_DISABLED:					;
		MOV	AH,9			;and display that message
		INT	21H
		JMP	SHORT UNINSTALL_EXIT	;all done here.
UNINSTALL_OK:
		MOV	ES,INSTALLED_SEGMENT	;get resident prog's psp
		MOV	DX,ES:WORD PTR ADDR_INT9H	;put back int 9 vector
		MOV	DS,ES:WORD PTR ADDR_INT9H+2
		MOV	AH,25H
		MOV	AL,9
		INT	21H
		MOV	DX,ES:WORD PTR ADDR_INT10H	;restore int 10h vector
		MOV	DS,ES:WORD PTR ADDR_INT10H+2
		MOV	AH,25H
		MOV	AL,10H
		INT	21H
		PUSH	ES
		MOV	ES,ES:[2CH]		;get segment of environment
		MOV	AH,49H			;belonging to resident program
		INT	21H			;free it
		POP	ES
		MOV	AH,49H			;free memory block of program
		INT	21H
		PUSH	CS
		POP	DS			;get back our data segment
		MOV	DX,OFFSET UNINSTALLED
		MOV	AH,9
		INT	21H			;for whom it may concern
UNINSTALL_EXIT:
		RET
UNINSTALL ENDP
;----------------------------------------------------------------------
INSTALL PROC NEAR
		MOV	CL,9			;link vector 9
		MOV	SI,OFFSET ADDR_INT9H
		MOV	DI,OFFSET INT9H
		CALL	INSTALL_VECTOR
		MOV	CL,10H			;link vector 10h
		MOV	SI,OFFSET ADDR_INT10H
		MOV	DI,OFFSET INT10H
		CALL	INSTALL_VECTOR
		RET
INSTALL ENDP
;----------------------------------------------------------------------
INSTALL_VECTOR PROC NEAR

		MOV	AL,CL			;get vector number
		MOV	AH,35H			;get interrupt vector
		INT	21H			;
		MOV	[SI],BX			;save interrupt vector
		MOV	[SI+2],ES		;
		MOV	DX,DI			;get replacement address
		MOV	AH,25H			;set vector address
		MOV	AL,CL			;for vector
		INT	21H
		RET

INSTALL_VECTOR ENDP

_TEXT ENDS
		END	START