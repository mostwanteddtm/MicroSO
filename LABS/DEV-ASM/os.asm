org 0

start:
	mov ax,cs
	mov ds,ax
	mov es,ax
	mov ax,0x7000	
	mov ss,ax	; stack segment initialisation
	mov sp,ss

	cmp [first],0
	jnz skip_msg
    
    lea si,welcome
	call print
	mov [first],1

	skip_msg:

	mov ax,0x2000 	;address where the file table is loaded
	;mov gs,ax
	mov bx,0

	show_prompt:
		lea si, prompt 	
		call print

		lea si, query
		call readcmd

		call search

		jmp show_prompt



;================================FUNCTIONS======================================


readcmd:	; read an exe name from the user
	pusha
	mov bp,sp
	cld
	mov [charcount],0
	mov di,[bp+18]
	continue_read:
		mov ah,0
		int 16h
		cmp al,0dh
		jz fin
		mov ah,0x0e
		mov bx,0
		int 10h
		stosb
		inc [charcount]
		jmp continue_read	
	fin:
		lea si, nl
		call print
		mov sp,bp
		popa
		ret


search:		; search the filetable for the file
	pusha
	mov bp,sp 

	cmp ax,ax ; to set zero flag
	lea di,query

	mov bx,0
	cld
	cont_chk:
		;mov al,[gs:bx]
		cmp al,'}'

		je complete	

		cmp al,[di]
		je chk
		inc bx
		jmp cont_chk

	chk:
		push bx
		mov cx, [charcount] 
	check:
		;mov al,[gs:bx]
		inc bx

		scasb
		loope check

		je succ

		lea di,query
		pop bx
		inc bx
		jmp cont_chk

	complete:
		lea si, fail
		call print
		jmp en
	succ:

		inc bx
		push  bx

		call findsect
	en:
		mov sp,bp
		popa
		ret


findsect:	; find the sector containing the given file	
	pusha
	mov bp,sp
	mov bx,[bp+18]
	cld
	mov [sect],0
	mov cl,10
	cont_st:
		;mov al,[gs:bx]
		inc bx
		cmp al,','
		jz finish
		cmp al,48
		jl mismatch
		cmp al,58
		jg mismatch
		sub al,48
		mov ah,0
		mov dx,ax
		mov ax,[sect]
		mul cl
		add ax,dx
		mov [sect],ax		
		jmp cont_st
		finish:
			push [sect]

			call load 	;load exe in memory


			jmp 0x9000:0000  ;switching to our program 

		mismatch_end:
			mov sp,bp
			popa
			ret
		mismatch:
			lea si, fail
			call print
			jmp mismatch_end

load:		;load the specified sector into RAM
	pusha
	mov bp,sp

	mov ah,0
	mov dl,0
	int 0x13

	mov ax,0x9000
	mov es,ax
	mov cl,[bp+18] 
	mov al,1
	mov bx,0
	mov dl,0 
	mov dh,0 
	mov ch,0 
	mov ah,2
	int 0x13
	jnc success
	err:
			lea si, erro
			call print
	success:
		mov sp,bp
		popa
		ret


print:	;print a zero terminated string
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


tohex:
	pusha
	mov bp,sp
	mov dx, [bp+18]

	mov cx,4
	lea si,hexc
	lea di,hex+2

	stor:

	rol dx,4
	mov bx,15
	and bx,dx
	mov al, [si+bx]
	stosb
	loop stor
	lea si, hex
	call print
	mov sp,bp
	popa
	ret


welcome db "Bem vindo ao teste OS v.0.01",10,13,0
erro db "Error loading sector",10,13,0
fail db "File not found !",0
query db 30 dup (0)
arr db 10 dup (0)
first_time db 1
nl db 10,13,0
prompt db 10,13, ">>",0
charcount dw 0

hex db "0x0000",10,13,0
hexc db "0123456789ABCDEF"
first db 0
sect dw 0