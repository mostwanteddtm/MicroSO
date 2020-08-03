; file: testa.asm
GLOBAL _myMul1
GLOBAL _myMul2

SEGMENT _TEXT PUBLIC CLASS=CODE USE16

_myMul1:
        ;push    bp
        ;mov     bp, sp
        ;mov     ax, [bp+4]
        ;imul    word [bp+6]
        ;pop     bp 
        mov ah, 0eh
        mov al, 41h
        int 10h
        xor ax, ax
        int 16h
        ret 
        
_myMul2:
        mov ah, 0eh
        mov al, 42h
        int 10h
        xor ax, ax
        int 16h 
        mov dx, 1
        push 0800h
        push 0000h
        retf
        ret
