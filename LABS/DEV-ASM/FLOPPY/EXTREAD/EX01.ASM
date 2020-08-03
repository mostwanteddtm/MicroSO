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

start:
        CLD
		
		INT     12h 							; OBTENHO O TOPO DA MEMORIA CONVENCIONAL A0000h = A000:0000 = 280h kb = 640kb
												; PARA TRASNFORMARMOS O RESULTADO EM KBYTES, RETORNADOS NO REGISTRADOR AX,
												; EM BYTES POR PARÁGRAFO, QUE É FORMA QUE OS REGISTRADORES ES ou DS USAM PRA LER A MEMÓRIA,
												
												; VAMOS ENTENDER O MODO DE ENDEREÇAMENTO POR PARÁGRAFO.
												; EX: 16 bytes = 10h bytes, PARA ACESSAR USAMOS: [ES=1]:[DI=0], ABAIXO VEMOS COMO FICARIA NO HxD
												; 0000		00 01 02 03 04 05 06 07 08 09 0A 0B 0C 0D 0E 0F
												; 0010		XX
												; CONCLUÍMOS QUE O PRIMEIRO PARÁGRAFO ACESSA O 16º byte
												
												; COMO O RETORNO NO REGISTRADOR AX É EM kbytes, TEMOS QUE TRANSFORMAR
												; SEGUINDO A LOGICA DE PARÁGRAFO, TEREMOS:
												; AX=1 TRANSFORMANDO EM 1 kbyte, ACESSÍVEL POR PARÁGRAFO
												; SE 1 kbyte é = 1024 bytes E CADA PARÁGRAFO TEM 16 bytes, LOGO TEMOS:
												; 1024 / 16 = 64, ENTAO O PARAGRAFO 64, ACESSA 1 kbyte DE MEMÓRIA										
		SHL     AX, 6							; AGORA A CONTA INVERSA: (shl ax, 6) 1x 2=2, x2=4, x2=8, x2=16, x2= 32, x2=64, PARAGRAFO 64
		
        SUB     AX, 400h    					; RESERVO 16 kbytes PARA TRABALHAR NO BOOT 
        MOV     ES, AX          				
        				
        SUB     AX, 1000h  						; PRECISO ENTENDER MELHOR A UTILIZAÇÃO DA PILHA
        MOV     SS, AX          				
        MOV     SP, 0FFFEh        				; BEM COMO OS REGISTRADORES SS e SP
		
		MOV     CX, 100h						; APOS O BIOS POST COPIO O BOOT DE 07C0:0000 PARA 9C00:0000
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
		
		MOV		BYTE PTR [bsDriveNumber], DL	

		MOV		WORD PTR DAPS[6], AX
		CALL	READDISK
		
		MOV		SI, WORD PTR DAPS[4]
		MOV		CX, 8
		CALL	PRINTMEM
		
		JMP		$

READDISK:
		MOV 	SI, OFFSET DAPS                	; LOAD DAPS STRUCT TO DS:SI
		MOV 	AH, 42h                			; AH = 42h IBM/MS INT 13 EXTENSIONS - EXTENDED READ
		MOV		DL, BYTE PTR [bsDriveNumber]	; NAO FUNCIONA PARA O FLOPPY
        int     13h
		JC 		short ERROR 					; IF SOMETHING GOES WRONG...
		RET

ERROR:
		MOV		BYTE PTR ERR, AH
		MOV		SI, OFFSET ERR
		MOV		CX, 1
		CALL	PRINTHEX
		JMP		$
		

PRINTHEX:		
		MOV     BX, OFFSET HEXTAB
		ADD		SI, CX
		DEC		SI
		MOV		AH, 0Eh
	PRN:
		LODSB
		MOV     DL, AL
		RCR     AL, 4
		AND     AL, 0Fh
		XLATB
		INT		10h
		MOV     AL, DL
		AND     AL, 0Fh
		XLATB
		INT		10h
		SUB		SI, 2
		LOOP    PRN  
		
		MOV		AL, 20h
		INT		10h
		
		RET
		
PRINTMEM:
		MOV     BX, OFFSET HEXTAB
		MOV		AH, 0Eh
	PRM:
		LODSB
		MOV     DL, AL
		RCR     AL, 4
		AND     AL, 0Fh
		XLATB
		INT		10h
		MOV     AL, DL
		AND     AL, 0Fh
		XLATB
		INT		10h
		LOOP    PRM  
		
		MOV		AL, 20h
		INT		10h
		
		RET
		
			
DAPS 	DB 		10h              					; size of DAP (set this to 10h)
        DB 		0                					; unused, should be zero
        DW 		1									; number of sectors to be read, (some Phoenix BIOSes are limited to a maximum of 127 sectors)
		DW 		0200h			 					; segment:offset pointer to the memory buffer to which sectors will be transferred 
		DW 		?				 					; (note that x86 is little-endian: if declaring the segment and offset separately, the offset must be declared before the segment)
		DQ 		0		 	 						; absolute number of the start of the sectors to be read (1st sector of drive has number 0)
		
HEXTAB 	DB 		'0123456789ABCDEF'
ERR		DB 		?

		ORG 	510

		DW      0AA55h          
ENTRY ENDP
	
	;================================================================================================================

CSEG ENDS

END ENTRY