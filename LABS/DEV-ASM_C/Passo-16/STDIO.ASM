.286
.MODEL TINY,C
.STACK 100						   
 _Text SEGMENT PUBLIC USE16 
 
			PUBLIC	printf       			
.CODE 
printf 		PROC
			mov     ah, 0eh
			int     10h  
fim:    	ret  
  
printf ENDP

_Text ENDS
END