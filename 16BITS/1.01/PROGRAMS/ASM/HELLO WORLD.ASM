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
            helloWorld  BYTE "Hello World, escrito em Assembly x86 e compilado com o MASM 6.15!!", 0              
.CODE 

ORG 100h 

main:       

            push        cs
            pop         ds
            
            mov         si, OFFSET helloWorld
    print:  lodsb
            cmp         al, 0
            je          fim
            mov         ah, 0Eh
            int         10h
            jmp         print
            
            
      fim:  int         20h
    
_Text ENDS
end main
