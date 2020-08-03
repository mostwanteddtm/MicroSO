ORG 100H

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

ENTRYPOINT:

                        JMP     START 
                        
TOTALSETORESPORTRILHA   DW      18
TOTALCABECASNODISCO     DW      2
CABECA                  DB      ?
TRILHA                  DB      ?
SETOR                   DB      ?

;------------------------------------------------------------------------------------------------|
;                                                                                                |
; CONVERTER LBA PARA CHS                                                                         |
; AX=>LBA ENDERECO DE CONVERCAO                                  19                              |        
;                                                                              AL  DL            |
; SETOR     = (SETOR MOD SETORES POR TRILHA) + 1                 (19 MOD 18) = 1      + 1   = 2  |
; CABECA    = (SETOR / SETORES POR TRILA) MOD NUMERO DE CABECAS  (19/18) = 1(SOBRA 1) MOD 2 = 1  |  
; TRILHA    = SETOR / (SETORES POR TRILHA * NUMERO DE CABECAS)   19 / (18*2) = 36 19 / 36   = 0  | 
;                                                                                                |
;------------------------------------------------------------------------------------------------|                    
                    
CONVERTLBACHS:          XOR     DX, DX                
                        DIV     [TOTALSETORESPORTRILHA]  
                        INC     DL                    
                        MOV     [SETOR], DL
                        XOR     DX, DX                
                        DIV     [TOTALCABECASNODISCO] 
                        MOV     [CABECA], DL
                        MOV     [TRILHA], AL 
                	    RET
    

START:                  MOV     AL, 19          ; ENDERECO LBA DO DIRETORIO RAIZ NO FLOPPY
                        CALL    CONVERTLBACHS
                        MOV     AH, 02H         ; INTERRUPCAO PARA LEITURA
                        MOV     AL, 01H         ; QUANTIDADE DE SETORES A SEREM LIDOS
                        MOV     CH, [TRILHA]    ; CYLINDER OU TRACK - TRILHA (0....79)
                        MOV     DH, [CABECA]    ; HEAD              - CABECA (0.....1)
                        MOV     CL, [SETOR]     ; SECTOR            - SETOR  (1....18)  1
                        MOV     DL, 00H         ; FLOPPY A:\> 
                        MOV     BX, 0050H
                        MOV     ES, BX
                        MOV     BX, 0
                        INT     13H
                        
                        MOV     AX, 0050H
                        MOV     DS, AX
                        MOV     SI, 0
                        MOV     AH, 0EH
                        C:      LODSB
                        CMP     AL, 0
                        JE      FIM
                        INT     10H
                        JMP     C
                        
                                   
                        FIM:
                        INT     20H
                        
END   