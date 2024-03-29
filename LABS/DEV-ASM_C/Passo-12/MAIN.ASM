#MASM#

;
; +-------------------------------------------------------------------------+
; |   This file	has been generated by The Interactive Disassembler (IDA)    |
; |	      Copyright	(c) 2014 Hex-Rays, <support@hex-rays.com>	    |
; |			 License info: 48-3057-7374-2C			    |
; |	Zhou Tao, Jiangsu Australia Sinuo Network Technology Co., Ltd.	    |
; +-------------------------------------------------------------------------+
;
; Input	MD5   :	F8128C30E08E791B9D74C9287C6B06A4
; Input	CRC32 :	90C6CD6C

; File Name   :	C:\MicroSO\trunk\LABS\DEV-ASM_C\Passo-12\MAIN.COM
; Format      :	MS-DOS COM-file
; Base Address:	1000h Range: 10100h-1015Eh Loaded length: 5Eh

		.286p
		.model tiny

; ===========================================================================

; Segment type:	Pure code
seg000		segment	word public 'CODE'
		assume cs:seg000
		org 100h
		assume es:nothing, ss:nothing, ds:seg000

; =============== S U B	R O U T	I N E =======================================

; Attributes: noreturn

		public start
start		proc near
		call	sub_10105
		int	20h		; DOS -	PROGRAM	TERMINATION
start		endp			; returns to DOS--identical to INT 21/AH=00h


; =============== S U B	R O U T	I N E =======================================

; Attributes: bp-based frame

sub_10105	proc near		; CODE XREF: startp
		push	bp
		mov	bp, sp
		;push	134h
		push 	offset aCompilacaoComb
		call	sub_10116
		pop	cx
		xor	ax, ax
		jmp	short $+2
; ---------------------------------------------------------------------------

loc_10113:				; CODE XREF: sub_10105+Cj
		pop	bp
		retn
sub_10105	endp

; ---------------------------------------------------------------------------
		align 2

; =============== S U B	R O U T	I N E =======================================


sub_10116	proc near		; CODE XREF: sub_10122+Bp
arg_0		= word ptr  4

		push	bp
		mov	bp, sp
		push	si
		mov	si, [bp+arg_0]
		add	si, 0
		mov	ah, 0Eh

loc_10118:				; CODE XREF: sub_10116+9j
		lodsb
		cmp	al, 0
		jz	short locret_10121
		int	10h		; - VIDEO - WRITE CHARACTER AND	ADVANCE	CURSOR (TTY WRITE)
					; AL = character, BH = display page (alpha modes)
					; BL = foreground color	(graphics modes)
		jmp	short loc_10118
; ---------------------------------------------------------------------------

locret_10121:				; CODE XREF: sub_10116+5j
		pop	cx
		pop	si
		pop	bp
		retn
sub_10116	endp


; =============== S U B	R O U T	I N E =======================================

; Attributes: bp-based frame


; ---------------------------------------------------------------------------
aCompilacaoComb	db 'Compilacao Combinada entre C e Assembly!',0
		db 0
seg000		ends


		end start
