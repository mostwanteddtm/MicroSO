.386p

	COMMENT ^
											GDT - TABELA GLOBAL DE DESCRITORES DE SEGMENTOS
										
										 GRANULARIDADE: 0 - BYTE 1 - 4 KB 
														  |
	LIMITE DE ACESSO A MEMORIA, P/ ESTE SEGMENTO   0xFFFF |    0xF = [0xFFFFF = 1048575] * 4096(4KB) = 4294963200 BYTES | 4194300 MB | 4 GB
	 _______|_______									  |   __|_
	|				|									  |   |  |
	11111111 11111111 00000000 00000000 00000000 10011010 11001111 00000000
					  |_______________| |______| ||||||||  |	   |______|
							  |				|	 ||||||||  |		  |								 
	SETUP DO SEGMENTO		0xFFFF		  0xFF   ||||||||  |		 0xFF - O SEGMENTO PODE INICIAR DE 0 À 0xFFFFFFFF | 4GB
												 ||||||||  |
												 |||||||| SIZE: 0 SEGMENTO DE 16 BITS | 1 SEGMENTO DE 32 BITS
												 ||||||||
												 |||||||0 - SEMPRE 0 - QUANDO O SEGMENTO É REQUISITADO A CPU MUDA PRA 1
												 ||||||1 -- SOMENTE LEITURA 0 - ESCRITA - 1 
												 |||||0 --- SE 0 - O CÓDIGO SÓ PODE SER EXECUTADO SOMENTE PELO MESMO NIVEL DE ANEL - SE 1 DE QUALQUER NIVEL DE ANEL
												 ||||1 ---- SE 0 - SEGMENTO DE DADOS - SE 1 SEGMENTO DE CÓDIGO
												 |00 ------ NÍVEL DO ANEL. DE: 0 À 3
												 1 -------- ESTE SEMPRE SERÁ 1
												 
	11111111 11111111 00000000 00000000 00000000 10011010 00000000 00000000	
    |_______________|									  |______|	
			|												  |		
		 0xFFFF												 0x0 - EM DESCRITOR DE 16 BITS A GRANULARIDADE SERÁ SEMPRE 0
		 
	LIMITE DE ACESSO DO DESCRITOR EM 16 BITS É DE NO MÁXIMO 64K | 0xFFFF | 65535 BYTES
	^

DESCRIPTOR STRUCT
	LIMIT_0_15  	DW  ?      ;  LOWEST 16 BITS OF SEGMENT LIMIT
    BASE_0_15   	DW  ?      ;  LOWEST 16 BITS OF BASE
    BASE_16_23  	DB  ?      ;  BASE BITS 16-23
    ACCESS      	DB  ?      ;  PRESENT BIT, PRIV. LEVEL, TYPE
    GRAN        	DB  ?      ;  G BIT, D/B BIT , LIMIT BITS 16-19
    BASE_24_31  	DB  ?      ;  BASE BITS 24-31
DESCRIPTOR ENDS

STACK32 SEGMENT STACK 'STACK'
	DB 1024 DUP(?)
STACK32 ENDS

DATA16 SEGMENT PUBLIC 'DATA' USE16

	GDT				LABEL BYTE
	NULLDESC		DESCRIPTOR <0, 0, 0, 0, 0, 0>
	CODEDESC16 		DESCRIPTOR <0FFFFh, ?, ?, 10011110b, 0h,>
	DATADESC16		DESCRIPTOR <0FFFFh, ?, ?, 10010010b, 0h,>
	CODEDESC32 		DESCRIPTOR <0FFFFh, ?, ?, 10011110b, 11001111b,>
	DATADESC32 		DESCRIPTOR <0FFFFh, ?, ?, 10010010b, 11001111b,>
	GDT_SIZE    	EQU $ - GDT 
	GDTR        	DW  GDT_SIZE - 1
	DD  			?
	
	SELCODEDESC16 	EQU (OFFSET CODEDESC16 - GDT)
	SELDATADESC16 	EQU (OFFSET DATADESC16 - GDT)
	SELCODEDESC32 	EQU (OFFSET CODEDESC32 - GDT)
	SELDATADESC32 	EQU (OFFSET DATADESC32 - GDT)
	
DATA16 ENDS

DATA32 SEGMENT PUBLIC 'DATA' USE32

	GDT2			LABEL BYTE
	NULLDESC32		DESCRIPTOR <0, 0, 0, 0, 0, 0>	
	VIDEODESC32 	DESCRIPTOR <0FFFFh, 08000h, 0Bh, 10010010b, 01000000b, 0>
	GDT_SIZE2    	EQU $ - GDT2 
	GDTR2        	DW  GDT_SIZE2 - 1
	DD  			?

	SELVIDEODESC32 	EQU (OFFSET VIDEODESC32 - GDT2)
	
	MESSAGE			DB 'Configurando descritores de segmento e instalando GDT e IDT!!', 0
	
DATA32 ENDS

CODE16 SEGMENT PUBLIC 'CODE' USE16
	ASSUME CS:CODE16, DS:DATA16, ES:DATA16
	
	;===================================== ENTRYPOINT ==================================================================================
	
		ENTRYPOINT PROC
		
			MOV		AX, DATA16
			MOV		DS, AX
			MOV 	ES, AX
			
			MOV		AX, 3h
			INT		10h
			
			XOR		EAX, EAX
			MOV		AX, CODE16
			SHL		EAX, 4
			ADD		EAX, ENTRYPOINT
			MOV		CODEDESC16.BASE_0_15, AX
			SHR		EAX, 16
			MOV		CODEDESC16.BASE_16_23, AL
			MOV		CODEDESC16.BASE_24_31, AH
			
			XOR		EAX, EAX
			MOV		AX, DATA16
			SHL		EAX, 4
			MOV		DATADESC16.BASE_0_15, AX
			SHR		EAX, 16
			MOV		DATADESC16.BASE_16_23, AL
			MOV		DATADESC16.BASE_24_31, AH
			
			XOR		EAX, EAX
			MOV		AX, CODE32
			SHL		EAX, 4
			MOV		CODEDESC32.BASE_0_15, AX
			SHR		EAX, 16
			MOV		CODEDESC32.BASE_16_23, AL
			MOV		CODEDESC32.BASE_24_31, AH
			
			XOR		EAX, EAX
			MOV		AX, DATA32
			SHL		EAX, 4
			MOV		DATADESC32.BASE_0_15, AX
			SHR		EAX, 16
			MOV		DATADESC32.BASE_16_23, AL
			MOV		DATADESC32.BASE_24_31, AH
			
			XOR		EAX, EAX
			MOV		AX, DATA16
			SHL		EAX, 4
			ADD		EAX, OFFSET GDT
			MOV		DWORD PTR GDTR+2, EAX
			
			LGDT	FWORD PTR GDTR      

			CLI

			MOV 	EAX, CR0
			OR  	AX, 1
			MOV 	CR0, EAX
			
			DB  	0EAH, 0H, 0H, SELCODEDESC32, 0H 

		ENTRYPOINT ENDP
	
	;===================================================================================================================================
	
CODE16 ENDS

CODE32 SEGMENT PUBLIC 'CODE' USE32
	ASSUME CS:CODE32, DS:DATA32, ES:DATA32
	
	;===================================== START 32 BITS ===============================================================================
	
		START32 PROC
			
			MOV		AX, SELDATADESC32
			MOV		DS, AX

			XOR		EAX, EAX
			MOV		AX, DATA32
			SHL		EAX, 4
			ADD		EAX, OFFSET GDT2
			MOV		DWORD PTR GDTR2+2, EAX
			
			LGDT	FWORD PTR GDTR2

			MOV		AX, SELVIDEODESC32
			MOV		ES, AX
			MOV		EDI, 0
			MOV		ESI, OFFSET MESSAGE
			
		@@:
			LODSB
			CMP		AL, 0
			JE		@f
			MOV		AH, 07h
			STOSW
			JMP		@b

		@@:
			HLT	
			
		START32 ENDP
		
	;===================================================================================================================================
	
CODE32 ENDS

END ENTRYPOINT