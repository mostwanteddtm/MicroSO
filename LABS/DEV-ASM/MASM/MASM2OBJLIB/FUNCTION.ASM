.MODEL tiny

.data
    text db "This is sub1.",13,10,0

.code

sub1 PROC

    mov ah, 0eh
	mov si, offset text
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