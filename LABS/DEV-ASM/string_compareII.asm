
; You may customize this and other start-up templates; 
; The location of this template is c:\emu8086\inc\0_com_template.txt

org 100h

BufferLength equ 50
mov dx,BufferLength ;This will be decremented.
xor cx,cx ;This will be incremented.
mov di,offset CMD

MoreKeys:
xor ah,ah
int 16h
cmp al,13 ;Check for ENTER.
jz ExecuteCommand
cmp al,8 ;Check for BackSpace.
jz BackSpace  
mov ah, 0eh
int 10h
and al,0DFh ;This makes the key uppercase, no case sensitivity.
inc cx
dec dx
stosb ;This won't modify Flags.
jnz MoreKeys
dec cx
inc dx
mov ax,0E07h ;Beep
xor bh,bh
int 10h
jmp MoreKeys

BackSpace:
inc dx
dec cx
jmp MoreKeys

ExecuteCommand:
mov si,offset CMD
mov di,offset CDcmd
mov dx,cx ;Back up this value in DX.
rep cmpsb
je ok
jnz nok
;Display something like "Bad command" right here. 

ok:
ret

nok:
ret
;...
CDcmd db 'CD'
CMD db (BufferLength) dup (?)

ret




