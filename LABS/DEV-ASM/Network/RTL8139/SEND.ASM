.386 

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

OUTP PROTO C PORT:WORD, VALUE:BYTE  
OUTPDW PROTO C PORT:WORD, VALUE:DWORD

STACK SEGMENT STACK 'STACK'
    DB      100h  DUP(0) 
    TOPS    LABEL BYTE
STACK ENDS

DATA SEGMENT PUBLIC 'DATA' USE16
     
    physaddr    DD  0
    buffer      DB  40h DUP(0FFh)
    
DATA ENDS

CODE SEGMENT PUBLIC 'CODE' USE16
    ASSUME CS:CODE, DS:DATA, ES:DATA
    
    MAIN PROC
    
        MOV     AX, DATA
        MOV     DS, AX
        MOV     ES, AX
         
        CALL    RESET 
        CALL    ISSUECMD
        
        MOV     AX, 4C00h
        INT     21h    
    
    MAIN ENDP  
    
    RESET PROC 
         
        XOR     EAX, EAX
        XOR     ESI, ESI
        MOV     AX, CS
        SHL     EAX, 4
        MOV     SI, OFFSET buffer
        ADD     EAX, ESI
        MOV     DWORD PTR physaddr, EAX

        INVOKE  OUTP, IOBase + CR, CR_RST
        INVOKE  OUTP, IOBase + CR, CR_RE + CR_TE 
        INVOKE  OUTPDW, IOBase + TCR, TCR_IFG0 OR TCR_IFG1 OR TCR_MXDMA2 OR TCR_MXDMA1 
        INVOKE  OUTPDW, IOBase + RRCR, RCR_RBLEN0 OR RCR_MXDMA2 OR RCR_MXDMA1 OR RCR_AB OR RCR_AM OR RCR_APM 
        INVOKE  OUTPDW, IOBase + RBSTART, physaddr
        INVOKE  OUTP, IOBase + IMR, R39_INTERRUPT_MASK  
        
        RET
        
    RESET ENDP  
    
    ISSUECMD PROC
          
        CLI
        INVOKE  OUTPDW, IOBase + TSAD0, physaddr
        INVOKE  OUTPDW, IOBase + TSD0, 40h
        STI 
         
        RET
        
    ISSUECMD ENDP
    
    OUTP PROC C PORT:WORD, VALUE:BYTE
       
        MOV       AL, BYTE PTR VALUE        
        MOV       DX, WORD PTR PORT
        OUT       DX, AL
        RET
        
    OUTP ENDP
    
    OUTPDW PROC C PORT:WORD, VALUE:DWORD
            
        MOV     EAX, DWORD PTR VALUE
        MOV     DX, WORD PTR PORT
        OUT     DX, EAX
        RET
        
    OUTPDW ENDP
    
CODE ENDS

END MAIN