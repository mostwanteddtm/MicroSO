org 100h
mov si, offset txtStr
call printTxt
call crlf
mov si, offset txtStr2
call printTxt
call crlf
 
mov si, offset txtDisk
call printTxt
 
;Read HD1 parameters
mov AH, 08h     ;Read Drive Parameters
mov DL, 80h     ; First Drive
int 13h
 
push cx
mov ax, cx      ;Cylinders
and ax, 0C0h
shl ax, 2
and cx, 0FF00h
shr cx, 8
or cx, ax
mov ax, cx
inc ax
call printNum
mov si, offset txtSlash
call printTxt
pop cx
 
mov al, dh      ;Num Heads
mov ah, 0
inc ax
call printNum
mov si, offset txtSlash
call printTxt
 
and cx, 3Fh ;[5..0] Sectors Per Track
mov ax, cx
call printNum
call crlf
 
mov ax, 4c00h
int 21h
 
;********************* Utility Functions ******************
 
printNum:       ;Print a number (ax)
        push cx
        push dx
        mov cx,000Ah    ;divide by 10
        mov bx, sp
        getDigit:
                mov dx,0        ;puting 0 in the high part of the divided number (DX:AX)
                div cx          ;DX:AX/cx.  ax=dx:ax/cx  and dx=dx:ax%cx(modulus)
                push dx
                cmp ax,0
        jne getDigit
 
        printNmb:
                pop ax
                add al, 30h     ;adding the '0' char for printing
                mov ah,0eh      ;print char interrupt
                int 10h
                cmp bx, sp
        jne printNmb
 
        pop dx
        pop cx
        RET
 
printTxt:       ;Print a String (si)
  lodsb
  cmp al, 0
  je exitFn
  mov ah, 0Eh
  int 10h
  jmp printTxt
exitFn:
  RET
 
crlf:   ;Print End of line
        mov ax, 0E0dh
        int 10h
        mov ax, 0E0ah
        int 10h
        RET
 
;AppData
txtStr db "Hello Again", 0
txtStr2 db "Hard Drive Information", 0
txtDisk db "Disk Geometry (C/H/S): ", 0
txtSlash db "/", 0