.MODEL tiny

.data
    text db "Hello World!",13,10,0

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
	xor ax, ax
	int 16h
    ret
sub1 ENDP

END