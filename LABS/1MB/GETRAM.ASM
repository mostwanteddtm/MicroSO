TITLE OBTER 1MB RAM DO MS-DOS
;*******************************************************************************************************************************************|
;                                                        								                                                    |
;       				                          TEMPLATE PARA COMPILACAO COM MASM 6.15           				                            |
;     				                           FACIMENTE TESTADO NO EMU8086 COM A DIRETIVA        				                            |
;                       			                            #MASM#                           			                                |
;                                                        								                                                    |
;*******************************************************************************************************************************************|  
   
;===========================================================================================================================================|
;                                                                                                                                           | 
;                               O HXD HEX EDITOR, UTILIZA O MODO DE ENDERECAMENTO LBA 0 - 2880 SETORES                                      |
;                                                                                                                                           |
;                               PARA OBTER O ENDERECO LBA A PARTIR DO HXD HEX EDITOR                                                        |
;                               FAZER O SEGUINTE CALCULO: ENRERECO FISICO / BYTES POR SETOR                                                 |
;                               EXEMPLO: 02600H / 200H = 13H (DECIMAL 19)                                                                   |
;                                                                                                                                           |
;                               CHS COMECA COM: CYLINDER 0, HEAD 0, SECTOR 1                                                                | 
;                                                                                                                                           |
;                               MODO DE LEITURA CHS                                                                                         |
;                                                                                                                                           |
;                               TRILHA 00.............. |01.............|02....TOTAL: 80   CYLINDER / TRACK                                 |                                
;                               CABECA 00......|01..... |00....01.......|......TOTAL: 2    HEADS                                            |                                
;                               SETOR  01...18 |19...36 |37....54....71.|......TOTAL: 2880 SECTORS                                          |
;                                                                                                                                           |
;                               CHS TEM A BASE / INICIO COM 1                                                                               |
;                               LBA TEM A BASE / INICIO COM 0                                                                               |
;                               EXEMPLO: (CHS) SETOR 18 = (LBA) SETOR 17                                                                    |
;                                                                                                                                           |
;                               A CADA CHAMADA DE INT 13H, PODE-SE LER OU ESCREVER APENAS 72 SETORES                                        |
;                               POR VEZ. POR QUE CADA TRILHA (CYLINDER / TRACK), POSSUI 72 SETORES.                                         |
;                               COMO MOSTRADO NO DESENHO ABAIXO:                                                                            |
;                                                                                                                                           |
;                               TRILHA 00.............. |01............|                                                                    |
;                               CABECA 00......|01..... |00....01......|                                                                    |
;                               SETOR  01...18 |19...36 |37....54....71|                                                                    |
;                                                                                                                                           |
;===========================================================================================================================================|   
   
.286
.MODEL TINY					   
_TEXT SEGMENT PUBLIC USE16
.DATA 

        TOTALSETORESPORTRILHA           DW          18
        TOTALCABECASNODISCO             DW          2
        CABECA                          DB          ?
        TRILHA                          DB          ?
        SETOR                           DB          ?
        ERROR                           DB          'ERRO', 0    
        EOFF                            DW          0
        ESEG                            DW          0
        
        QTDELEITURAS                    DB          1                               ; A CADA LEITURA, MULTIPLICO ESSE VALOR POR QTDESETORES
        INICIARPELOSETOR                DB          1                               ; INICIA A LEITURA PELO SETOR 1 
        
        LOOPOFF                         DB          0
        LOOPSEG                         DB          0
        
        QTDESETORES                     EQU         40H
        ULTIMOSEGMENTO                  EQU         0FH
        DRIVE                           EQU         1                               ; FLOPPY 0 A:\> || FLOPPY B 1 B:\>
		        
.CODE 

ORG 100H 

;============================================================================================================================================

START:	                                ;SECAO DE CODIGO                              AQUI PODE-SE COLOCAR TODOS OS COMENTARIOS
		                                                                        
                                        JMP         INIT
  
CONVERTLBACHS:                          XOR         DX, DX                
                                        DIV         [TOTALSETORESPORTRILHA]                    
                                        MOV         [SETOR], DL
                                        XOR         DX, DX                
                                        DIV         [TOTALCABECASNODISCO] 
                                        MOV         [CABECA], DL
                                        MOV         [TRILHA], AL 
                	                    RET
    
INIT:                                   MOV         AL, INICIARPELOSETOR            ; INICIAR LEITURA PELO SETOR ?
                                        CALL        CONVERTLBACHS  
                                                         
                                        MOV         AH, 03H                         ; INTERRUPCAO PARA LEITURA 
                                        MOV         AL, QTDESETORES                 ; QUANTIDADE DE SETORES A SEREM LIDOS 
                                        MOV         CH, [TRILHA]                    ; CYLINDER OU TRACK - TRILHA (0....79)
                                        MOV         DH, [CABECA]                    ; HEAD              - CABECA (0.....1)
                                        MOV         CL, [SETOR]                     ; SECTOR            - SETOR  (1....18)  1
                                        MOV         DL, DRIVE                       ; FLOPPY A:\> 
                                        MOV         BX, ESEG                        ; SEGMENTO
                                        MOV         ES, BX
                                        MOV         BX, EOFF
                                        INT         13H
                                        JC          ERR

                                        MOV         AL, QTDELEITURAS                ; ASSIM 40H*1=40H, 40H*2=80H, 40H*3=120H
                                        MOV         BL, QTDESETORES
                                        MUL         BL
                                        
                                        MOV         BYTE PTR INICIARPELOSETOR, AL 
                                        INC         INICIARPELOSETOR                ; INCLUO 1 PARA INICIAR A GRAVACAO, 1 SETOR DEPOIS DO ULTIMO GRAVADO
                                        INC         QTDELEITURAS                    
                                        ADD         EOFF, 8000H                     ; FACO A PRIMEIRA LEITURA DE 0000H:7FFFH
                                                                                    ; FACO A SEGUNDA LEITURA DE  8000H:FFFFH
                                        CMP         LOOPOFF, 1                      ; NA SEGUNDA LEITURA, PULO PARA INICIAR UM NOVO SEGMENTO
                                        JE          ADDSEG                          
                                        
                                        INC         LOOPOFF
                                        
                                        JMP         INIT 
                                        
ADDSEG:                                 MOV         LOOPOFF, 0                      ; ZERO A VARIAVEL DE LOOP DE OFFSET
                                        MOV         EOFF, 0
                                        ADD         ESEG, 1000H                     ; INCIO O NOVO SEGMENTO
                                        
                                        CMP         LOOPSEG, ULTIMOSEGMENTO
                                        JE          FIM
                                        
                                        INC         LOOPSEG
                                        JMP         INIT
                                        
                                        JMP         FIM
ERR:                                    MOV         SI, OFFSET ERROR
                                        MOV         AH, 0EH
CPRINT:                                 LODSB
                                        CMP         AL, 0
                                        JE          FIM
                                        INT         10H
                                        JMP         CPRINT                                                                                  
                                        
FIM:	                                INT         20H
                                        

;============================================================================================================================================
    
_TEXT ENDS
END START
