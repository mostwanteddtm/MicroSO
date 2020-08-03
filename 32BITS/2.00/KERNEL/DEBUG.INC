;===============================================================================================|
;																								|
; 		PRINTHEX16 E PRINTHEX32 PARA DEBUGAR DETERMINADA POSICAO DE MEMORIA - 08-12-18			|
;																								|
;		EXEMPLOS DE CHAMADAS:																	|
;																								|
;		MOV		CX, SIZEOF rootStart															|
;		MOV		SI, OFFSET rootStart															|
;		CALL	PRINTHEX16																		|
;		JMP		$																				|
;																								|
;		MOV		ECX, SIZEOF TOTALSECTORS														|
;		MOV		ESI, OFFSET TOTALSECTORS														|
;		XOR		EDI, EDI																		|
;		CALL	PRINTHEX32																		|
;		JMP		$																				|
;																								|
;===============================================================================================|

DT_SEG SEGMENT USE32

	HEXTAB DB '0123456789ABCDEF'

DT_SEG ENDS

RM_SEG SEGMENT USE16

	PRINTHEX16 PROC
	
		MOV     BX, OFFSET HEXTAB
		MOV		AH, 0Eh
		ADD		SI, CX
		DEC		SI
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
		
		RET
		
	PRINTHEX16 ENDP

RM_SEG ENDS

PM_SEG SEGMENT USE32

	PRINTHEX32 PROC
	
		XOR		EBX, EBX
		MOV		EBX, DT_SEG
		SHL		BX, 4
		ADD     EBX, OFFSET HEXTAB
	PRN:
		LODSB
		MOV     DL, AL
		RCR     AL, 4
		AND     AL, 0Fh
		XLATB
		MOV		AH, 7h
		STOSW
		MOV     AL, DL
		AND     AL, 0Fh
		XLATB
		MOV		AH, 7h
		STOSW 
		MOV		AX, 720h
		STOSW
		LOOP    PRN  
		
		RET
		
	PRINTHEX32 ENDP

PM_SEG ENDS