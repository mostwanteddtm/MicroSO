.MODEL tiny

.code

sub1 PROC

    mov ah, 0eh

	retorno:
		lodsb
		cmp al, 0h
		je continue
		int 10h
		jmp retorno
	
	continue:

    ret
sub1 ENDP

END