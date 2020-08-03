;-------------------------------------------------------------------------------|
;   Copyright Marcos Roberto da Costa - 03 de Outubro de 2015                   |
;   Kernel 1.02 - Compilado Com MASM                                            |
;-------------------------------------------------------------------------------| 

.286
.model tiny  
.code

org 0h

EXTERN      _print:NEAR 
EXTERN      _loadFile:NEAR 

main PROC

	        push    cs
            pop     ds
            
            mov     dx, OFFSET copyright
            push    dx
            call    _print
            
            mov     dx, OFFSET command
            push    dx
            call    _loadFile
        
            push    0070h
            push    0100h
            retf
    
copyright   db      "Copyright MicroSO 1.02 by Marcos R. Costa - 13 de outubro de 2015", 0Dh, 0Ah, 0Dh, 0Ah, 0
command     db      "COMMAND COM"
	
main ENDP


END main