.286
.model tiny  
.code

org 100h

EXTERN _main:NEAR  

start PROC

            call    _main
	
	        int     20h
start ENDP


END start