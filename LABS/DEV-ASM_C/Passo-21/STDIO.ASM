.286
.MODEL TINY,C
.STACK 100						   
 _Text SEGMENT PUBLIC USE16 
 
			PUBLIC	_putch
			
.CODE 
_putch 		PROC

			mov     ah, 0eh
			int     10h
        
fim:    	ret    
     
_putch ENDP

_Text ENDS
END