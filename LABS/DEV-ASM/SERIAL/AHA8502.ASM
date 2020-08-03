#masm#
;Serial communications port interupt intercepter   AHA 8502.27
;
;	Functions:
;	al=0 then Disable communications interupt vector
;	al=1 then Enable communications interupt vector
;	Issue and int 44h
;
progseg segment para public 'CODE'
	public	setcom
	assume	cs:progseg, ds:progseg, es:progseg
	org	100h
doscall equ	21h
;
startup proc	far
	jmp	setup
;
setcom	proc	far
	push	ds
	push	es
	push	dx
	push	ax
	mov	ax,cs
	mov	ds,ax
	mov	es,ax
	pop	ax
	cmp	al,1		;is function 1
	jz	enable		;then enable
;
disable:
	mov	dx,offset interupt ;get new vector address
	mov	ax,cs
	mov	ds,ax		;set segment
	mov	ah,25h		;set interupt vector address function
	mov	al,14h		;communications interupt vector
	int	doscall 	;set the interupt
	jmp	exit		;exit
enable:
	mov	dx,word ptr vector	 ;set old segment 
	mov	ds,word ptr vector+2	    ;set old communications vector
	mov	ah,25h		;set interupt vector address function
	mov	al,14h		;communications interupt vector
	int	doscall
exit:
	pop	dx
	pop	es
	pop	ds
;
interupt       proc    far
	sub	ax,ax		;zero return status
	iret
interupt       endp
setcom	endp
;
msg	db	'Serial communications intercepter installed',0ah,0dh,'$'
msg1	db	'Serial communications intercepter is already installed',0ah,0dh,'$'
vector	db	8 dup(0)	;only 4 needed 4 more for safety
;
setup:
	mov	ah,35h		;get interupt vector address function
	mov	al,44h		;communications interupt vector
	int	doscall 	;go get it
	cmp	bx,0		;check if vector used
	jnz	lderr		;if used then exit
	mov	ax,es		;check segment
	cmp	ax,0
	jnz	lderr
;
	mov	dx,offset msg
	mov	ah,9
	int	doscall
;
	mov	ah,35h		;get interupt vector address function
	mov	al,14h		;communications interupt vector
	int	doscall 	;go get it
;
	mov	word ptr vector,bx	 ;save offset
	mov	bx,es		;get segment address
	mov	word ptr vector+2,bx	 ;save segment
;
	mov	dx,offset setcom ;get new vector address
	mov	ax,cs
	mov	ds,ax		;set segment
	mov	ah,25h		;set interupt vector address function
	mov	al,44h		;set to our new interupt vector
	int	doscall 	;set the interupt
;
	mov	dx,offset setup ;terminate and stay resident
	int	27h
lderr:
	mov	dx,offset msg1
	mov	ah,9
	int	doscall
	int	20h
startup endp
progseg ends
;
	end	startup