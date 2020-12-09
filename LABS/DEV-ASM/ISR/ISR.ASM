.286 
.MODEL SMALL

STACK SEGMENT STACK 'STACK'
	DB 100h DUP(0)
STACK ENDS  

_DATA SEGMENT PUBLIC 'DATA' USE16
     
    INSTALL_BY_DOS  EQU 01h 
    CHAR	        DB  2Eh
    
_DATA ENDS

_TEXT SEGMENT PUBLIC 'CODE' USE16
	ASSUME CS:_TEXT, DS:_DATA, ES:_DATA
	
	MAIN PROC

		MOV		AX, _DATA
		MOV		DS, AX
		
		CLI
		
		CALL	ENABLE_IRQ8
		
		IF INSTALL_BY_DOS
		CALL    USE_DOS_INSTALLATION
		ELSE
		CALL    USE_BIOS_INSTALLATION 
		ENDIF
		
        STI
        
		MOV		AX, 4C00h
		INT		21h
		
	MAIN ENDP
	
	;*************************************************************************************************************;
    ;                                                                                                             ;
    ; ENABLE IRQ 8                                                                                          	  ;
    ;   IN:     NONE                                                                  							  ;
    ;   OUT:    NONE                                                                                              ;
    ;                                                                                                             ;
    ;**************************************************************************************************************
	
	ENABLE_IRQ8 PROC
	
		PUSH 	AX     				; Interrupt may occur while updating

		IN 		AL, 0A1h  			; Make sure IRQ8 is not masked

		AND 	AL, 0FEh 			; Set bit 0 of port 0A1 to zero
		OUT 	0A1h, AL 			

		MOV		AL, 0Bh				; Select status register B
		OUT		70h, AL				; Any write to PORT 70h 
		
		IN 		AL, 71h				; should be followed by an action to PORT 71h 
									; or the RTC wil be left in an unknown state.			
		
		OR 		AL, 10h  			; Enable update interrupts (UI=1) only
		OUT 	71h, AL 			; Write into status register  B
		
		MOV 	AL, 0Ah				; Status Register A
		OUT 	70h, AL
		MOV 	AL, 00101101b		; RTC@32.768KHz (0010), Rate@8Hz (1101)
		OUT 	71h, AL
		
		IN 		AL, 71h
		
		POP AX
		
		RET
		
	ENABLE_IRQ8 ENDP

	;*************************************************************************************************************;
    ;                                                                                                             ;
    ; DOS INTERRUPT SERVICE ROUTINE INSTALLATION                                                               	  ;
    ;   IN:     NONE                                                                  							  ;
    ;   OUT:    NONE                                                                                              ;
    ;                                                                                                             ;
    ;**************************************************************************************************************	
	
	USE_DOS_INSTALLATION PROC
	    
	    PUSH    DS   
	    
	    MOV     AH, 25h
	    MOV     AL, 70h
	    MOV     DX, _TEXT
	    MOV     DS, DX
	    MOV     DX, OFFSET INT_70h
	    INT     21h 
	    
	    POP     DS   
	    RET  
	    
	USE_DOS_INSTALLATION ENDP 
	
	;*************************************************************************************************************;
    ;                                                                                                             ;
    ; BIOS INTERRUPT SERVICE ROUTINE INSTALLATION                                                                 ;
    ;   IN:     NONE                                                                  							  ;
    ;   OUT:    NONE                                                                                              ;
    ;                                                                                                             ;
    ;**************************************************************************************************************	
	
	USE_BIOS_INSTALLATION PROC
	    
		PUSH	ES
		PUSH	AX
		
		XOR		AX, AX
		MOV		ES, AX
		
		MOV		WORD PTR ES:[70h * 4], OFFSET _TEXT:INT_70h
		MOV		WORD PTR ES:[70h * 4 + 2], SEG INT_70h
		
		POP		AX
		POP		ES
		
	    RET
	    
	USE_BIOS_INSTALLATION ENDP
	
	;*************************************************************************************************************;
    ;                                                                                                             ;
    ; INT 70h - HARDWARE INTERRUPT SERVICE ROUTINE                                                             	  ;
    ;   IN:     NONE                                                                  							  ;
    ;   OUT:    NONE                                                                                              ;
    ;                                                                                                             ;
    ;**************************************************************************************************************	
	
	INT_70h PROC FAR
	
		PUSHF 
		
		MOV     AX, _DATA
		MOV     DS, AX
		MOV     ES, AX
		
	@@:	MOV 	AL, 0Ah				; Status Register A
		OUT 	70h, AL
		IN 		AL, 71h
		
		TEST 	AL, 80h				; Is there an update in process?
		JNE 	@b					; If so then keep polling

		MOV 	AL, 0Ch				; Acknowledge the RTC
		OUT 	70h, AL
		
		IN 		AL, 71h
		
		XOR		AX, AX
		OUT		70h, AL
		
		IN		AL, 71h
		
		;MOV		SI, OFFSET CHAR
		;LODSB
		MOV		AH, 0Eh
		INT		10h
		
		MOV 	AL, 20h				; INFORMA O FIM DA INSTRUCAO DE INTERRUPCAO
		OUT 	0A0h, AL  			; Notify Secondary PIC
		OUT 	20h, AL  			; Notify Primary PIC
		
		POPF
		
		IRET
		
	INT_70h ENDP
	
_TEXT ENDS
	
END MAIN
	