
;********************************************************************************************************************|
;                                                        								                             |
;       				   Funcao responsavel por habilitar a porta A20 do teclado    			                 	 |
;     				          	Inicio do desenvolvimento em 14-12-2017       				                         |
;                        			Por: Marcos Roberto da Costa                      			                     |
;                                                        								                             |
;********************************************************************************************************************|

RM_SEG SEGMENT PUBLIC 'CODE' USE16
	ASSUME CS:RM_SEG, SS:ST_SEG
	
	;========================================= CODE AREA ============================================================
	
		ENABLE_A20 PROC                    		; HARDWARE ENABLE GATE A20
		
			PUSHF
			PUSH 	FS
			PUSH 	GS
			CLI

			XOR 	AX, AX                      ; SET A20 TEST SEGMENTS 0 AND 0FFFFH
			MOV 	FS, AX
			DEC 	AX
			MOV 	GS, AX

			CALL 	ENABLE_A20_TEST             ; IS A20 ALREADY ENABLED?
			JZ 		ENABLE_A20_DONE         	; IF YES, DONE

			IN 		AL, 92H                     ; PS/2 A20 ENABLE
			OR 		AL, 2
			JMP 	$+2
			JMP 	$+2
			JMP 	$+2
			OUT 	92H, AL

			CALL 	ENABLE_A20_TEST             ; IS A20 ENABLED?
			JZ 		ENABLE_A20_DONE         	; IF YES, DONE

			CALL 	ENABLE_A20_KBWAIT           ; AT A20 ENABLE
			JNZ 	ENABLE_A20_F0

			MOV 	AL, 0D1H
			OUT 	64H, AL

			CALL 	ENABLE_A20_KBWAIT
			JNZ 	ENABLE_A20_F0

			MOV 	AL, 0DFH
			OUT 	60H, AL

			CALL 	ENABLE_A20_KBWAIT

		ENABLE_A20_F0:                      	; WAIT FOR A20 TO ENABLE
			MOV 	CX, 800H                    ; DO 800H TRIES

		ENABLE_A20_L0:
			CALL 	ENABLE_A20_TEST             ; IS A20 ENABLED?
			JZ 		ENABLE_A20_DONE             ; IF YES, DONE

			IN 		AL, 40H                     ; GET CURRENT TICK COUNTER
			JMP 	$+2
			JMP 	$+2
			JMP 	$+2
			IN 		AL, 40H
			MOV 	AH, AL

		ENABLE_A20_L1:                      	; WAIT A SINGLE TICK
			IN 		AL, 40H
			JMP 	$+2
			JMP 	$+2
			JMP 	$+2
			IN 		AL, 40H
			CMP 	AL, AH
			JE 		ENABLE_A20_L1

			DEC 	CX
			JNZ 	ENABLE_A20_L0               ; LOOP FOR ANOTHER TRY

			MOV 	AX, -1                    	; ERROR, A20 DID NOT ENABLE
			RET

		ENABLE_A20_DONE:
			POP 	GS
			POP 	FS
			POPF
			XOR 	AX, AX
			RET

		ENABLE_A20_KBWAIT:                  	; WAIT FOR SAFE TO WRITE TO 8042
			XOR 	CX, CX
		ENABLE_A20_KBWAITL0:
			JMP 	$+2
			JMP 	$+2
			JMP 	$+2
			IN 		AL, 64H                     ; READ 8042 STATUS
			TEST 	AL, 2                       ; BUFFER FULL?
			LOOPNZ 	ENABLE_A20_KBWAITL0        	; IF YES, LOOP
			RET

		ENABLE_A20_TEST:                    	; TEST FOR ENABLED A20
			MOV 	AL, FS:[0]                  ; GET BYTE FROM 0:0
			MOV 	AH, AL                      ; PRESERVE OLD BYTE
			NOT 	AL                          ; MODIFY BYTE
			XCHG 	AL, GS:[10H]                ; PUT MODIFIED BYTE TO 0FFFFH:10H
			CMP 	AH, FS:[0]                  ; SET ZERO IF BYTE AT 0:0 NOT MODIFIED
			MOV 	GS:[10H], AL                ; PUT BACK OLD BYTE AT 0FFFFH:10H
			RET                             	; RETURN, ZERO IF A20 ENABLED
		ENABLE_A20 ENDP
		
	;================================================================================================================
	
RM_SEG ENDS