.286
.model tiny,c						   
 _Text SEGMENT PUBLIC USE16 
    PUBLIC print
.code 
print PROC
			push    bp
			mov     bp, sp 
			mov     si, [bp+4]
			pop     bp
			
continue:	lodsb
            cmp     al, 00h
            je      sair
            mov		ah, 0eh
			int		10h
			jmp     continue
sair:
			ret
     
print ENDP

END