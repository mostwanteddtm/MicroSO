.286
.model tiny  
.code

org 100h

EXTERN sub1:NEAR  

main PROC

	push cs
    pop ds

    call sub1
    xor  ax, ax
    int  16h
	
	int 20h
	
	mov dx, 1
    push 0800h
    push 0000h
    retf
	
main ENDP


END main