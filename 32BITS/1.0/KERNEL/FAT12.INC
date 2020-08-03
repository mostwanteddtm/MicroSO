
;********************************************************************************************************************|
;                                                        								                             |
;       				   Funcao responsavel por colocar o Kernel32 na memoria    			                 	 	 |
;     				          	Inicio do desenvolvimento em 19-12-2017       				                         |
;                        			Por: Marcos Roberto da Costa                      			                     |
;                                                        								                             |
;********************************************************************************************************************|

DT_SEG SEGMENT PUBLIC 'DATA' USE32

	;============================== DATA AREA ===================================================================

	bpbTotalSetoresPorTrilha  		DW		18                      			; 18 sectors per track (36/cylinder) 
	bpbTotalCabecasNoDisco    		DW		2                       			; 2 heads per cylinder 
												
	bsDriveDisquete           		DB		0                       			; drive number (for drive A) 
	bsCabecaDisco             		DB		0                       			; reserved (current head) 

	Cluster                         DW      0                            
																							
	Cabeca                          DB      ?                        
	Trilha                          DB      ?                        
	Setor                           DB      ? 

	KernelAddrRM    				DW		9000h 	
	
	DiretorioRaiz                   DW      ?                      				; endereco LBA do diretorio Raiz                    		
	TotalSetoresDiretorioRaiz       DW      32									; 14 Stores com 16 Arquivos/DIRs = 224 Arquivos
																				; 16 Arq/DIRs de 32 Bytes = 512 Bytes = 1 Setor	
																				
	;=============================================================================================================

DT_SEG ENDS

RM_SEG SEGMENT PUBLIC 'CODE' USE16
	ASSUME CS:RM_SEG, SS:ST_SEG, DS:DT_SEG
	
	;============================== FUNCAO PRINCIPAL =============================================================
	
	LOAD_KERNEL32 PROC
	
									PUSHA
									MOV		AX, DT_SEG
									MOV		DS, AX
									XOR		AX, AX
									MOV		ES, AX
									
									MOV		DI, 7E00h
		PROXIMOSETOR: 				                  
                            
		CONT:        				MOV     SI, OFFSET KernelArquivo        	; "KRNLDR  SYS" 
									PUSH    DI
									MOV     CX, 0Bh
									REPE    CMPSB
									JE      LEIAFAT
									POP     DI
									ADD     DI, 20h 
									LOOP    CONT
							
									DEC     DS:[TotalSetoresDiretorioRaiz]   	; 14 - representa o Total de Setores do diretorio Raiz
									CMP     DS:[TotalSetoresDiretorioRaiz], 0  	; Verifica se percorreu os 14 setores
									JE      SAIR                            	; Percorreu todos e nao encontrou o arquivo
									INC     DS:[DiretorioRaiz]                 	; Ainda nao percorreu os 14 setores e vai para o proximo
									MOV     AX, DiretorioRaiz
									JMP     PROXIMOSETOR
										
									JMP     SAIR                            	; Nao encontrou o arquivo
																						
		LEIAFAT:                    POP     DI                              	  
									XOR     DX, DX                          	  
									MOV     AX, ES:[DI + 001Ah]             	; Leio o 26 Byte, para Encontrar o cluster inicial do arquivo  
									MOV		DS:[Cluster], AX	
									MOV     BX, 8400h	
									PUSH 	BX	
																						
		PROXIMOCLUSTER:             MOV     BX, DS:[KernelAddrRM] 	
																														
									MOV     AX, 31d                         	; A regra abaixo consiste em:
									MOV     DX, DS:[Cluster]                	; Endereco LBA da area de dados dos arquivos
									ADD     AX, DX                          	; que se inicia no Setor 33 - 2 primeiros Clusters reservados = 31
									CALL    LeiaDisco                       	; Mais Cluster indicado na tabela FAT. 
																				; Entao 31 + 2 = 33 para o primeiro arquivo no disco
																				; Lembrando que cada Cluster e um Setor no Disquete  
									POP		BX	
									PUSH	BX	
									MOV     AX, DS:[Cluster]                	     
									MOV     CX, AX                          	  
									MOV     DX, AX                          	  
									SHR     DX, 1                           	; calculo para leitura de endereco de memoria
									ADD     CX, DX                          	; onde estara a informacao do proximo cluster
									ADD     BX, CX                          	; cluster atual / 2 + cluster
									MOV     DX, ES:[BX] 	
	
									TEST    AX, 0001h                       	  
									JNZ     CLUSTERPAR                      	  
																						
		CLUSTERIMPAR:               AND     DX, 0000111111111111b           	; Considera apenas os 12 bits da direita
									JMP     DONE                            	  
																						
		CLUSTERPAR:                 SHR     DX, 0004h                       	; Considera apenas os 12 bits da esquerda
																					  
		DONE:                       ADD     [KernelAddrRM], 200h              
									MOV     [Cluster], DX                     
									MOV     AX, [Cluster]
									INC     LenKernel32
									CMP     DX, 0FF0h
									JB      PROXIMOCLUSTER 
									
									POP		BX
									POPA
									RET
									
		SAIR::						INT		19h									; Label Publico SAIR
	LOAD_KERNEL32 ENDP
	
	;============================== FUNCOES LOCAIS ===============================================================

		;---------------------------------------------------------------------------------------------------------------|
		;                                                                                                               |
		;                                       Converter LBA para CHS                                                  |
		;                                       AX=>LBA Endereco de convercao	19                                   	|        
		;                                                                   	AL  DL                                  |
		;    	setor     = (setor MOD setores por trilha) + 1                 (19 mod 18) = 1      + 1   = 2           |
		;    	cabeca    = (setor / setores por trila) MOD numero de cabecas  (19/18) = 1(sobra 1) mod 2 = 1           |  
		;    	trilha    = setor / (setores por trilha * numero de cabecas)   19 / (18*2) = 36 19 / 36   = 0           | 
		;                                                                                                               |
		;---------------------------------------------------------------------------------------------------------------|
								
		LEIADISCO PROC
										CALL	CONVERTLBACHS               
										MOV 	AH, 02h                     
										MOV 	AL, 01h                     
										MOV 	CH, DS:[Trilha]                	; C - Clylinder / Track
										MOV 	DH, DS:[Cabeca]                	; H - Head
										MOV 	CL, DS:[Setor]                 	; S - Sector
										MOV 	DL, DS:[bsDriveDisquete]
										INT 	13h 
										JC  	SAIR 
										RET
		LEIADISCO ENDP
		
	;================================================================================================================
												
		CONVERTLBACHS PROC                  
										XOR 	DX, DX                
										DIV 	DS:[bpbTotalSetoresPorTrilha]  
										INC 	DL                    
										MOV 	DS:[Setor], DL
										XOR 	DX, DX                
										DIV 	DS:[bpbTotalCabecasNoDisco] 
										MOV 	DS:[Cabeca], DL
										MOV 	DS:[Trilha], AL 
										RET 
		CONVERTLBACHS ENDP
	
	;================================================================================================================
	
RM_SEG ENDS