TITLE   8086 Code Template (for EXE file)

;       AUTHOR          emu8086
;       DATE            ?
;       VERSION         1.00
;       FILE            ?.ASM

; 8086 Code Template

; Directive to make EXE output:

DSEG    SEGMENT 'DATA'

; TODO: add your data here!!!!
        mensagem DB "Ola, Mundo!", 0
      
DSEG    ENDS

SSEG    SEGMENT STACK   'STACK'
        DW      100h    DUP(?)
SSEG    ENDS

CSEG    SEGMENT 'CODE'

;*******************************************

START   PROC    FAR

	PUSH	ES
; set segment registers:
    MOV     AX, DSEG
    MOV     DS, AX
    MOV     ES, AX
	
	MOV		SI, OFFSET mensagem
	MOV		AH, 0EH
CP: LODSB
	CMP		AL, 0
	JE		FIM
	INT		10H
	JMP 	CP
	
FIM:POP 	ES
	INT		20H

START   ENDP

;*******************************************

CSEG    ENDS 

        END    START    ; set entry point.

