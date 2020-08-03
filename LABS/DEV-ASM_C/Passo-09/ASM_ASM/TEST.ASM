		.286
		.model small
		.code
		org 100h
		extrn _myMul2:near	; CODE XREF: _main:loc_10014p
		extrn _myMul1:near	; CODE XREF: _main+Cp

		public _main
_main:
		push	bp
		mov	bp, sp
		push	si
; #line	6
		mov	si, 2
; #line	7
		cmp	si, 1
		jnz	short loc_10014
; #line	8
		call	_myMul1
		jmp	short loc_10017
; 컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
; #line	10

loc_10014:				; CODE XREF: _main+Aj
		call	_myMul2
; #line	11

loc_10017:				; CODE XREF: _main+Fj
		xor	ax, ax
		jmp	short $+2
; #line	12
		pop	si
		pop	bp
		retn

		end
