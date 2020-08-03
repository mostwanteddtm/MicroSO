;--------------------------------------------------------|
;                                                        |
;       Template para compilacao com MASM 6.15           |
;     Facimente testado no EMU8086 com a diretiva        |
;                       #masm#                           |
;                                                        |
;--------------------------------------------------------|  

.286
.model tiny
.STACK 100					   
_Text SEGMENT PUBLIC USE16
.data
            msg     db 'Hello World!!', 0              
.code 

org 100h 

main:
            mov     si, OFFSET msg
            mov     ah, 0Eh
cmsg:       lodsb    
            cmp     al, 0
            je      fim
            int     10h
            jmp     cmsg 
            
fim:        xor     ax, ax
            int     16h
            
            int     20h
    
_Text ENDS
end main