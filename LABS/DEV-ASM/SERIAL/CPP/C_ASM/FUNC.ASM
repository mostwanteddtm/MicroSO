.486
.MODEL FLAT

public 	_initcom1
public	_outport

.code

_initcom1	proc

	mov		ah, 0 						; initialize port service
	mov 	al, 0E3h 					; line settings = 9600, 8, N, 1
	xor 	dx, dx 						; port = COM1
	int 	14h

_initcom1	endp

_outport	proc

	push 	ebp
	mov 	ebp, esp

	mov 	edx, [ebp+8]
	mov		eax, [ebp+12]
	out		dx, al

	mov 	esp, ebp
	pop 	ebp
	ret
	
_outport	endp

end