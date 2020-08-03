
;***********************************************************************************************************************|
;                                                        								                             	|
;       				   	Funcao responsavel por colocar o Kernel32 na memoria    			                 	 	|
;     				          		Inicio do desenvolvimento em 11-12-2018       				                        |
;                        				Por: Marcos Roberto da Costa                      			                    |
;																													 	|
;		Esta versao experimental, funciona apenas em Imagem de HD de 1GB (1024 MB), utilizando o bximage			 	|	
;																														|
; Physical CHS (PCHS) = 2080 Cylinders, 16 Heads, 63 Sectors | Logical CHS (LCHS) = 520 Cylinders, 64 Heads, 63 Sectors	|
;  Parametros no arquivo bochsrc.bxrc #ata0-master: type=disk, mode=flat, path=c.img, cylinders=2080, heads=16, spt=63	|										
;                                                        								                             	|
;***********************************************************************************************************************|

DT_SEG SEGMENT PUBLIC 'DATA' USE32

	;============================== DATA AREA ===================================================================
	
	bpbSectorsPerCluster    DB 	   08h  	; 0x0D
	bsDriveNumber           DB     80h      ; 0x40
	bpbSectorsPerTrack      DW 	   003Fh  	; 0x18
	bpbHeadsPerCylinder     DW 	   0040h  	; 0x1A
	
	
	Cylinder 			DB	?
	Head				DB	?
	Sector				DB	?
	
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
		MOV		BX, 9000h
		MOV		AX, 106Bh

	READDISK:
		PUSH	BX
		CALL	LBATOCHS
		POP		BX
		MOV 	AH, 02h                     
		MOV 	AL, DS:[bpbSectorsPerCluster]                     
		MOV 	CH, DS:[Cylinder]                		; C - Clylinder / Track
		MOV 	DH, DS:[Head]                			; H - Head
		MOV 	CL, DS:[Sector]                 		; S - Sector
		MOV 	DL, DS:[bsDriveNumber]
		INT 	13h 
		JC  	ERROR 
		
		POPA
		RET

;======================================
;		
;	AX = LBA ADDRESS
;
;======================================		
LBATOCHS:
		XOR		BX, BX
		XOR		DX, DX
		MOV		BX, DS:[bpbSectorsPerTrack] 
		DIV 	BX  
		INC 	DL                    
		MOV 	DS:[Sector], DL
        
		XOR 	DX, DX  
		MOV		BX, DS:[bpbHeadsPerCylinder] 
		DIV 	BX
		MOV 	DS:[Head], DL
		MOV 	DS:[Cylinder], AL 
		
		RET

ERROR:
		MOV		AX, 0E45h
		INT		10h
		JMP		$

	LOAD_KERNEL32 ENDP
	
RM_SEG ENDS