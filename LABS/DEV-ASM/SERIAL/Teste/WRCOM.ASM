.286
.MODEL TINY
.STACK 100					   
_Text SEGMENT PUBLIC USE16
.DATA

.CODE                
                
				ORG		100h
                
main: 			push	cs
				pop		ds
				push	es
				
				mov		ah, 0 						; initialize port service
				mov 	al, 0E3h 					; line settings = 9600, 8, N, 1
				xor 	dx, dx 						; port = COM1
				int 	14h 						; BIOS serial port services
				
wr:				xor		ax, ax
				int		16h
				cmp		al, 1Bh
				je		quit
				mov 	dx, 3F8h 					; data port
				out 	dx, al 						; send on serial port

				mov		ah, 0Eh
				int		10h
				jmp		wr
				
quit:			pop 	es
				int 	20h  

_Text ENDS
end main