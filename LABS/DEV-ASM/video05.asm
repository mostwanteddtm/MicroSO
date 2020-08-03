#masm#
;--------------------------------------------------------|
;                                                        |
;       Template para compilacao com MASM 6.15           |
;     Facimente testado no EMU8086 com a diretiva        |
;                       #masm#                           |
;                                                        |
;--------------------------------------------------------|  

.286
.MODEL TINY
.STACK					   
_TEXT SEGMENT PUBLIC USE16
.DATA
	            cor     DB      00h         
.CODE 

ORG 100h 

main:  
                        push    cs
                        pop     ds
                        
                        push    es
                        
                        mov     ah, 00h
                        mov     al, 13h
                        int     10h
                            
                		xor     ax, ax
                		mov     cx, 0FFFFh
		
cont:                   mov     ah, 01
                        int     16h
                
                        cmp     al, 27
                        je      sair 
                
                        push    cx
                
                        and     cx, 0001h
                        jnz     par
                        mov     cor, 00h
                        jmp     impar
par:                    mov     cor, 0Fh
            
impar:                  call    blinking

                        mov     cx, 01h
                        mov     dx, 320h
                        mov     ah, 86h
                        int     15h
                
                        pop     cx
                
                        loop    cont
        
sair:                   pop     es
                        int     20h 

blinking:               mov     ax, 0A000h
                        mov     es, ax
                        xor     ax, ax
                        mov     al, cor
                        mov     di, 1600
            
lblink:                 mov     es:[di], al
                        inc     di
                        cmp     di, 1608
                        je      sblink
                        jmp     lblink
            
sblink:                 ret 
    
_TEXT ENDS
END main
