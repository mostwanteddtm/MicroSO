.286
.model tiny  
.code

org 100h

EXTERN sub1:NEAR  

main PROC

	push cs
    pop ds

    call sub1
	
	int 20h
	
	mov dx, 1
    push 0800h
    push 0000h
    retf
	
main ENDP


END main