.MODEL tiny

.data
    text db "Calling sub function in different ASM file!!",13,10,0

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