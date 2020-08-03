.286
.MODEL TINY,C
.STACK 100						   
 _Text SEGMENT PUBLIC USE16 
 
			PUBLIC	printf
			PUBLIC  _acrtused
			
.CODE 
printf 		PROC
		
			mov		si, [bp-0Ah]
			mov     ah, 0eh
			
cont:   	lodsb
			cmp     al, 0
			je		fim
			int     10h
			dec		cx
			jmp    	cont
        
fim:    	ret    
     
printf ENDP

_acrtused	PROC

			ret
			
_acrtused	ENDP

END