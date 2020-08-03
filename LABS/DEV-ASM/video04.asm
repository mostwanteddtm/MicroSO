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

main:
            
		MOV     AH,0        ;Set mode function.
    	MOV     AL,03H      ;mode 4
    	INT     10H
    	MOV     AH,0BH      ;set background/palette function.
    	MOV     BH,1        ;palette
    	MOV     BL,1        ;palette 1
    	INT     10H
    	MOV     BH,0        ;background
    	MOV     BL,2        ;green
    	INT     10H
    	
    	XOR     AX, AX
    	INT     16H
    	
    	INT     20H
    
_TEXT ENDS
END main
