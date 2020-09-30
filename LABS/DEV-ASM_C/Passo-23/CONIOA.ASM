.MODEL SMALL
.286

PUBLIC  _putch

param_1 equ bp+4
param_2 equ bp+6
param_3 equ bp+8
param_4 equ bp+10
param_5 equ bp+12
param_6 equ bp+14

_TEXT SEGMENT PUBLIC 'CODE' USE16

_putch:
    push  bp
    mov   bp, sp

    mov   ax, [param_1]
    xor   bl, bl
    mov   ah, 0eh
    int   10h
    mov   ax, [param_1]

    pop   bp
    ret
	
_TEXT ENDS
END