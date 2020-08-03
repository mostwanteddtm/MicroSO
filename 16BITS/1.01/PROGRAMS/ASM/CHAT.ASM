
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

            screenpos   dw 0 				        ; where to display next character  
            portacom    dw 0 
                
            bgread      db 01001111b 
            bgwrite     db 00111111b
            
            center      dw 0 
                
        ;HEX    BIN     COLOR
        ;0      0000    black			- preto
        ;1      0001    blue			- azul  
        ;2      0010    green			- verde
        ;3      0011    cyan			- ciano
        ;4      0100    red				- vermelho
        ;5      0101    magenta			- magenta
        ;6      0110    brown			- marrom
        ;7      0111    light gray		- cinza claro 
        ;8      1000    dark gray		- cinza escuro
        ;9      1001    light blue		- azul claro
        ;A      1010    light green		- verde claro
        ;B      1011    light cyan		- ciano claro
        ;C      1100    light red		- vermelho claro
        ;D      1101    light magenta	- magenta claro
        ;E      1110    yellow			- amarelo
        ;F      1111    white		    - branco
        ;Bit 8-5 BackGround | Bit 4-1 ForeColor

.CODE                
                ; -- a program using serial port to transfer data back and forth --
                
				ORG		100h
                
main: 			push	cs
				pop		ds

				call    clrscr 						; clear the screen

				mov		ah, 0 						; initialize port service
				mov 	al, 0E3h 					; line settings = 9600, 8, N, 1
				xor 	dx, dx 						; port = COM1
				int 	14h 						; BIOS serial port services
				
				xor 	ax, ax
				mov 	es, ax 						; point es to IVT base
				mov 	es:[0Ch*4], serial
				mov 	es:[0Ch*4+2], cs 			; hook serial port interrupt
				mov 	dx, 3FCh 					; modem control register
				in 		al, dx 						; read register
				or 		al, 8 						; enable bit 3 (OUT2)
				out 	dx, al 						; write back to register
				mov 	dx, 3F9h 					; interrupt enable register
				in 		al, dx 						; read register
				or 		al, 1 						; receiver data interrupt enable
				out 	dx, al 						; write back to register

				in 		al, 21h 					; read interrupt mask register
				and 	al, 0EFh 					; enable IRQ 4
				out 	21h, al 					; write back to register 
				
				mov     ah, 02h
				mov     dh, 0Ch
				mov     dl, 00h
				xor     bx, bx
				int     10h
				
write: 			mov  	ah, 0 						; read key service
				int  	16h 						; BIOS keybaord services
				push	ax							; save key for later use 
				
				cmp     al, 1bh
				je      quit 
				
				cmp     al, 08
				je      rwrite
				
				cmp     al, 40h
				jl      noUpperWrite
				cmp     al, 61h
				jl      noUpperWrite
				cmp     al, 7Ah
				jg      noUpperWrite

				and     al, 0DFh                    ;Convert.ToUpper(AL)
				
noUpperWrite:	mov		ah, 0Eh
				int		10h				
				
				pop 	ax 							; load saved key
				mov 	dx, 3F8h 					; data port
				out 	dx, al 						; send on serial port
				jmp 	write
				
rwrite:         mov		ah, 0Eh
				mov		al, 08h
				int		10h
				
				mov		ah, 0Eh
				mov		al, 20h
				int		10h
				
				mov		ah, 0Eh
				mov		al, 08h
				int		10h 
				jmp     write
				
quit:			mov     ax, 4E00h                   ;informo ao KERNEL.SYS pra resetar o video
				int     20h
				
;*************************************************************************************************************				

; subroutine to clear the screen
clrscr: 		push 	es
				push 	ax
				push 	cx
				push 	di
				
				mov     ah, 00h
                mov     al, 03h
                int     10h 

            	mov     ah, 06h                     ;defino a cor de fundo das mensagens recebidas
                mov     al, 00h
            	mov     ch, 00h
            	mov     cl, 00h 
            	mov     bh, bgread
            	mov     dh, 0Bh                     ;18h = 24d, numero de linhas do video
            	mov     dl, 4fh                     ;4fh = 84d, numero de colunas
            	int     10h 
            	
            	mov     ah, 06h                     ;defino a cor de fundo das mensagens digitadas
                mov     al, 00h
            	mov     ch, 0Ch
            	mov     cl, 00h 
            	mov     bh, bgwrite
            	mov     dh, 18h                     ;18h = 24d, numero de linhas do video
            	mov     dl, 4fh                     ;4fh = 84d, numero de colunas
            	int     10h 
                
				pop		di
				pop		cx
				pop		ax
				pop		es
				ret
				
serial:			push	ax
				push	bx
				push	dx
				push	es
				
				mov 	dx, 3FAh 					; interrupt identification register
				in 		al, dx 						; read register
				and 	al, 0Fh 					; leave lowerniblle only
				cmp 	al, 4 						; is receiver data available
				jne 	skipall 					; no, leave interrupt handler
				mov 	dx, 3F8h 					; data register
				in 		al, dx 						; read character
				
				cmp     al, 08                      ; se for backspace retorna o cursor
				jne     noBack
				mov     al, 0 
				sub 	cs:[screenpos], 2                   
				
noBack:		    cmp     al, 13                      ; pressionou enter, avanco a linha
                jne     noEnter
                xor     ax, ax
                inc     cs:[center]                 ; a cada enter somo + 1
                mov     ax, 160                     ; 160 bytes por linha (80 caracteres)
                mul     cs:[center]                 ; quantidade de enters * 160 bytes por linha
                mov     cs:[screenpos], ax          ; pula linha
                mov     al, 0
                
noEnter:        mov 	dx, 0B800h
				mov 	es, dx 						; point es to video memory
				mov 	bx, cs:[screenpos]			; get current screen position 
				mov     ah, cs:[bgread]             
				
        		cmp     al, 40h                     ;valido se precisa converter para maiusculo
				jl      noUpperRead
				cmp     al, 61h
				jl      noUpperRead
				cmp     al, 7Ah
				jg      noUpperRead 

				and     al, 0DFh                    ;Convert.ToUpper(AL)
				
noUpperRead:	mov 	es:[bx], ax 				; write character on screen 

                cmp     al, 0
                je      noUpdateCur
				add 	cs:[screenpos], 2  			; update screen position
				
noUpdateCur:	cmp 	cs:[screenpos], 4000		; is the screen full
				jne 	skipall 					; no, leave interrupt handler
				call 	clrscr 						; clear the screen
				mov  	cs:[screenpos], 0 				; reset screen position 
				
skipall: 		cmp     cs:[screenpos], 0
                jge     cskipall
                mov     cs:[screenpos], 0
                mov     cs:[center], 0
                
cskipall:       mov 	al, 20h
				out 	20h, al 					; end of interrupt
				
				pop		es
				pop		dx
				pop		bx
				pop		ax
				iret

;************************************************************************************************************* 

_Text ENDS
end main
