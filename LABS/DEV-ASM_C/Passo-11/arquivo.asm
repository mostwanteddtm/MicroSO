#masm#

;--------------------------------------------------------|
;                                                        |
;       Template para compilacao com MASM 6.15           |
;     Facimente testado no EMU8086 com a diretiva        |
;                       #masm#                           |
;                                                        |
;--------------------------------------------------------|  

.286
.model tiny
.STACK 100					   
_Text SEGMENT PUBLIC USE16
.data
            ;area de dados              
.code 

org 100h 

main:
		public start
start		proc near
		call	sub_10105
		int	20h		; DOS -	PROGRAM	TERMINATION
start		endp			; returns to DOS--identical to INT 21/AH=00h


; =============== S U B	R O U T	I N E =======================================

; Attributes: bp-based frame

sub_10105	proc near		; CODE XREF: startp

var_C		= byte ptr -0Ch
var_B		= byte ptr -0Bh
var_A		= byte ptr -0Ah
var_9		= byte ptr -9

		enter	0Ch, 0
		push	si
		xor	si, si
		push	5
		push	25Ah
		push	254h
		call	sub_101E9
		add	sp, 6
		mov	[bp+var_C], al
		cmp	[bp+var_C], 0
		jz	short loc_1012C
		push	260h
		call	sub_101B7
		pop	cx
		jmp	short loc_10133
; ---------------------------------------------------------------------------

loc_1012C:				; CODE XREF: sub_10105+1Cj
		push	270h
		call	sub_101B7
		pop	cx

loc_10133:				; CODE XREF: sub_10105+25j
		push	284h
		call	sub_101B7
		pop	cx
		push	2A6h
		call	sub_101B7
		pop	cx
		push	2
		push	6
		call	sub_101CB
		pop	cx
		pop	cx
		push	2C6h
		call	sub_101B7
		pop	cx

loc_10151:				; CODE XREF: sub_10105:loc_101B2j
		call	sub_101DF
		mov	[bp+var_B], al
		cmp	[bp+var_B], 1Bh
		jnz	short loc_1015F
		jmp	short loc_101B4
; ---------------------------------------------------------------------------

loc_1015F:				; CODE XREF: sub_10105+56j
		cmp	[bp+var_B], 0Dh
		jnz	short loc_101A7
		push	2C9h
		call	sub_101B7
		pop	cx
		lea	ax, [bp+var_A]
		push	ax
		call	sub_101B7
		pop	cx
		push	2CCh
		call	sub_101B7
		pop	cx
		push	6
		lea	ax, [bp+var_A]
		push	ax
		push	2CFh
		call	sub_101E9
		add	sp, 6
		mov	[bp+var_C], al
		cmp	[bp+var_C], 0
		jz	short loc_1019C
		push	2D6h
		call	sub_101B7
		pop	cx
		jmp	short loc_101A3
; ---------------------------------------------------------------------------

loc_1019C:				; CODE XREF: sub_10105+8Cj
		push	2DFh
		call	sub_101B7
		pop	cx

loc_101A3:				; CODE XREF: sub_10105+95j
		xor	si, si
		jmp	short loc_101B2
; ---------------------------------------------------------------------------

loc_101A7:				; CODE XREF: sub_10105+5Ej
		mov	al, [bp+var_B]
		mov	[bp+si+var_A], al
		mov	[bp+si+var_9], 0
		inc	si

loc_101B2:				; CODE XREF: sub_10105+A0j
		jmp	short loc_10151
; ---------------------------------------------------------------------------

loc_101B4:				; CODE XREF: sub_10105+58j
		pop	si
		leave
		retn
sub_10105	endp


; =============== S U B	R O U T	I N E =======================================

; Attributes: bp-based frame

sub_101B7	proc near		; CODE XREF: sub_10105+21p
					; sub_10105+2Ap ...

arg_0		= word ptr  4

		push	bp
		mov	bp, sp
		push	si
		mov	si, [bp+arg_0]
		add	si, 0
		push	si
		call	sub_10200
		pop	cx
		jmp	short $+2
; ---------------------------------------------------------------------------

loc_101C8:				; CODE XREF: sub_101B7+Fj
		pop	si
		pop	bp
		retn
sub_101B7	endp


; =============== S U B	R O U T	I N E =======================================

; Attributes: bp-based frame

sub_101CB	proc near		; CODE XREF: sub_10105+40p

arg_0		= byte ptr  4
arg_2		= byte ptr  6

		push	bp
		mov	bp, sp
		mov	al, [bp+arg_2]
		push	ax
		mov	al, [bp+arg_0]
		push	ax
		call	sub_10222
		pop	cx
		pop	cx
		jmp	short $+2
; ---------------------------------------------------------------------------

loc_101DD:				; CODE XREF: sub_101CB+10j
		pop	bp
		retn
sub_101CB	endp


; =============== S U B	R O U T	I N E =======================================

; Attributes: bp-based frame

sub_101DF	proc near		; CODE XREF: sub_10105:loc_10151p
		push	bp
		mov	bp, sp
		call	sub_1020C
		jmp	short $+2
; ---------------------------------------------------------------------------

loc_101E7:				; CODE XREF: sub_101DF+6j
		pop	bp
		retn
sub_101DF	endp


; =============== S U B	R O U T	I N E =======================================

; Attributes: bp-based frame

sub_101E9	proc near		; CODE XREF: sub_10105+Fp
					; sub_10105+7Fp

arg_0		= word ptr  4
arg_2		= word ptr  6
arg_4		= byte ptr  8

		push	bp
		mov	bp, sp
		mov	al, [bp+arg_4]
		push	ax
		push	[bp+arg_2]
		push	[bp+arg_0]
		call	sub_10235
		add	sp, 6
		jmp	short $+2
; ---------------------------------------------------------------------------

loc_101FE:				; CODE XREF: sub_101E9+13j
		pop	bp
		retn
sub_101E9	endp


; =============== S U B	R O U T	I N E =======================================


sub_10200	proc near		; CODE XREF: sub_101B7+Bp
		mov	ah, 0Eh

loc_10202:				; CODE XREF: sub_10200+9j
		lodsb
		cmp	al, 0
		jz	short locret_1020B
		int	10h		; - VIDEO - WRITE CHARACTER AND	ADVANCE	CURSOR (TTY WRITE)
					; AL = character, BH = display page (alpha modes)
					; BL = foreground color	(graphics modes)
		jmp	short loc_10202
; ---------------------------------------------------------------------------

locret_1020B:				; CODE XREF: sub_10200+5j
		retn
sub_10200	endp


; =============== S U B	R O U T	I N E =======================================


sub_1020C	proc near		; CODE XREF: sub_101DF+3p
		xor	ax, ax
		int	16h		; KEYBOARD - READ CHAR FROM BUFFER, WAIT IF EMPTY
					; Return: AH = scan code, AL = character
		cmp	al, 0Dh
		jz	short loc_1021E
		cmp	al, 1Bh
		jz	short locret_10221
		mov	ah, 0Eh
		int	10h		; - VIDEO - WRITE CHARACTER AND	ADVANCE	CURSOR (TTY WRITE)
					; AL = character, BH = display page (alpha modes)
					; BL = foreground color	(graphics modes)
		jmp	short locret_10221
; ---------------------------------------------------------------------------

loc_1021E:				; CODE XREF: sub_1020C+6j
		mov	si, 0

locret_10221:				; CODE XREF: sub_1020C+Aj
					; sub_1020C+10j
		retn
sub_1020C	endp


; =============== S U B	R O U T	I N E =======================================

; Attributes: bp-based frame

sub_10222	proc near		; CODE XREF: sub_101CB+Bp

arg_0		= byte ptr  4
arg_2		= byte ptr  6

		push	bp
		mov	bp, sp
		mov	ah, [bp+arg_0]
		mov	al, [bp+arg_2]
		add	al, ah
		add	al, 30h
		mov	ah, 0Eh
		int	10h		; - VIDEO - WRITE CHARACTER AND	ADVANCE	CURSOR (TTY WRITE)
					; AL = character, BH = display page (alpha modes)
					; BL = foreground color	(graphics modes)
		leave
		retn
sub_10222	endp


; =============== S U B	R O U T	I N E =======================================

; Attributes: bp-based frame

sub_10235	proc near		; CODE XREF: sub_101E9+Dp

arg_0		= word ptr  4
arg_2		= word ptr  6
arg_4		= word ptr  8

		push	bp
		mov	bp, sp
		mov	di, [bp+arg_0]
		mov	si, [bp+arg_2]
		mov	cx, [bp+arg_4]
		mov	ch, 0
		repe cmpsb
		jz	short loc_1024B
		mov	al, 0
		jmp	short loc_1024D
; ---------------------------------------------------------------------------

loc_1024B:				; CODE XREF: sub_10235+10j
		mov	al, 1

loc_1024D:				; CODE XREF: sub_10235+14j
		xor	si, si
		xor	di, di
		pop	bp
		leave
		retn
sub_10235	endp

; ---------------------------------------------------------------------------
aTeste		db 'TESTE',0
aTeste_0	db 'TESTE',0
aStringIgual	db 'String Igual!',0Dh,0Ah,0
aStringDiferent	db 'String Diferente!',0Dh,0Ah,0
aProgramaCombin	db 'Programa combinando C e ASM!...',0Dh,0Ah,0
aOResultadoDaSo	db 'O resultado da soma de 6 e 2 = ',0
		db 0Dh,0Ah,0
		db 0Dh,0Ah,0
		db 0Dh,0Ah,0
aMarcos		db 'marcos',0
aIgual		db 'Igual!',0Dh,0Ah,0
aDiferente	db 'Diferente!',0Dh,0Ah,0
_Text ENDS
end main
