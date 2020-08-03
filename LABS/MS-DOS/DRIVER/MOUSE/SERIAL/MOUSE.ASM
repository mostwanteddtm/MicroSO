;Released to the public domain, 1989, by JRB.
;
;	3-1-1988	JRB. Version 1.0 works!
;
;	3-5-1988	JRB. Fixed bugs in updating a GCB that overlaps the
;			screen boundary.
;	3-7-1988	JRB. Fixed yet more bugs. Changed the way I call user
;			routines to match the Microsoft calling sequence.
;	8-17-1988	JRB. Major reorganization, fixes some more screen
;			boundary problems. Changed to a much simpler GCB
;			rotation routine. Version 1.1
;	9-2-1988	More bug fixes. Version 1.11
;
;	7-28-1989	Version 1.2. Keith Johnson - Changed to a ballistic
;			movement algorithm.

;ASCII control codes
LF	EQU	10		;Line feed
CR	EQU	13		;Carriage return
DOS_SET_INT	EQU	25H	;SET INTERRUPT VECTOR
DOS_GET_INT	EQU	35H	;GET INTERRUPT VECTOR
;

;Turn this flag ON if you want to run the mouse driver under a debugger, using
;the internal debug routine to generate mouse events. Be sure to set SYS_FILE
;OFF if you turn on DEBUG.
DEBUG	EQU	0H

;This Flag controls the type of driver produced. If you set it to 0FFFFH,
;then we produce a .SYS file, otherwise we produce a .COM file.
SYS_FILE EQU	0H

;This structure defines the order in which registers are pushed onto the
;stack on entry to the INT 33H routine.
RETURN_STACK	STRUC
	Return_ES	DW	1
	Return_DS	DW	1
	Return_DI	DW	1
	Return_SI	DW	1
	Return_BP	DW	1
	Return_BX	DW	1
	Return_DX	DW	1
	Return_CX	DW	1
	Return_AX	DW	1
RETURN_STACK	ENDS


;IBM ROM BIOS functions
RS232_INT	EQU	14H		;INT 14H
RS232_INIT	EQU	0		;Function 0 is INITIALIZE

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
DOS_SEG_2 SEGMENT AT 0040H
		ORG	17H
KB_FLAG		DB	?		;KEYBOARD FLAG
;
;	SHIFT FLAG EQUATES IN KB_FLAG
;
DOS_INS_STATE	EQU	80H		;INSERT STATE IS ACTIVE
DOS_CAPS_STATE	EQU	40H		;CAPS LOCK STATE HAS BEEN TOGGLED
DOS_NUM_STATE	EQU	20H		;NUM LOCK STATE HAS BEEN TOGGLED
DOS_SCROLL_STATE EQU	10H		;SCROLL LOCK STATE HAS BEEN TOGGLED
DOS_ALT_KEY	EQU	08H		;ALTERNATE KEY DEPRESSED
DOS_CTL_KEY	EQU	04H		;CONTROL KEY DEPRESSED
DOS_LEFT_SHIFT	EQU	02H		;LEFT SHIFT KEY DEPRESSED
DOS_RIGHT_SHIFT	EQU	01H		;RIGHT SHIFT KEY DEPRESSED

		ORG	4EH
Vid_Page_Offset DW	?		;Offset of video page from base segment
		ORG	63H
DOS_2_CRT_BASE	DW	?		;CRT CONTROLLER BASE ADDRESS
		ORG	6CH
TICK_COUNTER	DB	?
DOS_SEG_2	ENDS

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;8250 DIVISOR DEFINITIONS
;
;	7	6	5	4	3	2	1	0
;	----Baud Rate----	-Parity--	Stopbits	-DataBits-
;	=================	=========	========	===========
;	000 - 110		x0 - None	0 - 1	10 - 7 bits
;	001 - 150		01 - Odd	1 - 2	11 - 8 bits
;	010 - 300		11 - Even
;	011 - 600
;	100 - 1200
;	101 - 2400
;	110 - 4800
;	111 - 9600
;
;8250 DEFINITIONS
bit_tbe 	equ	02h
bit_carrier	equ	80h
bit_cts 	equ	10h
bit_data_rdy	equ	01H

;6845 CRT Controller Register Definitions
CRT_Ctrl_Horiz_Total	EQU	0	;Horizontal Total Characters
CRT_Ctrl_H_Displayed	EQU	1	;Horizontal Displayed
CRT_Ctrl_HSync_Pos	EQU	2	;Horizontal Sync Position
CRT_Ctrl_Hsync_Width	EQU	3	;Horizontal Sync Width
CRT_Ctrl_Vert_Total	EQU	4	;Vertical Total Rows
CRT_Ctrl_VTotal_Adjust	EQU	5	;Scan Lines
CRT_Ctrl_Vert_Displayed EQU	6	;Vertical Rows
CRT_Ctrl_VSync_Pos	EQU	7	;Character Row
CRT_Ctrl_Interlace_Mode EQU	8
CRT_Ctrl_Max_Scan_Addr	EQU	9
CRT_Ctrl_Cursor_Start_H EQU	0AH
CRT_Ctrl_Cursor_Start_L EQU	0BH
CRT_Ctrl_Cursor_H	EQU	0CH
CRT_Ctrl_Cursor_L	EQU	0DH
CRT_Ctrl_Cursor_Addr_H	EQU	0EH
CRT_Ctrl_Cursor_Addr_L	EQU	0FH
CRT_Ctrl_Light_Pen_H	EQU	10H
CRT_Ctrl_Light_Pen_L	EQU	11H

;Video Memory and GCB definitions
CRT_Base_Seg	EQU	0B800H		;Base address of CGA video memory
Next_Scan_Line	EQU	2000H		;One-half of a video screen buffer
Prev_Scan_Line	EQU	3FB0H		;Offset to next scan line
GCB_Height	EQU	16
GCB_Width	EQU	2
;GCB_Size is actually the size of the buffer we need to store a GCB from the
;screen. Since the GCB will probably not be byte-aligned, we add one byte to
;the width in order to be certain of capturing all of it.
GCB_Size	EQU	(GCB_Height * (GCB_Width+1))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Code_Seg SEGMENT PUBLIC PARA 'CODE'
	ASSUME ES:Code_Seg,CS:Code_Seg,DS:Code_Seg

IF	SYS_FILE
	ORG	00000H

Sys_Proc	PROC	FAR
	DB	0FFH
	DB	0FFH
	DB	0FFH
	DB	0FFH
	DW	8000H			;Attribute word, Character devic
	DW	MOUSE			;Strategy, Interupt entry points
	DW	Driver_Interrupt	;Interrupt entry point
	DB	'MS$MOUSE'

MOUSE:	MOV	CS:[DRB_Off],BX 	;Save Offset and Segment of the
	MOV	CS:[DRB_Seg],ES 	;Device Request Block
	RET

DRB_Off DW	0			;Device Request Block Offset
DRB_Seg DW	0			;Device Request Block Segment

Driver_Interrupt:			;Driver Interrupt Entry Point
	PUSHF
	PUSH	AX
	PUSH	CX
	PUSH	DX
	PUSH	BX
	PUSH	BP
	PUSH	SI
	PUSH	DI
	PUSH	DS
	PUSH	ES
	LDS	BX,DWORD PTR CS:[DRB_Off]
	MOV	AL,[BX]+2		;Get the DRB Command code
	OR	AL,AL
	JNZ	Mouse_Exit		;Branch if not "INITIALIZE"
	JMP	Init_Mouse		;Initialize the Mouse Driver

Mouse_Exit:
	MOV	AH,1			;Unsupported commands come here
	LDS	BX,DWORD PTR CS:[DRB_Off]
	MOV	[BX]+3,AX		;AH = 1 Means we are done with
	POP	ES			;the command, and no error.
	POP	DS
	POP	DI
	POP	SI
	POP	BP
	POP	BX
	POP	DX
	POP	CX
	POP	AX
	POPF
	RET

Sys_Proc	ENDP
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

ELSE
IF	(NOT DEBUG)
;Create a COM file
	ORG	100H
ELSE
;Create a .EXE file
	ORG	0
ENDIF
MOUSE:	JMP	Init_Mouse
ENDIF
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;These variables are not used (because I use a ballistic sensitivity algorithm),
;but we save them here and return them if the application asks for them.
Dbl_Speed_Thr	DW	50		;Normal - halfway between 1 and 100
Horiz_Sens	DW	50
Vert_Sens	DW	50

CRT_Page	DW	0		;Current Video Page Number
CRT_Ctrl	DW	3D4H		;Base Address of CRT Controller
Cursor_Count	DB	0FFH
Cursor_Line1	DW	0FFFFH		;First Line of Hdwr Text Cursor
Cursor_Line2	DW	7700H		;Last line of Hdwr Text Cursor
Cursor_Select	DB	0		;0 = Software, 1 = Hardware
Page_Size_in_Paras DW	0		;Size of a Video Page in paragraphs

;The following 13 words are a block and are initialized in Software_Reset.
;The block ends with R_ButtRV.
Button_Status	DW	0		;Current Button Status
L_Butt_P	DW	0		;Left Button Press Count
L_Butt_PH	DW	0FFFFH		;Horizontal Coordinate
L_Butt_PV	DW	0FFFFH		;Vertical Coordinate
L_Butt_R	DW	0		;Left Button Release Count
L_Butt_Rh	DW	0FFFFH		;Horizontal Coordinate
L_Butt_RV	DW	0FFFFH		;Vertical Coordinate
R_Butt_P	DW	0		;Right Button Press Count
R_Butt_PH	DW	0FFFFH		;Horizontal Coordinate
R_Butt_PV	DW	0FFFFH		;Vertical Coordinate
R_Butt_R	DW	0		;Right Button Release Count
R_ButtRH	DW	0FFFFH		;Horizontal Coordinate
R_ButtRV	DW	0FFFFH		;Vertical Coordinate

Cursor_Data	Struc
	Count		DW	0	;Mickey Count
	Curs_Pos	DW	0	;Current Cursor Position
	Mick_Pix_Ratio	DW	0	;Mickey/Pixel Ratio
	Remainder	DW	0	;Unused Mickeys from previous movement
	Adjust_Remain	DW	0	;Remainder from ballistic algorithm
	;This is a virtual screen position, as opposed to pixel positions.
	Virtual_Pos	DW	0
	Pixels_per_Char DW	8H
	Min		DW	0	;Minimum Horizontal Position
	Max		DW	0	;Maximum Horizontal Position
Cursor_Data	Ends

;This declares a structure to hold horizontal data about the cursor.
Horiz		Cursor_Data	<>
;This declares a structure to hold vertical data about the cursor.
Vert		Cursor_Data	<>

User_Event_Mask DW	0		;User Subroutine Event Mask
User_Sub_Off	DW	0		;User Event Subroutine Offset
User_Sub_Seg	DW	0		;User Event Subroutine Segment
;Table of Alternate Subroutine Call Masks and addresses
Alt_Subr_Tbl_Struc	Struc
	User_Call_Mask	DW	0	;Conditions for calling the user routine
	User_Address	DW	0	;Address of the user routine
	User_Segment	DW	0	;segment
	In_User_Flag	DB	0	;Flag that is set when we call the routine
Alt_Subr_Tbl_Struc	ENDS

;Alternate Subroutine Call Mask and Addresses for 3 routines.
Alt_Subr_Tbl	Alt_Subr_Tbl_Struc	3 Dup (<>)

Cond_Off_Left	DW	0		;Conditional Off Left Boundary
Cond_Off_Top	DW	0		;Top Boundary
Cond_Off_Right	DW	0		;Right Boundary
Cond_Off_Low	DW	0		;Lower Boundary

LtPen_Mode	DB	0FFH		;Light Pen Emulation Mode

;Buffers for the user-defined Screen Mask and Cursor Mask
GCB_Screen_Mask DB	GCB_Size DUP(0FFH)
GCB_Cursor_Mask DB	GCB_Size DUP(0)

Horiz_Hot_Spot	DW	0FFFFH		;Horizontal Hot Spot relative to GCB
Vert_Hot_Spot	DW	0FFFFH		;Vertical Hot Spot relative to GCB
GCB_Horiz_Pos	DW	0		;Position of the GCB on the screen
GCB_Vert_Pos	DW	0
Prev_GCB_Horiz_Pos DW	0
Prev_GCB_Vert_Pos DW	0
Old_Horiz_Pos	DW	0
Old_Vert_Pos	DW	0
;This is the bit count by which the GCB must be rotated in order to match the
;bit offset (from the nearest byte) of the GCB screen position.
GCB_Rotate_Count DB	0
;GCB Horizontal Position, rounded down to the nearest byte. This is the left-
;most of the current GCB position and the previous GCB position.
;The height of the GCB, plus the vertical overlap between the new and previous
;GCB positions.
GCB_Height_plus_Overlap DW	0
GCB_Horiz_Byte_Pos DW	0
;Lower of Previous and Current GCB Positions, if the new GCB will overlap the
;previous GCB. If the mouse moved far enough to put the new GCB outside the
;previous GCB, then this is the (new) GCB_Vertical_Pos.
GCB_Lower_Pos	DW	0

;The GCB Video Address, as a double word.
GCB_Video_Address DW	0
Curr_Pg_Seg	DW	0B800H		;Segment address of current page

Update_Block_Width DW	0		;Width of block to update on screen
Update_Block_Height DW	0		;Height of block to update on screen

Cursor_Update_Flag DB	0		;Updating the cursor position
;The In_Mouse flag prevents reentrancy problems after we issue the EOI and
;reenable interrupts, but before we finish all of the processing associated
;with a mouse interrupt.
In_Mouse_Flag	DB	0		;Checking the event mask
;Set IFF we have screen data (from under the cursor) saved.
Char_Under_Crs_Saved DB 0

;The character and attribute under the software text cursor, or the data under
;the GCB. We have to have this data so we can restore the screen when the GCB
;moves or is disabled.
Data_Under_Cursor DW	GCB_Size DUP(0)

Columns 	DW	80

Tmp_Butt_Stat	DW	0		;Temporary Button Status flag
;Tmp_Button_Flag matches the Alternate Call Mask in bit positions and meanings.
Tmp_Button_Flag DW	0		;Button Flags (matches Call Mask)
;Button_Flag matches the Alternate Call Mask in bit positions and meanings.
Button_Flag	DW	0		;Another copy of the Button Flags

Char_Cell_Width DW	8H
Char_Cell_Height DW	8H

Screen_Size_H	DW	640		;Horizontal screen pixel count
Screen_Size_V	DW	200		;Vertical Screen pixel count

Com_Pt_Num	DW	0		;COM Number
Comm_Tbl	DW	3F8H		;Port Address for COM1
		DB	0CH,0EFH	;Interrupt Number and Mask
		DW	2F8H		;Port Address for COM2
		DB	0BH,0F7H	;Interrupt Number and Mask
		DW	3E8H		;Port Address for COM3
		DB	0CH,0EFH	;Interrupt Number and Mask
		DW	2E8H		;Port Address for COM4
		DB	0BH,0F7H	;Interrupt Number and Mask

Default_GCB	DW	0011111111111111B	;Graphics Cursor Block
		DW	0001111111111111B
		DW	0000111111111111B
		DW	0000011111111111B
		DW	0000001111111111B
		DW	0000000111111111B
		DW	0000000011111111B
		DW	0000000001111111B
		DW	0000000000111111B
		DW	0000000000011111B
		DW	0000000111111111B
		DW	0001000011111111B
		DW	0011000011111111B
		DW	1111100001111111B
		DW	1111100001111111B
		DW	1111110000111111B

		DW	0000000000000000B
		DW	0100000000000000B
		DW	0110000000000000B
		DW	0111000000000000B
		DW	0111100000000000B
		DW	0111110000000000B
		DW	0111111000000000B
		DW	0111111100000000B
		DW	0111111110000000B
		DW	0111111111000000B
		DW	0111110000000000B
		DW	0100011000000000B
		DW	0000011000000000B
		DW	0000001100000000B
		DW	0000001100000000B
		DW	0000000000000000B

;This is a temporary screen buffer that we use for updating the GCB image. By
;updating to this buffer first, then putting it on the screen, we eliminate
;cursor flashing problems when the new GCB overlaps the previous GCB, or when
;the screen is slow and the user could see the two stages of the GCB update
;(XOR and AND).
;This buffer must be twice the GCB width plus 1 byte, in order to hold GCBs
;that overlap horizontally by only one pixel, and it must be twice the GCB
;height, less one scan line, in order to hold two GCBs that overlap by only
;one scan line.
Temp_Screen	DB	(((GCB_Width * 2) + 1) * ((GCB_Height * 2)-1)) DUP(0)

Int_Number	DB	0		;The Mouse Interrupt Number
Int_Enable_Mask DB	0		;A mask value for the PIC mask register
Mouse_Port	DW	0		;I/O Address for the Mouse
X_AXIS_CHANGE	DB	0		;X-Axis change in pos., used by ISR
Y_AXIS_CHANGE	DB	0		;Y-Axis change in pos., used by ISR
Old_Int_10H_Off DW	0		;Offset of old INT 10H routine
Old_Int_10H_Seg DW	0		;Segment
Old_Int_33H_Off DW	0
Old_Int_33H_Seg DW	0
Old_Mouse_ISR	DW	0		;Offset & Segment of the old
Old_Mouse_Seg	DW	0		;mouse (serial) interrupt vector.
;This is a pointer to the routine that will process the next byte we are
;expecting from the mouse.
PACKET_BYTE	DW	Offset ISR_1st_Byte

Mouse_Active_Flag DB	0		;0 if driver is enabled, -1 if Disabled

Jmp_Tbl 	DW	Reset,Show_Cursor,Hide_Cursor
		DW	Get_Pos,Set_Pos,Get_ButP
		DW	Get_ButR,Set_Min_Max_Horiz,Set_Min_Max_Vert
		DW	Set_GCB,Set_Text_Cursor,GetCount
		DW	Set_Mask,LPEM_ON,LPEM_Off
		DW	Set_Ratio,Cond_Off,Undefined
		DW	Undefined,Undefined,Swap_Int
		DW	Get_Mem,Save_State,Restore_State
		DW	Set_Alt_Subr,Get_Alt_Subr,Set_Sens
		DW	Get_Sens,Undefined,Set_CRT_Page
		DW	Get_CRT_Page,Disable_Mouse,Enable_Mouse
		DW	Software_Reset,Undefined,Undefined
		DW	Driver_Version
Jmp_Tbl_End	EQU	$

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Interrupt 33H handler - processes mouse function calls. This code does
;NOT handle interpreted BASIC calls. We all know that BASIC is brain dead,
;and interpreted BASIC is even more so. It has a special calling sequence
;that would go here if I wanted to support it.
;
;Entry Conditions:
;	AL	- Mouse Function Number
;	AH	- Zero
;
;Exit Conditions:	As defined by the mouse function.
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
INT_33H PROC	FAR
	OR	AH,AH			;If AH <> 0, then it can't be a
	JNZ	Not_Mouse_Func		;call to us.
	STI				;Allow interrupts to continue
	CALL	Call_Mouse_Func 	;Call the appropriate Mouse Function
Int_33_Iret:
	IRET
;
;Not a Mouse Function, pass it to the old INT 33H vector
;
Not_Mouse_Func:
	CMP	CS:Old_Int_33H_Seg,0	;Was there an INT 33H routine installed?
	JZ	Int_33_Iret		;Branch if not - just return
	JMP	DWORD PTR CS:Old_Int_33H_Off	;else there was; call it
INT_33H ENDP


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Call Mouse Function - Calls the appropriate mouse function. If the
;function number is invalid it just returns.
;
;Entry Conditions:
;	AX	- AH - Mouse Function Number
;
;Exit Conditions:	As defined by the mouse function.
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Call_Mouse_Func PROC	NEAR
	PUSH	AX
	PUSH	CX
	PUSH	DX
	PUSH	BX
	PUSH	BP
	PUSH	SI
	PUSH	DI
	PUSH	DS
	PUSH	ES

	MOV	BP,SP			;Save the pointer to the registers
;Test to see if the function number is valid.
	CMP	AL,(Offset Jmp_Tbl_End - Offset Jmp_Tbl) /2
	JA	Call_Mouse_Func_Exit	;Branch if invalid
	PUSH	BX
	SHL	AX,1			;Multiply by 2 (bytes per jump table entry)
	MOV	BX,CS
	MOV	DS,BX
	MOV	BX,AX			;BX <- Pointer into table
	MOV	AX,[BX]+Jmp_Tbl 	;Get the entry
	POP	BX
	CLD
	CALL	AX			 ;And call it
IF	NOT DEBUG
	CMP	Mouse_Active_Flag,-1	;Test the Mouse Active Flag
	JZ	Call_Mouse_Func_Exit	;Branch if Mouse driver is disabled
	IN	AL,21H			;Interrupt Mask Register
	AND	AL,CS:Int_Enable_Mask
	OUT	21H,AL
ENDIF

Call_Mouse_Func_Exit:
	POP	ES
	POP	DS
	POP	DI
	POP	SI
	POP	BP
	POP	BX
	POP	DX
	POP	CX
	POP	AX
	RET

CALL_MOUSE_FUNC ENDP

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;INT 10H - Processes video mode changes, because the mouse driver has to
;know about them. Also handles Light Pen function calls.
;
;Entry Conditions:
;
;Exit Conditions:
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Our_Int_10H	PROC	FAR
	OR	AH,AH			;Is it Set Video Mode?
	JNZ	Not_Set_Mode		;Branch if not
	PUSH	AX
	MOV	AL,2			;Mouse Hide Cursor Function
	CALL	Call_Mouse_Func 	;Else Hide the Cursor
	POP	AX
	MOV	CS:Cursor_Count,-1	;Set the Cursor Count to -1
	CALL	Set_Vid_Mode		;Set our video mode
Int_10H_Exit:
	JMP	DWORD PTR CS:Old_Int_10H_Off	;And call the original video func

Not_Set_Mode:
	CMP	AH,4			;Is it Read Light Pen?
	JNZ	Int_10H_Exit		;Exit if not
	TEST	CS:LtPen_Mode,0FFH	;See if we have light pen mode on
	JZ	Int_10H_Exit		;Exit if not
	STI
	PUSH	DS
	MOV	AX,CS
	MOV	DS,AX
	MOV	AX,Horiz.Virtual_Pos
	MOV	BX,AX
	CWD
	DIV	Horiz.Pixels_per_Char
	XCHG	AX,BX
	DIV	BYTE PTR Char_Cell_Width
	MOV	DL,AL
	MOV	AX,Vert.Virtual_Pos
	MOV	CH,AL
	DIV	BYTE PTR Char_Cell_Height
	MOV	DH,AL
	MOV	AH,BYTE PTR Button_Status
	POP	DS
	IRET

Our_Int_10H	ENDP


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Set the Video Mode
;
;Entry Conditions:
;	AH	- Number of Columns
;	AL	- Display Mode
;	BH	- Display Page
;
;Exit Conditions:	NONE
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Set_Vid_Mode	PROC	NEAR
	PUSH	DS
	PUSH	CS
	POP	DS
	PUSH	AX
	PUSH	BX
	AND	AL,7FH
	CLI
	CMP	AL,7			;80 x 25 Mono Text
	JNZ	Not_Mode_7
	MOV	AL,2			;Switch Mode 7 to Mode 2
Not_Mode_7:
	MOV	Curr_Pg_Seg,0B800H
	MOV	CRT_Page,0
	MOV	Columns,80		;80 Columns
	MOV	Page_Size_in_Paras,100H
	MOV	Screen_Size_H,640	;640 Dots Horizontally
	MOV	Screen_Size_V,200	;200 Dots Vertically
	MOV	BX,0108H
	MOV	BYTE PTR Char_Cell_Height,BL
	MOV	BYTE PTR Char_Cell_Width,BL
	MOV	BYTE PTR Horiz.Pixels_per_Char,BL
	MOV	BYTE PTR Vert.Pixels_per_Char,BL
	CMP	AL,4			;Check for text Modes 0 through 3
	JAE	Set_Mode_Graphics	;Branch if graphics mode ( >= 4)
	CMP	AL,2
	JAE	Set_Mode_Exit		;Branch if not a 40 column text mode (>=2)
	SHR	Columns,1		;Only 40 columns
	MOV	Page_Size_in_Paras,80H
	ADD	BYTE PTR Horiz.Pixels_per_Char,BL ;Double the character height
	ADD	BYTE PTR Char_Cell_Width,BL	;Double the character width
	JMP	Set_Mode_Exit

Set_Mode_Graphics:
	MOV	Page_Size_in_Paras,400H
	MOV	Byte Ptr Horiz.Pixels_per_Char,BH ;1
	MOV	Byte Ptr Vert.Pixels_per_Char,BH ;1
	CMP	AL,6			;640 x 200 Mono
	JE	Set_Mode_Exit

;Mode 4 or 5, 320 x 200 4-color
	ADD	Byte Ptr Char_Cell_Width,BL	;Add 8
	INC	Horiz.Pixels_per_Char
Set_Mode_Exit:
	MOV	AX,DOS_SEG_2
	MOV	DS,AX
ASSUME	DS:DOS_SEG_2
	MOV	AX,DOS_2_CRT_BASE	;Get the CRT Controller Address
	PUSH	CS
	POP	DS
ASSUME	DS:CODE_SEG
	MOV	CRT_Ctrl,AX
	STI
	POP	BX
	POP	AX
	POP	DS
	RET
Set_Vid_Mode	ENDP

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Reset the Mouse Driver and return status.
;
;Entry Conditions:
;	AX	- Zero
;
;Exit Conditions:
;	AX	- -1 if OK, else Zero
;	BX	- number of Buttons
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Mouse_Functions PROC	NEAR
Reset:
	MOV	DX,Mouse_Port		;Get the Base Address of the COM Port
	ADD	DX,3			;Point to the Line Control Register
	XOR	AL,AL
	OUT	DX,AL			;Set DLAB to Zero
	JMP	SHORT Reset_Mouse_2	;delay
Reset_Mouse_2:
	SUB	DX,2			;Interrupt Enable Register
	OUT	DX,AL			;Disable all interrupts
	MOV	AL,Int_Number		;Get the Mouse Interrupt Number
	MOV	DX,Offset Mouse_ISR	;Point it to us
	MOV	SI,Offset Old_Mouse_ISR ;and save the current vector
	CALL	Set_Vector		;Point it to our serial ISR
	MOV	AH,RS232_INIT		;Initialize the COM Port
	MOV	AL,10000010B		;1200 BPS, 7 Data Bits, No Parity, 1 Stop bit
	MOV	DX,Com_Pt_Num		;Get the port number
	INT	RS232_INT
	MOV	DX,Mouse_Port		;Address of the RX Data Register again
	INC	DX			;Interrupt Enable Register
	XOR	AL,AL			;Disable all Serial Interrupts
	OUT	DX,AL
	JMP	SHORT Reset_Mouse_3	;Delay
Reset_Mouse_3:
	ADD	DX,3			;Modem Control Register
	MOV	AL,1			;Raise DTR, drop RTS
	OUT	DX,AL
	SUB	DX,4			;Address of the RX Data Register again

	PUSHF
	STI
	PUSH	DS
	MOV	CX,DOS_SEG_2
	MOV	DS,CX
ASSUME	DS:DOS_SEG_2
	IN	AL,DX			;Clear the RD Register
	MOV	CL,TICK_COUNTER
	ADD	CL,3			;Wait three timer ticks
Reset_Mouse_4:
	CMP	CL,TICK_COUNTER
	JNZ	Reset_Mouse_4		;Loop for 3 Timer Ticks
	IN	AL,DX			;Clear the RD Register

	ADD	DX,4			;Modem Control Register
	MOV	AL,0BH			;OUT2, DTR, RTS
	OUT	DX,AL
	JMP	SHORT Reset_Mouse_5
Reset_Mouse_5:
	SUB	DX,4			;RD/TD Register
	MOV	CL,TICK_COUNTER
	ADD	CL,2			;Wait two timer ticks
Reset_Mouse_6:
	IN	AL,DX			;Clear the RD Register
	CMP	CL,TICK_COUNTER
	JNZ	Reset_Mouse_6		;Loop for 2 Timer Ticks
	POP	DS
ASSUME	DS:CODE_SEG
	POPF

	ADD	DX,5			;Line Status Register
	IN	AL,DX			;Clear all error flags
	JMP	SHORT Reset_Mouse_7
Reset_Mouse_7:
	SUB	DX,4			;Interrupt Enable Register
	MOV	AL,1			;Enable RDA Interrupts
	OUT	DX,AL
;Fall through to Software_Reset

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Software Reset
;
;Entry Conditions:
;	AX	- 33
;
;Exit Conditions:
;	AX	- Mouse Status
;	BX	- number of Buttons
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Software_Reset:
	MOV	[BP].Return_AX,0FFFFH	;Mouse is Installed
	MOV	[BP].Return_BX,2	;Two Button Mouse
	MOV	AH,0FH			;Get Current Video Mode
	INT	10H
	CLI
	MOV	Horiz.Mick_Pix_Ratio,1
	MOV	Vert.Mick_Pix_Ratio,2
	MOV	AX,Screen_Size_H	;Set the max horizontal mouse position
	DEC	AX			;to screen size -1.
	MOV	Horiz.Max,AX
	MOV	AX,Screen_Size_V	;Set the max vertical mouse position
	DEC	AX			;to screen size -1.
	MOV	Vert.Max,AX
	XOR	AX,AX
	MOV	Cursor_Count,AL 	;Hide Cursor later
	MOV	Horiz.Min,AX		;Min horizontal and vertical get set
	MOV	Vert.Min,AX		;to zero.
	MOV	User_Event_Mask,AX	;Clear the event mask
	MOV	Cursor_Select,AL
	MOV	Cursor_Update_Flag,AL
	MOV	In_Mouse_Flag,AL
	MOV	Cursor_Line1,0FFFFH
	MOV	Cursor_Line2,7700H
;Zero out all of the Button Press/Release flags and their associated positions.
;This also zeroes the button status and the Horizontal and Vertical Mickey counts.
	MOV	CX,(Offset R_ButtRV - Offset Button_Status + 2)/2
	PUSH	DS
	POP	ES
	MOV	DI,OFFSET Button_Status
	REPZ STOSW
	MOV	Horiz.Count,AX
	MOV	Vert.Count,AX
	DEC	AX			;AX <- 0FFFFH
	MOV	Horiz_Hot_Spot,AX
	MOV	Vert_Hot_Spot,AX
	MOV	SI,OFFSET Default_GCB	;Point to the default GCB
;CX (Vertical Hot Spot position) is already zero (from the REPZ above), but
;we also need BX (Horizontal Hot Spot position) to be zero.
	XOR	BX,BX
	CALL	Set_Active_GCB		;Make the default GCB the active GCB
	CALL	Hide_Cursor		;Now hide the cursor
	MOV	AX,Screen_Size_H
	SHR	AX,1			;Divide the Screen Height by 2
	MOV	BX,Screen_Size_V
	SHR	BX,1			;Divide the Screen Width by 2
	JMP	SHORT Set_Pos_2 	;Set the cursor position to center

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Show Cursor
;
;Entry Conditions:
;	AX	- 1
;
;Exit Conditions:	NONE
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Show_Cursor:
	MOV	AX,Screen_Size_V
	INC	AX
	MOV	Cond_Off_Top,AX
	MOV	Cond_Off_Right,AX
	XOR	AX,AX
	MOV	Cond_Off_Left,AX
	MOV	Cond_Off_Low,AX
	CMP	Cursor_Count,0
	JZ	Show_Cursor_Exit	;Branch if cursor is already visible

Show_Cursor_2:
	CMP	Cursor_Count,0FFH	;If Cursor Count is not -1
	JNZ	Show_Curs_3		;then increment the count and exit
;	INC	Cursor_Count		;Else increment the cursor count
;	JNZ	Show_Cursor_Exit	;Branch if not up to zero
	CALL	Set_ESDS_to_CS		;Set ES <- DS <- CS
	CALL	Display_Cursor
Show_Curs_3:
	INC	Cursor_Count
Show_Cursor_Exit:
	RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Hide the Cursor
;
;Entry Conditions:
;	AX	- 2
;
;Exit Conditions:	NONE
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Hide_Cursor:
	DEC	Cursor_Count		;Decrement the Cursor Count
	PUSH	CS
	POP	ES
	JMP	Restore_Data_Under_Cursor

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Get Button Status and Cursor Position
;
;Entry Conditions:
;	AX	- 3
;
;Exit Conditions:
;	BX	- Button Status
;	CX	- Horizontal Cursor Position (in Virtual Screen coordinates)
;	DX	- Vertical Cursor Position
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Get_Pos:
	CLI
	MOV	AX,Button_Status
	MOV	[BP].Return_BX,AX
	MOV	AX,Horiz.Virtual_Pos
	MOV	[BP].Return_CX,AX
	MOV	AX,Vert.Virtual_Pos
	MOV	[BP].Return_DX,AX
	STI
Undefined:
	RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Set Cursor Position
;
;Entry Conditions:
;	AX	- 4
;	CX	- new Horizontal Cursor Position
;	DX	- new Vertical Cursor Position
;
;Exit Conditions:	NONE
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Set_Pos:
	MOV	AX,DX			;AX <- new Vertical Position
	MOV	SI,Offset Vert		;Point to the Vertical Cursor Table
	CALL	Check_Bounds		;Validate the position
	MOV	BX,AX			;BX <- valid vertical position
	MOV	AX,CX			;AX <- new Horizontal Position
	MOV	SI,Offset Horiz 	;Point to the Horizontal Cursor Table
	CALL	Check_Bounds		;Validate the position
Set_Pos_2:
	CLI
	MOV	SI,Offset Horiz 	;Point to the Horizontal Cursor Table
	CALL	Set_Pos_Pixel		;Calculate a pixel position
	MOV	AX,BX			;Convert vertical virtual to pixel
	MOV	SI,Offset Vert		;Point to the Vertical Cursor Table
	CALL	Set_Pos_Pixel		;Calculate a pixel position
	STI
Set_Pos_3:
	CMP	Cursor_Count,0		;Are we displaying the cursor?
	JL	Set_Pos_Exit		;Branch if not
	CALL	Set_ESDS_to_CS
	CLI
	INC	Cursor_Update_Flag
	STI
	CALL	Display_Cursor
	CLI
	DEC	Cursor_Update_Flag
	STI
Set_Pos_Exit:
	RET

Set_Pos_Pixel:
	MOV	[SI].Curs_Pos,AX	;Save the Cursor Position
	CWD
	DIV	[SI].Pixels_per_Char	;And convert to pixel positions
	MUL	[SI].Pixels_per_Char
	MOV	[SI].Virtual_Pos,AX
	MOV	[SI].Remainder,0
	RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Get Button Press Information
;
;Entry Conditions:
;	AX	- 5
;	BX	- button number
;
;Exit Conditions:
;	AX	- button status for both buttons -
;		01 = Left button down
;		10 = Right button down
;	BX	- Number of button presses since last call
;	CX	- horizontal cursor coordinate at last press
;	DX	- vertical cursor coordinate at last press
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Get_ButP:
	MOV	SI,OFFSET L_Butt_P	;Pointer to Left Button Info
	TEST	BL,1			;Test to see which button
	JZ	Get_Button_Count	;Branch if they want the left button
	MOV	SI,OFFSET R_Butt_P	;Pointer to Right Button Info
	JMP	SHORT Get_Button_Count

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Get Button Release Information
;
;Entry Conditions:
;	AX	- 6
;	BX	- button number
;
;Exit Conditions:
;	AX	- button status for both buttons -
;		01 = Left button down
;		10 = Right button down
;	BX	- Number of button releases since last call
;	CX	- horizontal cursor coordinate at last release
;	DX	- vertical cursor coordinate at last release
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Get_ButR:
	MOV	SI,OFFSET L_Butt_R	;Pointer to Left Button Info
	OR	BX,BX
	JZ	Get_Button_Count	;Branch if left button
	MOV	SI,OFFSET R_Butt_R	;Pointer to Right Button Info
Get_Button_Count:
	MOV	AX,Button_Status	;Get the Current Button Status
	MOV	[BP].Return_AX,AX
	XOR	AX,AX			;Set the Count to Zero
	XCHG	AX,[SI]
	MOV	[BP].Return_BX,AX
	LODSW				;Skip the count (now zero)
	LODSW				;Get the Horizontal Coordinates
	MOV	[BP].Return_CX,AX
	LODSW				;And Vertical Coordinates
	MOV	[BP].Return_DX,AX
	RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Set Minimum and Maximum Horizontal Cursor Position
;
;Entry Conditions:
;	AX	- 7
;	CX	- Minimum Position
;	DX	- Maximum Position
;
;Exit Conditions:	NONE
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Set_Min_Max_Horiz:
	CALL	Make_CX_Min		;Make sure CX <= DX
	CLI
	MOV	Horiz.Min,CX		;Save the minimum and maximum values
	MOV	Horiz.Max,DX
	JMP	SHORT Set_MinMax_Now	;and put the cursor inside them

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Set Minimum and Maximum Vertical Cursor Position
;
;Entry Conditions:
;	AX	- 8
;	CX	- Minimum Position
;	DX	- Maximum Position
;
;Exit Conditions:	NONE
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Set_Min_Max_Vert:
	CALL	Make_CX_Min		;Make sure CX <= DX
	CLI
	MOV	Vert.Min,CX		;Save the minimum and maximum values
	MOV	Vert.Max,DX
Set_MinMax_Now:
	MOV	CX,Horiz.Curs_Pos
	MOV	DX,Vert.Curs_Pos
	JMP	Set_Pos

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Set Graphics Cursor Block
;
;Entry Conditions:
;	AX	- 9
;	BX	- Horizontal Cursor Hot Spot
;	CX	- Vertical Cursor Hot Spot
;	ES:DX	- Pointer to Screen and Cursor masks
;
;Exit Conditions:	NONE
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Set_GCB:
	MOV	AX,BX			;AX <- Horizontal Cursor Hot Spot
	CBW
	MOV	BX,Horiz.Pixels_per_Char
	MOV	SI,DX			;SI <- Ptr to GCB data
	CMP	BL,1			;Are we are in a character mode?
	JZ	Set_GCB_Not_Char	;Branch if not in a character mode
	CWD
	IDIV	BX			;Else convert the hot spot to a multiple
	IMUL	BX			;of character positions
Set_GCB_Not_Char:
	MOV	Horiz_Hot_Spot,AX
	MOV	AX,CX			;AX <- Vertical Cursor Hot Spot
	CBW
	MOV	Vert_Hot_Spot,AX	;Vertical Cursor Hot Spot
	DEC	Cursor_Count
	STI
	PUSH	ES
	POP	DS
	CALL	Set_Active_GCB
	CALL	Set_ESDS_to_CS
	JMP	Show_Cursor_2

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Set Text Cursor
;
;Entry Conditions:
;	AX	- 10
;	BX	- Cursor Select
;		0 = Software Text Cursor
;		1 = Hardware Text Cursor
;	CX	- Screen Mask Iff BX = 0
;		- Cursor First Scan Line Iff BX = 1
;	DX	- Cursor Mask Iff BX = 0
;		- Cursor Last Scan Line Iff BX = 1
;
;Exit Conditions:	NONE
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Set_Text_Cursor:
	DEC	Cursor_Count		;Do an implicit 'Hide Cursor'
	CALL	Set_ESDS_to_CS		;Set ES and DS to CS
	MOV	Cursor_Select,BL
	MOV	Cursor_Line1,CX
	MOV	Cursor_Line2,DX
	OR	BX,BX
	JNZ	Set_Text_Cursor_2	;Branch if text cursor
	JMP	Show_Cursor_2		;Branch if Software Cursor

Set_Text_Cursor_2:
	INC	Cursor_Count		;Show the cursor again
	MOV	AH,0FH
	AND	CL,AH
	AND	DL,AH
	MOV	CH,CL
	MOV	CL,DL
	MOV	AH,1
	INT	10H			;Set Cursor Size
	RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Get Motion Counters
;
;Entry Conditions:
;	AX	- 11
;
;Exit Conditions:
;	CX	- Horizontal Mickey Count since last call
;	DX	- Vertical Mickey Count since last call
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
GetCount:
	CLI				;Get Horizontal/Vertical Motion
	XOR	AX,AX			;Counters since last request.
	XCHG	AX,Vert.Count		;Vertical Count
	MOV	[BP].Return_DX,AX
	XOR	AX,AX
	XCHG	AX,Horiz.Count		;Horizontal Count
	MOV	[BP].Return_CX,AX
	STI
	RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Set User Interrupt Subroutine Call Mask and Address
;
;Entry Conditions:
;	AX	- 12
;	CX	- Call Mask
;	 Bit Definitions:
;			0 - Mouse Moved
;			1 - Left Button Pressed
;			2 - Left Button Released
;			3 - Right Button Pressed
;			4 - Right Button Released
;
;	ES:DX		- User Subroutine Address
;
;Exit Conditions:	NONE
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Set_Mask:
	CLI				;Set User Subroutine Event Mask
	AND	CX,7FH			;Mask off unused bits
	MOV	User_Event_Mask,CX
	MOV	User_Sub_Off,DX
	MOV	User_Sub_Seg,ES
	STI
	RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Turn Light-Pen Emulation Mode ON
;
;Entry Conditions:
;	AX	- 13
;
;Exit Conditions:	NONE
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
LPEM_ON:
	MOV	LtPen_Mode,0FFH
	RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Turn Light-Pen Emulation Mode OFF
;
;Entry Conditions:
;	AX	- 14
;
;Exit Conditions:	NONE
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
LPEM_Off:
	MOV	LtPen_Mode,0
	RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Set Mickey/Pixel Ratio
;
;Entry Conditions:
;	AX	- 15
;	CX	- Horizontal Mickey/Pixel Ratio
;	DX	- Vertical Mickey/Pixel Ratio
;
;		The ratio is the number of Mickeys of mouse movement for
;		every 8 virtual pixels of cursor movement.
;
;Exit Conditions:	NONE
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Set_Ratio:
	CALL	Calc_Ratio		;Calculate the Mickey/(1 Pixel) ratio
	MOV	Horiz.Mick_Pix_Ratio,CX ;Horizontal Mickey/Pixel Ratio
	MOV	CX,DX
	CALL	Calc_Ratio
	MOV	Vert.Mick_Pix_Ratio,CX	;Vertical Mickey/Pixel Ratio
	RET

Calc_Ratio:
	SAR	CX,1			;Divide by 8 to get Mickeys/(1 Pixel)
	SAR	CX,1
	SAR	CX,1
	OR	CX,CX			;Must be at least 1
	JNZ	Set_Ratio_2
	MOV	CX,1
Set_Ratio_2:
	RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Set Conditional Off Region
;
;Entry Conditions:
;	AX	- 16
;	CX	- Left border
;	DX	- Top border
;	SI	- Right Border
;	DI	- Bottom Border
;
;		If the Mouse moves into the defined region the driver does
;		an automatic 'Hide Cursor'.
;
;Exit Conditions:	NONE
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Cond_Off:
	DEC	Cursor_Count		;Hide the Cursor
	MOV	Cond_Off_Left,CX	;Left Boundary
	MOV	Cond_Off_Right,SI	;Right Boundary
	MOV	Cond_Off_Top,DX 	;Top Boundary
	MOV	Cond_Off_Low,DI		;Lower Boundary
	JMP	Show_Cursor_2

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Set Double Speed Threshold - not implemented, because I am using a ballistic
;driver algorithm.
;
;Entry Conditions:
;	AX	- 19
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Swap Interrupt Subroutines
;
;Entry Conditions:
;	AX	- 20
;	BX	- Segment of new subroutine
;	CX	- new Call Mask
;	DX	- Offset of new subroutine
;
;Exit Conditions:
;	BX	- Segment of old subroutine
;	CX	- old Call Mask
;	DX	- Offset of old subroutine
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Swap_Int:
	MOV	AX,User_Event_Mask	;Get the old Call Mask
	MOV	[BP].Return_CX,AX
	MOV	AX,User_Sub_Off 	;And the Offset of the old subroutine
	MOV	[BP].Return_DX,AX
	MOV	AX,User_Sub_Seg 	;and the Segment
	MOV	[BP].Return_ES,AX
	JMP	Set_Mask		;and set the new Mask and address

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Get State Storage Requirements
;
;Entry Conditions:
;	AX	- 21
;
;Exit Conditions:
;	BX	- amount of memory needed to save the Mouse state
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Get_Mem:
	MOV	[BP].Return_BX,(Offset Columns - Offset Dbl_Speed_Thr)
	RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Save the Mouse State
;
;Entry Conditions:
;	AX	- 22
;	ES:DX	- pointer to a buffer in which to store the state
;
;Exit Conditions:
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Save_State:
	CLI				;Do not allow interrupts while we are
	MOV	DI,DX			;saving the state.
	MOV	SI,OFFSET Dbl_Speed_Thr
	MOV	CX,(Offset Columns - Offset Dbl_Speed_Thr)
	CALL	Move_State
	STI
	RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Restore the Mouse State
;
;Entry Conditions:
;	AX	- 23
;	ES:DX	- pointer to a buffer in which the Mouse state was stored
;
;Exit Conditions:
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Restore_State:
	CLI				;Do not allow interrupts while changing
	MOV	AX,ES			;the state.
	MOV	DS,AX
	MOV	AX,CS
	MOV	ES,AX
	MOV	CX,(Offset Columns - Offset Dbl_Speed_Thr)
	MOV	SI,DX			;DS:SI now points to the buffer
	MOV	DI,OFFSET Dbl_Speed_Thr ;ES:DI now points to our variables
	CALL	Move_State
	STI
	CALL	Set_ESDS_to_CS
	JMP	Set_Pos_3

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Set Alternate Subroutine Call Mask and Address
;
;Entry Conditions:
;	AX	- 24
;	CX	- Interrupt Call Mask
;	DX	- User Subroutine Address
;	ES	- User Subroutine Segment
;
;Exit Conditions:
;	AX	- -1 IFF Error
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Set_Alt_Subr:
	CALL	Find_User_Alt_Routine	;Look up the routine
	JC	Set_Alt_Error		;Branch if no such call mask/no slot
	MOV	AX,ES			;Subroutine Segment
	OR	AX,DX			;Subroutine Address
	JNZ	Set_Alt_Non_Zero	;Branch if address is non-zero
;Else the subroutine segment and address are zero, so we want to zero out this
;entry in the table.
	MOV	CX,AX			;CX <- 0; set the call mask to zero
Set_Alt_Non_Zero:
	CLI
;This flag keeps track of whether or not we are in the user routine. We cannot
;assume that the user routine is reentrant, so we only call it once, then wait
;for it to return before setting the flag back to zero.
	MOV	[SI].In_User_Flag,0
	MOV	[SI].User_Call_Mask,CX	;Save the Mask
	MOV	[SI].User_Address,DX	;Save the Address
	MOV	[SI].User_Segment,ES	;And the Segment
	STI
	RET

Set_Alt_Error:
	MOV	[BP].Return_AX,-1
	RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Get Alternate Subroutine Call Mask and Address
;
;Entry Conditions:
;	AX	- 25
;	CX	- Interrupt Call Mask
;
;Exit Conditions:
;	AX	- -1 IFF Error
;	DX	- User Subroutine Address
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Get_Alt_Subr:
	CALL	Find_User_Alt_Routine
	JC	No_Alt_Int		;Branch if invalid mask
	JNZ	No_Alt_Int		;Branch if no User Subroutine
	LODSW
	MOV	[BP].Return_CX,AX	;Call Mask
	LODSW
	MOV	[BP].Return_DX,AX	;Subroutine Address
	LODSW
	MOV	[BP].Return_BX,AX	;Subroutine Segment
	RET

;There is no Alternate Subroutine set by the user.
No_Alt_Int:
	XOR	AX,AX
	MOV	[BP].Return_BX,AX
	MOV	[BP].Return_CX,AX
	MOV	[BP].Return_DX,AX
	DEC	AX
	MOV	[BP].Return_AX,AX	;AX <- -1
	RET


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Set Mouse Sensitivity - This routine just stores the values so we can
;return them later, but the mouse driver never uses them.
;
;Entry Conditions:
;	AX	- 26
;	BX	- horizontal mickey sensitivity (1 to 100)
;	CX	- Vertical mickey sensitivity (1 to 100)
;	DX	- threshold for double speed (1 to 100)
;
;Exit Conditions:	NONE
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Set_Sens:
	MOV	Horiz_Sens,BX
	MOV	Vert_Sens,CX
	MOV	Dbl_Speed_Thr,DX
	RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Get Mouse Sensitivity
;
;Entry Conditions:
;	AX	- 27
;
;Exit Conditions:
;	BX	- horizontal mickey sensitivity (1 to 100)
;	CX	- Vertical mickey sensitivity (1 to 100)
;	DX	- threshold for double speed (1 to 100)
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Get_Sens:
	MOV	AX,Horiz_Sens		;Horizontal Sensitivity
	MOV	[BP].Return_BX,AX
	MOV	AX,Vert_Sens		;Vertical Sensitivity
	MOV	[BP].Return_CX,AX
	MOV	AX,Dbl_Speed_Thr	;Double Speed Threshold
	MOV	[BP].Return_DX,AX
	RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Set Mouse Interrupt Rate - This function is not implemented, because it
;only affects bus mice, and this is a serial mouse driver.
;
;Entry Conditions:
;	AX	- 28
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Set CRT Page
;
;Entry Conditions:
;	AX	- 29
;	BX	- CRT page number
;
;Exit Conditions:	NONE
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Set_CRT_Page:
	MOV	CRT_Page,BX		;Set the CRT Page to use
	MOV	AX,BX
	MUL	Page_Size_in_Paras	;Find the offset from base page
	ADD	AX,CRT_Base_Seg 	;Add it to the base page
	MOV	Curr_Pg_Seg,AX		;and save that as our current segment
	RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Get CRT Page
;
;Entry Conditions:
;	AX	- 30
;
;Exit Conditions:
;	BX	- CRT page number
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Get_CRT_Page:
	MOV	AX,CRT_Page		;Get the current CRT Page
	MOV	[BP].Return_BX,AX
	RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Disable Mouse Driver
;
;Entry Conditions:
;	AX	- 31
;
;Exit Conditions:
;	AX	- 0FFFH if unable to remove interrupt vectors
;	BX	- Offset of old INT 33H vector
;	CX	- Segment of old INT 33H vector
;
;		This function restores all vectors used by the driver
;		EXCEPT for the INT 33H vector.
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Disable_Mouse:
	MOV	AL,10H			;Restore the BIOS video interrupt vector
	MOV	DX,Offset Our_Int_10H
	MOV	SI,Offset Old_Int_10H_Off
	CALL	Restore_Vector
	MOV	AL,Int_Number		;Get our mouse interrupt number
	MOV	DX,Offset Mouse_ISR
	MOV	SI,Offset Old_Mouse_ISR
	CALL	Restore_Vector		;And restore the mouse ISR vector
	OR	AX,Old_Int_10H_Off	;See if we restored both vectors
	MOV	AX,-1
	JZ	Disable_Mouse_OK	;Branch if we did
	MOV	[BP].Return_AX,AX	;AX <- -1; could not restore vectors
Disable_Mouse_OK:
	MOV	Mouse_Active_Flag,AL	;Record that we have disabled the driver
	MOV	AX,Old_Int_33H_Off
	MOV	[BP].Return_BX,AX
	MOV	AX,Old_Int_33H_Seg	;And return the address of any previous
	MOV	[BP].Return_ES,AX		;INT 33H service routine
	RET

Restore_Vector:
	CALL	Get_Vector		;Get the vector
	JNZ	Restore_Vector_Exit	;Exit if not pointing to our segment
	CMP	BX,DX			;See if it points to our service routine
	JNZ	Restore_Vector_Exit	;Branch if not our service routine.
;The interrupt vector does point to our service routine, so we need to
;restore it to its original value.
	PUSH	DS
	MOV	DX,[SI] 		;Get the previous ISR offset
	MOV	DS,[SI]+2		;And the previous segment
	MOV	AH,DOS_SET_INT
	INT	21H			;Restore the vector
	POP	DS
	XOR	AX,AX
	MOV	[SI],AX 		;Record the fact that we restored it
Restore_Vector_Exit:
	RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Enable Mouse Driver
;
;Entry Conditions:
;	AX	- 32
;
;Exit Conditions:	NONE
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Enable_Mouse:
;First, hook the INT 10H vector so that we get notified of video mode changes.
	MOV	AL,10H			;BIOS video ISR
	MOV	DX,Offset Our_Int_10H
	MOV	SI,Offset Old_Int_10H_Off
	CALL	Set_Vector		;Point it to our video ISR

;Now make sure the Mouse interrupt points to our service routine.
	MOV	AL,Int_Number		;Get the Mouse Interrupt Number
	MOV	DX,Offset Mouse_ISR
	MOV	SI,Offset Old_Mouse_ISR
	CALL	Set_Vector		;Point it to our serial ISR

	MOV	Mouse_Active_Flag,0	;Record that the driver is enabled
	RET

Set_Vector:
	CMP	[SI],Word Ptr 0 	;See if we have hooked the interrupt
	JNZ	Set_Vector_Exit 	;Branch if already hooked
	CALL	Get_Vector		;Does it point to our code segment?
	JZ	Set_Vector_Exit	 ;Branch if so - don't hook it again
	CMP	BX,DX			;See if it points to our routine
	JZ	Set_Vector_Exit	 ;Branch if so - don't hook it again
	MOV	[SI],BX 	 ;Save the previous vector
	MOV	[SI]+2,ES
	MOV	AH,DOS_SET_INT		;And point the vector to our ISR
	INT	21H
Set_Vector_Exit:
	RET

Get_Vector:
	MOV	AH,DOS_GET_INT
	INT	21H			;Get the current vector
	PUSH	BP
	MOV	BP,ES
	MOV	CX,CS
	CMP	BP,CX			;See if it points to our code segment
	POP	BP
	RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Set Language for Messages - Not Implemented
;
;Entry Conditions:
;	AX	- 34
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Get Language for Messages - Not Implemented
;
;Entry Conditions:
;	AX	- 35
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Driver_Version - Returns the mouse driver version number, mouse type, and
;interrupt number.
;
;Entry Conditions:
;	AX	- 36
;
;Exit Conditions:
;   BX  - Mouse driver version
;   CH  - Mouse Type
;   CL  - IRQ
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Driver_Version:
    MOV [BP].Return_BX,0620H    ;Version 6.20
    MOV AH,2            ;Mouse type = serial
	MOV	AL,Int_Number		;Get the interrupt number
	SUB	AL,8			;Convert to PC IRQ number
    MOV [BP].Return_CX,AX
	RET


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Find User Alt Subroutine - Finds a user subroutine entry with a call mask
;matching the one in CX.	The call mask MUST specify one of CTRL, ALT,
;or SHIFT.
;
;Entry Conditions:
;	CL	- Our_KB_Flag or Call Mask
;		- 80H - Alt Key Depressed
;		- 40H - Ctrl Key Depressed
;		- 20H - Shift Key Depressed
;
;Exit Conditions:
;	CX	- Unchanged
;	ZF	- Set if we found a matching mask
;	CF	- Set if (we did not find a match AND there are no unused
;		entries in the table) OR (invalid mask)
;	ZF,CF	- if both are reset (zero), then SI holds a pointer to an
;		unused entry
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Find_User_Alt_Routine:
	MOV	BX,0E0E0H		;Create a Key bit mask
	AND	BL,CL			;Put the Keyboard bits in BL
	JZ	Find_User_Routine_Error ;Branch if Alt, Ctrl, Shift not specified.
	PUSH	CX
	MOV	AX,CX			;AX <- mask
	MOV	CX,3			;Three user routines possible
	XOR	DI,DI
	MOV	SI,(OFFSET Alt_Subr_Tbl - 7) ;Point to Alt. Subroutine Tables
Next_User_Routine:
	ADD	SI,7			;Point to the next entry
	MOV	AX,[SI].User_Call_Mask	;Get the mask
	AND	AL,BH			;Are Alt-Ctrl-Shift bits zero (unused)?
	JNZ	Find_Mask_Not_Zero	;Branch if not zero
	MOV	DI,SI			;else save the pointer to this entry
Find_Mask_Not_Zero:
	CMP	AL,BL			;Do any of the Alt-Ctrl-Shift bits match?
	LOOPNZ	Next_User_Routine	;Loop if no match
	POP	CX
	JNZ	Find_User_No_Match	;Exit if no match and compared all 3
	XOR	AL,AL			;We found a match, set the Zero flag
	RET

;If we get here, then we did not find a match, but we may have found an
;unused entry. If DI is non-zero then it points to an unused entry.
Find_User_No_Match:
	OR	DI,DI			;Did we find an unused entry?
	JZ	Find_User_Routine_Error ;Branch if not
	MOV	SI,DI			;SI <- pointer to unused entry
	RET

Find_User_Routine_Error:
	STC
	RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Set the Active GCB
;
;Entry Conditions:
;	DS:SI	- Ptr to User Graphics Cursor Block
;
;Exit Conditions:	NONE
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Set_Active_GCB:
	MOV	BX,CS
	MOV	ES,BX
	MOV	DI,OFFSET GCB_Screen_Mask
	MOV	BX,0FFFFH		;Store 0FFH after each row of GCB
	CALL	Store_User_GCB
	XOR	BX,BX			;Store Zero after each row of GCB
;DS may be pointing into the user's data segment.
	MOV	CS:GCB_Rotate_Count,BL
	MOV	DI,OFFSET GCB_Cursor_Mask
;Fall through to Store_User_GCB

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Store User GCB
;
;Entry Conditions:
;	BL	- Byte to store after each row of GCB data
;	DI	- Ptr to storage for User GCB
;	SI	- Ptr to User Graphics Cursor Block
;
;Exit Conditions:
;	BP	- Number of words in a row of GCB data (Word width of GCB)
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Store_User_GCB:
	MOV	BP,((GCB_Width+1) / 2)	;Get the width in Words
	MOV	CX,GCB_Height		;16 Words of GCB data

Store_User_GCB_Screen_Mask:
	MOV	DX,BP
Store_User_GCB_Row:			;Store one row of the GCB
	LODSW
	XCHG	AH,AL
	STOSW
	DEC	DX
	JNZ	Store_User_GCB_Row
	MOV	AL,BL			;Store the row trailer byte
	STOSB
	LOOP	Store_User_GCB_Screen_Mask
	RET

Set_ESDS_to_CS:
	MOV	AX,CS
	MOV	ES,AX
	MOV	DS,AX
	RET


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Move Mouse State to/from user
;
;Entry Conditions:
;	CX	- number of bytes to move
;	ES:DI	- pointer to the place to store/restore the data
;	DS:SI	- pointer to the source of the data
;
;Exit Conditions:
;	NONE
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Move_State:
	SHR	CX,1			;Convert bytes to words
	JNC	Move_State_Word 	;Branch if an even number of bytes
	MOVSB				;Else move the odd byte
Move_State_Word:
	REPZ MOVSW			;Move the remaining words
	RET

Mouse_Functions ENDP

;
;This is the start of the actual Mouse interrupt service routine. When the
;mouse sends a data packet, this code reads in the bytes and processes them
;to determine what has changed.
;
Mouse_ISR	PROC	NEAR
	PUSH	AX			;Serial Mouse Interrupt Handler
	PUSH	CX
	PUSH	DX
	PUSH	BX
	PUSH	BP
	PUSH	SI
	PUSH	DI
	PUSH	DS
	PUSH	ES
	CALL	Set_ESDS_to_CS		;ES <- DS <- CS
	CLD
	MOV	DX,Mouse_Port		;Serial Port Base Address
;Check to see if our port has data available. If not, then it was a spurious
;interrupt and we should ignore it.
	ADD	DX,5			;Line Status Register
	IN	AL,DX			;Get the Status
	SUB	DX,5			;Receive Data Register again
	AND	AL,BIT_DATA_RDY 	;Check for Data Ready bit
	JNZ	ISR_Get_Data		;Data is available, go get it
	JMP	Short JMP_to_EOI	;Else ignore it.

ISR_Get_Data:
	IN	AL,DX			;Get the character
	JMP	Short ISR_1		;Delay
ISR_1:
	MOV	AH,AL			;Save it in AH
	ADD	DX,5			;Line Status Register
	IN	AL,DX
	JMP	Short ISR_2
ISR_2:
	SUB	DX,5			;RD/TD Register
	TEST	AL,2			;Test for Overrun
	MOV	AL,AH			;Get the character again
	JZ	No_Overrun
;Process the first byte the next time through the ISR.
	MOV	PACKET_BYTE,Offset ISR_1st_byte
JMP_to_EOI:
	JMP	ISR_EOI 		;Send an EOI and exit

No_Overrun:
	TEST	AL,40H			;Test for Valid Byte 1
	JNZ	ISR_1st_byte		;Branch if the first byte of a packet
;Else it is the second or third byte. We need to verify that we are really
;expecting the second or third byte. If we are not, then we should discard
;this one and wait for another start byte.
	MOV	BX,PACKET_BYTE		;Get the pointer to the byte we expect
	CMP	BX,Offset ISR_1st_byte
	JZ	JMP_to_EOI		;Exit if looking for the first byte
	JMP	BX			;Else branch to the proper routine

;Process the first byte of the mouse data packet.
;
ISR_1st_byte:
;Process the second byte the next time through the ISR.
	MOV	PACKET_BYTE,Offset ISR_2nd_byte
	MOV	BX,Button_Status
	MOV	Tmp_Butt_Stat,BX	;Save the previous Button Status
	XOR	DX,DX
	MOV	Button_Flag,DX
	MOV	Tmp_Button_Flag,DX	;Zero the button Flags
	MOV	DL,AL			;DL <- Input Data (Byte 1)
	MOV	CL,5
	SHR	DL,CL			;DH is already zero
	MOV	CX,1
	AND	DX,CX			;Leave only the Left Button Bit
	NOT	CX			;CX <- 0FFFEH
	AND	CX,Tmp_Butt_Stat	;Set CX to old Right Button State
	OR	DX,CX			;Set DX to old Right plus new Left
	XCHG	DX,Tmp_Butt_Stat	;Save the new button status, get old
	MOV	SI,Horiz.Virtual_Pos	;Get the current cursor position
	MOV	DI,Vert.Virtual_Pos
	CMP	Tmp_Butt_Stat,DX	;Has the Left Button changed?
	JZ	Do_Right_Button 	;Branch if not - do Right Button
	JA	Left_Button_Pressed	;Branch if Left Button was pressed
	INC	L_Butt_R		;Else Left Button was Released
	MOV	L_Butt_Rh,SI
	MOV	L_Butt_RV,DI
	OR	BYTE PTR Tmp_Button_Flag,4
	JMP	SHORT Do_Right_Button

Left_Button_Pressed:
	INC	L_Butt_P		;Left Button was Pressed
	MOV	L_Butt_PH,SI
	MOV	L_Butt_PV,DI
	OR	BYTE PTR Tmp_Button_Flag,2

Do_Right_Button:			;See if the Right Button has changed
	MOV	DL,AL			;Get the 1st data byte again
	MOV	CL,3
	SHR	DL,CL			;DH is already zero
	MOV	CX,2H
	AND	DX,CX			;Leave only the Right Button bit
	NOT	CX			;CX <- 0FFFDH
	AND	CX,Tmp_Butt_Stat	;Set CX to current Left Button state
	OR	DX,CX			;DX now has the new button state
	XCHG	DX,Tmp_Butt_Stat	;Save new, get old right button state
	CMP	Tmp_Butt_Stat,DX	;Has the right button changed?
	JZ	Do_XY_Change		;Branch if not - process X/Y change
	JA	Right_Button_Pressed	;Branch if Right Button was pressed
	INC	R_Butt_R		;Right Button was Released
	MOV	R_ButtRH,SI
	MOV	R_ButtRV,DI
	OR	BYTE PTR Tmp_Button_Flag,10H
	JMP	SHORT Do_XY_Change

Right_Button_Pressed:
	INC	R_Butt_P		;Right Button was Pressed
	MOV	R_Butt_PH,SI
	MOV	R_Butt_PV,DI
	OR	BYTE PTR Tmp_Button_Flag,8

Do_XY_Change:
	MOV	BX,AX			;Get the First Data Byte back
	MOV	CL,4
	SHL	AX,CL			;Move bits Y7 and Y6 into position
	AND	AL,0C0H 		;(bits 2 & 3 to high 2 bits) and mask
	MOV	Y_AXIS_CHANGE,AL	;Save high 2 bits of Y-Axis change
	MOV	CL,6
	SHL	BX,CL			;Move bits X7 and X6 into position
	AND	BL,0C0H 		;(bits 0 & 1 to high 2 bits) and mask
	MOV	X_AXIS_CHANGE,BL	;Save high 2 bits of X-Axis change

ISR_EOI:
IF	NOT DEBUG
	MOV	AL,20H
	OUT	20H,AL
ENDIF
	JMP	ISR_IRET

;Process the second (X) byte of the mouse data packet.
;
ISR_2nd_byte:
;Process the third byte the next time through the ISR.
	MOV	PACKET_BYTE,Offset ISR_3rd_byte
	AND	AL,3FH			;High bit is unused, so mask it.
	OR	X_AXIS_CHANGE,AL	;Merge in the low 6 bits of X-Axis
	JMP	SHORT ISR_EOI

;Process the third (Y) byte of the mouse data packet.
;
ISR_3rd_byte:
;Process the first byte the next time through the ISR.
	MOV	PACKET_BYTE,Offset ISR_1st_byte
	OR	AL,Y_AXIS_CHANGE	;Merge in the low 6 bits of Y-Axis
	CBW
	MOV	CX,AX			;CX <- Y-Axis change
	MOV	AL,X_AXIS_CHANGE
	CBW
	MOV	BX,AX			;BX <- X-Axis change
;Now we are done with a packet, and have the new button status and button
;flag values, so we copy them from the temporary variable to the regular
;variable.
	MOV	AX,Tmp_Butt_Stat
	MOV	Button_Status,AX	;Update the button status
	MOV	AX,Tmp_Button_Flag	;and the button flags
	MOV	Button_Flag,AX
;
;When we get here:
;
; CX	<-	Y-Axis change
; BX	<-	X-Axis change
;

Process_Packet:
	MOV	AX,BX			;AX <- X-Axis change
	OR	AX,CX			;CX = Y-Axis change
	JZ	Do_User_Routines	;Branch if the mouse has not moved

;Else the mouse has moved, and we need to process the movement.
	OR	BYTE PTR Button_Flag,1	;Set the "Mouse Moved" bit
	MOV	AX,BX			;AX <- X-Axis change
	MOV	SI,Offset Horiz 	;Point to the Horizontal Cursor table
	CALL	Adjust_Mickeys		;Adjust mickey count based on speed
	CALL	Calc_New_Pos		;and calculate a new position
	MOV	AX,CX			;AX <- Vertical movement
	MOV	SI,Offset Vert		;Point to the Vertical Cursor table
	CALL	Adjust_Mickeys		;Adjust the raw mickey count
	CALL	Calc_New_Pos

Do_User_Routines:
;If we get here, we need to check for any user-installed subroutines that
;need to be called.

IF	NOT DEBUG
	MOV	AL,20H			;Send an EOI to the Interrupt Controller
	OUT	20H,AL
ENDIF
;Here we test to make sure we haven't gotten a second interrupt before we
;finished processing the first. So if this flag is non-zero, we just do an IRET.
	TEST	In_Mouse_Flag,0FFH	;Are we already in the Mouse code?
	JNZ	ISR_IRET		;Exit if already in the mouse code
	INC	In_Mouse_Flag		;Set the flag; no more interrupts
	MOV	AX,DOS_SEG_2
	MOV	ES,AX
ASSUME ES:DOS_SEG_2
	MOV	CL,ES:KB_FLAG		;Check keyboard status
	PUSH	CS
	POP	ES
ASSUME	ES:Code_Seg
	AND	CL,0FH			;Leave only the CTRL, ALT, and SHIFT keys
	JZ	No_Shift_State		;Branch if nothing pressed
	SHR	CL,1			;Now merge the two Shift keys into one bit.
	JNC	No_Right_Shift		;Branch if Right Shift is not down
	OR	CL,1			;Else set the Left Shift bit
No_Right_Shift:
	ROR	CL,1			;Move the bits into position for an
	ROR	CL,1			;Alternate Subroutine Call Mask
	ROR	CL,1
	CALL	Find_User_Alt_Routine	;See if there is a routine for them
	JNZ	No_Shift_State		;Branch if no Alt routine for this state
	MOV	AX,Button_Flag
	AND	AX,[SI].User_Call_Mask	;Compare button state to the call mask
	JZ	No_Shift_State		;If no matching conditions, then don't call it
;Here we test to see if we have called the user routine and not returned. We
;cannot assume that the user subroutine is reentrant. So if this flag is
;non-zero, we don't call it again.
	TEST	[SI].In_User_Flag,0FFH
	JNZ	User_Routines_Done	;Branch if not returned from user
	INC	[SI].In_User_Flag	;Else set the flag
	PUSH	SI
	MOV	BP,SI
	CALL	Call_User_Subr		;And call the user Alternate subroutine
	POP	SI
	DEC	[SI].In_User_Flag	;And clear the flag
	JMP	User_Routines_Done

;
;If we get here, then no shift keys were pressed, so we didn't call a user
;Alternate subroutine (Function 24). Instead, we will check to see if there
;is a primary (Function 12) subroutine to be called. We call it if ANY of the
;user-specified conditions are true.
;
No_Shift_State:
	MOV	AX,Button_Flag
	AND	AX,User_Event_Mask
	JZ	User_Routines_Done	;Branch if no matching conditions
	MOV	BP,OFFSET User_Sub_Off	;Else call the user routine
	CALL	Call_User_Subr
User_Routines_Done:
	CLI
	TEST	Button_Flag,1		;Test for mouse motion
	JZ	Cursor_Update_Done	;Branch if no motion
	MOV	AL,Cursor_Count 	;Are we supposed to display the cursor?
	OR	AL,Cursor_Update_Flag	;Are we already updating the cursor Pos?
;Branch if the cursor is hidden or we are already moving it.
	JNZ	Cursor_Update_Done
	INC	Cursor_Update_Flag	;Set the flag; don't reenter
	STI
	CALL	Display_Cursor		;And put the cursor on the screen
	CLI
	DEC	Cursor_Update_Flag	;Clear the flag, no longer updating
Cursor_Update_Done:
	DEC	In_Mouse_Flag		;Clear the flag, mouse code is done

ISR_IRET:
IF	NOT DEBUG
	POP	ES
	POP	DS
	POP	DI
	POP	SI
	POP	BP
	POP	BX
	POP	DX
	POP	CX
	POP	AX
ELSE	;Else we are debugging
	INT	3
	JMP	DEBUG_LOOP
ENDIF	;DEBUG
Mouse_ISR	ENDP

	IRET

;
;This routine does everything necessary to make the cursor appear on the
;screen.
;
Display_Cursor	PROC	NEAR
	CLI
	MOV	AX,Vert.Virtual_Pos
	MOV	BX,Horiz.Virtual_Pos
	STI
	CLD
	CMP	BYTE PTR Vert.Pixels_per_Char,1
	JNZ	Text_Cursor		;Branch if we are in text mode
	JMP	Graphics_Cursor

;
;We are using a text Cursor
;
Text_Cursor:
	CMP	Cursor_Select,0 	;See which type of cursor we are using
	JZ	Update_Soft_Text_Cursor ;Branch if software text cursor
	CALL	Calc_Text_Vid_Addr	;Get the cursor address in ES:DI
	SHR	DI,1			;Divide the offset by 2
	MOV	CX,DI
	MOV	DX,CRT_Ctrl		;CRT Controller Base Address
	MOV	AL,CRT_Ctrl_Cursor_Addr_H
	OUT	DX,AL
	INC	DX
	MOV	AL,CH
	OUT	DX,AL
	DEC	DX
	MOV	AL,CRT_Ctrl_Cursor_Addr_L
	OUT	DX,AL
	INC	DX
	MOV	AL,CL
	OUT	DX,AL
	PUSH	CS
	POP	ES
	JMP	Update_Pos_Exit
;
;Update the position of the Software Text Cursor
;
Update_Soft_Text_Cursor:
	CALL	Restore_Data_Under_Cursor
	MOV	AX,Vert.Virtual_Pos
	MOV	BX,Horiz.Virtual_Pos
	MOV	CX,AX
	ADD	CX,Char_Cell_Height-1
	MOV	DX,BX
	ADD	DX,Char_Cell_Width-1
	CALL	Test_For_Cond_Off
	JNC	Up_Soft_Text_Crs_2	;Branch if not hidden
	RET

Up_Soft_Text_Crs_2:
	CALL	Calc_Text_Vid_Addr	;Get the cursor address in ES:DI
	MOV	AX,ES			;AX <- Video Ram base address
;If we get here, then we have a CGA controller in text mode. We have to wait
;until the beginning of Horizontal Retrace before we start updating, if we
;want to avoid creating snow on lousy controllers.
	MOV	DX,CRT_Ctrl
	ADD	DX,6H			;Point to the Status Register
Soft_Text_3:
	IN	AL,DX			;Get the status
	TEST	AL,1
	JNZ	Soft_Text_3		;Loop back if in retrace
	CLI
Soft_Text_4:
	IN	AL,DX			;Get status again
	TEST	AL,1
	JZ	Soft_Text_4		;Loop back until in retrace

;Now we are at the beginning of horizontal retrace, and can get one word off
;the screen without causing snow.
	MOV	AX,ES:[DI]		;Get the character under the cursor
	STI
	MOV	Data_Under_Cursor,AX	;Save the character
	MOV	Char_Under_Crs_Saved,0FFH ;Record the fact that we saved it
	AND	AX,Cursor_Line1
	XOR	AX,Cursor_Line2
	CALL	Put_Char_On_Screen
	JMP	SHORT Update_Pos_Exit

;
;Update the Graphics Cursor Position
;
Graphics_Cursor:
	CLI
	SUB	BX,Horiz_Hot_Spot	;Subtract the Hot Spot position
	MOV	GCB_Horiz_Pos,BX	;to get the position of the block
	SUB	AX,Vert_Hot_Spot
	MOV	GCB_Vert_Pos,AX
	STI
	MOV	CX,AX
	ADD	CX,GCB_Height
	MOV	DX,BX
	ADD	DX,(GCB_Width * 8)
	CALL	Test_For_Cond_Off	;See if we should hide the cursor
	JNC	Up_Graph_Cursor_2	;Branch if not hidden
	JMP	SHORT Restore_Data_Under_Cursor

Up_Graph_Cursor_2:
	CALL	Restore_Prev_Screen_Data
	CALL	Save_Current_Screen_Data
	CALL	Rotate_GCB
	CALL	Put_GCB_on_Temp_Screen
	CALL	Copy_Temp_to_Screen
;
;When we get here we have finished updating the screen and the cursor position.
;
Update_Pos_Exit:
	CLI
	MOV	AX,Horiz.Virtual_Pos	;Save the current positions as the
	MOV	Old_Horiz_Pos,AX	;previous positions for next time.
	MOV	AX,Vert.Virtual_Pos
	MOV	Old_Vert_Pos,AX
	STI
	RET


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Restore the screen data that was under the cursor before we put the cursor
;there. Of course, this makes the original text appear, and the cursor
;goes away.
;
;Entry Conditions:
;
;
;Exit Conditions:	NONE
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Restore_Data_Under_Cursor:
	CLD
	TEST	Char_Under_Crs_Saved,0FFH	;Is there saved data to restore?
	JZ	Restore_Data_Exit		;Exit if not
	MOV	Char_Under_Crs_Saved,0		;Else zero the flag and restore it
	CMP	BYTE PTR Vert.Pixels_per_Char,1 ;Are we in a graphics mode?
	JZ	Restore_Data_Under_GCB		;Branch if graphics

Restore_Data_2:
	CMP	Cursor_Select,0
	JNZ	Restore_Data_Exit
	MOV	AX,Old_Vert_Pos 	;Position of the GCB
	MOV	BX,Old_Horiz_Pos
	CALL	Calc_Text_Vid_Addr	;Get the cursor address in ES:DI
	MOV	AX,Data_Under_Cursor	;Restore the previous character and attr.


Put_Char_On_Screen:
	MOV	DX,ES
	XCHG	AX,CX
;If we get here, then we have a CGA controller in text mode. We have to wait
;until the beginning of Horizontal Retrace before we start updating, if we
;want to avoid creating snow on lousy controllers.
	MOV	DX,CRT_Ctrl
	ADD	DX,6H			;Point to the status register
Restore_Data_3:
	IN	AL,DX			;Get the status
	TEST	AL,1
	JNZ	Restore_Data_3		;Loop back if in retrace
	CLI
Restore_Data_4:
	IN	AL,DX			;Get the status again
	TEST	AL,1
	JZ	Restore_Data_4		;Loop back until start of retrace
	XCHG	AX,CX

;Now we are at the beginning of horizontal retrace, and can put one word on
;the screen without causing snow.
	STOSW			;Put the character and attribute on the screen
	STI
	PUSH	CS
	POP	ES
Restore_Data_Exit:
	RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Restore_Data_Under_GCB - Restores previously saved data to the space
;currently occupied by the GCB. This makes the GCB go away, and the
;previous data reappear. You have to do this whenever the GCB moves.
;
;Entry Conditions:
;
;
;Exit Conditions:	NONE
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Restore_Data_Under_GCB:
	MOV	DI,Offset Data_Under_Cursor	;Get the pointer to the data
	MOV	AX,Prev_GCB_Horiz_Pos		;Get the place to put it
	MOV	SI,Prev_GCB_Vert_Pos
	MOV	BX,SI
	CALL	Calc_GCB_Vid_Off	;Get the GCB offset in SI
	XCHG	SI,DI			;SI <- Pointer to stored screen data
	MOV	CX,AX			;CX <- Prev_GCB_Horiz_Pos
	MOV	AX,(Next_Scan_Line - (GCB_Width +1))
	MOV	Update_Block_Width,(GCB_Width + 1) ;Width of block to copy
	MOV	DX,GCB_Height
	MOV	Update_Block_Height,DX
	MOV	DH,(GCB_Width + 1)	;Width of block to copy
	JMP	Copy_Temp_to_Screen_2


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Restore_Prev_Screen_Data
;Before restoring the screen data, we need to check to see if the GCB has moved
;less than GCB_Height (vertically) or GCB_Width (horizontally). If it has, then
;we only want to restore the portion that has been uncovered by the move. If
;we restored everything, then we would immediately re-write part of it with the
;GCB, and cause annoying flashing.
;
;Entry Conditions:
;
;
;Exit Conditions:	NONE
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
Restore_Prev_Screen_Data:
;If we don't have data saved then we don't have to test to see how far the
;cursor moved.
	TEST	Char_Under_Crs_Saved,0FFH
	JZ	Rest_P_Moved_Outside_GCB ;Branch if no data saved
	MOV	AX,GCB_Horiz_Pos
	MOV	BX,Prev_GCB_Horiz_Pos
	CMP	AX,BX			;See which way the mouse is moving
	JG	Restore_Prev_Moving_Right ;Branch if moving to the right
	XCHG	AX,BX			;AX <- lesser of AX and BX
Restore_Prev_Moving_Right:
;At this point we know that BX contains the leftmost (smaller number) of
;GCB_Horiz_Pos and Prev_GCB_Horiz_Pos. We will mask the leftmost to an even
;byte boundary, then subtract it from the rightmost. If the difference is
;more than GCB_Width bytes, then we can restore the saved screen data (from
;under the previous GCB) directly to the screen, rather than messing with
;Temp_Screen.
	AND	BL,0F8H
	SUB	AX,BX			;Calculate Horizontal distance moved
	CMP	AX,((GCB_Width +1) * 8) ;Less than the GCB Width?
	JGE	Rest_P_Moved_Outside_GCB ;Branch if the move was wider than the GCB
	MOV	GCB_Horiz_Byte_Pos,BX
	MOV	AX,GCB_Vert_Pos
	MOV	BX,Prev_GCB_Vert_Pos
	CMP	AX,BX			;See which way the mouse is moving
	JG	Restore_Prev_Moving_Down ;Branch if moving down
	XCHG	AX,BX			;AX <- lesser of AX and BX
Restore_Prev_Moving_Down:
	MOV	GCB_Lower_Pos,BX
	SUB	AX,BX			;Calculate vertical distance moved
	CMP	AX,GCB_Height		;Less than the GCB Height?
	JL	Rest_P_Moved_Inside_GCB ;Branch if move was less than GCB height
;If we get here, then the mouse was moved so that no part of the new GCB covers
;any part of the previous GCB position. This makes it easy to restore the
;previous screen contents, because we can restore everything, without worrying
;about restoring only those parts that were uncovered.
Rest_P_Moved_Outside_GCB:
	MOV	AX,GCB_Horiz_Pos	;Get the current Horizontal Position
	AND	AL,0F8H 		;Round down to the nearest byte
	MOV	GCB_Horiz_Byte_Pos,AX
	MOV	AX,GCB_Vert_Pos
	MOV	GCB_Lower_Pos,AX
	XOR	AX,AX
	CALL	Set_GCB_Video_Address
	JZ	No_Data_to_Restore
	CALL	Restore_Data_Under_GCB
No_Data_to_Restore:
	CALL	Move_Screen_Data_to_Temp_Screen
	RET

Rest_P_Moved_Inside_GCB:
	CALL	Set_GCB_Video_Address
;Restore the data under the previous GCB to the temporary screen.
	CALL	Move_Screen_Data_to_Temp_Screen
	MOV	DI,Offset Data_Under_Cursor
	MOV	AX,Prev_GCB_Horiz_Pos
	MOV	SI,Prev_GCB_Vert_Pos
	CALL	Index_Into_Temp_Screen	;Return a pointer in SI
	XCHG	SI,DI			;SI points to data under the previous GCB
	PUSH	DS			;DI points to Temp_Screen
	PUSH	ES
	CALL	SET_ESDS_to_CS
	MOV	AX,2
Restore_Prev_Row:
	MOVSW
	MOVSB
	ADD	DI,AX			;DI <- DI + 2
	LOOP	Restore_Prev_Row
	POP	ES
	POP	DS
	RET

Set_GCB_Video_Address:
	ADD	AX,GCB_Height
	MOV	GCB_Height_plus_Overlap,AX
	MOV	AX,GCB_Horiz_Byte_Pos
	MOV	SI,GCB_Lower_Pos
	CALL	Calc_GCB_Vid_Off	;Get GCB address in SI
	MOV	GCB_Video_Address,SI
	MOV	BX,OFFSET Char_Under_Crs_Saved
	TEST	[BX],Byte Ptr 0FFH
	MOV	[BX],Byte Ptr 0 	;Clear the flag
	RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Move Screen data to Temp_Screen.
;This routine moves the data from where the GCB will be to our internal
;screen buffer. I used MOVSBs instead of MOVSWs here because the position
;algorithm I am using allows negative positions in some cases. This creates
;a GCB address of B800:FFFF, and doing a WORD move at that address appears
;to cause problems on 386 machines.
;
;Entry Conditions:
;	GCB_Height_plus_Overlap - Set to the number of scan lines to move
;	GCB_Video_Address - Set to the
;
;Exit Conditions:
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Move_Screen_Data_to_Temp_Screen:
	MOV	DI,Offset Temp_Screen
	MOV	AX,(Next_Scan_Line - (GCB_Width * 2) - 1)
;	 MOV	 BX,Columns		 ;Number of bytes per row
;Set BX to the Video Page size, less the width of two GCBs plus one byte. This
;gives us a check to see if we are going to go past the end of the video page
;on the next copy.
	MOV	BX,(Prev_Scan_Line - (GCB_Width * 2) -1)
	MOV	CX,GCB_Height_plus_Overlap
;DX gets a value that, when subtracted from the source address, will bring our
;pointer back onto the current video page.
	MOV	DX,Prev_Scan_Line
	PUSH	ES
	MOV	SI,CS
	MOV	ES,SI
	LDS	SI,DWORD PTR GCB_Video_Address
Move_to_Temp_2:
	MOVSB
	MOVSB
	MOVSB
	MOVSB
	MOVSB
	ADD	SI,AX			;Point to the next scan line
	CMP	SI,BX			;See if past the end of the video page
	JC	Move_to_Temp_On_Page	;Branch if still on the page
	SUB	SI,DX			;else skip to the next scan line
Move_to_Temp_On_Page:
	LOOP	Move_to_Temp_2
	POP	ES
	PUSH	CS
	POP	DS
	RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Save_Current_Screen_Data - moves the data that will be under the new
;GCB position from Temp_Screen to Data_Under_Cursor.
;
;Entry Conditions:	NONE
;
;
;Exit Conditions:
;	AX, CX, DI, SI - Unkown
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Save_Current_Screen_Data:
	CLI
	MOV	AX,GCB_Horiz_Pos	;Get the current GCB position
	MOV	SI,GCB_Vert_Pos
;Record the fact that we have saved screen data.
	MOV	Char_Under_Crs_Saved,0FFH
	MOV	Prev_GCB_Horiz_Pos,AX	;Save the address so we know where the
	MOV	Prev_GCB_Vert_Pos,SI	;data came from.
	STI
	MOV	DI,Offset Data_Under_Cursor
	CALL	Index_Into_Temp_Screen	;Point SI to the GCB in Temp_Screen,
	PUSH	DS			;and CX is set to the GCB Height
	PUSH	ES
	CALL	SET_ESDS_to_CS
;Move one GCB row's worth of screen data from Temp_Screen to Data_Under_Cursor
	MOV	AX,2
Save_C_Row:
	MOVSW
	MOVSB
;Skip the next two bytes of Temp_Screen - they are not under the GCB
	ADD	SI,AX			;SI <- SI + 2
	LOOP	Save_C_Row		;Loop back for another GCB Row
	POP	ES
	POP	DS
	RET


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Rotate_GCB - Rotates (bit shifts) the internal GCB left or right so
;that it is aligned with the bit position we have calculated for it on
;the screen. For example, if we are in 640x200 and the GCB starts at
;1,1, then we must shift the internal GCB one bit to the right before
;copying it to the screen. When we stored the GCB internally we added
;one byte of 0FFH or 00H to each row, so that we can put the GCB on the
;screen with simple byte ANDs and XORs.
;
;Entry Conditions:
;	GCB_Rotate_Count - Current rotation
;
;
;Exit Conditions:	GCB_Screen_Mask and GCB_Cursor_Mask will be in position
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Rotate_GCB:
	MOV	BL,7
	MOV	AL,BYTE PTR GCB_Horiz_Pos	;Get the current position
	AND	AL,BL			;Mask to get the low three bits
	AND	BL,GCB_Rotate_Count	;BL <- Current rotation Modulo 8
	MOV	GCB_Rotate_Count,AL	;Update the required rotate position
	MOV	BP,GCB_Size		;Number of bytes to be rotated
	SUB	AL,BL			;And see how many bits to rotate
	JZ	Rotate_GCB_Exit 	;If AL = BL then we are done
	JG	Rotate_GCB_Right
Rotate_GCB_Left:
	NEG	AL			;Make the count positive
	MOV	SI,Offset GCB_Screen_Mask
	CALL	Rotate_Mask_Left
	MOV	SI,Offset GCB_Cursor_Mask

;Rotate one mask to the left.
Rotate_Mask_Left:
	MOV	BL,AL			;BL <- Rotate Count
	ADD	SI,BP			;Point SI to the end of the mask + 1
	DEC	SI			;now just the end of the mask
Rotate_Mask_L_2:
	MOV	DI,SI			;Point DI to the end of the mask
	MOV	CX,BP			;Number of bytes to rotate
Rotate_L_Row:
	RCL	BYTE PTR [DI],1 	;Rotate a byte
	DEC	DI			;Point to the previous byte
	LOOP	Rotate_L_Row		;and loop to rotate it
	JC	Rotate_L_Set_Bit
	AND	BYTE PTR [SI],0FEH	;Clear the LSB in the last byte
	JMP	SHORT Rotate_L_End

Rotate_L_Set_Bit:
	OR	BYTE PTR [SI],1 	;Set the LSB in the last byte
Rotate_L_End:
	DEC	BL			;Done enough shifts?
	JNZ	Rotate_Mask_L_2 	;Loop if not
Rotate_GCB_Exit:
	RET

Rotate_GCB_Right:
	MOV	SI,OFFSET GCB_Screen_Mask
	CALL	Rotate_Mask_Right
	MOV	SI,OFFSET GCB_Cursor_Mask

;Rotate one mask to the Right.
Rotate_Mask_Right:
	MOV	BL,AL			;BL <- number of bits to rotate
Rotate_Mask_R_2:
	MOV	DI,SI			;DI <- pointer to the mask
	MOV	CX,BP			;CX <- number of bytes to rotate
Rotate_R_1_Bit:
	RCR	BYTE PTR [DI],1 	;Rotate a byte
	INC	DI			;Point to the next byte
	LOOP	Rotate_R_1_Bit		;and loop to rotate it
	JC	Rotate_R_Set_Bit
	AND	BYTE PTR [SI],7FH	;Clear the LSB in the last byte
	JMP	SHORT Rotate_R_End

Rotate_R_Set_Bit:
	OR	BYTE PTR [SI],80H	;Clear the LSB in the last byte
Rotate_R_End:
	DEC	BL			;Done enough shifts?
	JNZ	Rotate_Mask_R_2 	;Loop if not
	RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Put_GCB_on_Temp_Screen
;
;Entry Conditions:
;
;
;Exit Conditions:	NONE
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Put_GCB_on_Temp_Screen:
	MOV	AX,GCB_Horiz_Pos
	MOV	SI,GCB_Vert_Pos
	CALL	Index_Into_Temp_Screen	;Point SI to the GCB on the Temp Screen
					;CX returns set to GCB_Height
	MOV	DI,OFFSET GCB_Screen_Mask
	MOV	BX,OFFSET GCB_Cursor_Mask
	XCHG	SI,DI			;DI now points to Temp_Screen
	MOV	DX,(GCB_Width + 1)	;Get the GCB width in whole bytes

Update_Graphics_Cursor:
	MOV	BP,CX			;Save the line count
	MOV	CX,DX			;And get the byte count for this line
;Update one line of the GCB.
Update_GCB_Cursor_Line:
	LODSB				;Get a byte of the Screen_Mask
	AND	AL,[DI] 		;AND it with the screen data
	XOR	AL,[BX] 		;XOR it with the Cursor_Mask
	MOV	[DI],AL
	INC	BX
	INC	DI
	LOOP	Update_GCB_Cursor_Line	;Update another byte on this line
	ADD	DI,GCB_Width		;Else point to the next screen line
	MOV	CX,BP			;Recover the line count
	LOOP	Update_Graphics_Cursor	;And loop back to update another line
	RET


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Copy_Temp_to_Screen copies the updated GCB from Temp_Screen to the actual
;video memory, in the correct location.
;
;Entry Conditions:
;	Temp_Screen	- completely updated
;	GCB_Height_Plus_Overlap - Number of scan lines to copy
;
;Exit Conditions:	NONE
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
Copy_Temp_to_Screen:
	MOV	SI,Offset Temp_Screen	;Point to the updated temporary screen
	MOV	DI,GCB_Video_Address	;And the destination for the GCB
;By subtracting the GCB width (in bytes to be copied) from the value that gives
;us the next scan line, we get a value which we can use to get the next scan
;line, at the correct position for the first byte of that GCB line. By
;subtracting the width here, we don't have to do it inside the loop.
	MOV	AX,(Next_Scan_Line - ((GCB_Width * 2) +1))
	MOV	BX,GCB_Lower_Pos
	MOV	CX,GCB_Horiz_Byte_Pos
	MOV	DX,GCB_Height_plus_Overlap
	MOV	Update_Block_Height,DX
	MOV	DH,(GCB_Width * 2) + 1
	MOV	Update_Block_Width,(GCB_Width * 2) + 1	;Width of block to copy

Copy_Temp_to_Screen_2:
	SAR	CX,1			;Convert horizontal position to bytes
	SAR	CX,1
	SAR	CX,1
	XOR	BP,BP
	OR	CX,CX
;Branch if the GCB does not extend past the left edge of the screen.
	JNS	GCB_OK_on_Left
	NEG	CX			;Else convert to a positive number
	ADD	DI,CX			;and add to the indices, so we don't
	ADD	SI,CX			;copy the overhanging part of the GCB.
	JMP	SHORT Clip_Left_And_Right

GCB_OK_on_Left:
	ADD	CX,Update_Block_Width	;Add the block width
	SUB	CX,Columns		;Subtract the number of columns
;Branch if the GCB does not extend past the right edge of the screen.
	JLE	GCB_OK_on_Right
Clip_Left_And_Right:
	SUB	DH,CL			;Else subtract the overhang
;	 JLE	 P_GCB_On_S_Exit	 ;Exit if nothing left to display
	ADD	AX,CX			;Adjust our Next_Scan_Line value
	MOV	BP,CX			;And save the overhang for future use
GCB_OK_on_Right:
	MOV	CX,BX			;CX <- GCB_Lower_Pos
	MOV	BX,Prev_Scan_Line
	OR	CX,CX
;Branch if the GCB does not extend past the top edge of the screen.
	JNS	GCB_OK_on_Top
;Else the GCB does extend past the top of the screen. We need to convert CX
;to a positive number (of GCB rows that must be clipped off). Then multiply
;by the GCB update width (total columns), and add to SI to get a pointer
;to the first visible byte in the GCB.
	NEG	CX
	PUSH	CX
	XCHG	AX,CX			;AX <- GCB overhang at top
	MUL	Byte Ptr Update_Block_Width
	ADD	SI,AX
	MOV	AX,CX			;AX <- Next_Scan_Line (adjusted)
	POP	CX			;Restore the number of invisible rows
;Now we must adjust DI to point to the correct destination for the visible
;portion of the GCB.
	PUSH	CX
	PUSH	DX
	MOV	DX,Next_Scan_Line	;Offset of the next scan line
P_GCB_On_S_2:
	ADD	DI,DX			;Point DI to the next scan line
	CMP	DI,BX			;Have we gone off the video page?
	JC	P_GCB_On_S_Still_on_Page ;Branch if still on the page
	SUB	DI,BX			;Else put us back on the page
P_GCB_On_S_Still_on_Page:
	LOOP	P_GCB_On_S_2		;Loop back for another row
	POP	DX
	POP	CX
	JMP	SHORT Clip_Top_And_Bottom

GCB_OK_on_Top:
	ADD	CX,Update_Block_Height	;Add the block height to move
	SUB	CX,Screen_Size_V	;and see if it goes past the bottom
;Branch if the GCB does not extend past the bottom edge of the screen.
	JLE	GCB_OK_on_Bottom
Clip_Top_And_Bottom:
	SUB	DL,CL			;Else subtract the overhang
	JLE	P_GCB_On_S_Exit 	;Exit if nothing left to display
GCB_OK_on_Bottom:
	MOV	ES,Curr_Pg_Seg		;Segment address of Video Page
	XOR	CX,CX
P_GCB_On_S_Copy_Row:
	MOV	CL,DH			;CX <- number of bytes per row
	REPZ MOVSB			;Copy one row
	ADD	SI,BP			;Point to the next GCB row
	ADD	DI,AX			;And the place on the screen to put it
	CMP	DI,BX			;Have we gone off the video page?
	JC	P_GCB_On_S_3		;Branch if still on the page
	SUB	DI,BX			;Else put us back on the page
P_GCB_On_S_3:
	DEC	DL			;Number of GCB rows to copy
	JNZ	P_GCB_On_S_Copy_Row	;Loop back if more rows to copy
	PUSH	CS
	POP	ES
P_GCB_On_S_Exit:
	RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Index_Into_Temp_Screen
;
;Entry Conditions:
;	AX	- GCB Horizontal Position (either Previous or Current)
;	SI	- GCB Vertical Position (either Previous or Current)
;
;Exit Conditions:
;	CX	- 16 (GCB Height)
;	SI	- Pointer into Temp_Screen, offset by the distance the GCB has
;			moved horizontally and vertically.
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Index_Into_Temp_Screen:
;GCB_Horiz_Byte_Pos is the leftmost of the Previous GCB position and the
;Current GCB position, rounded down to the nearest byte boundary.
	PUSH	AX
	SUB	AX,GCB_Horiz_Byte_Pos	;AX <- Horiz. distance the mouse has moved
	SAR	AX,1
	SAR	AX,1
	SAR	AX,1			;Convert distance to whole bytes
	SUB	SI,GCB_Lower_Pos	;SI <- vertical distance moved
	MOV	CX,SI
	MOV	SI,Offset Temp_Screen
	ADD	SI,AX			;Add the Horizontal offset
	MOV	AX,((GCB_Width * 2) + 1)
	MUL	CL			;Multiply by the number of lines moved
	ADD	SI,AX			;Add the Vertical offset
	MOV	CX,GCB_Height
	POP	AX
	RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Calc_New_Pos - Calculates a new cursor position based on the previous
;position and the current mouse movement.
;
;Entry Conditions:
;	AX	- Current GCB movement
;	SI	- Pointer to cursor table
;
;Exit Conditions:
;	Remainder, Curs_Pos, and Virtual_Pos will all be set correctly
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Calc_New_Pos:
;Here we add the remainder from the previous move to this move. The reason for
;this is to capture movement that is too slow to exceed the Mickey/Pixel ratio
;in one time period. For example, if the mouse reports 1 Mickey of movement,
;then the cursor does not move. When it later reports 1 more, and 1 more, etc.,
;we will eventually move the cursor. If we did not store the remainder, then
;there would be a threshold speed below which we did not work.
	ADD	AX,[SI].Remainder
	CWD
	IDIV	[SI].Mick_Pix_Ratio	;Divide by the Mickey to Pixel Ratio
	MOV	[SI].Remainder,DX	;Save the remainder
	ADD	AX,[SI].Curs_Pos	;Get the new Horizontal Cursor Position
	CALL	Check_Bounds		;make sure it is within bounds
	MOV	[SI].Curs_Pos,AX	;and update the Cursor Position
	MOV	BX,[SI].Pixels_per_Char ;Get the number of pixels per character
	CMP	BL,1			;If 1, then we are in a graphics mode
	JZ	MS_Grph 		;Branch if in 1:1 graphics mode
;Else we are in text mode, or a graphics mode other than 640 x 200, so we must
;convert the virtual cursor position to a physical screen (pixel) position
;by dividing by the character width or height. This removes any fractional
;part. Then multiply by the character width (or height) and we have a cursor
;position that maps directly to a screen pixel.
	CWD
	DIV	BX
	MUL	BX
MS_Grph:
	MOV	[SI].Virtual_Pos,AX
	RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Adjust_Mickeys - Calculates an adjustment to the raw mickey value, such that
;the cursor moves proportionately further as you move the mouse faster. It
;does this by looking up the raw mickey count in a table. Then it takes the
;multiplication factor associated with that table position, and multiplies it
;by the raw mickey count. My thanks to Michael Mefford for providing the idea.
;
;Entry Conditions:
;	AX	- raw mickey count, not greater than 255
;	SI	- Pointer to cursor information structure
;	ES, DS <- CS
;
;Exit Conditions:
;	AX	- Adjusted mickey count, not greater than +/- 32,767
;	DX	- Remainder
;	DI, SI - unknown
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Accel_Lookup	DW	3,	7, 15, 30, 50
Accel_Table_Length	EQU	(($ - Accel_Lookup) / 2)
;Multiplier values mean .5, 1, 1.5, 2, 3
Multiplier	DW	5, 10, 15, 20, 30

Adjust_Mickeys:
	PUSH	CX
	OR	AX,AX			;Check the sign of the movement
	PUSHF				;Save the sign
	PUSH	SI			;Save the pointer to the cursor table
	JNS	Adjust_M_2
	NEG	AX			;Get the absolute value of the change
Adjust_M_2:
	MOV	CX,Accel_Table_Length	;Length of the acceleration table
	MOV	DI,Offset Accel_Lookup	;Point to the lookup table
	MOV	SI,Offset Multiplier	;And the multiplier table
	CLD
Next_Accel:
	SCASW				;Compare AX to [SI]
	JBE	Got_Accel		;Branch if [DI] >= AX
	INC	SI			;Else point to the next multiplier
	INC	SI
	LOOP	Next_Accel
;When we get here, we have found the appropriate acceleration value.
Got_Accel:
	IMUL	Word Ptr [SI]		;Multiply by the acceleration value
	POP	SI			;Recover the pointer to the cursor table
	ADD	AX,[SI].Adjust_Remain	;Add any previous remainder
;Now we divide the result by 10 so that we can have multipliers of less than
;one.
	MOV	CX,10
	IDIV	CX
	MOV	[SI].Adjust_Remain,DX	;Save any remainder
	POPF				;Recover the original sign
	JNS	Adjust_M_Exit		;And restore it to AX
	NEG	AX
Adjust_M_Exit:
	ADD	[SI].Count,AX		;Update the mickey count
	POP	CX
	RET


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Calc_GCB_Vid_Off - Calculates the offset of the GCB from the start of the
;current page of video RAM. This function doesn't work quite the way I want -
;it returns 0FFFFH if you pass it a negative position, and the position can
;be negative if the GCB extends to the left of the hotspot, or above the
;hotspot. This causes the mouse driver to save (and later restore) one byte
;from B800:FFFF, and that could be REALLY BAD if you are running QEMM, and it
;has part of your EMS disk cache mapped to that address. The solution of
;course is DON'T DO THAT, but I haven't found an easy way around it. The
;straight foward way seems to involve too many special cases - ugly code.
;It doesn't bite me, so I am not going to worry about it yet - maybe in
;version 1.2.
;
;Entry Conditions:
;	AX	- GCB Horizontal Position
;	SI	- GCB Vertical Position
;
;Exit Conditions:
;	SI	- GCB Offset from base of current Video page
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Calc_GCB_Vid_Off:
	PUSH	AX
	PUSH	BX
	XOR	BX,BX			;Assume an Even scan line
	TEST	SI,1			;Now check to see
	JZ	Calc_GCB_Vid_Off_Even
	MOV	BX,Next_Scan_Line	;Else Odd, add half a screen buffer
Calc_GCB_Vid_Off_Even:
;At this point, BX equals zero if the GCB starts on an Even scan line; and
;2000H if the GCB starts on an Odd scan line.
	XCHG	AX,SI			;AX <- Vertical Position
;Now divide the Vertical position by 2. This gives the number of Even or Odd
;scan lines to skip to find the GCB offset in video memory.
	SAR	AX,1
	IMUL	Columns 		;Multiply by the number of bytes per line
	ADD	AX,BX			;Add the offset for Even or Odd
;Now divide the Horizontal Position by 8 bits per byte, and we have the byte
;offset on the line.
	SAR	SI,1			;Divide by 8
	SAR	SI,1
	SAR	SI,1
	ADD	SI,AX			;SI <- Pointer to GCB in Video Ram
	POP	BX
	POP	AX
	RET


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Call a User Subroutine
;
;Entry Conditions:
;	BP	- Pointer to Offset:Segment of user routine
;
;Exit Conditions:
;		- ES and DS will be set to CS
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Call_User_Subr:
	MOV	BX,Button_Status
	MOV	CX,Horiz.Virtual_Pos
	MOV	DX,Vert.Virtual_Pos
	MOV	SI,Horiz.Count
	MOV	DI,Vert.Count
	STI
	CALL	DWORD PTR CS:[BP]
	CLI
	CALL	Set_ESDS_to_CS
	RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Calculate the Text Cursor Video Address - Calculate the address of the Text
;Cursor in video RAM.
;
;Entry Conditions:
;	AX	- Cursor Vertical Position
;	BX	- Cursor Horizontal Position
;
;Exit Conditions:
;	DI	- Cursor Offset in screen memory
;	ES	- Segment address of the screen
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Calc_Text_Vid_Addr:
	MOV	CX,DOS_SEG_2
	MOV	ES,CX
ASSUME	ES:DOS_SEG_2
;Convert the Vertical cursor position to a screen row number by dividing by the
;character cell height.
	DIV	BYTE PTR Char_Cell_Height
;Multiplying by number of bytes per row gives the byte offset of the start of
;the screen row where the cursor starts (in AX).
	MUL	BYTE PTR Columns
	MOV	DI,Vid_Page_Offset	;Offset of Active CRT Page
	ADD	DI,AX			;Add the cursor offset to the page offset.
	MOV	AX,BX			;AX <- Horiz Cursor Position
;Now we must find out how far into the row the cursor starts. To do this, we
;divide the horizontal position by the character width.
	DIV	BYTE PTR Char_Cell_Width
	ADD	DI,AX			;Add this to the offset
	SHL	DI,1			;Two bytes per character
	MOV	ES,Curr_Pg_Seg
	RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Check_Bounds - Checks Horizontal or Vertical position against the
;allowed minimum or maximum, and adjusts it to be within bounds if not
;already.
;
;Entry Conditions:
;	AX	- Cursor Position
;	SI	- Pointer to Horizontal or Vertical Cursor Table
;
;Exit Conditions:
;	AX	- Will be within allowed bounds
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
ASSUME	ES:Code_Seg
Check_Bounds:
	CMP	AX,[SI].Min		;Compare position against the minimum
	JL	Check_too_low		;Branch if too low - adjust it
	CMP	AX,[SI].Max		;Compare position against the max
	JLE	Check_B_OK		;Branch if OK
	MOV	AX,[SI].Max		;Set AX to the maximum allowed
Check_B_OK:
	RET

Check_too_low:
	MOV	AX,[SI].Min		;Set AX to the minimum allowed
	RET


Make_CX_Min:
	CMP	CX,DX
	JL	CX_is_Min
	XCHG	CX,DX
CX_is_Min:
	RET


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Test to see if we should hide the cursor because it has entered a
;conditional off region set by the user.
;
;Entry Conditions:
;	AX	- Address of bottom of GCB
;	BX	- Address of right side of GCB
;	CX	- Address of top of GCB
;	DX	- Address of left side of GCB
;
;Exit Conditions:
;	CF	- Set IFF cursor is in the conditional off region
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Test_For_Cond_Off:
	CMP	AX,Cond_Off_Low 	;Low boundary
	JG	Cond_Off_OK
	CMP	BX,Cond_Off_Right	;Right boundary
	JG	Cond_Off_OK
	CMP	CX,Cond_Off_Top 	;Top Boundary of Conditional Off Region
	JL	Cond_Off_OK
	CMP	DX,Cond_Off_Left
	JL	Cond_Off_OK
	DEC	Cursor_Count		;Hide the cursor
	STC
	RET

Cond_Off_OK:
	CLC
	RET

Display_Cursor	ENDP

;
;This is the Mouse Initialization Code
;
Init_Mouse	PROC	NEAR
	CLD
	CALL	Set_ESDS_to_CS
	MOV	Driver_End_Address,Offset Mouse ;End of the Driver
	MOV	AX,3533H
	INT	21H			;Get interrupt vector 33H.
	MOV	AX,ES
	OR	AX,BX
	JZ	Not_Inst		;Branch if vector is 0:0
;The INT 33H vector is non-Zero, check to see if a mouse driver is already
;installed.
	MOV	AX,21			;Query Mouse for storage requirements
	XOR	BX,BX
	INT	33H			;Else test for MS Mouse driver
	OR	BX,BX			;See if it returned a valid size
	JZ	Not_Inst		;Branch if not a mouse driver
	MOV	DX,OFFSET Installd	;Mouse Driver already installed

Jmp_Disp_Str_2:
	JMP	Disp_Str

Not_Inst:
IF	SYS_FILE
;Get a pointer to any parameters.
	LDS	SI,DWORD PTR CS:DRB_Off ;Mouse Driver is not installed
	LDS	SI,DWORD PTR [SI]+18
ENDIF
	CALL	Set_ESDS_to_CS

Find_Serial_Mouse:
	MOV	SI,OFFSET Comm_Tbl	;Point to the table of port addresses
	MOV	AL,Num_Of_Ports 	;Get the number of entries in it
	MOV	DX,Offset No_Ports_Msg	;Point to the 'No Ports' message
	OR	AL,AL			;Branch if zero, no ports available
	JZ	Jmp_Disp_Str_2
	XOR	AX,AX			;Zero the Port Count

Test_Next_Port:
	MOV	Com_Pt_Num,AX		;Set the port number
	CALL	Test_Mouse		;Test for a Mouse on this port
	MOV	AX,Com_Pt_Num		;Recover the Port count
	JNC	Found_Com_Addr		;Branch if we found a Mouse
	MOV	DX,Offset NoMouse	;'No Mouse Found' Message
	INC	AL			;Increment the COM Port count
	CMP	AL,Num_Of_Ports 	;Are we out of ports?
	JE	Jmp_Disp_Str_2		;Branch if we are out of ports - No Mouse
	JMP	SHORT Test_Next_Port	;and loop.

Found_Com_Addr:
	MOV	Driver_End_Address,Offset Init_Mouse
	MOV	AL,Int_Number
	MOV	AX,3510H
	INT	21H			;Get interrupt vector 10H
	MOV	Old_Int_10H_Off,BX
	MOV	Old_Int_10H_Seg,ES
	MOV	AX,2510H
	MOV	DX,OFFSET Our_Int_10H
	INT	21H			;Set it to point to our Video routine
	MOV	AX,3533H
	INT	21H			;Get interrupt vector 33H
	MOV	Old_Int_33H_Off,BX
	MOV	Old_Int_33H_Seg,ES
	MOV	DX,OFFSET INT_33H
	MOV	AX,2533H
	INT	21H			;Set it to our Mouse function call routine
	XOR	AX,AX			;Reset the mouse driver
	INT	33H
	MOV	DX,OFFSET InstMous	;Point to the "Installed" message
Disp_Str:
	MOV	AH,9
	INT	21H			;Display message
IF	SYS_FILE
	MOV	AX,CS:Driver_End_Address
	LDS	BX,DWORD PTR CS:[DRB_Off]
	MOV	[BX]+14,AX		;Ending Address of the Driver
	MOV	[BX]+16,CS
	JMP	Mouse_Exit
ELSE
IF	NOT DEBUG
;Make a .COM file instead.
	MOV	DX,Driver_End_Address
	CMP	DX,Offset Mouse
	JZ	Do_Not_Install		;If they match, then don't install
	INT	27H			;Else go TSR

Do_Not_Install:
	MOV	AX,4C00H		;NORMAL TERMINATE PROCESS CALL. THIS
	INT	21H			;WILL RETURN OUR LOW MEMORY FOR REUSE.
ELSE	;Else we are debugging
	INT	3
	JMP	DEBUG_INIT
ENDIF	;DEBUG

ENDIF


Test_Mouse:
	LODSW				;Test Port for a Mouse
	MOV	Mouse_Port,AX
	LODSB
	MOV	Int_Number,AL
	LODSB
	MOV	Int_Enable_Mask,AL

	MOV	DX,Mouse_Port		;Program the 8250
	INC	DX			;Don't save the RD register
	MOV	DI,Offset Serial_Regs	;Point to a place to save the registers
	MOV	CX,5			;Number of registers to save

Save_Current_Regs:
	IN	AL,DX			;Read a Register
	STOSB				;Save it
	INC	DX			;Point to the next register
	LOOP	Save_Current_Regs

	MOV	AH,RS232_INIT		;Initialize the COM Port
	MOV	AL,10000010B		;1200 BPS, 7 Data Bits, No Parity, 1 Stop bit
	MOV	DX,Com_Pt_Num		;Get the port number
	INT	RS232_INT

	MOV	DX,Mouse_Port		;Address of the RX Data Register again
	INC	DX			;Interrupt Enable Register
	XOR	AL,AL			;Disable all Serial Interrupts
	OUT	DX,AL
	JMP	SHORT Test_Mouse_2	;Delay
Test_Mouse_2:
	ADD	DX,3			;Modem Control Register
	MOV	AL,1			;Raise DTR, drop RTS
	OUT	DX,AL
	MOV	DX,Mouse_Port		;Address of the RX Data Register again

	PUSHF
	STI
	PUSH	DS
	MOV	AX,DOS_SEG_2
	MOV	DS,AX
ASSUME	DS:DOS_SEG_2
	IN	AL,DX			;Clear the RD Register
	MOV	CL,TICK_COUNTER
	ADD	CL,3			;Wait three timer ticks
Test_M_Delay_1:
	CMP	CL,TICK_COUNTER
	JNZ	Test_M_Delay_1		;Loop for 3 Timer Ticks
	IN	AL,DX			;Clear the RD Register
	POP	DS
ASSUME	DS:CODE_SEG
	POPF

	ADD	DX,5			;Line Status Register
	IN	AL,DX			;Reset all of the error flags
	JMP	SHORT Test_Mouse_3	;Delay
Test_Mouse_3:
	DEC	DX			;Modem Control Register
	MOV	AL,0BH			;OUT2, DTR, RTS
	OUT	DX,AL
	MOV	BX,3

;Wait for the Mouse to respond with a character.
Tst_M_Wait_Char:
	PUSHF
	STI
	PUSH	DS
	MOV	AX,DOS_SEG_2
	MOV	DS,AX
ASSUME	DS:DOS_SEG_2
	MOV	DX,Mouse_Port		;Wait for a Character
	ADD	DX,5			;Line Status Register
	MOV	CL,TICK_COUNTER		;LSB of Timer Count
	ADD	CL,2			;Wait for two timer ticks
Tst_M_Wait_Char_2:
	IN	AL,DX
	TEST	AL,bit_data_rdy 	;Check for Receive Data Available
	JNZ	Test_Mouse_Got_Char	;Branch if we got a character
	CMP	CL,TICK_COUNTER
	JNZ	Tst_M_Wait_Char_2	;Loop for 2 Timer Ticks
	POP	DS
ASSUME	DS:CODE_SEG
	POPF
	JMP	Restore_Port

;We got a character from the Mouse, see if it is an 'M'.
Test_Mouse_Got_Char:
	POP	DS
	POPF
	SUB	DX,5
	IN	AL,DX			;Get the Character
	CMP	AL,'M'
	JZ	Found_Mouse		;Branch if we found the mouse
	DEC	BX
	JNZ	Tst_M_Wait_Char 	;Else wait for another character

;If we get here, we didn't find a mouse. We need to restore all of the port
;registers to their original values.
Restore_Port:
	PUSH	SI
	MOV	DX,Mouse_Port		;Program the 8250
	INC	DX			;Don't save the RD register
	MOV	SI,Offset Serial_Regs	;Point to the saved registers
	MOV	CX,5			;Number of registers saved

Restore_Port_2:
	LODSB				;Get a register
	OUT	DX,AL			;Restore it
	INC	DX			;Point to the next register
	LOOP	Restore_Port_2
	POP	SI

	STC				;Didn't find a mouse on this port.
	RET

;If we get here, then we found a mouse on the current port.
Found_Mouse:
	MOV	DX,Mouse_Port
	INC	DX			;Interrupt Enable Register
	MOV	AL,1			;Enable the RDA Interrupt
	OUT	DX,AL
	CLC
	RET

Init_Mouse	ENDP


;
;This code is for debugging - it reads bytes from an event table and passes
;them directly to the mouse serial interrupt handler. This simulates mouse
;events.
;
IF	DEBUG
DEBUG_INIT	PROC	NEAR
	MOV	Event_Pointer,Offset Event_Table
	JMP	Debug_Loop
	
Debug_Loop:
	MOV	SI,Event_Pointer	;Get the pointer into the event table
	CMP	SI,Offset Event_End	;Is it past the end of the table?
	JG	Debug_Done		;Branch if past the end
	LODSB				;Else get the byte
	MOV	Event_Pointer,SI	;Save the new pointer
	JMP	No_Overrun		;Jump into the serial interrupt handler

Debug_Done:
	INT	3
	JMP	Debug_Done

Event_Pointer	DW	0		;Pointer to next byte in the event table

Event_Table	DB	30h
		db	0
		db	0
Event_End	EQU	$

Debug_Init	ENDP
ENDIF	;DEBUG


Num_Of_Ports	DB	4		;Number of Ports to check
Driver_End_Address	DW	0
Serial_Regs	DB	5 DUP(?)	;Storage for the 8250 registers

InstMous DB	'Installing MOUSE Device Driver V1.20.', CR,LF,'$'
No_Ports_Msg DB 'MOUSE: No Serial Ports found.',CR,LF,'$'
Installd DB	'MOUSE: Driver already installed.',CR,LF,'$'
NoMouse DB	'MOUSE: Driver not installed -- Mouse not found.',CR,LF,'$'
	DB	' length.',CR,LF,'$'

Code_Seg ENDS
        END     MOUSE

