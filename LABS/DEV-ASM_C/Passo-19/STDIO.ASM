.286
.MODEL TINY,C
.STACK 100						   
 _Text SEGMENT PUBLIC USE16 
 
			PUBLIC	_printf
			
.CODE 
_printf 		PROC
		
			mov		si, [bp+4]
			mov     ah, 0eh
			
cont:   	lodsb
			cmp     al, 0
			je		fim
			int     10h
			dec		cx
			jmp    	cont
        
fim:    	ret    
     
_printf ENDP

_Text ENDS
END