
;*******************************************************************************************************************************************|
;                                                        								                                                    |
;       				                       TEMPLATE PARA COMPILACAO COM MASM 6.15 .EXE           				                        |
;     				                          FACILMENTE TESTADO NO EMU8086 COM A DIRETIVA:        				                            |
;                       			                            #MASM#                           			                                |
;                                                        								                                                    |
;*******************************************************************************************************************************************|  

.386

INCLUDE DEBUG.INC 

PUBLIC DEBUGRMODE
PUBLIC BUFFER
PUBLIC KEYPRESSED

DATA SEGMENT PUBLIC 'DATA' USE16

	KEYPRESSED 	DB			?

	BINORHEX	DB			1							; 0 - PRINT REGISTER BINARY | 1 - HEXADECIMAL
    
    HEADER      DB          '   00 01 02 03 04 05 06 07 08 09 0A 0B 0C 0D 0E 0F', 0
    
    ROW         DW          0
	
	BITSPACE	DB			?
    
    TAB         DB          '0123456789ABCDEF'
    
    BUFFER      DB          200h DUP(0) 
	
	REGS16		DW			?
	REGS32		DD			?

    GENREGS     GENERALREGS	  <'EAX:','EBX:','ECX:','EDX:','ESI:','EDI:','EBP:','ESP:'>
	SEGREGS		SEGREGISTERS  <'CS: ','DS: ','ES: ','SS: '>
	FLGREGS		FLAGREGISTERS <'CF: ','PF: ','AF: ','ZF: ','SF: ','TF: ',49463A20h,44463A20h,4F463A20h>
	
	OPTIONS		DB			  'Press F8 to switch output registers between Hexadecimal and Binary!!'
				DB			  'Press UP or DOWN to navigate Memory!!'
				
	STRFLAGS	DB			  '| FLAGS |', 0
	   
DATA ENDS

CODE SEGMENT PUBLIC 'CODE' USE16 
    ASSUME CS:CODE, DS:DATA, ES:DATA
    
    ;======================================================================================|
	;	PUBLIC METHOD FOR DEBUG ON REAL MODE                                               |
	;                                                                                      |
	;	DEBUGRMODE:                                                                        |
	;	IN:                                                                                |
	;		CX = SIZE OF BUFFER TO BE COPIED                                               |
	;		DS:SI = ORIGIN OF THE CONTENT TO BE COPIED TO THE BUFFER                       |
	;		AX, BX, CX, DX, SI, DI, BP, SP, DS, ES, SS = VALUE DEFINED ON MAIN PROGRAM     |
	;                                                                                      |
	;	OUT: BUFFER = COPIED FROM CONTENT LOADED IN MEMORY                                 |
	;		 SHOW REGISTERS VALUES (AX, BX, CX, DX, SI, DI, BP, SP, CS, DS, ES, SS)        |
	;======================================================================================| 
    
    DEBUGRMODE 	PROC NEAR

		PUSH	ESP
		PUSH	EBP
		PUSH	EDI
		PUSH	ESI
		PUSH	EDX
		PUSH	ECX
		PUSH	EBX
		PUSH	EAX
		PUSH	SS
		PUSH	ES
		PUSH	DS
		PUSH	CS
		PUSHF
		
		MOV		AX, DATA
		MOV 	DS, AX
		MOV		ES, AX
		MOV		DI, OFFSET BUFFER
		REP		MOVSB

        MOV     AX, 0B800h
        MOV 	ES, AX

		CMP		KEYPRESSED, 42h								; IF KEYPRESS = F8
		JNE		CHECKDOWN									
		XOR		BINORHEX, 1									; (IF SHO WHEX) SHOW BINARY AND VICE VERSA
		SUB		ROW, 0A0h
		JMP		@f
		
	CHECKDOWN:
		CMP		KEYPRESSED, 50h
		JNE		CHECKUP
		SUB		ROW, 90h
		JMP		@f
		
	CHECKUP:
		CMP		KEYPRESSED, 48h
		JNE		NOTKEY
		SUB		ROW, 10h
		
	NOTKEY:
		SUB		ROW, 0A0h
		
	@@:
        CALL    CLEARSCR
		
		POP		BX
		CALL	PRINTFLAGS
        
		MOV     SI, OFFSET HEADER
        MOV     DI, 6                                       ; START HEADER POSITION
        CALL    PRINTSTR
        
        CALL    PRINTBUFFER
		
		MOV		SI, OFFSET SEGREGS.RCS					; PRINT CONTENT OF SEGMENT REGISTER CS					
		CALL	PRINTREG
		MOV		SI, OFFSET REGS16
		POP		AX
		MOV		[SI], AX
		CALL	PRINTSEGREG
		
		MOV		SI, OFFSET SEGREGS.RDS					; PRINT CONTENT OF SEGMENT REGISTER DS					
		CALL	PRINTREG
		MOV		SI, OFFSET REGS16
		POP		AX
		MOV		[SI], AX
		CALL	PRINTSEGREG
		
		MOV		SI, OFFSET SEGREGS.RES					; PRINT CONTENT OF SEGMENT REGISTER ES					
		CALL	PRINTREG
		MOV		SI, OFFSET REGS16
		POP		AX
		MOV		[SI], AX
		CALL	PRINTSEGREG
		
		MOV		SI, OFFSET SEGREGS.RSS					; PRINT CONTENT OF SEGMENT REGISTER SS					
		CALL	PRINTREG
		MOV		SI, OFFSET REGS16
		POP		AX
		MOV		[SI], AX
		CALL	PRINTSEGREG
		
		;**************************************************************************************
		;												
		ADD		DI, 0A0h								; END OF SEGMENT REGISTERS
		;
		;**************************************************************************************
		
		MOV		SI, OFFSET GENREGS.REAX					; PRINT CONTENT OF GENERAL REGISTER EAX					
		CALL	PRINTREG
		MOV		SI, OFFSET REGS32
		POP		EAX
		MOV		[SI], EAX
		CALL	PRINTGENREG
		
		MOV		SI, OFFSET GENREGS.REBX					; PRINT CONTENT OF GENERAL REGISTER EBX				
		CALL	PRINTREG
		MOV		SI, OFFSET REGS32
		POP		EAX
		MOV		[SI], EAX
		CALL	PRINTGENREG

		MOV		SI, OFFSET GENREGS.RECX					; PRINT CONTENT OF GENERAL REGISTER ECX				
		CALL	PRINTREG
		MOV		SI, OFFSET REGS32
		POP		EAX
		MOV		[SI], EAX
		CALL	PRINTGENREG
		
		MOV		SI, OFFSET GENREGS.REDX					; PRINT CONTENT OF GENERAL REGISTER EDX				
		CALL	PRINTREG
		MOV		SI, OFFSET REGS32
		POP		EAX
		MOV		[SI], EAX
		CALL	PRINTGENREG
		
		MOV		SI, OFFSET GENREGS.RESI					; PRINT CONTENT OF GENERAL REGISTER ESI				
		CALL	PRINTREG
		MOV		SI, OFFSET REGS32
		POP		EAX
		MOV		[SI], EAX
		CALL	PRINTGENREG
		
		MOV		SI, OFFSET GENREGS.REDI					; PRINT CONTENT OF GENERAL REGISTER EDI				
		CALL	PRINTREG
		MOV		SI, OFFSET REGS32
		POP		EAX
		MOV		[SI], EAX
		CALL	PRINTGENREG
		
		MOV		SI, OFFSET GENREGS.REBP					; PRINT CONTENT OF GENERAL REGISTER EBP				
		CALL	PRINTREG
		MOV		SI, OFFSET REGS32
		POP		EAX
		MOV		[SI], EAX
		CALL	PRINTGENREG
		
		MOV		SI, OFFSET GENREGS.RESP					; PRINT CONTENT OF GENERAL REGISTER ESP			
		CALL	PRINTREG
		MOV		SI, OFFSET REGS32
		POP		EAX
		MOV		[SI], EAX
		CALL	PRINTGENREG

		CALL	PRINTOPTIONS

		RET
        
    DEBUGRMODE 	ENDP 

	;======================================================================================
	;	PRINT BINARY OR HEXADECIMAL VALUE ON THE SEGMENTS REGISTER
	;======================================================================================
	PRINTSEGREG PROC

		CMP		BINORHEX, 1
		JE		PRINTHEX
		
		MOV		CX, BIT16								
		MOV     BITSPACE, 0
        XOR     AX, AX
        
    @@: RCL     REGS16, 1
        ADC     AL, 30h
        MOV     AH, VIDEOCOLOR
        STOSW 
        
        CMP     BITSPACE, 3
        JE      CBIN
        INC     BITSPACE 
        XOR     AL, AL
        LOOP    @b 
        
    CBIN:    
        MOV     AL, SPACE
        STOSW 
        XOR     AL, AL
        MOV     BITSPACE, 0
        LOOP    @b
		
		ADD		DI, 1Eh									; LINE FEED
		
		JMP		ENDPROC
			
	PRINTHEX:
		MOV		CX, REG16								
		ADD		SI, CX
		DEC		SI
		
	@@: LODSB
        MOV     DL, AL
        RCR     AL, 4
		AND		AL, 0Fh
        XLATB
        MOV     AH, VIDEOCOLOR
        STOSW
        
        MOV     AL, DL
        AND     AL, 0Fh
        XLATB   
        STOSW
		
		SUB		SI, 2
		
		LOOP	@b
		
		MOV		AL, 'h'
		STOSW
		
		ADD		DI, 3Ch									; LINE FEED
	
	ENDPROC:

		RET
	
	PRINTSEGREG ENDP
	
	;======================================================================================
	;	PRINT BINARY OR HEXADECIMAL VALUE ON THE GENERAL REGISTERS
	;======================================================================================
	PRINTGENREG PROC

		CMP		BINORHEX, 1
		JE		PRINTHEX
		
		MOV		CX, BIT32								
		MOV     BITSPACE, 0
        XOR     AX, AX
        
    @@: RCL     REGS32, 1
        ADC     AL, 30h
        MOV     AH, VIDEOCOLOR
        STOSW 
        
        CMP     BITSPACE, 3
        JE      CBIN
        INC     BITSPACE 
        XOR     AL, AL
        LOOP    @b 
        
    CBIN:    
        MOV     AL, SPACE
        STOSW 
        XOR     AL, AL
        MOV     BITSPACE, 0
        LOOP    @b
		
		ADD		DI, 46h									; LINE FEED
		
		JMP		ENDPROC
			
	PRINTHEX:
		MOV		CX, REG32								
		ADD		SI, CX
		DEC		SI
		
	@@: LODSB
        MOV     DL, AL
        RCR     AL, 4
		AND		AL, 0Fh
        XLATB
        MOV     AH, VIDEOCOLOR
        STOSW
        
        MOV     AL, DL
        AND     AL, 0Fh
        XLATB   
        STOSW
		
		SUB		SI, 2
		
		LOOP	@b
		
		MOV		AL, 'h'
		STOSW
		
		ADD		DI, 84h									; LINE FEED
	
	ENDPROC:

		RET
	
	PRINTGENREG ENDP
	
	;======================================================================================
	;	PRINT STRING REGISTER OF STRUCTURE IN COMMON.INC
	;======================================================================================
	
	PRINTREG 	PROC
	
		PUSH	SI
		PUSH	CX
	
		MOV		CX, REG32
		ADD		SI, CX
		DEC		SI
		
	@@: LODSB
		MOV		AH, VIDEOCOLOR
		STOSW
		
		SUB		SI, 2
		
		LOOP	@b
		
		MOV		AL, SPACE								
		STOSW
		
		MOV		CX, REG32
		MOV		SI, OFFSET REGS32
	@@: MOV		[SI], BYTE PTR 0
		LOOP	@b
		
		POP		CX
		POP		SI
	
		RET
		
	PRINTREG	ENDP
    
    ;======================================================================================
	;	PRINT HEADER OF REAL MODE DEBUG
	;======================================================================================
    
    PRINTSTR PROC
            
    @@: LODSB
        CMP     AL, 0
        JE      @f
        CMP     AL, '$'
        JE      @f
        MOV     AH, HEADERCOLOR
        STOSW
        JMP     @b
        
    @@: RET
    
    PRINTSTR ENDP 
    
    ;======================================================================================
	;	PRINT MEMORY BUFFER
	;====================================================================================== 
    
    PRINTBUFFER PROC
	
		CMP		ROW, 0										; IF ROW IS LOWER THEN 0
		JL		LOWERMIN									; SET ROW 0
		
		CMP		ROW, 160h									; END OF BUFFER = 160h + 90h (OFFSET SHOWING) = 200h
		JGE		UPMAX

		JMP		@f
		
	LOWERMIN:
		MOV		ROW, 0
		JMP		@f
		
	UPMAX:
		MOV		ROW, 160h
	
	@@:
	
		MOV     SI, OFFSET BUFFER
		MOV		AX, ROW
		ADD		SI, AX

		XOR		DH, DH
		
        MOV     DI, STARTBUFFER								; NEW LINE 
        MOV     BX, OFFSET TAB
        
    @@: CMP     DH, 0Ah                                    	; ROW - 00h~0Ah
        JE      @f
		
        MOV     CX, 10h                                     ; COL - 00h~0Fh 
        CALL    HEADERBUFFER
    
	CROW:
	
        LODSB
        MOV     DL, AL
        RCR     AL, 4
		AND		AL, 0Fh
        XLATB
        MOV     AH, VIDEOCOLOR
        STOSW
        
        MOV     AL, DL
        AND     AL, 0Fh
        XLATB   
        STOSW
        
        MOV     AL, SPACE
        STOSW
		
		LOOP	CROW
		
		INC		DH
		
		ADD		DI, 34h										; LINE FEED
		ADD		ROW, 10h

        JMP     @b    

    @@: ADD		DI, NEWLINE									; NEW LINE
		RET       
        
    PRINTBUFFER ENDP
    
    ;======================================================================================
	;	CLEAR SCREEN
	;======================================================================================
    
    CLEARSCR 	PROC
        
        MOV     CX, 80 * 24
        XOR     DI, DI
        MOV     AH, VIDEOCOLOR
		MOV		AL, SPACE                                   
    @@: STOSW
        LOOP    @b
        
        RET
        
    CLEARSCR 	ENDP
    
    ;======================================================================================
	;	PRINT HEADER OF BUFFER 0000: ~ 00F0:
	;======================================================================================
    
    HEADERBUFFER PROC
	
		PUSH	DX
        
		MOV		BX, OFFSET TAB
		
        MOV     AH, HEADERCOLOR

        MOV     DX, ROW
		
		MOV		AL, DH
        RCR     AL, 4
		AND		AL, 0Fh
        XLATB
        MOV     AH, HEADERCOLOR
        STOSW
        MOV     AL, DH
        AND     AL, 0Fh
        XLATB   
        STOSW
		
		MOV		AL, DL
        RCR     AL, 4
		AND		AL, 0Fh
        XLATB
        MOV     AH, HEADERCOLOR
        STOSW
        MOV     AL, DL
        AND     AL, 0Fh
        XLATB   
        STOSW
        
        MOV     AL, ':'
        STOSW
        
        MOV     AL, SPACE 
        STOSW
		
		POP		DX
        
        RET
        
    HEADERBUFFER ENDP
	
	;======================================================================================
	;	PRINT OPTIONS
	;======================================================================================
    
    PRINTOPTIONS PROC

        MOV     SI, OFFSET OPTIONS
        MOV     DI, 1b0h                                       ; START HEADER POSITION
		MOV		CX, 13h
		MOV		AH, VIDEOCOLOR
            
    @@: LODSB
        STOSW
        LOOP    @b
		
		MOV		CX, 11h
		ADD		DI, 07Ah
		
	@@: LODSB
		STOSW
		LOOP	@b
		
		MOV		CX, 13h
		ADD		DI, 7Eh
		
	@@: LODSB
		STOSW
		LOOP	@b
		
		MOV		CX, 0Dh
		ADD		DI, 078h
		
	@@: LODSB
		STOSW
		LOOP	@b
		
		MOV		CX, 14h
		ADD		DI, 128h
		
	@@: LODSB
		STOSW
		LOOP	@b
        
		MOV		CX, 12h
		ADD		DI, 78h
		
	@@: LODSB
		STOSW
		LOOP	@b
        
		RET
	
	PRINTOPTIONS ENDP
    
	;======================================================================================
	;	PRINT FLAG REGISTERS
	;======================================================================================
	
	PRINTFLAGS PROC
	
		XOR		AX, AX
	
		MOV		DI, 8A4h
		MOV		SI, OFFSET STRFLAGS
		CALL	PRINTSTR
		
		ADD		DI, 632h
		MOV		SI, OFFSET FLGREGS.ROF
		
		MOV		CX, TOTALFLAGS
	
	@@: PUSH    CX
		DEC     CL
	    CMP		CL, 5
		JE		RESERVEDFLAG
		CMP		CL, 3
		JE		RESERVEDFLAG
		CMP		CL, 1
		JE		RESERVEDFLAG 
		CALL	PRINTREG
		SUB		SI, REG32
		MOV		AX, BX 
		SHR     AX, CL
		AND		AL, 01h
		ADD		AL, 30h
		MOV		AH, VIDEOCOLOR
		STOSW
		SUB		DI, 0ACh
		
	RESERVEDFLAG:
		POP		CX
		LOOP	@b

		RET
	
	PRINTFLAGS ENDP
	
	;======================================================================================
   
CODE ENDS

END DEBUGRMODE
