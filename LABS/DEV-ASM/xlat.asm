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
		    tabconvert      DB  '0123456789ABCDEF' 
		    buffer          DB  0EFh, 9Ah         
.CODE 

ORG 100h 

start:	            mov     si, OFFSET buffer
                    mov     bx, OFFSET tabconvert 
                    mov     ah, 0Eh 
                    mov     cx, SIZEOF buffer
                    
svalue:             mov     al, [si] 
                    rol     al, 4
                    and     al, 00001111b
                    xlat
                    int     10h
                    
                    mov     al, [si]
                    and     al, 00001111b
                    xlat
                    int     10h
                    
                    mov     al, 20h
                    int     10h
                    
                    inc     si
                    loop    svalue 
                    
		            int		20h
    
_TEXT ENDS
END start
