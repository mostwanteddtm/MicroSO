; a program using serial port to transfer data back and forth
                ORG     100h 
                
                jmp     start 
                
portacom        dw      0
                
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
				
				mov     ah, 0Eh
				int     10h
				
skipall:		mov 	al, 20h
				out 	20h, al 					; end of interrupt
				
				pop		es
				pop		dx
				pop		bx
				pop		ax
				iret

start: 			push    cs
                pop     ds
                push    es

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
				
main: 			mov  	ah, 0 						; read key service
				int  	16h 						; BIOS keybaord services
				push	ax							; save key for later use 
				
				cmp     al, 1bh
				je      quit 
				
				mov     ah, 0Eh
				int     10h
				
				pop 	ax 							; load saved key
				mov 	dx, 3F8h 					; data port
				out 	dx, al 						; send on serial port  
				
				jmp 	main
				
quit:
                pop     es
                int     20h