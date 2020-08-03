.486
.MODEL FLAT

.code
public	_sum

_sum		proc

	push 	ebp
	mov 	ebp, esp

	mov 	eax, [ebp+8]
	add		eax, [ebp+12]

	mov 	esp, ebp
	pop 	ebp
	ret
	
_sum		endp

end