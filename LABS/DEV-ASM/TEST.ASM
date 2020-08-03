#masm#
; ______________________________________________________________________________________
;|																						|
;|						Template para compilacao com o MASM 6.15						|
;|______________________________________________________________________________________|

.286
.MODEL TINY 
_Text SEGMENT PUBLIC USE16
	ASSUME CS:_TEXT,DS:_TEXT,ES:_TEXT 

.DATA
 

.CODE

ORG 100h

;---------------------------------------------------------------------------------------
;									EntryPoint
;---------------------------------------------------------------------------------------

            comment ^
                1 AND 1 = 1         ;ZF não é setado
                1 AND 0 = 0         ;ZF é setado
                0 AND 1 = 0         ;ZF é setado
                0 AND 0 = 0         ;ZF é setado
            ^
main:
            MOV     AL, 010b
            TEST    AL, 100b             
            jz quit
            int 20h 
            
quit:       mov ah, 4Ch
            int 21h  
END main

_TEXT ENDS
