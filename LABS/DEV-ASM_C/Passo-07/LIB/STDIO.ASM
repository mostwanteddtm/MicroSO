GLOBAL _print

SEGMENT _TEXT PUBLIC CLASS=CODE USE16

_print:		push    bp
			mov     bp, sp 
			mov     si, [bp+4]
			pop     bp
			
while:		lodsb
            cmp     al, 00h
            je      sair
            mov		ah, 0eh
			int		10h
			jmp     while
sair:
			xor		ax, ax
			int		16h
			ret