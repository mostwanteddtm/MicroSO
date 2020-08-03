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
	;seção de dados             
.CODE 

ORG 100h 

main:   mov     cx, 5   
        mov     ax, offset [fase2]
        mov     si, ax 
        mov     ax, 0800h
        mov     es, ax
        mov     ax, 00FFh
        mov     di, ax 
        mov     byte ptr es:[di], 41h
        inc     di
        rep     movsb
        push    es
        push    0100h
        retf
        
        fase2:    
		mov     al, 41h
		int     20h     
    
_TEXT ENDS
END main
