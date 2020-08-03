.286
.model tiny  
.code

org 100h

EXTERN _main:NEAR  

start PROC
			push	cs
			pop		ax
			mov		ds, ax
			mov		es, ax
            call    _main
	
	        int     20h
start ENDP


END start