.286
.MODEL TINY,C
.STACK 100						   
 _Text SEGMENT PUBLIC USE16 
 
			PUBLIC	_putch
			PUBLIC 	_strcpy
			
.CODE 
_putch 		PROC

			mov     ah, 0eh
			int     10h
        
fim:    	ret    
     
_putch ENDP

_strcpy		PROC

			push    si
			push    ax
			mov     si, [bp-8]
			mov     cx, 0
cont:   	lodsb
			inc     cx
			cmp     al, 0
			je      ccount
			jmp     cont
        
ccount: 	pop     ax
			pop     si        

			mov		si, [bp-8]
			mov		di, [bp-0Ah]
			rep 	movsb
			
			ret
			
_strcpy		ENDP

_Text ENDS
END