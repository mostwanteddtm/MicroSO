.486
.MODEL FLAT

.code
public	_getvalue

_getvalue 	proc

	push	ebp
	mov		ebp, esp
	
	mov		al, 41h
	
	mov		esp, ebp
	pop		ebp
	ret
	
_getvalue	endp

end