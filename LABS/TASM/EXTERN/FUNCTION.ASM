.MODEL tiny

.code  

public print

print PROC

    mov ah, 0eh

	retorno:
		lodsb
		cmp al, 0h
		je continue
		int 10h
		jmp retorno
	
	continue:

    ret
print ENDP

END