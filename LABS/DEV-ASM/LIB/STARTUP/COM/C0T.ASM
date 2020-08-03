.286
.MODEL TINY

INCLUDE COMMON.INC

.CODE

ORG 100h

EXTERN _main:NEAR

PUBLIC 	    __acrtused		    ; trick to force in startup
	        __acrtused = 9876h	; funny value not easily matched in SYMDEB

start PROC
            push        cs 
            pop         ds
            call        _main
	        int         20h
start ENDP

END start