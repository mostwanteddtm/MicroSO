.286
.MODEL TINY
.STACK 100					   
_Text SEGMENT PUBLIC USE16
.DATA
                msg     db 'A qualquer momento, pressione uma tecla para sair...', 0Ah, 0Dh, 0
.CODE                
                
				ORG		100h
                
main: 			push	cs
				pop		ds
				push	es 
				
				mov		ah, 0 				; initialize port service
				mov 	al, 0E3h 			; line settings = 9600, 8, N, 1
				xor 	dx, dx 				; port = COM1
				int 	14h 				; BIOS serial port services
                
                mov     si, OFFSET msg   
                call    printf
                				
repet:			mov     cx, 03h
				mov     dx, 1220h
				mov     ah, 86h
				int     15h	

                mov     dx, 3FDh            ;set up status port address
                in      al, dx              ;read UART status
                test    al,1                ;has a character been received?
                jnz     read                ;yes, go get it
				
				mov		ah, 01h
				int		16h
				jnz		quit
				jmp		repet

read:           mov     dx, 3F8h            ;set up data port address
                in      al, dx              ;read UART receiver   
                mov		ah, 0Eh
				int 	10h
				jmp     repet
				
quit:			pop 	es
				int 	20h

printf:         mov     al, [si]  
                cmp     al, 0
                je      sprintf
                mov     ah, 0Eh
                int     10h
                inc     si 
                jmp     printf
sprintf:        ret
                         				
				_Text ENDS
end main