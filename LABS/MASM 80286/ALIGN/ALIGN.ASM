#MASM# 

.286

PRINT PROTO FAR

STSEG SEGMENT
    DB   128  DUP(0)
STSEG ENDS  

DTSEG SEGMENT PUBLIC 'DATA' USE16 
    
    DB 01					; ALIGN GARANTE QUE OS DADOS SEJAM ALINHADOS NA MEMÓRIA	
							; DESSA FORMA, EVITA QUE UMA VARIAVEL OU UM LABEL		 
    ALIGN 2					; SEJA INICIADO EM UMA POSICAO DE MEMORIA COM NUMERO IMPAR	
    DB 02					; O NUMERO PRECEDIDO DA DIRETIVA ALIGN, DETERMINA O VALOR A SER DIVISIVEL
                            ; EX: ALIGN 4 = DETERMINA QUE O ALINHAMENTO ACONTECERA	
    ALIGN 4 				; NO PRIMEIRO PROXIMO LOCAL DE MEMORIA, DIVISIVEL POR 4	
    DB 03					; MESMA LOGICA PARA: ALIGN 2, 4, 8, 16, 32, 64 	
							
    ALIGN 8						
    DB 04					
    
    ALIGN 16
    DB 05 
    
    SEMALIGN    DB 'SEM ALIGN, UMA VARIAVEL POODE INICIAR EM UMA POSICAO DE MEMORIA IMPAR!!', 0           
           
DTSEG ENDS

CSSEG SEGMENT PUBLIC 'CODE' USE16
    ASSUME CS:CSSEG, DS:DTSEG, ES:DTSEG
    
    START PROC NEAR

        MOV 	AX, DTSEG
        MOV 	DS, AX
        MOV 	ES, AX
		
		MOV     SI, OFFSET SEMALIGN
		CALL    PRINT									
		
        MOV 	AX, 4C00H
        INT 	21H
         
    START ENDP
        
CSSEG ENDS 

PRSEG SEGMENT PUBLIC 'PRINT' USE16
    ASSUME CS:PRSEG, DS:DTSEG, ES:DTSEG
    
    PRINT PROC FAR
        MOV     AX, DTSEG
        MOV     DS, AX
        MOV     ES, AX
        MOV     AH, 0Eh
    @@: LODSB 
        CMP     AL, 0
        JE      @f
        INT     10h
        JMP     @b
                                    
    @@: RET
        
    PRINT ENDP
    
PRSEG ENDS

END START 
