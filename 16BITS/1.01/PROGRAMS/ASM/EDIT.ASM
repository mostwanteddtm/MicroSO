include DEFINIRCORES.INC

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

    curX        db 00h
    curY        db 00h 
    
    CorFundo    db 0Fh
    CorFonte    db 00h
    
    msgFundo    db "Selecione o VALOR para cor de fundo que deseja usar: ", 0h
    msgFonte    db "Selecione o VALOR para cor de fonte que deseja usar: ", 0h
    
    Colors      db "VALOR    COR           ", 0Ah, 0Dh
                db "0        PRETO         ", 0Ah, 0Dh
                db "1        AZUL          ", 0Ah, 0Dh
                db "2        VERDE         ", 0Ah, 0Dh        
                db "3        CIANO         ", 0Ah, 0Dh
                db "4        VERMELHO      ", 0Ah, 0Dh
                db "5        MAGENTA       ", 0Ah, 0Dh
                db "6        MARRON        ", 0Ah, 0Dh
                db "7        CINZA CLARO   ", 0Ah, 0Dh
                db "8        CINZA ESCURO  ", 0Ah, 0Dh
                db "9        AZUL CLARO    ", 0Ah, 0Dh
                db "A        VERDE CLARO   ", 0Ah, 0Dh
                db "B        CIANO CLARO   ", 0Ah, 0Dh
                db "C        VERMELHO CLARO", 0Ah, 0Dh
                db "D        MAGENTA CLARO ", 0Ah, 0Dh
                db "E        AMARELO       ", 0Ah, 0Dh
                db "F        BRANCO        ", 0Ah, 0Dh, 0h                
.CODE 

ORG 100h 

main: 
                push        cs
                pop         ds
                
            	mov         ah, 00h
                mov         al, 03h
                int         10h
            
                mov         ah, 02h
                mov         dh, 0Ah
            	mov         dl, 00h
            	mov         bh, 00h
            	int         10h
	                    
            	mov         si, offset Colors
whileColors:    lodsb
        	    cmp         al, 0h
        	    je          SairColors
        	    mov         ah, 0eh
        	    int         10h
            	jmp         whileColors
            	
            	SairColors:

                SelecionarCores 
    
                mov         ah, 02h
                mov         dh, 00h
            	mov         dl, 00h
            	mov         bh, 00h
            	int         10h
	
cont:           mov         ah, 00h
                int         16h
        
                cmp         al, 1Bh
                je          fim
        
                cmp         al, 08h
                je          back 
                cmp         al, 13
                je          addLinha
                jge         avancaCursor
        
                                                ;ah armazena o keyboard scan code (seta para direita) 
                                                ;buffer do teclado esta em segment 0h, offset 1054h (41E hex)
                cmp         ah, 4dh             ;seta para direita
                je          vseta
                cmp         ah, 4bh             ;seta para esquerda
                je          vseta 
                
continue:       mov         ah, 0Eh
                int         10h
                jmp         cont
    
back:           dec         curY 
                mov         ah, 0eh
                mov         al, 08h
                int         10h		            ;backspace on the screen
                
                mov         al, 20h
                int         10h		            ;blank character out
                
                mov         al, 08h
                int         10h                 ;backspace
                
                jmp         cont  
 
    
vseta:          cmp         ah, 4dh             ;seta para direita
                je          addCur
                cmp         ah, 4bh             ;seta para esquerda
                je          removeCur  
                  
return:         mov         dl, curY
                mov         dh, curX
                mov         bh, 00h
                mov         ah, 02h
                int         10h 
                jmp         cont


avancaCursor:   inc         curY 
                jmp         continue
         
    
addCur:         inc         curY
                jmp         return 
        
    
removeCur:      dec         curY
                jmp         return

    
addLinha:       inc         curX
                mov         curY, 0
                jmp         return 
    
fim:            mov         ax, 4E00h           ;informo ao KERNEL.SYS que o video deve ser resetado
                int         20h
    
_Text ENDS
end main
