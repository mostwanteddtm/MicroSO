#masm#
;--------------------------------------------------------|
;                                                        |
;       Template para compilacao com MASM 6.15           |
;     Facimente testado no EMU8086 com a diretiva        |
;                       #masm#                           |
;                                                        |
;--------------------------------------------------------|  

.286
.MODEL TINY
.STACK					   
_TEXT SEGMENT PUBLIC USE16
.DATA

Cylinder        DW 0
Head            DB 0
Sector          DB 0
CrLf            EQU 0Ah, 0Dh, 0
 
BASE10          DW 10
BUFFER          DB 5 DUP (0) 

Prompt          DB           "Cylinder: ", 0
                DB 0AH, 0DH, "Head:     ", 0
                DB 0AH, 0DH, "Sector:   ", 0 
                    
.CODE 

ORG 100h 

MAIN:   

                MOV     AH, 08H
                MOV     DL, 80H 
                INT     13H
                
                MOV     BX, CX
                AND     BL, 11000000B
                XCHG    BL, BH
                INC     BL
                MOV     WORD PTR [Cylinder], BX
                INC     DH
                MOV     BYTE PTR [Head], DH
                MOV     BX, CX
                AND     BL, 00111111B 
                MOV     BYTE PTR [Sector], BL 
                
                MOV     SI, OFFSET Prompt  
                CALL    PRNSTR 
                XOR     AX, AX
                MOV     AX, [Cylinder]
                XOR     BX, BX 
                CALL    HEX2DEC
                
                MOV     SI, OFFSET Prompt+0BH
                CALL    PRNSTR
                XOR     AX, AX
                MOV     AL, [Head]
                XOR     BX, BX 
                CALL    HEX2DEC
                
                MOV     SI, OFFSET Prompt+18H
                CALL    PRNSTR
                XOR     AX, AX
                MOV     AL, [Sector]
                XOR     BX, BX 
                CALL    HEX2DEC
                
                INT     20H
;----------------------------------------------------------------

HEX2DEC:        XOR     DX, DX
                DIV     [BASE10]
                ADD     DL, 30H 
                MOV     [BUFFER+BX], DL
                INC     BX
                CMP     AL, 9
                JA      HEX2DEC
    
CONTINUE:       XOR     DX, DX
                XCHG    DL, AL
                ADD     DL, 30H 
                MOV     [BUFFER+BX], DL 
                MOV     CX, BX 
                INC     CX
   
                MOV     SI, OFFSET BUFFER
                ADD     SI, BX 
                
PRINT:          MOV     AH, 0EH
                MOV     AL, [SI]
                INT     10H
                DEC     SI
                LOOP    PRINT 
                
                RET
                
;---------------------------------------------------------------  

PRNSTR:         MOV     AL, [SI]
                CMP     AL, 0
                JE      CPRINT
                MOV     AH, 0EH
                INT     10H 
                INC     SI
                JMP     PRNSTR 
        
CPRINT:         RET 
    
_TEXT ENDS
END MAIN
