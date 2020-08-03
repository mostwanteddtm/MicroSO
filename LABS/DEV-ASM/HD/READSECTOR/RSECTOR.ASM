;*******************************************************************************************************************************************|
;                                                        								                                                    |
;       				                          Template para compilacao com MASM 6.15           				                            |
;     				                           Facimente testado no EMU8086 com a diretiva        				                            |
;                       			                            #masm#                                                                      |
;                                                                                                                                           |
;                                   EXECUTA A LEITURA DE UM SETOR DO HD ATA, USANDO A TECNOLOGIA PIO                           			    |
;                                                        								                                                    |
;*******************************************************************************************************************************************|  

.286
.MODEL TINY					   
_TEXT SEGMENT PUBLIC USE16
.DATA 

        ;secao de dados
        buffer                          DB			512 DUP(0)
		tabconvert      				DB  		'0123456789ABCDEF'
		count							DW			0
		        
.CODE 

ORG 100h 

;============================================================================================================================================

start:	                                ;secao de codigo                              Aqui pode-se colocar todos os comentarios

										push    	cs
										pop     	ds
										mov 		di, OFFSET buffer
										mov			bx, 0
 
ata_chs_read:   						mov 		dx, 1f2h            			; Sector count port
										mov 		al, 1               			; Read CH sectors
										out 		dx, al				              
						                                                              
										mov 		dx, 1f3h            			; Sector number port
										mov 		al, 0               			; BL is sector index
										out 		dx, al				              
						                                                              
										mov 		dx, 1f4h            			; Cylinder low port
										out 		dx, al				              
												                                      
										mov 		dx, 1f5h            			; Cylinder high port
										out 		dx, al				              
						                                                              
										mov			dx, 1f6h				          
										mov			al, 0000000011100000b			; aqui seleciona o drive master / slave				          
										out 		dx, al				            ; 0f0h ou 0000000011110000b para slave  
						                                                              
										mov 		dx, 1f7h            			; Command port
										mov 		al, 20h             			; Read with retry.
										out 		dx, al 
										in  		al, dx							; aqui comecaria o codigo comentado abaixo
				
@@:	        							mov			dx, 1f7h 
										in			al, dx 
										cmp			al, 58h 
										jnz			@b 
 
																					; read data    
										mov     	cx, 256     
										mov     	dx, 1f0h                 
@@:             						in      	ax, dx 
										mov     	[di+bx], ax 
										add     	bx, 2 
										loop    	@b								; aqui terminaria o codigo comentado abaixo

 
;still_going:    						in 			al, dx
;                						test 		al, 8               			; the sector buffer requires servicing.
;                						jz 			still_going         			; until the sector buffer is ready.
; 									
;                						mov 		ax, 512/2           			; to read 256 words = 1 sector
;                						xor 		bx, bx			
;                						mov 		bl, ch              			; read CH sectors
;                						mul 		bx			
;                						mov 		cx, ax              			; RCX is counter for INSW
;                						mov 		dx, 1f0h            			; Data port, in and out
;                						rep 		insw                			; in to [DI]                
                
										mov     	si, OFFSET buffer
										mov     	bx, OFFSET tabconvert 
										mov     	ah, 0Eh 
										mov     	cx, 512
										call    	showvalue

		                                int         20h

;============================================================================================================================================ 

showvalue           					PROC    	NEAR
                	
svalue::            					mov     	al, [si] 
										rol     	al, 4
										and     	al, 00001111b
										xlat	
										int     	10h
											
										mov     	al, [si]
										and     	al, 00001111b
										xlat	
										int     	10h 
											
										add     	count, 3
										cmp     	count, 80
										jge     	nextline 
											
										mov     	al, 20h
										int     	10h
											
										inc     	si 
											
										loop    	svalue 
					
										ret
										
showvalue           					ENDP

;============================================================================================================================================            		
            		
prn                 					PROC    	NEAR
											
										lodsb	
										cmp     	al, 0
										je      	fprn
										mov     	ah, 0Eh
										int     	10h
										jmp     	prn
										
fprn:               					ret 
					
prn                 					ENDP 

;============================================================================================================================================ 

nextline:           					mov     	count, byte ptr 0 
										inc     	si
					
										jmp     	svalue
    
_TEXT ENDS
END start
