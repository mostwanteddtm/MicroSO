
;********************************************************************************************************************|
;                                                        								                             |
;       				   Funcao responsavel por colocar o Kernel32 na memoria    			                 	 	 |
;     				          	Inicio do desenvolvimento em 08-12-2018       				                         |
;                        			Por: Marcos Roberto da Costa                      			                     |
;                                                        								                             |
;********************************************************************************************************************|

DATASEG16 SEGMENT USE16

	;============================== DATA AREA ===================================================================
	
	TEMPBUFFER				EQU 2000h					; OFFSET TEMPORARIO PRA CARREGAR O ROOT DIR E A FAT
														; ESSE NUMERO TEM QUE SEMPRE SER MAIOR QUE SIZEOFKERNEL * 2
			
	bpbSectorsPerCluster   	DB ?  						; 0x0D
	bpbReservedSectors     	DW ?  						; 0x0E
	bpbNumberOfFATs        	DB ?  						; 0x10
	bpbRootEntries          DW ?  						; 0x11
			
	bpbHiddenSectors       	DD ?  						; 0x1C
				
	bsSectorsPerFAT32      	DD ?          				; 0x24
	bsDriveNumber          	DB ?         				; 0x40
	
	
	fatStart				DD ?						; FIRST FAT SECTOR
	rootStart				DD ?           				; FIRST ROOT SECTOR
		                       
	CLUSTER					DD ?
	
	ImageLoadSeg        	DW 0h     	
	ImageLoadOff			DW 9000h

	ImageName				DB 'KERNEL32EXE'
	
	HEXTAB 					DB '0123456789ABCDEF'
	
	DAPS 					DB 10h              		; SIZE OF DAP (SET THIS TO 10H)
							DB 0                		; UNUSED, SHOULD BE ZERO
							DW 8						; NUMBER OF SECTORS TO BE READ, (SOME PHOENIX BIOSES ARE LIMITED TO A MAXIMUM OF 127 SECTORS)
							DW TEMPBUFFER				; SEGMENT:OFFSET POINTER TO THE MEMORY BUFFER TO WHICH SECTORS WILL BE TRANSFERRED 
							DW ?				 		; (NOTE THAT X86 IS LITTLE-ENDIAN: IF DECLARING THE SEGMENT AND OFFSET SEPARATELY, THE OFFSET MUST BE DECLARED BEFORE THE SEGMENT)
							DQ ?			 	 		; ABSOLUTE NUMBER OF THE START OF THE SECTORS TO BE READ (1ST SECTOR OF DRIVE HAS NUMBER 0)
			                   
	
	
	;=============================================================================================================

DATASEG16 ENDS

CODESEG16 SEGMENT USE16
	
	;============================== FUNCAO PRINCIPAL =============================================================
	
	LOAD_KERNEL32 PROC
	
		MOV		AX, CS
		MOV     WORD PTR DAPS[6], AX 

		CALL	SETUPBPB

		MOV		SI, WORD PTR [bpbHiddenSectors]
		MOV		DI, WORD PTR [bpbHiddenSectors+2]
		ADD		SI, WORD PTR [bpbReservedSectors]
		ADC		DI, BYTE PTR 0
	
		MOV		WORD PTR [fatStart], SI
		MOV		WORD PTR [fatStart+2], DI			; ENDERECO ONDE ESTA LOCALIZADO A FAT	

		MOV		AL, BYTE PTR [bpbNumberOfFATs]
		CBW
		PUSH	AX
		MUL		WORD PTR [bsSectorsPerFAT32+2]
		ADD		DI, AX
		POP		AX
		MUL		WORD PTR [bsSectorsPerFAT32]
		ADD		AX, SI
		ADC		DX, DI
		MOV		WORD PTR [rootStart], AX
		MOV		WORD PTR [rootStart+2], DX			; ENDERECO DO DIRETORIO RAIZ
		
		MOV		DI, WORD PTR DAPS[4]				; OFFSET ONDE SERA CARREGADO O DIRETORIO RAIZ

NEXTSECT:

		MOV		AX, WORD PTR rootStart
		MOV		WORD PTR DAPS[8], AX
		CALL	READDISK							; OFFSET TEMPBUFFER

		MOV		CX, 10h								; 16 ARQUIVOS POR SETOR LID
@@:        					
		MOV     SI, OFFSET ImageName        		; "STARTUP BIN" 
		PUSH    DI
		MOV		DX, CX
		MOV     CX, 0Bh
		REPE    CMPSB
		JE      READFAT
		POP     DI
		ADD     DI, 20h 
		MOV		CX, DX
		LOOP    @b
		
		DEC		bpbRootEntries						; 14 SETORES DO DIRETORIO RAIZ
		CMP		bpbRootEntries, 0					; PRECISO ACERTAR ISSO DEPOIS
		JE		ERROR
		
		ADD		WORD PTR rootStart, 1000h
		MOV		AX, WORD PTR rootStart
		
		JMP		NEXTSECT
		
READFAT:

		POP     DI  
		ADD		DI, 1Ah
		
		XOR		EAX, EAX							; SETOR DE DADOS DO ARQUIVO CONSISTE EM:
		MOV		AX, [DI]							; SETOR  = (CLUSTER INICIAL - 2) * SETOR POR CLUSTER + DIRETORIO RAIZ
		MOV		DWORD PTR CLUSTER, EAX
		
NEXTCLUSTER:

		INC		LENKERNEL32

		MOV		BX, 2								
		SUB		AX, BX
		XOR		BX, BX
		MOV		BL, BYTE PTR bpbSectorsPerCluster
		MUL		BX
		ADD		AX, WORD PTR rootStart

		MOV		WORD PTR DAPS[8], AX				; SETOR LBA INICIAL DE DADOS DO KERNEL
		
		MOV		AX, WORD PTR ImageLoadOff			; OFFSET ONDE SERA CARREGADO O KERNEL
		MOV		WORD PTR DAPS[4], AX
		
		MOV		AX, ImageLoadSeg					; SEGMENTO ONDE SERA CARREGADO O KERNEL
		MOV		WORD PTR DAPS[6], AX
		CALL	READDISK

		MOV		EAX, DWORD PTR CLUSTER
		MOV		BX, 4								; QUE IRA ACESSAR A TABELA FAT. COMO, CADA ENTRADA NA TABELA FAT TEM 4 BYTES
		MUL		BX									; MULTIPLICO O INDICE PELA QUANTIDADE DE BYTES DE CADA INDICE
													; EX: INDICE 3h * 4 BYTES POR INDICE = 0Ch
		
		PUSH	AX									; SALVO O OFFSET QUE DEVERA SER ACESSADO NO ROOT
		
		MOV		AX, WORD PTR [fatStart]				; ARMAZENO NO ROOT TEMPORARIAMENTE O CONTEUDO DA TABELA FAT
		MOV		WORD PTR DAPS[8], AX
        
		MOV		AX, CS
		MOV     WORD PTR DAPS[6], AX

		MOV		WORD PTR DAPS[4], TEMPBUFFER
		CALL	READDISK
		
		POP		SI									; RESTAURO O OFFSET QUE CONTEM O CLUSTER INICIAL DO ARQUIVO
		ADD		SI, WORD PTR DAPS[4]				; ROOT 07C0h:0200h + OFFSET DO INDICE DA TABELA FAT 0Ch
		LODSD										; CARREGO EM EAX O CONTEUDO DE 07C0h:020Ch

		CMP		EAX, 0FFFFFFFh
		JE		IMAGELOADED
		
		MOV		DWORD PTR CLUSTER, EAX
		ADD		ImageLoadOff, 1000h
		ADD		rootStart, 1000h
		
		JMP		NEXTCLUSTER

IMAGELOADED:

		RET			
		
READDISK:
		mov 	si, OFFSET DAPS                		; LOAD DAPS STRUCT TO DS:SI
		mov 	ah, 42h                				; READ FUNCTIONS (AL IGNORED)
		mov		dl, BYTE PTR [bsDriveNumber]
		int 	13h
		jc 		short ERROR 						; IF SOMETHING GOES WRONG...
		RET

ERROR:
		MOV		AX, 0E45h
		INT		10h
		JMP		$
			
SETUPBPB:	
	
		PUSH	DS	
			
		MOV		AX, 9C00h							; LOCAL ONDE O BOOT FOI TRANSFERIDO
		MOV		DS, AX	
		MOV		SI, 0Dh	
			
		MOV		DI, OFFSET bpbSectorsPerCluster		; bpbSectorsPerCluster  DB ? 0x0D						
		MOV		CX, 3                           	; bpbReservedSectors    DW ? 0x0E~0x0F
	@@: MOVSW                                   	; bpbNumberOfFATs       DB ? 0x10
		LOOP	@b                              	; bpbRootEntries        DW ? 0x11~0x12
			
		ADD		SI, 09h								; DI = 0x13 + 0x09 		= 	 0x1C
		MOVSD										; bpbHiddenSectors      DD ? 0x1C~0x1F
			
		ADD		SI, 04h								; DI = 0x20 + 0x04 		= 	 0x24
		MOVSD										; bsSectorsPerFAT32     DD ? 0x24~0x27
		
		ADD		SI, 18h								; DI = 0x28 + 0x18 		= 	 0x40
		MOVSB										; bsDriveNumber         DB ? 0x40
		
		POP		DS
		
		RET

	LOAD_KERNEL32 ENDP
	
CODESEG16 ENDS