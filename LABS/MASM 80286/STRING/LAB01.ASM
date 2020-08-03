
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
    assume ds:_TEXT, es:_TEXT
.data
                msg     db "Iniciando desenvolvimento no Intel 80286, com o MASM 6.15!!", 0              
.code 

org 100h 

main:
                mov     si, OFFSET msg 
                mov     ah, 0Eh
            @@:
                lodsb
                or      al, al
                cmp     al, 0
                je      @F
                int     10h
                jmp     @B
            @@:
			
				xor		ax, ax
				int		16h
                int     20h            
    
_Text ENDS
end main
