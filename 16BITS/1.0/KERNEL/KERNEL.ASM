.286
.model Tiny

extern _KernelMain:near 

.code

org 0h
        
main:

    push cs
    pop ds
    
    call _KernelMain 
    
End main
    
    