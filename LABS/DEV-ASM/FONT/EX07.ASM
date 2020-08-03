;http://www.fysnet.net/modex.htm

.286
.MODEL TINY
.STACK 100H

INCLUDE EX07.INC

_TEXT SEGMENT PUBLIC USE16 
    
.DATA

X       DW  00h
Y       DW  00h
COLOR   DB  00h

LENFX   EQU 8                   ; TOTAL DE BITS DA FONT, POR LINHA
LENFY   EQU 8                  ; TOTAL DE BYTES DA FONT 8X16
FONTOFF DB  0                   ; OFFSET DA FONT A SER IMPRESSA  

MESSAGE DB  'A', 0        
    
.CODE
            
        ORG 100H
        
.STARTUP

        XOR     AX, AX
        MOV     AL, 12h
        INT     10h
		
		MOV     AX, 1010h               ; SET INDIVIDUAL DAC REGISTER (VGA/MCGA)
		MOV     BX, 0                   ; PALETTE 0 (BLACK) ~ FH (WHITE)
		MOV     CL, 20                  ; BLUE
		MOV     CH, 20                  ; GREEN
		MOV     DH, 00                  ; RED
		INT     10h

		MOV     AH, 0Bh                 ; SET BACKGROUND/BORDER COLOR	
		MOV     BX, 0	                ; PALETTE 0
		INT     10h  

        MOV     AX, 0A000h
        MOV     ES, AX
        MOV     DI, 0 
        
        MOV     SI, OFFSET MESSAGE 
        
LOADCHAR:
        LODSB  
        PUSH    SI 
        
        MOV     BYTE PTR FONTOFF, AL
        XOR     AH, AH
        
        MOV     SI, OFFSET FONT
        MOV     DX, LENFY               ; LOOP DAS 16 LINHAS 
        MUL     DX
        ADD     SI, AX 
        XOR     BX, BX
        
        MOV     DX, LENFY               ; LOOP DAS 16 LINHAS 
        
NEXTLINE:
        LODSB 
        
        MOV     CX, LENFX 
INVERTBITS:
        SAL     AL, 1
        RCR     BL, 1

        LOOP    INVERTBITS 
        
        XCHG    AL, BL

        MOV     CX, LENFX               ; LOOP DOS 8 BITS 
PRINTROW:
        MOV     BL, AL
        AND     AL, 1
        CMP     AL, 1
        JNE     CONTROW
        MOV     BYTE PTR COLOR, 0Fh
        CALL	PUTPIXEL
CONTROW: 
        INC     WORD PTR X
        ROR     BL, 1
        MOV     AL, BL
        LOOP PRINTROW 
        
        CMP     DX, 1
        JE      SAIR 
        INC 	WORD PTR Y
        MOV     WORD PTR X, 0
        JE      SAIR
        DEC     DX
        JMP     NEXTLINE        
        
SAIR:
        XOR     AX, AX
        INT     16h
        
        MOV     AX, 3
        INT     10h
        
        MOV     AX, 4C00h
        INT     21h 
        

PUTPIXEL   PROC NEAR USES AX BX CX DX

; BYTE PTR OFFSET = Y * (HORZ_RES / 8) + INT(X / 8) 

        PUSH    AX
        PUSH    BX
        PUSH    CX
        PUSH    DX

		MOV  	AX, Y                    ; CALCULATE OFFSET
		MOV  	DX, 80                   ;
		MUL  	DX                       ; AX = Y * 80
		MOV  	BX, X                    ;
		MOV  	CL, BL                   ; SAVE LOW BYTE PTR FOR BELOW
		SHR  	BX, 03                   ; DIV BY 8
		ADD  	BX, AX                   ; BX = OFFSET THIS GROUP OF 8 PIXELS
	
		MOV  	DX, 03CEh                ; SET TO VIDEO HARDWARE CONTROLLER
	
		AND  	CL, 07h                  ; COMPUTE BIT MASK FROM X-COORDINATES
		XOR  	CL, 07h                  ;  AND PUT IN AH
		MOV  	AH, 01h                  ;
		SHL  	AH, CL                   ;
		MOV  	AL, 08h                  ; BIT MASK REGISTER
		OUT  	DX, AX                   ;
	
		MOV  	AX, 0205h                ; READ MODE 0, WRITE MODE 2
		OUT  	DX, AX                   ;
	
		MOV  	AL, ES:[BX]              ; LOAD TO LATCH REGISTER
		MOV  	AL, COLOR
		MOV  	ES:[BX], AL              ; WRITE TO REGISTER 
		
		POP     DX
		POP     CX
		POP     BX
		POP     AX

		RET 
		
PUTPIXEL   ENDP

_TEXT ENDS

END