.286
.MODEL TINY,C
.STACK 100						   
 _Text SEGMENT PUBLIC USE16 
 
			_printf PROTO C arg_0:SBYTE,arg_1:SWORD
			valor 	DB 5 dup (0)  
			decimal DW 10
			
.CODE  

;===================================================================================
 
_printf 	PROC 	C arg_0:SBYTE,arg_1:SWORD
		
			mov		dl, [arg_0]
			mov		dh, [arg_0+1]
			mov		si, dx
			call	print
			mov		ax, arg_1
			call	hextodec
    
			ret
     
_printf 	ENDP

;====================================================================================

print		PROC 

			mov     ah, 0Eh
cprintf:	lodsb
			cmp		al, 0
			je		fprintf
			int     10h
			jmp		cprintf
			        
fprintf:    ret

print		ENDP

;====================================================================================

hextodec	PROC
    
			xor 	bx, bx
    
cconv:		xor 	dx, dx
			div 	[decimal]
			add 	dl, 30h 
			mov 	[valor+bx], dl
			inc 	bx
			cmp 	al, 9
			ja 		cconv
     
			xor 	dx, dx
			xchg 	dl, al
			add 	dl, 30h 
			mov 	[valor+bx], dl 
			mov 	cx, bx 
			inc 	cx
   
			mov 	si, offset valor
			add 	si, bx
			
decprint:	mov 	ah, 0eh
			mov 	al, [si]
			int 	10h
			dec 	si
			loop 	decprint
			
			ret

hextodec	ENDP  

;====================================================================================

_Text ENDS
END
