.MODEL SMALL
.286

PUBLIC	__acrtused
		__acrtused = 0
PUBLIC  __terminate
PUBLIC  _abort
EXTERN  _main:PROC

_BSS SEGMENT PUBLIC 'BSS'
_BSS ENDS

_STACK SEGMENT STACK 'STACK'
        DB    128 DUP(?)
_STACK ENDS

_DATA SEGMENT PUBLIC 'DATA'
_DATA ENDS

_TEXT SEGMENT PUBLIC 'CODE' USE16

start:
        MOV     AX, _DATA
        MOV     DS, AX
        MOV     ES, AX
        CLI
        MOV     SS, AX
        XOR     AX, AX
        MOV     SP, AX
        STI
        CALL    _MAIN

__terminate:
_abort:
        MOV     AX, 4C00h
        INT     21h
		
_TEXT ENDS

END start