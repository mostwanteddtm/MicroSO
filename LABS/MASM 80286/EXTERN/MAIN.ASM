.286
.model tiny   
.data
    text db "Usando Extern e Public, com MASM!!",0

.code

org 100h

EXTERN sub1:NEAR  

main PROC

    mov     si, OFFSET text
    call    sub1
	
	int 20h
	
main ENDP


END main