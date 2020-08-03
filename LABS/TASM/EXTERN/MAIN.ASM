.286
.model tiny   
.data
    text db "Extern e Public usando TASM !!",13,10,0

.code

org 100h

EXTRN print:NEAR  

main PROC

    mov     si, OFFSET text
    call    print
	
	int 20h
	
main ENDP


END main