
INCLUDE PUBLIC.INC
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

        message                         DB          'Utilizando Invoke, com o Mircosoft Macro Assembly 6.15!!', 0            
		        
.CODE 

ORG 100h 

;============================================================================================================================================

start:	                                ;secao de codigo                              Aqui pode-se colocar todos os comentarios
                                        mov         ax, OFFSET message 
                                        INVOKE      external_function, ax
		                                int         20h

;============================================================================================================================================
    
_TEXT ENDS
END start
