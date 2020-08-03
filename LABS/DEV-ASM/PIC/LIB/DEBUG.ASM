.386

INCLUDE DEBUG.INC

PUBLIC DEBUGPMODE
PUBLIC BUFFER
PUBLIC KEYPRESSED

EXTERN CHECKKEYPRESS:DWORD

DDATASEG32 SEGMENT PUBLIC 'DATA' USE32

    KEYPRESSED 	DB			0

	BINORHEX	DB			1							; 0 - PRINT REGISTER BINARY | 1 - HEXADECIMAL
    
    HEADER      DB          '   00 01 02 03 04 05 06 07 08 09 0A 0B 0C 0D 0E 0F', 0
    
    ROW         DW          0
	
	BITSPACE	DB			?
    
    TAB         DB          '0123456789ABCDEF'
    
    BUFFER      DB          200h DUP(0) 
	
	REGS16		DW			?
	REGS32		DD			?							

    GENREGS     GENERALREGS   <'EAX:','EBX:','ECX:','EDX:','ESI:','EDI:','EBP:','ESP:'>
	SEGREGS		SEGREGISTERS  <'CS: ','DS: ','ES: ','SS: '>
	FLGREGS		FLAGREGISTERS <'CF: ','PF: ','AF: ','ZF: ','SF: ','TF: ',49463A20h,44463A20h,4F463A20h>
	
	OPTIONS		DB			  'Press F8 to switch output registers between Hexadecimal and Binary!!'
				DB			  'Press UP or DOWN to navigate Memory!!'
				
	STRFLAGS	DB			  '| FLAGS |', 0

DDATASEG32 ENDS

DEBUGSEG32 SEGMENT PUBLIC 'CODE' USE32
	ASSUME 	CS:DBGS32, DS:DBGS32
	
	;======================================================================================|
	;																					   |
	;	PUBLIC METHOD FOR DEBUG ON PROTECTED MODE                                          |
	;                                                                                      |
	;	DEBUGPMODE:                                                                        |
	;	IN:                                                                                |
	;		ECX = SIZE OF BUFFER TO BE COPIED                                              |
	;		DS:ESI = ORIGIN OF THE CONTENT TO BE COPIED TO THE BUFFER                      |
	;		EAX, EBX, ECX, EDX, ESI, EDI, EBP, ESP,										   | 
	;		DS, ES, SS = VALUE DEFINED ON MAIN PROGRAM     								   |
	;                                                                                      |
	;	OUT: BUFFER = COPIED FROM CONTENT LOADED IN MEMORY                                 |
	;		 SHOW REGISTERS (EAX, EBX, ECX, EDX, ESI, EDI, EBP, ESP, CS, DS, ES, SS)       |
	;																					   |
	;======================================================================================|

	DEBUGPMODE PROC
	
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
		PUSHFD
		
		MOV		AX, 38h									; DDATADESC32: GDT DESCRIPTOR
		MOV		ES, AX
		MOV		EDI, OFFSET BUFFER
		REP		MOVSB
		
		MOV		AX, 38h									; DDATADESC32: GDT DESCRIPTOR
		MOV		DS, AX
		MOV		AX, 28h									; VIDEODESC32: GDT DESCRIPTOR
		MOV		ES, AX
		
		CMP		KEYPRESSED, 42h							; IF KEYPRESS = F8
		JNE		CHECKDOWN								
		XOR		BINORHEX, 1								; (IF SHO WHEX) SHOW BINARY AND VICE VERSA
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
		
		POP		EBX
		CALL	PRINTFLAGS
		
        MOV     ESI, OFFSET HEADER
        MOV     EDI, 6                                  ; START HEADER POSITION
        CALL    PRINTSTR
		
		CALL    PRINTBUFFER
		
		MOV		ESI, OFFSET SEGREGS.RCS					; PRINT CONTENT OF SEGMENT REGISTER CS					
		CALL	PRINTREG
		MOV		ESI, OFFSET REGS16
		POP		EAX
		MOV		[ESI], EAX
		CALL	PRINTSEGREG
		
		MOV		ESI, OFFSET SEGREGS.RDS					; PRINT CONTENT OF SEGMENT REGISTER DS					
		CALL	PRINTREG
		MOV		ESI, OFFSET REGS16
		POP		EAX
		MOV		[ESI], EAX
		CALL	PRINTSEGREG
		
		MOV		ESI, OFFSET SEGREGS.RES					; PRINT CONTENT OF SEGMENT REGISTER ES					
		CALL	PRINTREG
		MOV		ESI, OFFSET REGS16
		POP		EAX
		MOV		[ESI], EAX
		CALL	PRINTSEGREG
		
		MOV		ESI, OFFSET SEGREGS.RSS					; PRINT CONTENT OF SEGMENT REGISTER SS					
		CALL	PRINTREG
		MOV		ESI, OFFSET REGS16
		POP		EAX
		MOV		[ESI], EAX
		CALL	PRINTSEGREG
		
		;**************************************************************************************
		;												
		ADD		EDI, 0A0h								; END OF SEGMENT REGISTERS
		;
		;**************************************************************************************
		
		MOV		ESI, OFFSET GENREGS.REAX				; PRINT CONTENT OF GENERAL REGISTER EAX					
		CALL	PRINTREG
		MOV		ESI, OFFSET REGS32
		POP		EAX
		MOV		[ESI], EAX
		CALL	PRINTGENREG
		
		MOV		ESI, OFFSET GENREGS.REBX				; PRINT CONTENT OF GENERAL REGISTER EBX				
		CALL	PRINTREG
		MOV		ESI, OFFSET REGS32
		POP		EAX
		MOV		[ESI], EAX
		CALL	PRINTGENREG

		MOV		ESI, OFFSET GENREGS.RECX				; PRINT CONTENT OF GENERAL REGISTER ECX				
		CALL	PRINTREG
		MOV		ESI, OFFSET REGS32
		POP		EAX
		MOV		[ESI], EAX
		CALL	PRINTGENREG
		
		MOV		ESI, OFFSET GENREGS.REDX				; PRINT CONTENT OF GENERAL REGISTER EDX				
		CALL	PRINTREG
		MOV		ESI, OFFSET REGS32
		POP		EAX
		MOV		[ESI], EAX
		CALL	PRINTGENREG
		
		MOV		ESI, OFFSET GENREGS.RESI				; PRINT CONTENT OF GENERAL REGISTER ESI				
		CALL	PRINTREG
		MOV		ESI, OFFSET REGS32
		POP		EAX
		MOV		[ESI], EAX
		CALL	PRINTGENREG
		
		MOV		ESI, OFFSET GENREGS.REDI				; PRINT CONTENT OF GENERAL REGISTER EDI				
		CALL	PRINTREG
		MOV		ESI, OFFSET REGS32
		POP		EAX
		MOV		[ESI], EAX
		CALL	PRINTGENREG
		
		MOV		ESI, OFFSET GENREGS.REBP				; PRINT CONTENT OF GENERAL REGISTER EBP				
		CALL	PRINTREG
		MOV		ESI, OFFSET REGS32
		POP		EAX
		MOV		[ESI], EAX
		CALL	PRINTGENREG
		
		MOV		ESI, OFFSET GENREGS.RESP				; PRINT CONTENT OF GENERAL REGISTER ESP			
		CALL	PRINTREG
		MOV		ESI, OFFSET REGS32
		POP		EAX
		MOV		[ESI], EAX
		CALL	PRINTGENREG
		
		CALL	PRINTOPTIONS
		
		DB		0EAh
		DD		CHECKKEYPRESS
		DW		18h										; CODEDESC32: GDT DESCRIPTOR

	DEBUGPMODE ENDP
	
	;======================================================================================
	;	CLEAR SCREEN
	;======================================================================================
    
    CLEARSCR 	PROC
        
        MOV     ECX, 80 * 24
        XOR     EDI, EDI
        MOV     AH, VIDEOCOLOR
		MOV		AL, SPACE                                   
    @@: STOSW
        LOOP    @b
        
        RET
        
    CLEARSCR 	ENDP
	
	;======================================================================================
	;	PRINT HEADER OF PROTECTED MODE DEBUG
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
	
		MOV     ESI, OFFSET BUFFER
		MOV		AX, ROW
		CWDE
		ADD		ESI, EAX

		XOR		DH, DH
		
        MOV     EDI, STARTBUFFER							; NEW LINE 
        MOV     EBX, OFFSET TAB
        
    @@: CMP     DH, 0Ah                                    	; ROW - 00h~0Ah
        JE      @f
		
        MOV     ECX, 10h                                    ; COL - 00h~0Fh 
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
	;	PRINT HEADER OF BUFFER 0000: ~ 00F0:
	;======================================================================================
    
    HEADERBUFFER PROC
	
		PUSH	EDX

		MOV		EBX, OFFSET TAB
		
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
		
		POP		EDX
        
        RET
        
    HEADERBUFFER ENDP
	
	;======================================================================================
	;	PRINT STRING REGISTER OF STRUCTURE IN COMMON.INC
	;======================================================================================
	
	PRINTREG 	PROC
	
		PUSH	ESI
		PUSH	ECX
	
		MOV		ECX, REG32
		ADD		ESI, ECX
		DEC		ESI
		
	@@: LODSB
		MOV		AH, VIDEOCOLOR
		STOSW
		
		SUB		ESI, 2
		
		LOOP	@b
		
		MOV		AL, SPACE								
		STOSW
		
		MOV		ECX, REG32
		MOV		ESI, OFFSET REGS32
	@@: MOV		[ESI], BYTE PTR 0
		LOOP	@b
		
		POP		ECX
		POP		ESI
	
		RET
		
	PRINTREG	ENDP
	
	;======================================================================================
	;	PRINT BINARY OR HEXADECIMAL VALUE ON THE SEGMENTS REGISTER
	;======================================================================================
	PRINTSEGREG PROC

		CMP		BINORHEX, 1
		JE		PRINTHEX
		
		MOV		ECX, BIT16								
		MOV     BITSPACE, 0
        XOR     EAX, EAX
        
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
		
		ADD		EDI, 1Eh								; LINE FEED
		
		JMP		ENDPROC
			
	PRINTHEX:
		MOV		ECX, REG16								
		ADD		ESI, ECX
		DEC		ESI
		
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
		
		SUB		ESI, 2
		
		LOOP	@b
		
		MOV		AL, 'h'
		STOSW
		
		ADD		EDI, 3Ch									; LINE FEED
	
	ENDPROC:

		RET
	
	PRINTSEGREG ENDP
	
	;======================================================================================
	;	PRINT BINARY OR HEXADECIMAL VALUE ON THE GENERAL REGISTERS
	;======================================================================================
	PRINTGENREG PROC

		CMP		BINORHEX, 1
		JE		PRINTHEX
		
		MOV		ECX, BIT32								
		MOV     BITSPACE, 0
        XOR     EAX, EAX
        
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
		
		ADD		EDI, 46h								; LINE FEED
		
		JMP		ENDPROC
			
	PRINTHEX:
		MOV		ECX, REG32								
		ADD		ESI, ECX
		DEC		ESI
		
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
		
		SUB		ESI, 2
		
		LOOP	@b
		
		MOV		AL, 'h'
		STOSW
		
		ADD		EDI, 84h									; LINE FEED
	
	ENDPROC:

		RET
	
	PRINTGENREG ENDP
	
	;======================================================================================
	;	PRINT OPTIONS
	;======================================================================================
    
    PRINTOPTIONS PROC

        MOV     ESI, OFFSET OPTIONS
        MOV     EDI, 1b0h                                    ; START HEADER POSITION
		MOV		ECX, 13h
		MOV		AH, VIDEOCOLOR
            
    @@: LODSB
        STOSW
        LOOP    @b
		
		MOV		ECX, 11h
		ADD		EDI, 07Ah
		
	@@: LODSB
		STOSW
		LOOP	@b
		
		MOV		ECX, 13h
		ADD		EDI, 7Eh
		
	@@: LODSB
		STOSW
		LOOP	@b
		
		MOV		ECX, 0Dh
		ADD		EDI, 078h
		
	@@: LODSB
		STOSW
		LOOP	@b
		
		MOV		ECX, 14h
		ADD		EDI, 128h
		
	@@: LODSB
		STOSW
		LOOP	@b
        
		MOV		ECX, 12h
		ADD		EDI, 78h
		
	@@: LODSB
		STOSW
		LOOP	@b
        
		RET
	
	PRINTOPTIONS ENDP
    
    ;======================================================================================
	;	PRINT FLAG REGISTERS
	;======================================================================================
	
	PRINTFLAGS PROC
	
		XOR		EAX, EAX
	
		MOV		EDI, 8A4h
		MOV		ESI, OFFSET STRFLAGS
		CALL	PRINTSTR
		
		ADD		EDI, 632h
		MOV		ESI, OFFSET FLGREGS.ROF
		
		MOV		ECX, TOTALFLAGS
	
	@@: PUSH    ECX
		DEC     CL
	    CMP		CL, 5
		JE		RESERVEDFLAG
		CMP		CL, 3
		JE		RESERVEDFLAG
		CMP		CL, 1
		JE		RESERVEDFLAG 
		CALL	PRINTREG
		SUB		ESI, REG32
		MOV		AX, BX 
		SHR     AX, CL
		AND		AL, 01h
		ADD		AL, 30h
		MOV		AH, VIDEOCOLOR
		STOSW
		SUB		EDI, 0ACh
		
	RESERVEDFLAG:
		POP		ECX
		LOOP	@b

		RET
	
	PRINTFLAGS ENDP
	
	;======================================================================================
	
DEBUGSEG32 ENDS

END