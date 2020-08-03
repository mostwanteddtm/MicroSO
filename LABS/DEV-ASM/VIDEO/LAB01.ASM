#MASM#
;-------------------------------------------------------------------------------|
;                                                        						|
;       		   Template para compilacao com MASM 6.15           			|
;     			Facimente testado no EMU8086 com a diretiva	        			|
;                       	    #masm#                           				|
;                                                        						|
;-------------------------------------------------------------------------------|  

.286
.MODEL TINY					   
_TEXT SEGMENT PUBLIC USE16
	ASSUME DS:_TEXT,ES:_TEXT 
	
						OPTION 		EXPR16               ;CONSTANTES COM TAMANHO DE 16 BITS   

.DATA
						POS_X   	DW 0
						POS_Y   	DW 0 
							
						OLD_X   	DW 0
						OLD_Y   	DW 0 
							
						POS     	DW 0
						OLD_POS 	DW 0 
						BUFFER      DB 5 DUP (0)  
                        BASE10      DW 10 

						STRPOSX		DB	'X: ', 0
						STRPOSY		DB	'Y: ', 0
.CODE 

ORG 100h 

MAIN:					CALL		CLS

						MOV			DH, 0
						MOV			DL, 0 
						CALL        SETCURPOS
						MOV			SI, OFFSET STRPOSX
						CALL		PRINTF
						
						MOV			DH, 1
						MOV			DL, 0  
						CALL        SETCURPOS
						MOV			SI, OFFSET STRPOSY
						CALL		PRINTF

						MOV			POS_X, 78
						MOV			DH, 0
						MOV			DL, 3
						CALL        SETCURPOS
						MOV         AX, POS_X
						CALL        HEXTODEC
						
						MOV			POS_Y, 160 
						MOV			DH, 1
						MOV			DL, 3
						CALL        SETCURPOS
						MOV         AX, POS_Y
						CALL        HEXTODEC
						 
						MOV     	AX, POS_X
						ADD     	AX, POS_Y
						MOV     	POS, AX 
						MOV     	OLD_POS, AX
							
						CALL    	SET_POS
						CALL    	PAUSE
							
						CALL    	HIDE_POS
							
						MOV			POS_X, 80
						MOV			POS_Y, 160  
						MOV     	AX, POS_X
						ADD     	AX, POS_Y
						MOV     	POS, AX 
						MOV     	OLD_POS, AX
							
						CALL    	SET_POS
						CALL    	PAUSE
							
						INT 		20H
	
SET_POS:        		MOV     	AX, 0B800H
						MOV     	ES, AX
						MOV     	AL, 20H
						MOV     	AH, 7FH             ; SET COLORS: WHITE BACKGROUND, BLUE TEXT.
						MOV     	DI, POS             ; POINT TO START OF THE SCREEN.
						MOV     	ES:[DI], AX         ; WRITE TO VIDEO MEMORY. 
							
						RET 	
					
HIDE_POS:       		MOV     	AX, 0B800H
						MOV     	ES, AX
						MOV     	AL, 20H
						MOV     	AH, 00H             
						MOV     	DI, OLD_POS         
						MOV     	ES:[DI], AX         
							
						RET 	
	
PAUSE:          		XOR     	AX, AX
						INT     	16H
					
CLS:					MOV     	AH, 00H
						MOV     	AL, 03H
						INT     	10H
						
						RET

HEXTODEC:				PUSHA
						XOR         BX, BX
    
CONT:                   XOR         DX, DX
                        DIV         [BASE10]
                        ADD         DL, 30H 
                        MOV         [BUFFER+BX], DL
                        INC         BX
                        CMP         AL, 9
                        JA          CONT
    
CONTINUE:               XOR         DX, DX
                        XCHG        DL, AL
                        ADD         DL, 30H 
                        MOV         [BUFFER+BX], DL 
                        MOV         CX, BX 
                        INC         CX
           
                        MOV         SI, OFFSET BUFFER
                        ADD         SI, BX 
                
PRINT:                  MOV         AH, 0EH
                        MOV         AL, [SI]
                        INT         10H
                        DEC         SI
                        LOOP        PRINT
						
						POPA
						
						RET
						
SETCURPOS:				MOV 		BH, 0
						MOV 		AH, 2
						INT 		10H
						
						RET
						
PRINTF:					MOV         AL, [SI]
                        CMP			AL, 0
						JE			SPRINTF
						MOV			AH, 0EH
						INT			10H
						INC			SI
						JMP			PRINTF
						
SPRINTF:				RET

_TEXT ENDS
END main
