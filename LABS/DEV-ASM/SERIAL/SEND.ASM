;*******************************************************************************************************************************************|
;                                                        								                                                    |
;       				                          Template para compilacao com MASM 6.15           				                            |
;     				                           Facimente testado no EMU8086 com a diretiva        				                            |
;                       			                            #masm#                           			                                |
;                                                        								                                                    |
;*******************************************************************************************************************************************|  

.286
.MODEL TINY					   
_TEXT SEGMENT PUBLIC USE16

				COM1 	EQU	3f8h 	; COM1 base address
				COM2 	EQU	2f8h 	; COM2 base address
				IER 	EQU	3f9h 	; COM1 Interrupt Enable Register
				MCR 	EQU	3fch 	; COM1 Modem Control Register
				LCR 	EQU	3fbh 	; COM1 Line Control Register
				LSR 	EQU	3fdh 	; COM1 Line Status Register
				MSR 	EQU	3feh 	; COM1 Modem Status Register

.DATA 

				; DATA SECTION 
		        
.CODE 

ORG 100h 

;============================================================================================================================================

start:
				push    cs
                pop     ds

                call	rs232_init	; Work on Microsoft Windows 95/98/ME and MS-DOS 
				;call	int14h		; Work Only MS-DOS
							
cont:			xor     ax, ax
				int     16h
				
				cmp     al, 1Bh
				je      sair 
				
				mov 	dx, 03F8h 	; data port
				out 	dx, al 		; send on serial port 
				
				mov     ah, 0Eh
				int     10h 
				jmp     cont
				
sair:			int     20h
				

int14h:			mov		ah, 0 		; initialize port service
				mov 	al, 0E3h 	; line settings = 9600, 8, N, 1
				xor 	dx, dx 		; port = COM1
				int 	14h 		; BIOS serial port services 
				ret
				
				
rs232_init:							; initialize port service		
				mov 	dx, LCR 	; Select the Line Control Register to set up the comm. parameters.
				mov 	al, 80h 	; Bit7 = 1, 3f8h & 3f9h registers can access the baud rate divisor.
				out 	dx, al 		; Nominal baud rate = 1843200/(baud rate*16).
									;
				mov 	dx, COM1 	;
				mov 	al, 0Ch 	; b7 - b0 = (60h) = (01100000b) -> 3f8h (baud rate low-byte)
				out 	dx, al 		; 
									
				mov 	dx, IER 	;
				mov 	al, 00h 	; b7 - b0 = (00h) = (00000000b) -> 3f 9h (baud rate high-byte)
				out 	dx, al 		; Set up the baud rate high & low bytes (000Ch -> 9600 baud rate).
									
				mov 	dx, LCR 	; Finish set up the Line Controller Register.
				mov 	al, 0bh 	; b7 - b0 = 0bh = (00001011b) -> odd parity, 1 stop bit, 8 data bits.
				out 	dx, al 		; Set up LCR based on the above control parameters.
									
				mov 	dx, MCR 	; Set up Modem Control Register to set DTR & RTS to 1 (space or active).
				mov 	al, 03h 	; Self-test sub. if this line becomes "mov al,13h".
				out 	dx, al 		; Finish set up the MCR.
									
				mov 	dx, IER 	; Set up the Interrupt Enable Register.
				mov 	al, 0 		; No interrupt utilized.
				out 	dx, al
				ret	                                

;============================================================================================================================================
    
_TEXT ENDS
END start