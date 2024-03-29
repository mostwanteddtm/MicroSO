.386p

; DEFINE PROGRAM STACK SEGMENT

STACK SEGMENT STACK USE16
	DB 100 DUP(0)
STACK ENDS

; DEFINE 16 (FROM 0 TO 15) LOCAL INTERRUPT VECTOR TABLE
; EACH VECTOR CONTAINS THE SEGMENT AND OFFSET ADDRESS OF ITS
; INTERRUPT SERVICE PROCEDURE.

IDT SEGMENT PARA PUBLIC 'IDT' USE16

					DD	INT0						; INTERRUPT 00 SERVICE ROUTINE VECTOR
					DD	INT1						; INTERRUPT 01 SERVICE ROUTINE VECTOR
					DD	INT2						; INTERRUPT 02 SERVICE ROUTINE VECTOR
					DD	INT3						; INTERRUPT 03 SERVICE ROUTINE VECTOR
					DD	INT4						; INTERRUPT 04 SERVICE ROUTINE VECTOR
					DD	INT5						; INTERRUPT 05 SERVICE ROUTINE VECTOR
					DD	INT6						; INTERRUPT 06 SERVICE ROUTINE VECTOR
					DD	INT7						; INTERRUPT 07 SERVICE ROUTINE VECTOR
					DD	INT8						; INTERRUPT 08 SERVICE ROUTINE VECTOR
					DD	INT9						; INTERRUPT 09 SERVICE ROUTINE VECTOR
					DD	INT10						; INTERRUPT 10 SERVICE ROUTINE VECTOR
					DD	INT11						; INTERRUPT 11 SERVICE ROUTINE VECTOR
					DD	INT12						; INTERRUPT 12 SERVICE ROUTINE VECTOR
					DD	INT13						; INTERRUPT 13 SERVICE ROUTINE VECTOR
					DD	INT14						; INTERRUPT 14 SERVICE ROUTINE VECTOR
					DD	INT15						; INTERRUPT 15 SERVICE ROUTINE VECTOR
	IDT_LIMIT		EQU $
	
IDT ENDS

; DEFINE PROGRAM DATA SEGMENT

DATA SEGMENT PARA PUBLIC 'DATA' USE16

	IDT_ADDR		DW	IDT_LIMIT					; NEW IDT SEGMENT LIMIT
					DD	?							; NEW IDT BASE ADDRESS,
													; INITIALIZED AT RUN TIME
	OLD_IDT_ADDR	DW 	?							; DOS IDT SEGMENT LIMIT
					DD	?							; DOS IDT BASE ADDRESS (0:0)
					
	MSG				DB 	'Program to replace IDT address in real mode', '$'
	
	INT0M			DB 	'Interrupt 0', 0
	INT1M			DB 	'Interrupt 1', 0
	INT2M			DB 	'Interrupt 2', 0
	INT3M			DB 	'Interrupt 3', 0
	INT4M			DB 	'Interrupt 4', 0
	INT5M			DB 	'Interrupt 5', 0
	INT6M			DB 	'Interrupt 6', 0
	INT7M			DB 	'Interrupt 7', 0
	INT8M			DB 	'Interrupt 8', 0
	INT9M			DB 	'Interrupt 9', 0
	INT10M			DB 	'Interrupt 10', 0
	INT11M			DB 	'Interrupt 11', 0
	INT12M			DB 	'Interrupt 12', 0
	INT13M			DB 	'Interrupt 13', 0
	INT14M			DB 	'Interrupt 14', 0
	INT15M			DB 	'Interrupt 15', 0
	
DATA ENDS	
	
; PROGRAM CODE

CODE SEGMENT USE16
	ASSUME CS:CODE, DS:DATA, SS:STACK
	
		START PROC FAR
		
			MOV		AX, DATA						; GET DATA SEGMENT ADDRESS
			MOV		DS, AX							; PUT IN DOS REGISTER
			MOV		AH, 09H							; DISPLAY MESSAGE ON SCREEN
			MOV		DX, OFFSET MSG					; BY USING DOS FUNCTION CALL
			INT     21H
			
		; GET IDT BASE ADDRESS AND SAVE IT.
		; THE IDT ADDRESS CAN BE RETRIVIVED ONLY DURING PROGRAM RUN
		; TIME.
		
			XOR		EAX, EAX						; CLEAR EAX REGISTER CONTENT
			MOV		AX, IDT							; GET NEW IDT SEGMENT ADDRESS
			SHL		EAX, 4							; CONVERT TO 32-BIT LINEAR ADDRESS
			MOV		DWORD PTR [IDT_ADDR+2], EAX		; PUT IT IN DATA AREA
			
		; SAVE OLD IDTR CONTENT
			
			SIDT	FWORD PTR [OLD_IDT_ADDR]
			
		; LOAD LOCAL IDT LIMIT AND BASE ADDRESS INTO IDTR.
			
			LIDT 	FWORD PTR [IDT_ADDR]
			
		; EXECUTE A SOFTWARE INTERRUPT INSTRUCTION.
			
			INT		5H								; CALL INTERRUPT 5 SERVICE ROUTINE
			
		; RESTORE OLD IDTR CONTENT.
			
			LIDT	FWORD PTR [OLD_IDT_ADDR]
			
		; TERMINATE THE PROGRAM
			
			MOV		AX, 4C00H						; TERMINATE THIS PROGRAM
			INT		21H								; BY CALLING DOS FUNCTION CALL.
			
		START ENDP
		
	CODE ENDS
	
	; LOCAL INTERRUPT SERVICE ROUTINE
	; THESE ROUTINE WILL GET THE OFFSET ADDRESS OF ITS MESSAGE
	; AND DISPLAY THE MESSA ON THE SCREEN
	
INTCODE SEGMENT USE16
	ASSUME CS:INTCODE, DS:DATA
		
	INT0:	MOV		SI, OFFSET INT0M
			JMP		DISPMSG
	INT1:	MOV		SI, OFFSET INT1M
			JMP		DISPMSG
	INT2:	MOV		SI, OFFSET INT2M
			JMP		DISPMSG
	INT3:	MOV		SI, OFFSET INT3M
			JMP		DISPMSG
	INT4:	MOV		SI, OFFSET INT4M
			JMP		DISPMSG
	INT5:	MOV		SI, OFFSET INT5M
			JMP		DISPMSG
	INT6:	MOV		SI, OFFSET INT6M
			JMP		DISPMSG
	INT7:	MOV		SI, OFFSET INT7M
			JMP		DISPMSG
	INT8:	MOV		SI, OFFSET INT8M
			JMP		DISPMSG
	INT9:	MOV		SI, OFFSET INT9M
			JMP		DISPMSG
	INT10:	MOV		SI, OFFSET INT10M
			JMP		DISPMSG
	INT11:	MOV		SI, OFFSET INT11M
			JMP		DISPMSG
	INT12:	MOV		SI, OFFSET INT12M
			JMP		DISPMSG
	INT13:	MOV		SI, OFFSET INT13M
			JMP		DISPMSG
	INT14:	MOV		SI, OFFSET INT14M
			JMP		DISPMSG
	INT15:	MOV		SI, OFFSET INT15M
			JMP		DISPMSG
			
	DISPMSG:
			MOV		DI, 80 * 35
			CALL	DISPIT
			IRET
			
	; MESSAGE DISPLAY ROUTINE
	; BECAUSE DOS FUNCTION CALL IS NOT AVAILABLE AT THIS TIME,
	; WE HAVE TO DISPLAY IT BY OURSELF.
	
		DISPIT	PROC FAR
		
			PUSH	ES								; SAVE ES REGISTER
			MOV		AX, 0B800H						; VIDEO RAM SEGMENT ADDRESS
			MOV		ES, AX							; PUT IN ES REGISTER
			MOV		AH, 40H							; DISPLAY ATTRIBUTE
			
		L1:	LODSB									; GET DISPLAY CHARACTER
			CMP		AL, 0							; END OF DISPLAY ?
			JE		L2
			STOSW									; RESTORE IN VIDEO RAM
			JMP		L1
		L2:	POP		ES								; RESTORE ES REGISTER
			RET
			
		DISPIT ENDP
		
INTCODE ENDS
END START
	
	
			
	
	
	
	
	
	
	
	
	
	
	
	
	
	