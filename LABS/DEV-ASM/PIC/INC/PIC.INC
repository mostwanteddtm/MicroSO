DATASEG16 SEGMENT USE16

	REMAPPIC PROC

		MOV 	AL, 11h              ; INITIALIZATION COMMAND WORD (ICW) 1
		OUT 	20h, AL              ; INTO FIRST PIC
		OUT 	0A0h, AL             ; INTO CASSCADED SECOND PIC
	
		MOV 	AL, 20h              ; LOAD STARTING INTERRUPT 20H (ICW2)
		OUT 	21h, AL              ; INTO FIRST PIC
		MOV 	AL, 28h              ; LOAD STARTING INTERRUPT 28H
		OUT 	0A1h, AL             ; INTO SECOND PIC
	
		MOV 	AL, 04h              ; ICW3
		OUT 	21h, AL              ; FIRST PIC
		MOV 	AL, 02h              ; ICW3
		OUT 	0A1h, AL             ; SECOND PIC
	
		MOV 	AL, 01h              ; ICW4
		OUT 	21h, AL              ; FIRST PIC
		OUT 	0A1h, AL             ; SECOND PIC

		MOV 	AL,0                 ; FIRST 8 IRQS MAPPED
		OUT 	021h,AL
			
		MOV 	AL,0                 ; SECOND 8 IRQS MAPPED
		OUT 	0A1h,AL
		
		RET
		
	REMAPPIC ENDP
	
	RESTOREPIC PROC
	
		PUSH 	EAX
    
		MOV 	AL, 11h              ; INITIALIZATION COMMAND WORD (ICW) 1
		OUT 	20h, AL              ; INTO FIRST PIC
		OUT 	0A0h, AL             ; INTO CASSCADED SECOND PIC
	
		MOV 	AL, 08h              ; LOAD STARTING INTERRUPT 08H (ICW2)
		OUT 	21h, AL              ; INTO FIRST PIC
		MOV 	AL, 70h              ; LOAD STARTING INTERRUPT 70H
		OUT 	0A1h, AL             ; INTO SECOND PIC
	
		MOV 	AL, 04h              ; ICW3
		OUT 	21h, AL              ; FIRST PIC
		MOV 	AL, 02h              ; ICW3
		OUT 	0A1h, AL             ; SECOND PIC
	
		MOV 	AL, 01h              ; ICW4
		OUT 	21h, AL              ; FIRST PIC
		OUT 	0A1h, AL             ; SECOND PIC
			
		POP 	EAX
		
		RET
		
	RESTOREPIC ENDP

DATASEG16 ENDS