INCLUDE BASE.INC
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

.DATA 

        message							BYTE		'Templates desenvolvido em 20', 0 
		        
.CODE 									

ORG 100h

                                        EXTERN      __putch:NEAR
										EXTERN		__putstr:NEAR

;============================================================================================================================================

start:	                                ;secao de codigo                              Aqui pode-se colocar todos os comentarios
										push		OFFSET message
										call		__putstr
										SOMA		17h, 1Ah						; MACRO: SOMA 17h + 1Ah = 31h -> ASCII 1
										call		__putch
										SOMA		1Eh, 19h
										call		__putch
										mov			al, BYTE PTR CR
		                                int         20h

;============================================================================================================================================
    
_TEXT ENDS
END start
