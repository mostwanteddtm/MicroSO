name driver
page 55,132
title DRIVER.ASM Device-Driver Skeleton
;
; DRIVER.ASM MS-DOS device-driver skeleton
;
; The driver command-code routines are stubs only and have
; no effect but to return a nonerror "done" status.
;
; Copyright 1988 Ray Duncan
;
_TEXT segment word public 'CODE'
assume cs:_TEXT,ds:_TEXT,es:NOTHING
org 0
MaxCmd equ 24 ; maximum allowed command code:
; 12 for MS-DOS 2
; 16 for MS-DOS 3.0-3.1
; 24 for MS-DOS 3.2-3.3
cr equ 0dh ; ASCII carriage return
lf equ 0ah ; ASCII linefeed
eom equ '$' ; end-of-message signal
Header: ; device-driver header
dd -1 ; link to next device driver
dw 0c840h ; device attribute word
dw Strat ; "strategy" routine entry point
dw Intr ; "interrupt" routine entry point
db 'SKELETON' ; logical-device name
RHPtr dd ? ; pointer to request header, passed
; by MS-DOS kernel to strategy routine
Dispatch: ; interrupt-routine command-code
; dispatch table:
dw Init ; 0 = initialize driver
dw MediaChk ; 1 = media check
dw BuildBPB ; 2 = build BPB
dw IoctlRd ; 3 = IOCTL read
dw Read ; 4 = read
dw NdRead ; 5 = nondestructive read
dw InpStat ; 6 = input status
dw InpFlush ; 7 = flush input buffers
dw Write ; 8 = write
dw WriteVfy ; 9 = write with verify
dw OutStat ; 10 = output status
dw OutFlush ; 11 = flush output buffers
dw IoctlWt ; 12 = IOCTL write
dw DevOpen ; 13 = device open (MS-DOS 3.0+)
dw DevClose ; 14 = device close (MS-DOS 3.0+)
dw RemMedia ; 15 = removable media (MS-DOS 3.0+)
dw OutBusy ; 16 = output until busy (MS-DOS 3.0+)
dw Error ; 17 = not used
dw Error ; 18 = not used


dw GenIOCTL ; 19 = generic IOCTL (MS-DOS 3.2+)
dw Error ; 20 = not used
dw Error ; 21 = not used
dw Error ; 22 = not used
dw GetLogDev ; 23 = get logical device (MS-DOS 3.2+)
dw SetLogDev ; 24 = set logical device (MS-DOS 3.2+)
Strat proc far ; device-driver strategy routine,
; called by MS-DOS kernel with
; ES:BX = address of request header
; save pointer to request header
mov word ptr cs:[RHPtr],bx
mov word ptr cs:[RHPtr+2],es
ret ; back to MS-DOS kernel
Strat endp
Intr proc far ; device-driver interrupt routine,
; called by MS-DOS kernel immediately
; after call to strategy routine
push ax ; save general registers
push bx
push cx
push dx
push ds
push es
push di
push si
push bp
push cs ; make local data addressable
pop ds ; by setting DS = CS
les di,[RHPtr] ; let ES:DI = request header
; get BX = command code
mov bl,es:[di+2]
xor bh,bh
cmp bx,MaxCmd ; make sure it's legal
jle Intr1 ; jump, function code is ok
call Error ; set error bit, "unknown command" code
jmp Intr2
Intr1: shl bx,1 ; form index to dispatch table
; and branch to command-code routine
call word ptr [bx+Dispatch]
les di,[RHPtr] ; ES:DI = addr of request header
Intr2: or ax,0100h ; merge 'done' bit into status and
mov es:[di+3],ax ; store status into request header
pop bp ; restore general registers
pop si
pop di
pop es
pop ds
pop dx
pop cx
pop bx
pop ax
ret ; back to MS-DOS kernel
; Command-code routines are called by the interrupt routine


; via the dispatch table with ES:DI pointing to the request
; header. Each routine should return AX = 0 if function was
; completed successfully or AX = (8000h + error code) if
; function failed.
MediaChk proc near ; function 1 = media check
xor ax,ax
ret
MediaChk endp
BuildBPB proc near ; function 2 = build BPB
xor ax,ax
ret
BuildBPB endp
IoctlRd proc near ; function 3 = IOCTL read
xor ax,ax
ret
IoctlRd endp
Read proc near ; function 4 = read (input)
xor ax,ax
ret
Read endp
NdRead proc near ; function 5 = nondestructive read
xor ax,ax
ret
NdRead endp
InpStat proc near ; function 6 = input status
xor ax,ax
ret
InpStat endp
InpFlush proc near ; function 7 = flush input buffers
xor ax,ax
ret
InpFlush endp
Write proc near ; function 8 = write (output)
xor ax,ax
ret
Write endp


WriteVfy proc near ; function 9 = write with verify
xor ax,ax
ret
WriteVfy endp

OutStat proc near ; function 10 = output status
xor ax,ax
ret
OutStat endp
OutFlush proc near ; function 11 = flush output buffers
xor ax,ax
ret
OutFlush endp
IoctlWt proc near ; function 12 = IOCTL write
xor ax,ax
ret
IoctlWt endp
DevOpen proc near ; function 13 = device open
xor ax,ax
ret
DevOpen endp
DevClose proc near ; function 14 = device close
xor ax,ax
ret
DevClose endp
RemMedia proc near ; function 15 = removable media
xor ax,ax
ret
RemMedia endp
OutBusy proc near ; function 16 = output until busy
xor ax,ax
ret
OutBusy endp
GenIOCTL proc near ; function 19 = generic IOCTL
xor ax,ax
ret
GenIOCTL endp


GetLogDev proc near ; function 23 = get logical device
xor ax,ax
ret
GetLogDev endp
SetLogDev proc near ; function 24 = set logical device
xor ax,ax
ret
SetLogDev endp
Error proc near ; bad command code in request header
mov ax,8003h ; error bit + "unknown command" code
ret
Error endp
Init proc near ; function 0 = initialize driver
push es ; save address of request header
push di
mov ax,cs ; convert load address to ASCII
mov bx,offset Ident1
call hexasc
mov ah,9 ; display driver sign-on message
mov dx,offset Ident
int 21h
pop di ; restore request-header address
pop es
; set address of free memory
; above driver (break address)
mov word ptr es:[di+14],offset Init
mov word ptr es:[di+16],cs
xor ax,ax ; return status
ret
Init endp
hexasc proc near ; converts word to hex ASCII
; call with AX = value,
; DS:BX = address for string
; returns AX, BX destroyed
push cx ; save registers
push dx
mov dx,4 ; initialize character counter
mov cx,4 ; isolate next four bits
rol ax,cl
mov cx,ax
and cx,0fh
add cx,'0' ; convert to ASCII
cmp cx,'9' ; is it 0-9?
jbe hexasc2 ; yes, jump
add cx,'A'-'9'-1 ; add fudge factor for A-F


hexasc2: ; store this character
mov [bx],cl
inc bx ; bump string pointer
dec dx ; count characters converted
jnz hexasc2 ; loop, not four yet
pop dx ; restore registers
pop cx
ret ; back to caller
hexasc endp
Ident db cr,lf,lf
db 'Advanced MS-DOS Example Device Driver'
db cr,lf
db 'Device driver header at: '
Ident1 db 'XXXX:0000'
db cr,lf,lf,eom
Intr endp
_TEXT ends
end