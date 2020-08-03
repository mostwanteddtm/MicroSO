;CLASSE
.MODEL TINY
.CODE
external_function   PROC C  arg1:SWORD
                    
                    mov     si, arg1
                    mov     ah, 0Eh
cfunc:              lodsb
                    cmp     al, 0
                    je      efunc 
                    int     10h
                    jmp     cfunc
                    
efunc:              ret                                        
                        

external_function   ENDP

END