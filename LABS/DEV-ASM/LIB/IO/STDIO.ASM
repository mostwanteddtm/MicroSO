.286

INCLUDE COMMON.INC

.MODEL TINY,C
.STACK 100						   
 _Text SEGMENT PUBLIC USE16 
 
			PUBLIC print  
			
.CODE 

print 		PROC

			mov		al, PE
			cmp		al, 0
			jne		IPE				;is portable executable
			mov		si, [bp+4]
IPE:		mov     ah, 0eh
cont:   	lodsb
			cmp     al, 0
			je		fim
			int     10h
			jmp     cont
        
fim:    	ret    
     
print ENDP

END