DATASEG16 SEGMENT USE16

	INTDEF PROC

		MOV 	AL, 20h						; INFORMA O FIM DA INSTRUCAO DE INTERRUPCAO
		OUT 	20h, AL              		; ACK IRQ
		
		MOV		AL, 20h
		OUT		0A0h, AL

		IRETD
	
	INTDEF ENDP

DATASEG16 ENDS