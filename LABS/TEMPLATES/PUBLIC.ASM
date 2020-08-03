;*******************************************************************************************************************************************|
;                                                        								                                                    |
;       				                          	Template para Public Functions           				                            	|                          			                                |
;                                                        								                                                    |
;*******************************************************************************************************************************************|
.286
.MODEL TINY,C
						   
 _Text SEGMENT PUBLIC USE16 
 
										PUBLIC		_putch
										PUBLIC 		_putstr
													__factorial		PROTO C factor:SWORD,power:SWORD
			
.CODE 

;============================================================================================================================================

_putch 									PROC

										mov     	ah, 0Eh
										int     	10h
        
fim:    								ret    
     
_putch 									ENDP

;============================================================================================================================================

_putstr									PROC

										push		bp
										mov			bp, sp
										mov			si, [bp+4]
										mov			ah, 0Eh
cputstr:								lodsb
										cmp			al, 0
										je			fputstr
										int			10h
										jmp			cputstr
										
fputstr:								pop			bp
										ret
										
										
_putstr									ENDP										

;============================================================================================================================================

__factorial 							PROC 		C factor:SWORD,power:SWORD

										mov 		ax, factor
										mov 		cx, power
										shl 		ax, cl	
										ret
     
__factorial 							ENDP

_Text ENDS
END