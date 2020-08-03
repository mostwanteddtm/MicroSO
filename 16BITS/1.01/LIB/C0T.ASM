.286
.model tiny  
.code

org 100h

EXTERN 		_main:NEAR
PUBLIC 	    __acrtused		    ; trick to force in startup
	        __acrtused = 9876h	; funny value not easily matched in SYMDEB  

start PROC
            push    cs
            pop     ax
            mov     ds, ax
            mov     es, ax
            call    _main
	
	        int     20h
start ENDP

END start