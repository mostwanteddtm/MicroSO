GLOBAL  __terminate, _abort
EXTERN  main

; This module (c0?.obj) must be linked as the first module of your program

%ifdef  __TINY__
; This module is for tiny memory model, where CS = DS = ES = SS and the stack
; is in the end of the segment of the .COM program.
; Group all code/data segments together into a single physical segment:
GROUP DGROUP _TEXT _DATA _BSS
%else   ;%ifdef  __TINY__
GROUP DGROUP _DATA _BSS
%endif  ;%ifdef  __TINY__

; The code segment must be declared and placed first for a .COM program:
SEGMENT _TEXT PUBLIC CLASS=CODE USE16

%ifdef  __TINY__
        resb    100h            ; reserve 100h bytes for a normal .COM program
..start:
%else   ;%ifdef  __TINY__
..start:
; Init segment registers:
        mov     ax, _DATA
        mov     ds, ax
        mov     es, ax
; Set the stack pointer to the end of the data segment
; (remember SS = DS for normal small model in Borland/Turbo C/C++),
; this makes things pretty much the same as with .COM files
; (e.g. tiny memory model, where CS = DS = ES = SS and the stack
; is in the end of the segment of the .COM program):
        cli
        mov     ss, ax
        xor     ax, ax
        mov     sp, ax
        sti
%endif  ;%ifdef  __TINY__

        call    main

__terminate:
_abort:
        mov     ax, 4c00h
        int     21h

; Declare empty data segments in this module:
SEGMENT _DATA PUBLIC CLASS=DATA

SEGMENT _BSS  PUBLIC CLASS=BSS

%ifdef  __TINY__
%else   ;%ifdef  __TINY__
; Allocate a small stack to avoid TLINK warnings:
SEGMENT _STACK STACK CLASS=STACK
        resb    512
%endif  ;%ifdef  __TINY__
