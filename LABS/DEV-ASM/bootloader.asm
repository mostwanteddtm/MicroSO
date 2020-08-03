#make_boot#

org 07c00h

start:

	; initialize the stack:
    mov ax, 07c0h
    mov ss, ax
    mov sp, 03feh ; top of the stack.

    xor ax, ax
    mov ds, ax

	mov al,03h
	mov ah,0
	int 10h	
    
    lea si, msg   
	call print

	mov ah,0
	int 16h

	mov ax,0x1000
	mov es,ax
	mov cl,3 ; sector
	mov al,2 ; number of sectors

	call loadsector

	mov ax,0x2000
	mov es,ax
	mov cl,2 ; sector
	mov al,1 ; number of sectors

	call loadsector


	jmp 0x1000:0000 ; jump to our os


done:
	jmp $

loadsector:
	mov bx,0
	mov dl,0 ; drive
	mov dh,0 ; head
	mov ch,0 ; track
	mov ah,2
	int 0x13
	jc err
	ret
err:
	mov si,erro
	call print
	ret
print:
	push    ax      ; store registers...
    push    si      ;
    next_char:      
            mov     al, [si]
            cmp     al, 0
            jz      printed
            inc     si
            mov     ah, 0eh ; teletype function.
            int     10h
            jmp     next_char
    printed:
    pop     si      ; re-store registers...
    pop     ax      ;
    ret

msg db "Booting Successful..",10,13,"Pressione qualquer tecla para continuar !",10,13,10,13,0   
erro dw "Error loading sector ",10,13,0
vetor1 db 510 - ($-start) dup (0)
dw 0xaa55