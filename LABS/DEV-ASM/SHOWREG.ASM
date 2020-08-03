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
.STACK 100					   
_Text SEGMENT PUBLIC USE16
.DATA
                ;API PARA EXIBIR VALORES DE REGISTRADORES              
.CODE 

ORG 100h 

main:

                mov     dx, cs
                call    SHOWREG
                
                int     20h


SHOWREG         PROC    NEAR
    
            	push    si
            	
            	mov     cx, 4
            	rol     dx, 4
            	mov     ah, 0Eh
prn:            mov     bx, OFFSET TAB
                mov     al, dl
                and     al, 00001111b
                xlat
                int     10h
                rol     dx, 4
                loop    prn
                
                pop     si
                
                ret
          
          TAB   DB      "0123456789ABCDEF" 
          
SHOWREG         ENDP
    
_Text ENDS
end main
