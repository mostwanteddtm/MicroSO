    ;===================================================================================================================
    ;                                                                                                                  |
    ;                       O PROGRAMA ESCREVE O ULTIMO SETOR POSSIVEL USANDO O CHS PADRAO DA BIOS                     |
    ;                                                                                                                  |
    ;                                   TESTADO COM UMA IMAGEM CRIADA COM O BXIMAGE                                    |
    ;                                COM O TAMANHO DE 8.225.784 KB - 8033 MB OU 7.84GB                                 |
    ;                                    PCHS = 16321/16/63 - LCHS = 1024/255/63                                       |
    ;                                     Ultimo Endereco em Bytes = 1F607FFFFh                                        |
    ;                                                                                                                  |
    ;                             PROXIMO PASSO, APRENDER A UTILIZAR O INT 13h AH 08h                                  |
    ;                                PARA PEGAR A GEOMETRIA DO DISCO, ANTES DE LER                                     |
    ;                                               OU ESCREVER NELE                                                   |
    ;                                                                                                                  |
    ;===================================================================================================================
    
    ORG 100h

                                        jmp         start
    
    bpbTotalSetoresPorTrilha            DW          63                      		; 63 sectors per track (36/cylinder)
    bpbTotalCabecasNoDisco              DW          16                       		; 16 heads per cylinder
   
    Cabeca                              DB          ?                        
    Trilha                              DB          ?                        
    Setor                               DB          ? 
    
    buffer                              DB          512 DUP(9fh) 
    bsDrive                             DB          80h                       		
		        
;============================================================================================================================================

start:	                                ;secao de codigo                              Aqui pode-se colocar todos os comentarios    
                                        
                                        push        cs
                                        pop         es
                                        mov         ax, 0301h
                                        mov         cx, 0FFFFh
                                        mov         dx, 0FE80h
                                        mov         bx, OFFSET buffer
                                        int         13h
                                        jnc         sair
                                        jmp         sair
                                        mov         al, 'E'
                                        mov         ah, 0Eh
                                        int         10h
sair:	                                int         20h

;============================================================================================================================================

LeiaDisco:                              call        ConvertLBACHS               
                                        mov         ah, 02h                     
                                        mov         al, 01h                     
                                        mov         ch, [Trilha]                	; C - Clylinder / Track
                                        mov         dh, [Cabeca]                	; H - Head
                                        mov         cl, [Setor]                 	; S - Sector
                                        mov         dl, [bsDrive]
                                        int         13h 
                                        jc          sair 
                                        ret
                                	          
ConvertLBACHS:                          xor         dx, dx                
                                        div         [bpbTotalSetoresPorTrilha]  
                                        inc         dl                    
                                        mov         [Setor], dl
                                        xor         dx, dx                
                                        div         [bpbTotalCabecasNoDisco] 
                                        mov         [Cabeca], dl
                                        mov         [Trilha], al
                                        ret