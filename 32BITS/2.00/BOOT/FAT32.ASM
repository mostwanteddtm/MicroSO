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
bsOemName               DB      "BootProg"      ; 0x03

;;;;;;;;;;;;;;;;;;;;;;
;; BPB1 starts here ;;
;;;;;;;;;;;;;;;;;;;;;;

bpbBytesPerSector       DW 	   0200h  	; 0x0B
bpbSectorsPerCluster    DB 	     08h  	; 0x0D
bpbReservedSectors      DW 	   0020h  	; 0x0E
bpbNumberOfFATs         DB 	     02h  	; 0x10
bpbRootEntries          DW 	   000Eh  	; 0x11
bpbTotalSectors         DW 	   0000h  	; 0x13
bpbMedia                DB 	    0F8h  	; 0x15
bpbSectorsPerFAT        DW 	   0000h  	; 0x16
bpbSectorsPerTrack      DW 	   003Fh  	; 0x18
bpbHeadsPerCylinder     DW 	   0040h  	; 0x1A
bpbHiddenSectors        DD 0000003Fh  	; 0x1C
bpbTotalSectorsBig      DD 001FFDC1h  	; 0x20

;;;;;;;;;;;;;;;;;;;;
;; BPB1 ends here ;;
;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;
;; BPB2 starts here ;;
;;;;;;;;;;;;;;;;;;;;;;

bsSectorsPerFAT32               DD        000007FEh         ; 0x24
bsExtendedFlags                 DW            0000h         ; 0x28
bsFSVersion                     DW            0000h         ; 0x2A
bsRootDirectoryClusterNo        DD        00000002h         ; 0x2C
bsFSInfoSectorNo                DW            0001h         ; 0x30
bsBackupBootSectorNo            DW            0006h         ; 0x32
bsreserved              		DB 12 DUP(?)                ; 0x34
bsDriveNumber                   DB              80h         ; 0x40
bsreserved1                     DB              00h         ; 0x41
bsExtendedBootSignature         DB        		29h         ; 0x42
bsVolumeSerialNumber            DD        00000000h         ; 0x43
bsVolumeLabel                   DB        "NO NAME    "     ; 0x47
bsFileSystemName                DB        "FAT32   "        ; 0x52

;;;;;;;;;;;;;;;;;;;;
;; BPB2 ends here ;;
;;;;;;;;;;;;;;;;;;;;

fatSector						DD		? 					; last accessed sector of the FAT
fatStart						DD		?					; first FAT sector
rootStart						DD 		?                   ; first data sector
fatSecmask                      DW		?                   ; number of clusters in a FAT sector - 1
fatSecshift                     DB		?                   ; fat_secmask+1 = 2^fat_secshift

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Boot sector code starts here ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

start:
        CLD
		
		MOV		AX, 7C0h
		MOV		DS, AX
		MOV		ES, AX
		
		MOV     FS, AX
		MOV     GS, AX

		;----------------------------------------------------
		; CREATE STACK
		;----------------------------------------------------

		MOV     AX, 0000h									; SET THE STACK
		MOV     SS, AX
		MOV     SP, 0FFFFh
		
		MOV		BYTE PTR [bsDriveNumber], DL
		
		MOV		SI, WORD PTR [bpbHiddenSectors]
		MOV		DI, WORD PTR [bpbHiddenSectors+2]
		ADD		SI, WORD PTR [bpbReservedSectors]
		ADC		DI, BYTE PTR 0
	
		MOV		WORD PTR [fatStart], SI
		MOV		WORD PTR [fatStart+2], DI					; ENDERECO ONDE ESTA LOCALIZADO A FAT	

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
		MOV		WORD PTR [rootStart+2], DX					; ENDERECO DO DIRETORIO RAIZ

NEXTSECT:
		
		MOV		DI, WORD PTR ROOT				; Armazena o OFFSET onde vai carregar o Root
		MOV		BX, WORD PTR ROOT
		CALL	READDISK							; 0200h ou 0000:7E00h
		
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
		
		ADD		WORD PTR rootStart, 200h
		MOV		AX, WORD PTR rootStart
		
		JMP		NEXTSECT
		
READFAT:
		POP     DI  
		ADD		DI, 1Ah
		
		XOR		EAX, EAX							; SETOR DE DADOS DO ARQUIVO CONSISTE EM:
		MOV		AX, [DI]							; SETOR  = (CLUSTER INICIAL - 2) * SETOR POR CLUSTER + DIRETORIO RAIZ
		MOV		DWORD PTR CLUSTER, EAX
		
NEXTCLUSTER:

		MOV		BX, 2								
		SUB		AX, BX
		XOR		BX, BX
		MOV		BL, BYTE PTR bpbSectorsPerCluster
		MUL		BX
		ADD		EAX, rootStart
		
		PUSH	ES
		MOV		ES, ImageLoadSeg
		MOV		BX, ImageLoadOff
		CALL	READDISK
		POP		ES
		
		MOV		EAX, DWORD PTR CLUSTER
		MOV		BX, 4								; QUE IRA ACESSAR A TABELA FAT. COMO, CADA ENTRADA NA TABELA FAT TEM 4 BYTES
		MUL		BX									; MULTIPLICO O INDICE PELA QUANTIDADE DE BYTES DE CADA INDICE
													; EX: INDICE 3h * 4 BYTES POR INDICE = 0Ch
		
		PUSH	AX									; SALVO O OFFSET QUE DEVERA SER ACESSADO NO ROOT
        
		MOV		EAX, [fatStart]						; ARMAZENO NO ROOT TEMPORARIAMENTE O CONTEUDO DA TABELA FAT
		MOV		BX, WORD PTR FAT
		CALL	READDISK
		
		POP		SI									; RESTAURO O OFFSET QUE CONTEM O CLUSTER INICIAL DO ARQUIVO
		ADD		SI, WORD PTR FAT					; ROOT 07C0h:0200h + OFFSET DO INDICE DA TABELA FAT 0Ch
		LODSD										; CARREGO EM EAX O CONTEUDO DE 07C0h:020Ch

		CMP		EAX, 0FFFFFFFh
		JE		IMAGELOADED
		
		MOV		DWORD PTR CLUSTER, EAX
		ADD		ImageLoadOff, 1000h
		
		JMP		NEXTCLUSTER

IMAGELOADED:
		
		XOR     BX, BX                            
		MOV     AX, ImageLoadSeg                         
		MOV     ES, AX                            
		MOV     DS, AX

		ADD     AX, DS:[08h]            		; ax = image base
		MOV     CX, DS:[06h]            		; cx = reloc items
		MOV     BX, DS:[18h]            		; bx = reloc table pointer

		JCXZ    RelocationDone

ReloCycle:						
		MOV     DI, DS:[BX]             		; DI = ITEM OFS
		MOV     DX, DS:[BX+2]           		; dx = item seg (rel)
		ADD     DX, AX                  		; dx = item seg (abs)

		PUSH    DS		
		MOV     DS, DX                  		; ds = dx
		ADD     DS:[DI], AX             		; fixup
		POP     DS		

		ADD     BX, 4                   		; point to next entry
		LOOP    ReloCycle

RelocationDone:					
		MOV     BX, AX
		ADD     BX, DS:[0Eh]
		MOV     SS, BX                  		; ss for EXE
		MOV     SP, DS:[10h]            		; sp for EXE

		ADD     AX, DS:[16h]            		; cs
		PUSH    AX		
		PUSH    DS:[14h]                		; ip
										
Run:	
		MOV     DL, [bsDriveNumber]                   		; let program know boot drive
		RETF	                                   
		
READDISK:
		PUSH	EBX
		CALL	LBATOCHS
		POP		EBX
		MOV 	AH, 02h                     
		MOV 	AL, [bpbSectorsPerCluster]                     
		MOV 	CH, [Cylinder]                		; C - Clylinder / Track
		MOV 	DH, [Head]                			; H - Head
		MOV 	CL, [Sector]                 		; S - Sector
		MOV 	DL, [bsDriveNumber]
		INT 	13h 
		JC  	ERROR 
		
		RET

;======================================
;		
;	AX = LBA ADDRESS
;
;======================================		
LBATOCHS:
		XOR		EBX, EBX
		XOR		EDX, EDX
		MOV		BX, [bpbSectorsPerTrack] 
		DIV 	BX  
		INC 	DL                    
		MOV 	[Sector], DL
        
		XOR 	DX, DX  
		MOV		BX, [bpbHeadsPerCylinder] 
		DIV 	BX
		MOV 	[Head], DL
		MOV 	[Cylinder], AL 
		
		RET

ERROR:
		MOV		AX, 0E45h
		INT		10h
		JMP		$

		ImageLoadSeg        DW     	50h     ; <=07Fh because of "push byte ImageLoadSeg" instructions
		ImageLoadOff		DW		0
		
		ROOT				DW		200h
		FAT					DW		400h
		
		Cylinder 			DB		?
		Head				DB		?
		Sector				DB		?
		Cluster				DD		?
		
		ImageName			DB		'KERNEL  SYS'

		ORG 	510

		DW      0AA55h          ; BIOS checks for this ID
ENTRY ENDP
	
	;================================================================================================================

CSEG ENDS

END ENTRY