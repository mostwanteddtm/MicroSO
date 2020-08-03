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
	    dados       BYTE "O Valor contido na variavel, sera zerado!"             
.CODE 

ORG 100h 

main:
            
		cld
		mov         di, offset dados
		mov         cx, (SIZEOF dados)
		mov         al, 0
		rep         stosb
		int         20h
    
_TEXT ENDS
END main
