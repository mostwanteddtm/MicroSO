#masm#
.286
.MODEL TINY
;********************************************************************************************************************|
;                                                        								                             |
;       				 Programa responsavel por realizar o BOOT via Floppy Disk    			                     |
;     				          	Inicio do desenvolvimento em 09-09-2017       				                         |
;                        			Por: Marcos Roberto da Costa                      			                     |
;                                                        								                             |
;********************************************************************************************************************|  

CSEG SEGMENT PUBLIC 'CODE' USE16
	ASSUME CS:CSEG, DS:CSEG, ES:CSEG, SS:CSEG
	
	ORG 100h
	
	;========================================= CODE AREA ============================================================
	
	START PROC NEAR
	
		EntryPoint:						JMP		MAIN 

		;============================== BPB - BIOS PARAMETER BLOCK ==================================================
	
		bpbOEM                    		DB		'MICROSO2'                  	; OEM disk label (8 bytes) 
												
		bpbBytesPorSetor          		DW		512                     		; bytes per sector 
		bpbSetoresPorCluster      		DB		1                       		; sectors per cluster 
		bpbSetoresReservados      		DW		1                       		; reserved sectors (1 for boot code) 
		bpbTotalFATs              		DB		2                       		; number of file allocation tables 
		bpbTotalDiretoriosArquivos		DW		224                     		; number of root directory entries 
		bpbTotalSetoresNoDisco    		DW		2880                    		; number of logical sectors 
		bpbTabelaDescricaoDisco   		DB		0f8h                    		; media descriptor byte 
		bpbTotalSetoresPorFAT     		DW		9                       		; 9 sectors per FAT 
		bpbTotalSetoresPorTrilha  		DW		18                      		; 18 sectors per track (36/cylinder) 
		bpbTotalCabecasNoDisco    		DW		2                       		; 2 heads per cylinder 
		bpbSetoresOcultos         		DD		0                       		; no hidden sectors 
		bpbOutros                 		DD		0                       		; no large sectors 
												
		bsDriveDisquete           		DB		0                       		; drive number (for drive A) 
		bsCabecaDisco             		DB		0                       		; reserved (current head) 
		bsAssinaturaDisquete      		DB		29h                     		; drive signature (29h for floppy) 
		bsNumeroSerie             		DD		0                       		; volume ID (serial number) 
		bsVolume                  		DB		'MICROS0v2.0'           		; volume label (11 bytes) 
		bsSistemaArquivos         		DB		'FAT12   '              		; file system type (8 bytes) 
	
		;=============================  VARIAVEIS LOCAIS =============================================================
																					
		Cluster                         DW      0                            
																								
		Cabeca                          DB      ?                        
		Trilha                          DB      ?                        
		Setor                           DB      ?                        
																								
		FileBuffer                      DW      0h                      		
		FindFile                        DB      "MAIN    EXE"           		; nome do arquivo (11 bytes)
	                                                                            
		DiretorioRaiz                   DW      ?                      			; endereco LBA do diretorio Raiz                    		
		TotalSetoresDiretorioRaiz       DW      ?								; 14 Stores com 16 Arquivos/DIRs = 224 Arquivos
																				; 16 Arq/DIRs de 32 Bytes = 512 Bytes = 1 Setor																					
																							
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
								
		LeiaDisco:                      CALL	ConvertLBACHS               
										MOV 	AH, 02h                     
										MOV 	AL, 01h                     
										MOV 	CH, [Trilha]                	; C - Clylinder / Track
										MOV 	DH, [Cabeca]                	; H - Head
										MOV 	CL, [Setor]                 	; S - Sector
										MOV 	DL, [bsDriveDisquete]
										INT 	13h 
										JC  	Sair 
										RET	
												
		ConvertLBACHS:                  XOR 	DX, DX                
										DIV 	[bpbTotalSetoresPorTrilha]  
										INC 	DL                    
										MOV 	[Setor], DL
										XOR 	DX, DX                
										DIV 	[bpbTotalCabecasNoDisco] 
										MOV 	[Cabeca], DL
										MOV 	[Trilha], AL 
										RET  
		
		;============================== FUNCAO PRINCIPAL =============================================================
		        
		MAIN:                      		MOV     AX, CS                      	
										MOV     DS, AX                         	
										MOV     ES, AX                         	
											
										MOV     AX, 0
									    MOV     SS, AX
										MOV     SP, 0FFFFh 
										
										XOR     CX, CX							; CALCULA O TAMANHO DO DIRETORIO RAIZ E ARMAZENA O VALOR EM CX
										XOR     DX, DX
										MOV     AX, 0020h                       ; 32 bytes cada informacao sobre pasta ou arquivo
										MUL     [bpbTotalDiretoriosArquivos]    ; total de diretorios ou arquivos
										DIV     [bpbBytesPorSetor]              ; total de bytes por setor
										XCHG    AX, CX							; Total_Setores_Diretorio_Raiz = 
																				; (TotalDiretoriosArquivos * 32) / Bytes_Por_Setor
										
										MOV		WORD PTR [TotalSetoresDiretorioRaiz], CX
										
										MOV     AL, [bpbTotalFATs]              ; Total de FATs (2)
										MUL     [bpbTotalSetoresPorFAT]         ; Total de Setores por FAT (9)
										ADD     AX, [bpbSetoresReservados]      ; Total de Setores Reservados
										MOV     WORD PTR [DiretorioRaiz], AX    ; Inicio_Diretorio_Raiz = 
																				; TotalSetoresReservados + (TotalFATs * TotalSetoresPorFAT)
																				 

										MOV     BX, 0500h                       ; OFFSET onde os nomes dos Arquivos/DIRs sao carregados
										MOV     DI, 0500h                       ; OFFSET onde sera comparado com o nome da imagem do TESTE.EXE
																				; Endereco do Diretorio Raiz = CS:0500h
										
		;===============================================================================================================
										
		ProximoSetor: 					CALL    LeiaDisco                  
                            
		Cont:        					MOV     SI, OFFSET FindFile             ; "TESTE   EXE" 
										PUSH    DI
										MOV     CX, 0Bh
										REPE    CMPSB
										JE      LeiaFAT
										POP     DI
										ADD     DI, 20h 
										LOOP    Cont
							
										DEC     [TotalSetoresDiretorioRaiz]     ; 14 - representa o Total de Setores do diretorio Raiz
										CMP     [TotalSetoresDiretorioRaiz], 0  ; Verifica se percorreu os 14 setores
										JE      Sair                            ; Percorreu todos e nao encontrou o arquivo
										INC     [DiretorioRaiz]                 ; Ainda nao percorreu os 14 setores e vai para o proximo
										MOV     AX, DiretorioRaiz
										JMP     ProximoSetor
											
										JMP     Sair                            ; Nao encontrou o arquivo
																						  
		LeiaFAT:                    	POP     DI                                
										XOR     DX, DX                            
										MOV     AX, [DI + 001Ah]                ; Leio o 26 Byte, para Encontrar o cluster inicial do arquivo  
										MOV     BX, 0800h                       ; Endereco da tabela FAT = 0:7C00h + 0800h = 0:8400h  
										PUSH    BX                                
																						  
		ProximoCluster:             	POP     BX                                
										MOV     [cluster], AX                   ; Armazeno o cluster inicial 
										XOR     DX, DX                            
										DIV     [bpbBytesPorSetor]              ; Divido o cluster inicial pelo numero de bytes por setor
										INC     AL                              ; Pego o resultado e adiciono 1
																				; Ex: cluster 2 / 512 = 0 + 1 = 1 - LBA 2
										CALL    LeiaDisco                       ; Outro Ex: 1081 / 512 = 2 + 1 = 3 - LBA 3 
																				  
										PUSH    BX                                
										PUSH    ES                                
										MOV     BX, [FileBuffer]                
																				  
										MOV     AX, 0050h                       ; O KRNLDR.SYS sera carregado em 0050:0000
										MOV     ES, AX                                          
										MOV     AX, 31d                         ; A regra abaixo consiste em:
										MOV     DX, [Cluster]                   ; Endereco LBA da area de dados dos arquivos
										ADD     AX, DX                          ; que se inicia no Setor 33 - 2 primeiros Clusters reservados = 31
										CALL    LeiaDisco                       ; Mais Cluster indicado na tabela FAT. 
																				; Entao 31 + 2 = 33 para o primeiro arquivo no disco
																				; Lembrando que cada Cluster e um Setor no Disquete
																				  
										POP     ES                                
										POP     BX                                
										PUSH    BX                                
																				  
										MOV     AX, [cluster]                     
										MOV     CX, AX                            
										MOV     DX, AX                            
										SHR     DX, 1                           ; calculo para leitura de endereco de memoria
										ADD     CX, DX                          ; onde estara a informacao do proximo cluster
										ADD     BX, CX                          ; cluster atual / 2 + cluster
										MOV     DX, [BX]                          
																				  
										TEST    AX, 0001h                         
										JNZ     ClusterPar                        
																						  
		ClusterImpar:               	AND     DX, 0000111111111111b           ; Considera apenas os 12 bits da direita
										JMP     DONE                              
																						  
		ClusterPar:                 	SHR     DX, 0004h                       ; Considera apenas os 12 bits da esquerda
																						  
		DONE:                       	ADD     [FileBuffer], 200h              
										MOV     [cluster], DX                     
										MOV     AX, [cluster]                     
										CMP     DX, 0FF0h                         
										JB      ProximoCluster                    
																				  
										XOR     BX, BX                            
										MOV     AX, 0050h                         
										MOV     ES, AX                            
										MOV     DS, AX
			
										ADD     AX, DS:[08h]            		; ax = image base
										MOV     CX, DS:[06h]            		; cx = reloc items
										MOV     BX, DS:[18h]            		; bx = reloc table pointer
			
										JCXZ    RelocationDone

		ReloCycle:						MOV     DI, DS:[BX]             		; DI = ITEM OFS
										MOV     DX, DS:[BX+2]           		; dx = item seg (rel)
										ADD     DX, AX                  		; dx = item seg (abs)
					
										PUSH    DS		
										MOV     DS, DX                  		; ds = dx
										ADD     DS:[DI], AX             		; fixup
										POP     DS		
					
										ADD     BX, 4                   		; point to next entry
										LOOP    ReloCycle

		RelocationDone:					MOV     BX, AX
										ADD     BX, DS:[0Eh]
										MOV     SS, BX                  		; ss for EXE
										MOV     SP, DS:[10h]            		; sp for EXE
					
										ADD     AX, DS:[16h]            		; cs
										PUSH    AX		
										PUSH    DS:[14h]                		; ip
										
		Run:							MOV     DL, 0                   		; let program know boot drive
										STI
										RETF	                                     
																				  
		Sair:   	                    INT     19h                             ; Sai com erro, pois nao carregou o KRNLDR.SYS
																				  
										;ORG     510                            ; db      510 - ($ - EntryPoint) dup(0)
										;DW      0AA55h
										
		;============================================================================================================
	
	START ENDP
	
	;================================================================================================================

CSEG ENDS

END START
