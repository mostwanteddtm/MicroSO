GLOBAL  _putch

%define param_1 bp+4
%define param_2 bp+6
%define param_3 bp+8
%define param_4 bp+10
%define param_5 bp+12
%define param_6 bp+14

SEGMENT _TEXT PUBLIC CLASS=CODE USE16

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
