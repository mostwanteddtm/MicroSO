.286
.model tiny,c
.stack 100						   
 _Text SEGMENT PUBLIC USE16 
 
			PUBLIC	print   
			PUBLIC	getchar
			
			calcular PROTO C a:SBYTE, b:SBYTE
			strcompare PROTO C str1:SBYTE, str2:SBYTE, lenStr:SBYTE
			
.code 
print 		PROC

			mov     ah, 0eh
cont:   	lodsb
			cmp     al, 0
			je		fim
			int     10h
			jmp     cont
        
fim:    	ret    
     
print ENDP

getchar		PROC

			xor		ax, ax
			int		16h
			cmp		al, 0Dh
			je		zgetchar
			cmp		al, 27
			je		fimgetchar
			mov		ah, 0eh
			int 	10h
			jmp		fimgetchar
			
zgetchar:	mov		si, 0
			
fimgetchar:	ret
			
getchar		ENDP

calcular 	PROC 	C a:SBYTE, b:SBYTE

			mov     ah, a
			mov     al, b
			add		al, ah
			add		al, 30h
			mov		ah, 0eh
			int 	10h
			
			ret    
     
calcular	ENDP

strcompare	PROC	C str1:SBYTE, str2:SBYTE, lenStr:SBYTE

			mov 	di, [bp+4]
			mov 	si, [bp+6]
			mov		cx, [bp+8]
			mov		ch, 0
			repe cmpsb 
			je  	igual
			mov 	al, 0
			jmp 	fimcmp
igual:  	mov 	al, 1

fimcmp:		xor 	si, si
			xor 	di, di
			pop 	bp
			ret

strcompare 	ENDP

END