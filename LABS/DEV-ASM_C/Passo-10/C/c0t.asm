.286
.model tiny  
.code

org 100h

EXTERN _main:NEAR  

start PROC

	push cs
    pop ds

    call _main
	
	int 20h
	
	mov dx, 1
    push 0800h
    push 0000h
    retf
	
start ENDP


END start