.286
.MODEL TINY
.STACK 100h

.DATA
	curPosX db 0 
	curPosY db 24 
	columns equ 80

.CODE

ORG 100h

.STARTUP

	mov	ax, 3
	int 10h
	
	;position = (row*80) + col; 
	;BX will contain 'position' 

	mov	bl, curPosY
	mov	bh, curPosX
	mov ax, bx
	and ax, 0FFh
	mov cl, columns
	mul cl
	mov cx, bx
	shr cx, 8
	add ax, cx
	mov cx, ax
 
	; cursor low port to VGA index register
	mov al, 0Fh
	mov dx, 3D4h
	out dx, al
 
	; cursor low position to VGA data register
	mov ax, cx
	mov dx, 3D5h
	out dx, al
 
	; cursor high port to VGA index register
	mov al, 0Eh
	mov dx, 3D4h
	out dx, al
 
	; cursor high position to VGA data register
	mov ax, cx
	shr ax, 8
	mov dx, 3D5h
	out dx, al
	
	xor ax, ax
	int 16h

	mov	ah, 4ch
	int	20h
	
END