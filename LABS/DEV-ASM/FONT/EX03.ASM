org 100h

push	ds			        ;
	pop	es			        ; make sure ES = DS
	mov	bp,offset OurFont	;
	mov	cx,02			    ; we'll change just 2 of them
	mov	dx,65			    ;   A and B --> our A and B
	mov	bh,14			    ; 14 bytes per char
	xor	bl,bl			    ; RAM block
	mov	ax,1100h		    ; change font to our font
	int	10h			        ; video interrupt
	mov	ax,4C00h		    ; exit to DOS
	int	21h			        ;

OurFont	
    db	00000000b
	db	01111111b
	db	01100011b
	db	01100011b
	db	01100011b
	db	01111111b
	db	01100011b
	db	01100011b
	db	01100011b
	db	01100011b
	db	01100011b
	db	01100011b
	db	00000000b
	db	00000000b

	db	00000000b
	db	01111110b
	db	01100110b
	db	01100110b
	db	01100110b
	db	01111111b
	db	01100011b
	db	01100011b
	db	01100011b
	db	01100011b
	db	01100011b
	db	01111111b
	db	00000000b
	db	00000000b