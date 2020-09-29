GLOBAL  __terminate, _abort
EXTERN  _main

SEGMENT _TEXT PUBLIC CLASS=CODE USE16
..start:
        mov     ax, _DATA
        mov     ds, ax
        mov     es, ax
        cli
        mov     ss, ax
        xor     ax, ax
        mov     sp, ax
        sti
        call    _main

__terminate:
_abort:
        mov     ax, 4c00h
        int     21h

SEGMENT _DATA PUBLIC CLASS=DATA

SEGMENT _BSS  PUBLIC CLASS=DATA

SEGMENT _STACK STACK CLASS=STACK
        resb    128
