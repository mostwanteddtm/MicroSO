.386 

CSEG SEGMENT PUBLIC 'CODE' USE16
	ASSUME CS:CSEG, DS:CSEG, ES:CSEG, SS:CSEG
	
	ORG 0
	
	;========================================= CODE AREA ============================================================
	
	ENTRY PROC NEAR

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Boot sector starts here ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

EntryPoint: 	jmp     start                   ; MS-DOS/Windows checks for this jump
				nop
bsOemName               DB      "MicroSO2"      ; 0x03

;;;;;;;;;;;;;;;;;;;;;;
;; BPB1 starts here ;;
;;;;;;;;;;;;;;;;;;;;;;

bpbBytesPerSector       	DW ?  				; 0x0B
bpbSectorsPerCluster    	DB ?  				; 0x0D
bpbReservedSectors      	DW ?  				; 0x0E
bpbNumberOfFATs         	DB ?  				; 0x10
bpbRootEntries          	DW ?  				; 0x11
bpbTotalSectors         	DW ?  				; 0x13
bpbMedia                	DB ?  				; 0x15
bpbSectorsPerFAT        	DW ?  				; 0x16
bpbSectorsPerTrack      	DW ?  				; 0x18
bpbHeadsPerCylinder     	DW ?				; 0x1A
bpbHiddenSectors        	DD ?  				; 0x1C
bpbTotalSectorsBig      	DD ?  				; 0x20

;;;;;;;;;;;;;;;;;;;;
;; BPB1 ends here ;;
;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;
;; BPB2 starts here ;;
;;;;;;;;;;;;;;;;;;;;;;

bsSectorsPerFAT32           DD ?         		; 0x24
bsExtendedFlags             DW ?         		; 0x28
bsFSVersion                 DW ?         		; 0x2A
bsRootDirectoryClusterNo    DD ?         		; 0x2C
bsFSInfoSectorNo            DW ?         		; 0x30
bsBackupBootSectorNo        DW ?         		; 0x32
bsreserved              	DB 12 DUP(?)        ; 0x34
bsDriveNumber               DB ?         		; 0x40
bsreserved1                 DB ?         		; 0x41
bsExtendedBootSignature     DB ?         		; 0x42
bsVolumeSerialNumber        DD ?         		; 0x43
bsVolumeLabel               DB "NO NAME    "    ; 0x47
bsFileSystemName            DB "FAT32   "       ; 0x52

;;;;;;;;;;;;;;;;;;;;
;; BPB2 ends here ;;
;;;;;;;;;;;;;;;;;;;;

fatStart					DD ?				; FIRST FAT SECTOR
rootStart					DD ?           		; FIRST ROOT SECTOR
Cluster						DD ?
ImageLoadOff				DW 0
ImageLoadSeg				DW 60h

ImageName					DB 'KERNEL  SYS'


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Boot sector code starts here ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

START:
        CLD
		
		MOV		AX, 9C00h						; PROXIMO PASSO, SERA IMPLEMENTAR O TOPO DE MEMORIA
        MOV     ES, AX          				
        				
        SUB     AX, 40h  						; PRECISO ENTENDER MELHOR A UTILIZAÇÃO DA PILHA
        MOV     SS, AX          				
        MOV     SP, 400h        				; BEM COMO OS REGISTRADORES SS e SP
		
		MOV     CX, 100h						; APOS O BIOS POST COPIO O BOOT DE 07C0:00 PARA 9C00:0000
        MOV     SI, 7C00h						; POIS O ACESSO AO ENDERECO DO BOOT E RESTRITO
        XOR     DI, DI
        MOV     DS, DI
        REP     MOVSW

        PUSH    ES
        PUSH    MAIN
        RETF

MAIN:
        MOV		AX, CS
		MOV		DS, AX
		MOV		ES, AX
		
		MOV     WORD PTR DAPS[6], AX
		MOV		AL, BYTE PTR bpbSectorsPerCluster
		CBW
		MOV		WORD PTR DAPS[2], AX
		MOV		BYTE PTR [bsDriveNumber], DL

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

		MOV		EAX, DWORD PTR rootStart
		MOV		DWORD PTR DAPS[8], EAX
		CALL	READDISK							; 0200h ou 9F80h:0200h
		
		MOV		CX, 10h								; 16 ARQUIVOS POR SETOR LID
@@:        					
		MOV     SI, OFFSET ImageName        		; "KERNEL  SYS" 
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
		MOV		DWORD PTR Cluster, EAX
		
NEXTCLUSTER:

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

		MOV		EAX, DWORD PTR Cluster
		MOV		BX, 4								; QUE IRA ACESSAR A TABELA FAT. COMO, CADA ENTRADA NA TABELA FAT TEM 4 BYTES
		MUL		BX									; MULTIPLICO O INDICE PELA QUANTIDADE DE BYTES DE CADA INDICE
													; EX: INDICE 3h * 4 BYTES POR INDICE = 0Ch
		
		PUSH	AX									; SALVO O OFFSET QUE DEVERA SER ACESSADO NO ROOT
		
		MOV		AX, WORD PTR [fatStart]				; ARMAZENO NO ROOT TEMPORARIAMENTE O CONTEUDO DA TABELA FAT
		MOV		WORD PTR DAPS[8], AX
        
		MOV		AX, CS
		MOV     WORD PTR DAPS[6], AX

		MOV		WORD PTR DAPS[4], 200h
		CALL	READDISK
		
		POP		SI									; RESTAURO O OFFSET QUE CONTEM O CLUSTER INICIAL DO ARQUIVO
		ADD		SI, WORD PTR DAPS[4]				; ROOT 07C0h:0200h + OFFSET DO INDICE DA TABELA FAT 0Ch
		LODSD										; CARREGO EM EAX O CONTEUDO DE 07C0h:020Ch

		CMP		EAX, 0FFFFFFFh
		JE		IMAGELOADED
		
		MOV		DWORD PTR Cluster, EAX
		ADD		ImageLoadOff, 1000h
		ADD		rootStart, 1000h
		
		JMP		NEXTCLUSTER

IMAGELOADED:
		
		XOR     BX, BX                            
		MOV     AX, ImageLoadSeg                         
		MOV     ES, AX                            
		MOV     DS, AX

		ADD     AX, DS:[08h]            			; AX = IMAGE BASE
		MOV     CX, DS:[06h]            			; CX = RELOC ITEMS
		MOV     BX, DS:[18h]            			; BX = RELOC TABLE POINTER
	
		JCXZ    RelocationDone	
	
ReloCycle:							
		MOV     DI, DS:[BX]             			; DI = ITEM OFS
		MOV     DX, DS:[BX+2]           			; DX = ITEM SEG (REL)
		ADD     DX, AX                  			; DX = ITEM SEG (ABS)
	
		PUSH    DS			
		MOV     DS, DX                  			; DS = DX
		ADD     DS:[DI], AX             			; FIXUP
		POP     DS			
	
		ADD     BX, 4                   			; POINT TO NEXT ENTRY
		LOOP    ReloCycle	
	
RelocationDone:						
		MOV     BX, AX	
		ADD     BX, DS:[0Eh]	
		MOV     SS, BX                  			; SS FOR EXE
		MOV     SP, DS:[10h]            			; SP FOR EXE
	
		ADD     AX, DS:[16h]            			; CS
		PUSH    AX			
		PUSH    DS:[14h]                			; IP
										
Run:	
		MOV     DL, [bsDriveNumber]                 ; LET PROGRAM KNOW BOOT DRIVE
		RETF	
		
READDISK:
		MOV 	SI, OFFSET DAPS                		; LOAD DAPS STRUCT TO DS:SI
		MOV 	AH, 42h                				; READ FUNCTIONS (AL IGNORED)
		MOV		DL, BYTE PTR [bsDriveNumber]
		INT 	13h
		JC 		short ERROR 						; IF SOMETHING GOES WRONG...
		RET

ERROR:
		MOV		AX, 0E42h
		INT		10h
		JMP		$
		
DAPS 	DB 		10h              					; size of DAP (set this to 10h)
        DB 		0                					; unused, should be zero
        DW 		8									; number of sectors to be read, (some Phoenix BIOSes are limited to a maximum of 127 sectors)
		DW 		0200h			 					; segment:offset pointer to the memory buffer to which sectors will be transferred 
		DW 		0				 					; (note that x86 is little-endian: if declaring the segment and offset separately, the offset must be declared before the segment)
		DQ 		0			 	 					; absolute number of the start of the sectors to be read (1st sector of drive has number 0)

		ORG 	510

		DW      0AA55h          
ENTRY ENDP
	
	;================================================================================================================

CSEG ENDS

END ENTRY