.286

IFDEF __EXE__
.MODEL SMALL
ELSE
.MODEL TINY
ENDIF

PUBLIC	__acrtused
		__acrtused = 0
PUBLIC  __terminate
PUBLIC  _abort
EXTERN  _main:PROC

_STACK SEGMENT STACK 'STACK'
        DB    128 DUP(?)
_STACK ENDS

_BSS SEGMENT PUBLIC 'BSS'
_BSS ENDS

IFDEF __EXE__
_DATA SEGMENT PUBLIC 'DATA'
_DATA ENDS
ENDIF

_TEXT SEGMENT PUBLIC 'CODE' USE16

start:
        IFDEF __EXE__
        MOV     AX, _DATA
        ELSE
        MOV     AX, CS
        ENDIF
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