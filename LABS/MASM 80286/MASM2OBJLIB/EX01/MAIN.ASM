.286
.model tiny  
.code

org 100h

EXTERN printf:NEAR  

main:

	push cs
    pop ds

    call printf
	
	int 20h
	
END main