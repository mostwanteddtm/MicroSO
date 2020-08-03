#masm#
;--------------------------------------------------------|
;                                                        |
;       Template para compilacao com MASM 6.15           |
;     Facimente testado no EMU8086 com a diretiva        |
;                       #masm#                           |
;                                                        |
;--------------------------------------------------------|  
Mensagem STRUCT
    Linha01 db "Programando em Assembly 80286 "
    Linha02 db "e aprentendo a usar STRUCT!!", 0
Mensagem ENDS

.286
.MODEL TINY
.STACK 100					   
_Text SEGMENT PUBLIC USE16 
    
        ASSUME DS:_TEXT, ES:_TEXT, SS:_TEXT
    
.DATA
	    msg      Mensagem <>             
.CODE 

ORG 100h 

.STARTUP

main:            
	    mov     si, OFFSET msg
	    mov     ah, 0eh
	
print:	  
	    mov     al, (Mensagem PTR [si]).Linha01
	    cmp     al, 0
	    je      sair    	
	    int     10h
	    inc     si
	    jmp     print
	
sair:  
        xor     ax, ax
        int     16h 
    
.EXIT
    
_Text ENDS
end main
