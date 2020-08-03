;******************************************************************
;program: en.asm by Shirley Her and Sen-Cuo Ro, NexGen Micro Sys.
;reviewed and supplemented by: R. Richardson
;purpose: This program shows the way to enter and leave
;	     the protected mode from DOS real-address mode.
;	     From chapter 4: "i386/i486 ADVANCED PROGRAMMING"
;	     copyright (c) 1993 by Van Nostrand Reinhold
;	     ISBN 0-442-01377-9 from Compubooks: (800) 880-6818
;******************************************************************

.386p				;p=enable highest privilege

INCLUDE STRUCT
INCLUDE MACRO1

;-------------------------------
;    STEP 8A
;	CODE	Segment
;-------------------------------

STACK SEGMENT STACK USE16
	DB 100 DUP(0)
STACK ENDS

;MACRO2	includes steps 1,2,3,4

INTNO			EQU	21			;NUMBER INTERRUPT VECTORS
DSCPSIZE		EQU	8			;SIZE OF DESCRIPTOR
INTSIZE			EQU	4			;SIZE INTERRUPT SERVICE ROUTINE
TWO				EQU	2			;2 BYTE HEX NUMBER
PROT_ENABLE		EQU	01H			;PROTECTED MODE ENABLE BIT CR0
ATTRIBUTE		EQU	07H			;DISPLAY CHARACTER ATTRIBUTE
SPACE			EQU	20H			;ASCII CODE FOR SPACE
FSSEG			EQU	0			;SET FS SEG TO 0000H
GSSEG			EQU	9000H		;SET GS SEG TO 9000H

;------------------------------------------
;	STEP 1:
;	GLOBAL DESCRIPTOR TABLE
;------------------------------------------

GDT	SEGMENT	PARA	PUBLIC 	USE16	'GDT'

GDT_TAB		LABEL	QWORD	;QUAD WORD = 8 BYTES
NULL_SELEC	EQU	$-GDT_TAB	;NULL SELECTOR
	DSCP	<>			;FIRST ONE MUST BE A NULL
					;DESCRIPTOR

CODE_SELEC	EQU	$-GDT_TAB  	;CODE SEGMENT SELECTOR
	DSCP	<0FFFFH,,,09AH,,>	;CODE SEGMENT DESCRIPTOR

TASK0_TSS_SELEC	EQU	$-GDT_TAB 	;TSS SELECTOR
	DSCP	<TASK0_TSS_LIMIT,,,089H,,>	;TSS SEGMENT DESCRIPTOR

STK0_SELEC	EQU	$-GDT_TAB	;SELECTOR FOR PRIVILEGE LEVEL 0
					;STACK
	DSCP	<STK0_LIMIT,,,92H,,>	;STACK SEGMENT DESCRIPTOR WITH
					;PRIVILEGE LEVEL 0

STK1_SELEC	EQU	$-GDT_TAB OR 1	;SELECTOR FOR PRIVILEGE LEVEL 1
					;STACK
	DSCP	<STK1_LIMIT,,,0B2H,,>	;STACK SEGMENT DESCRIPTOR WITH
					;PRIVILEGE LEVEL 1

STK2_SELEC	EQU	$-GDT_TAB  OR 2	;SELECTOR FOR PRIVILEGE LEVEL 2
					;STACK
	DSCP	<STK2_LIMIT,,,0D2H,,>	;STACK SEGMENT DESCRIPTOR WITH
					;PRIVILEGE LEVEL 2

DMY_SELEC	EQU	$-GDT_TAB	;DUMMY SEGMENT SELECTOR
	DSCP	<0FFFFH,,,92H,,>	;DUMMY SEGMENT DESCRIPTOR

VIDEO_SELEC	EQU	$-GDT_TAB OR 3	;VIDEO SEGMENT SELECTOR
	DSCP	<0FFFFH,8000H,0BH,0F2H,,>   ;VIDEO SEGMENT DESCRIPTOR

FSSEG_SELEC	EQU	$-GDT_TAB       ;FS SEGMENT SELECTOR
	DSCP	<0FFFFH,0000H,0F8H,0F2H,,>   ;FS SEGMENT DESCRIPTOR

GSSEG_SELEC	EQU	$-GDT_TAB      	;GS SEGMENT SELECTOR
	DSCP	<0FFFFH,9000H,0F4H,0F2H,,>   ;GS SEGMENT DESCRIPTOR

GDATA_SELEC	EQU	$-GDT_TAB 	;DATA SEGMENT SELECTOR
	DSCP	<0FFFFH,0000H,00H,0F2H,,>   ;DATA SEGMENT DESCRIPTOR
;ORG DSCP	<GDATA_LIMIT,,,0F2H,,>	;DATA SEGMENT DESCRIPTOR

INT_SELEC	EQU	$-GDT_TAB 	;INTERRUPT SEGMENT SELECTOR
	DSCP	<0FFFFH,,,09AH,,> 	;INTERRUPT SEGMENT DESCRIPTOR

GDT_LIMIT	EQU	$-GDT_TAB
GDT	ENDS

;-------------------------------------------
;	STEP 2:
;	INTERRUPT DESCRIPTOR TABLE
;-------------------------------------------

IDT	SEGMENT PARA	PUBLIC USE16	'IDT'
IDT_TAB EQU	$			;REPT = MASM 5.01 REPEAT
	REPT	INTNO			;21 INTERRUPT ENTRIES 0 TO 14H
	DSCP	<,INT_SELEC,0,0EEH,,>	;DPL = 3
	ENDM
IDT_LIMIT	EQU	$
IDT	ENDS

;---------------------------
;	DATA 	SEGMENT
;---------------------------

GDATA	SEGMENT	PARA	PUBLIC 	USE16	'GDATA'

;------------------------------------------------------
;	STEP 3:
;	VARIABLE TO SAVE GDT/IDT LIMIT AND LINEAR ADDRESS.
;------------------------------------------------------

PGDT		LABEL	FWORD
PGDT_LIMIT	DW	?		;GDT LIMIT
PGDT_ADDR	DD	?		;GDT SEGMENT LINEAR ADDRESS

PIDT		LABEL	FWORD
PIDT_LIMIT	DW	?		;IDT LIMIT
PIDT_ADDR	DD	?		;IDT SEGMENT LINEAR ADDRESS

POLD		LABEL	FWORD
DIDT_LIMIT	DW	03FFH		;DOS IDT LIMIT
DIDT_ADDR	DD	0		;DOS IDT SEGMENT LINEAR ADDRESS

;----------------------------------------------------------
;	STEP 4: TABLE DEFINES MAPPING OF DESCRIPTOR TO SEGMENT
;----------------------------------------------------------

DB 8 DUP(90H)			;SLOWDOWN MILLISECOND TO AVOID
					;AVOID TYPEMATIC ERROR ON
					;RETURN FROM EDMOD
GDT_PHYS_TAB	LABEL	WORD
	DW	TASK0_TSS_SELEC		;TSS SEGMENT SELECTOR
	DW	TASK0_TSS		;TSS SEGMENT
	DW	STK0_SELEC		;STK0 SEGMENT SELECTOR
	DW	STK0			;STK0 SEGMENT
	DW	STK1_SELEC		;STK1 SEGMENT SELECTOR
	DW	STK1			;STK1 SEGMENT
	DW	STK2_SELEC		;STK2 SEGMENT SELECTOR
	DW	STK2			;STK2 SEGMENT
	DW	DMY_SELEC		;DUMMY SEGMENT SELECTOR
	DW	DMY			;DUMMY SEGMENT
	DW	CODE_SELEC		;CODE SEGMENT SELECTOR
	DW	CODE			;CODE SEGMENT
	DW	GDATA_SELEC		;DS SEGMENT SELECTOR
	DW	GDATA			;DATA SEGMENT
	DW	FSSEG_SELEC		;FS SEGMENT SELECTOR
FSEG	DW	FSSEG			;DATA SEGMENT
	DW	GSSEG_SELEC		;GS SEGMENT DESCRIPTOR
GSEG	DW	GSSEG			;DATA SEGMENT
INTSEG DW	INT_SELEC		;INTERRUPT SEGMENT SELECTOR
	DW	CODE			;CODE SEGMENT

GDT_TAB_SIZE	EQU	($ - GDT_PHYS_TAB) / 4	;ENTRY NUMBERS IN

;---------------------------------------------
;	STEP 5:
;	MESSAGE DEFINE AREA + MINI-KEYBOARD TABLE
;---------------------------------------------

IN_PROTECTED	DB	'Now in Protected Mode',0
SAVDI1	DW	?		;DISP_IT'S NEXT LINE BEGIN
SAVDI4	DW	?		;DISPLAY CONTROL/DEBUG REGS
SAVCL	DB	4		;NOMINAL KEYBOARD DELAY

DB 9100H DUP(0)			;WAS DB 7000H

GDATA_LIMIT	EQU	$

GDATA	ENDS

;MACRO4

;-------------------------------------------
;	STEP 6:
;	STACK SEGMENT FOR PRIVILEGE LEVEL 0,1,2
;-------------------------------------------

STK0	SEGMENT	PARA	PUBLIC USE16	'STK0'
	DB	100H	DUP(0)
STK0_LIMIT	EQU	$
STK0	ENDS

STK1	SEGMENT	PARA	PUBLIC USE16	'STK1'
	DB	100H	DUP(0)
STK1_LIMIT	EQU	$
STK1	ENDS

STK2	SEGMENT	PARA	PUBLIC	USE16	'STK2'
	DB	100H	DUP(0)
STK2_LIMIT	EQU	$
STK2	ENDS

;------------------------------
;	STEP 7:
;	TASK STATE SEGMENT 
;------------------------------

TASK0_TSS	SEGMENT	PARA	PUBLIC USE16	'TASK0'
	TSS_STACK	STK0_SELEC,STK0_LIMIT,STK1_SELEC,STK1_LIMIT,STK2_SELEC,STK2_LIMIT
	TSS_CR3		;CR3
	TSS_REGS	0,0,0,0,0,0,0,0,0,STK0_LIMIT
;	TSS_SEG		FSSEG_SELEC,CODE_SELEC,STK0_SELEC,GSSEG_SELEC,GDATA_SELEC,GDATA_SELEC
	
	DD	0	;LDT FIELD
	DW	0	;TASK TRAP FLAG
	DW	68H	;I/O BASE ADDRESS
DB 3	DUP(0)
TASK0_TSS_LIMIT	EQU	$
TASK0_TSS	ENDS

;--------------------------
;	STEP 8:
;	DUMMY SEGMENT
;--------------------------

DMY	SEGMENT	PARA	PUBLIC USE16	'DMY'
	DB	128	DUP(0)
DMY	ENDS

code	segment	para	public use16	'code'
	assume	cs:code,ds:gdata
main	proc	far
				
	call	new_chars
	mov	ax,gdata
	mov	ds,ax			;put in DS
	jmp	init

init: 
	mov	ax,IDT			;get IDT segment address
	mov	es,ax			;put in ES
	mov	di,offset idt_tab	;get IDT offset address
	mov	ax,offset int_entry	;get interrupt service address
	mov	cx,INTNO		;get interrupt number
fillidt:
	mov	es:[di],ax		;put entry address in IDT
	add	di,DSCPSIZE		;adjust address in IDT
	add	ax,INTSIZE		;adjust interrupt service addrs
					;the size of each routine is
					;defined in INTSIZE
	loop	fillidt			;keep filling
		
;--------------------------------------
;	STEP 10:	
;	get GDT/IDT limit & linear address
;--------------------------------------

	mov	ax,offset gdt_limit	;get GDT segment limit
	mov	pGDT_limit,ax		;put in pGDT_limit
	xor	eax,eax			;clear eax
	mov	ax,GDT			;get GDT segment address
	shl	eax,4		       ;convert to 32 bit linear addrez
	mov	pGDT_addr,eax		;put in pGDT_addr

	mov	ax,offset idt_limit	;get IDT segment limit
	mov	pIDT_limit,ax		;put in pGDT_limit
	xor	eax,eax			;clear eax
	mov	ax,idt			;get IDT segment address
	shl	eax,4		       ;convert to 32 bit linear addrez
	mov	pIDT_addr,eax		;put in pIDT_addr

;---------------------------------------------------
;	STEP 11:
;	base on gdt_phys_tab to set linear base address 
; 	for each corresponding descriptor
;---------------------------------------------------

	mov	ax,GDT			;get gdt segment address
	mov	es,ax			;put in ES
	mov	si,offset gdt_phys_tab	;get address of gdt_phys_tab
	mov	cx,gdt_tab_size		;get gdt_phys_tab size
bdt1:
	lodsw				;get descriptor number
	mov	bx,ax			;put in BX
	and	bx,0fff8h		;mask off TI bit and RPL
	lodsw				;get corresponding seg address
					;for the above descriptor
	push	ax			;save it
	shl	ax,4			;get lower 4 bytes offset
	mov	es:[bx][d_base1],ax	;save it in descriptor base1
	pop	ax			;restore segment address
	shr	ax,12			;get the highest byte
	mov	es:[bx][d_base2],al	;save it in descriptor base2
	loop	bdt1			;continue

;----------------------------
;	STEP 12:
;	switch to protected mode
;----------------------------

	cli				;clear interrupts
	lgdt	[pGDT]			;load GDT address+limit in GDTR
	lidt	[pIDT]			;load IDT address+limit in IDTR
	mov	eax,cr0			;get cr0 register
	or	al,prot_enable		;set protected mode enable
	mov	cr0,eax			;restore cr0
	
	jmp dword ptr cs:[enter_prot]	;far jump flush instruct. queue

enter_prot:
	dw	offset now_in_prot	;EIP
	dw	code_selec		;code segment selector
	
;------------------------------
;	STEP 13:
;	execute in portected mode, 
;	set LDTR,SS,SP,DS,ES,FS,GS
;------------------------------

now_in_prot:
	xor	ax,ax			;clear ax
	lldt	ax			;load NULL seclector to LDTR
	mov	ax,stk0_selec		;get stack segment selector
	mov	ss,ax			;put in SS
	mov	sp,offset stk0_limit	;set stack pointer
	mov	ax,gdata_selec		;get data segment selector
	mov	ds,ax			;put in DS
	mov	ax,video_selec
	mov	es,ax			;put in ES
	mov	ax,fsseg_selec
	mov	fs,ax			;put in FS
	mov	ax,gsseg_selec
	mov	gs,ax			;put in GS

;-------------------------------------
;	STEP 14:
;	display message in protected mode
;-------------------------------------

	;cmp byte ptr saval,1
	;jz	skip_it			;skip introduction two pages

	mov	si,offset in_protected	;diz intro page only 1st time
	mov	di,0
	call	disp_it
	call	pr_ess			;wait key pressed
	call	re_lease		;wait key released
	JMP		go_exit
	
;------------------------------
;	STEP 15:
;	load TSS to TR
;------------------------------

bb4:					;begin exit protected mode
	mov	ax,task0_TSS_selec	;TSS selector for current task
;	ltr	ax			;load into task register

;-----------------------------------
;	STEP 16:
;	switch back to real mode
;-----------------------------------

	int	20			;= int 14h

;--------------------------------------
;	STEP 17:
;	Interrupt Service Routine
;--------------------------------------

int_entry:		;entry point for interrupt service routine

	REPT	INTNO			;number interrupts
	;call	disp			;diz exit interrupt message
	iret				;note
	ENDM

go_exit:
	mov	ax,dmy_selec		;dummy selector
	mov	es,ax			;reset segment registers
	mov	ds,ax
	mov	fs,ax
	mov	gs,ax
	mov	ss,ax
	
	mov	eax,cr0			;get CR0
	and	eax,not prot_enable	;disable protected mode
	mov	cr0,eax			;update it

	db	0eah		;far jump to flush instruction queue
	dw	offset next_instruction ;new EIP
	dw	code			;new CS
	
;----------------------------------
;	STEP 20:
;	execute in real mode,
;	set DS,SS and SP.
;----------------------------------
next_instruction:
	mov	ax,Gdata		;get data segment address
	mov	ds,ax			;put in DS 
	mov	ax,stk0			;get stack segment address
	mov	ss,ax			;put in SS 
	mov	sp,offset stk0_limit	;set stack pointer

;-----------------------------------
;	STEP 21:
;	set IDTR to DOS interrupt table
;-----------------------------------

	lidt	[pold]	       ;load DOS interrupt vector table to IDTR
	sti				;enable maskable interrupts

;------------------------------------------------
;	STEP 22:
;	N = terminate this process go to DOS> prompt
;	Y = go to EDMOD
;	Enter = return to protected mode
;	your choice
;------------------------------------------------

	push	cs			;calls not allowed here
	pop	ds			;as stack buggered up
	
ss0:	
	mov	ax,3
	int	10h			;cls
	mov ah, 09h
	mov dx, offset in_real
	int 21h
	xor	ax, ax
	int 16h
	mov	ax,4c00h		;go to DOS>
	int	21h			;exit
	
in_real	db	'Now in real mode$'

main	endp

;--------------------------------------------------------
;	procedure: disp_it
;	display string in protected mode
;	input: ds:si -> string address + di -> video address
;	the end of the string must be 0
;--------------------------------------------------------

disp_it	proc	near
	mov	ax,video_selec		;get video segment selector
	mov	es,ax			;put in ES
	mov	ah,attribute		;display attribute
	mov	[savdi1],di		;save video line
disp_it1:
	lodsb				;get display character
	cmp	al,0dh			;carriage return
	jz	dis2			;start next line down
	cmp	al,0			;end of display character ?
	jz	dis1			;all done
	stosw				;put it on video screen
	jmp	disp_it1		;continue
dis1: ret				;so return
dis2: mov	di,[savdi1]		;set next line down
	add	di,160
	mov	[savdi1],di
	jmp	disp_it1

disp_it	endp

;------------------------------------------
;	procedure: htoa
;	Convert hexdecimal code to ASCII code
;	input: si--> address to put ASCII code
;	       cx--> hexdecimal code size
;	      eax--> hexdecimal code
;------------------------------------------

htoa_tab	db	'0123456789ABCDEF'

htoa	proc	near
	xor	ebx,ebx			;clear EBX
	add	si,cx			;adjust target address
	dec	si			;fix it
htoa1:
	mov	bl,al			;get hexdecimal code
	and	bl,0fh			;distinguish it
	mov	bl,cs:[htoa_tab][ebx]	;get indexed ascii character
	mov	byte ptr [esi],bl	;place in target address
	dec	esi			;adjust target address
	shr	eax,4			;get rid of this hex code
	loop	htoa1			;continue
	ret				;return
htoa	endp

new_chars: 
	mov ax,1201h		;set 350 scan lines
	mov	bl,30h
	int	10h
	mov	ax,3
	int	10h			;must reset video
	push	es
	mov	ax,cs
	mov	es,ax
	mov	ax,1110h		;set custom characters
	mov	bx,0e00H		;14 points in table zero
	mov	cx,2			;2 characters
	mov	dx,0e7h			;1st one`s ASCII code
	mov	bp,cs:table		;to eliminate help overlap
	int	10h			;do it in real mode
	pop	es
	mov	bp,0
	ret
table:
	DB 0,0,0,0,0,0ffh,0,0ffh,36h,36h,36h,36h,36h,36h	   ;e7h
	DB 36h,36h,36h,36h,36h,37h,36h,37h,36h,36h,36h,36h,36h,36h ;e8h

pr_ess: in	al,60h			;keyboard port
	test	al,80h			;wait till key down
	mov	ah,al
	jnz	pr_ess
	call	key_delay
	call	key_delay
	ret

re_lease: push ax
rea: in	al,60h			;keyboard port unload
	test	al,80h			;wait till key released
	jz	rea
	pop	ax
	ret

key_delay: pusha				;keybd repeat delay
	mov	cl,ds:[savcl]			;repeat count for delay
im0:	mov	di,0
	mov	savdi4,di
	mov	al,10110010b			;set interrupt timer
	out	43h,al				;control register to
	mov	ax,0ffffh			;mode 1.
	out	40h,al				;interrupt timer port
	mov	al,ah
	out	40h,al
im1:	xor	eax,eax
	in	al,40h
	mov	ah,al				;counter zero
	in	al,40h
	xchg	al,ah
	mov	bx,ax
im2:	in	al,40h
	mov	ah,al
	in	al,40h
	xchg	al,ah
	cmp	bx,ax
	ja	im2
	dec	cl
	jnz	im1
	popa
	ret

code	ends
	end	main
