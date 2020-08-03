.MODEL tiny

.data
    text db "Texto impresso pela Extern Function printf!!",0

.code

printf PROC

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
printf ENDP

END