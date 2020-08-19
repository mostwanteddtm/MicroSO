.386 
.MODEL SMALL

IOBase      EQU 0C000h

TSD0        EQU 10h
TSAD0       EQU 20h

CR_TE       EQU 04h
CR_RE       EQU 08h
CR_RST      EQU 10h  
CR          EQU 37h

RBSTART     equ 30h
TCR         EQU 40h
RRCR        EQU 44h 
IMR         equ 3Ch 

RCR_APM     EQU 02h
RCR_AM      EQU 04h
RCR_AB      EQU 08h               
RCR_MXDMA1  EQU 200h
RCR_MXDMA2  EQU 400h
RCR_RBLEN0  EQU 800h
 
TCR_MXDMA1  EQU 200h
TCR_MXDMA2  EQU 400h
TCR_IFG0    EQU 1000000h 
TCR_IFG1    equ 2000000h 

R39_INTERRUPT_MASK EQU 7Fh                               

PRINTDW		PROTO C VALUE:DWORD
PRINTMEM    PROTO C LEN:DWORD, POINTER:WORD
OUTP 		PROTO C PORT:WORD, VALUE:BYTE  
OUTPDW 		PROTO C PORT:WORD, VALUE:DWORD

STACK SEGMENT STACK 'STACK'
    DB      100h  DUP(0) 
    TOPS    LABEL BYTE
STACK ENDS

DATA SEGMENT PUBLIC 'DATA' USE16
    
	BUFFER		DD 0
    TAB     	DB  '0123456789ABCDEF'
	
    physaddr    DD  0
    FRAME      	DB  40h DUP(0FFh)

    BASE        DB 10h
    
DATA ENDS

CODE SEGMENT PUBLIC 'CODE' USE16
    ASSUME CS:CODE, DS:DATA, ES:DATA
    
    MAIN PROC
    
        MOV     AX, DATA
        MOV     DS, AX
        MOV     ES, AX
		
		XOR     EAX, EAX
        XOR     ESI, ESI
        MOV     AX, CS
        SHL     EAX, 4
        MOV     SI, OFFSET FRAME
        ADD     EAX, ESI
        MOV     DWORD PTR physaddr, EAX
		
		XOR		EAX, EAX
		MOV		AX, CS
		INVOKE	PRINTDW, EAX
		CALL	CRLF
		XOR		EAX, EAX
		MOV		AX, OFFSET FRAME
		INVOKE	PRINTDW, EAX
		CALL	CRLF
		INVOKE	PRINTDW, physaddr
        INVOKE  PRINTMEM, 40h, OFFSET FRAME
		      
        CALL    RESET 
        CALL    ISSUECMD
        
        MOV     AX, 4C00h
        INT     21h    
    
    MAIN ENDP  

    ;==================================================================================
    
    RESET PROC 

        INVOKE  OUTP, IOBase + CR, CR_RST
        INVOKE  OUTP, IOBase + CR, CR_RE + CR_TE 
        INVOKE  OUTPDW, IOBase + TCR, TCR_IFG0 OR TCR_IFG1 OR TCR_MXDMA2 OR TCR_MXDMA1 
        INVOKE  OUTPDW, IOBase + RRCR, RCR_RBLEN0 OR RCR_MXDMA2 OR RCR_MXDMA1 OR RCR_AB OR RCR_AM OR RCR_APM 
        INVOKE  OUTPDW, IOBase + RBSTART, physaddr
        INVOKE  OUTP, IOBase + IMR, R39_INTERRUPT_MASK  
        
        RET
        
    RESET ENDP  

    ;==================================================================================
    
    ISSUECMD PROC
          
        CLI
        INVOKE  OUTPDW, IOBase + TSAD0, physaddr
        INVOKE  OUTPDW, IOBase + TSD0, 40h
        STI 
         
        RET
        
    ISSUECMD ENDP

    ;==================================================================================
    
    OUTP PROC C PORT:WORD, VALUE:BYTE
       
        MOV       AL, BYTE PTR VALUE        
        MOV       DX, WORD PTR PORT
        OUT       DX, AL
        RET
        
    OUTP ENDP

    ;==================================================================================
    
    OUTPDW PROC C PORT:WORD, VALUE:DWORD
            
        MOV     EAX, DWORD PTR VALUE
        MOV     DX, WORD PTR PORT
        OUT     DX, EAX
        RET
        
    OUTPDW ENDP

    ;==================================================================================
	
	PRINTDW PROC C VALUE:DWORD 

        MOV     ESI, DWORD PTR VALUE

        MOV     DI, OFFSET BUFFER
        MOV     EAX, ESI
        STOSD

        CALL    PRINTHEADER

        MOV     BX, OFFSET TAB
        MOV     SI, OFFSET BUFFER
        MOV     ECX, 4
        ADD     ESI, 3

    @@: MOV     AH, 0Eh 
        LODSB
        MOV     DL, AL
        SHR     AL, 4
        XLATB
        INT     10h
        MOV     AL, DL
        AND     AL, 0Fh
        XLATB
        INT     10h
        SUB     SI, 2
        LOOP    @b

        RET
                    
    PRINTDW ENDP

    ;==================================================================================

    PRINTHEADER PROC

        MOV     AH, 0Eh
        MOV     AL, '0'
        INT     10h

        MOV     AL, 'x'
        INT     10h

        RET

    PRINTHEADER ENDP

    ;==================================================================================

    CRLF PROC

        MOV     AH, 0Eh
        MOV     AL, 0Ah
        INT     10h

        MOV     AL, 0Dh
        INT     10h

        RET

    CRLF ENDP

    ;==================================================================================

    PRINTMEM PROC C LEN:DWORD, POINTER:WORD

        MOV     ECX, DWORD PTR LEN
        MOV     SI, WORD PTR POINTER
        MOV     BX, OFFSET TAB

    @@: 
        MOV     AX, CX
        DIV     BASE

        CMP     AH, 0
        JNE     CONT
        CALL    CRLF

    CONT:
        LODSB
        
        MOV     DL, AL
        AND     AL, 0Fh
        XLATB
        MOV     AH, 0Eh
        INT     10h
        MOV     AL, DL
        SHR     AL, 4
        XLATB
        MOV     AH, 0Eh
        INT     10h

        LOOP    @b

        RET

    PRINTMEM ENDP
 
CODE ENDS

END MAIN