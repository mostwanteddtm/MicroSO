.MODEL SMALL
.286

printf PROTO C, pointer:PTR BYTE

_TEXT SEGMENT PUBLIC 'CODE' USE16

printf PROC C pointer:PTR BYTE
    
	MOV		SI, pointer
@@: LODSB
	CMP		AL, 0
	JE		@f
	MOV		AH, 0Eh
	INT		10h
	JMP		@b
	
@@: RET
		
printf ENDP
	
_TEXT ENDS
END