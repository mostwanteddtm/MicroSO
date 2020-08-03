#masm#
; ______________________________________________________________________________________
;|																						|
;|						Template para compilacao com o MASM 6.15						|
;|______________________________________________________________________________________|

.286
.MODEL TINY 
_Text SEGMENT PUBLIC USE16
	ASSUME DS:_TEXT,ES:_TEXT 

.DATA
                        BUFFER      DB 5 DUP (0)  
                        BASE10      DW 10 
                        HEXVALUE    DW 63h

.CODE

ORG 100h

;---------------------------------------------------------------------------------------
;									EntryPoint
;---------------------------------------------------------------------------------------

MAIN:
                        CALL        SETCURPOS
                    	CALL        CLSCUR
                    	CALL        SETCURPOS
                    	
                        MOV         AX, HEXVALUE       
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
                        
                        XOR         AX, AX
                        INT         16H
                        
                        CMP         AH, 4DH
                        JE          ADDHEX
                        CMP         AH, 4BH
                        JE          SUBHEX 
                        
                        INT         20H

ADDHEX:                 ADD         HEXVALUE, 1
                        JMP         MAIN
                        
SUBHEX:                 SUB         HEXVALUE, 1
                        JMP         MAIN
                        
CLSCUR:                 
                        MOV         CX, 5
CONTCLS:                MOV         AL, 0
                        MOV         AH, 0EH
                        INT         10H
                        LOOP        CONTCLS
                        
                        RET  
                        
SETCURPOS:              MOV         DH, 0
                    	MOV         DL, 0
                    	MOV 		BH, 0
						MOV 		AH, 2
						INT 		10H
						
						RET
END MAIN

_TEXT ENDS
