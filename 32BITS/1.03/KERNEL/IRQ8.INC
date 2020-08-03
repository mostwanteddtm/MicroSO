CODESEG16 SEGMENT USE16  						

	ENABLE_IRQ8 PROC

		CLI         				; Disable interrupts
		PUSH 	AX     				; Interrupt may occur while updating

		IN 		AL, 0A1h  			; Make sure IRQ8 is not masked
		AND 	AL, 0FEh 			; Set bit 0 of port 0A1 to zero
		OUT 	0A1h, AL 			

		IN 		AL, 70h   			; Set up "Write into status register A"
		MOV 	AL, 0Ah  
		OUT 	70h, AL  
		MOV 	AL, 8Ah  
		OUT 	70h, AL  
		IN 		AL, 71h   
		AND 	AL, 11110000b 		; Change only Rate
		OR 		AL, 0110b 			; Make sure it is Rate =0110 (1Khz)
		OUT 	71h, AL  			; Write into status register A
		IN 		AL, 71h   			; Read to confirm write

		IN 		AL, 70h  			; Set up "Write into status register B"
		MOV 	AL, 0Bh 
		OUT 	70h, AL 
		MOV 	AL, 8Bh 
		OUT 	70h, AL 
		IN 		AL, 71h  
		AND 	AL, 8Fh 			; Mask out PI,AI,UI
		OR 		AL, 10h  			; Enable update interrupts (UI=1) only
		OUT 	71h, AL 			; Write into status register  B
		IN 		AL, 71h  			; Read to confirm write

		IN 		AL, 021h  			; Make sure IRQ2 is not masked
		AND 	AL, 0FBh 			; Write 0 to bit 2 of port 21h
		OUT 	021h, AL 			; Write to port 21h

		IN 		AL, 70h  			; Set up "Read into status resister C"
		MOV 	AL, 0Ch 			; Required for for "Write into port 71h"
		OUT 	70h, AL
		IN 		AL, 70h
		MOV 	AL, 8Ch 
		OUT 	70h, AL
		IN 		AL, 71h  			; Read status register C 
									; (we do nothing with it)

		IN 		AL, 70h  			; Set up "Read into status resister C"
		MOV 	AL, 0Dh 			; Required for for "Write into port 71h"
		OUT 	70h, AL
		IN 		AL, 70h
		MOV 	AL, 8Dh
		OUT 	70h, AL
		IN 		AL, 71h  			; Read status register D 
									; (we do nothing with it)
		STI
		POP AX
		
		RET
			
	ENABLE_IRQ8 ENDP
	
	INT70h PROC FAR
	
		PUSH	DS
		PUSH	ES
		PUSH	EAX
		PUSH	EBX
		
		XOR		EAX, EAX
		XOR		EBX, EBX
		
		MOV 	AX, SELVIDEODESC32
		MOV 	ES, AX
		MOV 	AX, SELDATADESC32
		MOV 	DS, AX
		
		IN 		AL, 70h   			; Read existing port 70h
		MOV 	BX, AX

		MOV 	AL, 0Ch  			; Set up "Read status register C"
		OUT 	70h, AL  
		MOV 	AL, 8Ch  
		OUT 	70h, AL 
		IN 		AL, 71h
		MOV 	AX, BX   			;  Restore port 70h
		OUT 	70h, AL  

		ASSUME 	DS:SEGS32
		
		MOV		EDI, DWORD PTR POS
		MOV		ESI, OFFSET CHAR
		LODSB
		MOV		AH, 07h
		STOSW
		
		INC		CHAR
		
		MOV 	AL, 20h				; INFORMA O FIM DA INSTRUCAO DE INTERRUPCAO
		OUT 	0A0h, AL  			; Notify Secondary PIC
		OUT 	20h, AL  			; Notify Primary PIC
		
		POP		EBX
		POP		EAX
		POP		ES
		POP		DS
		
		IRETD

	INT70h ENDP
		
CODESEG16 ENDS