;************************************
; By Dex
;
; Assemble with fasm
; c:\fasm vesa.asm vesa.bin
;
;************************************
org 0x7C00

use16
;****************************
; Realmode startup code.
;****************************

start:
        xor   ax,ax
        mov   ds,ax
        mov   es,ax
        mov   ss,ax
        mov   sp,0x7C00

;****************************
; Fill Vesa info list.
;****************************
        mov  bx,4112h  ;640x480x32bpp screen mod
        mov  ax,4f01h
        mov  di,Mode_Info ;info block
        mov  cx,bx
        int  10h
;*****************************
; Switch to vesa mode.
;*****************************
        mov  ax,4f02h
        int  10h
		
		MOV	  AH, 0EH
		MOV	  AL, 42H
		INT	  10H
;*****************************
; Setting up, to enter pmode.
;*****************************

        cli
        lgdt  [gdtr]

        mov   eax, cr0
        or    al,0x1
        mov   cr0,eax

        jmp   0x10: protected

;*****************************
; Pmode. ;-)
;*****************************

use32
protected:
        mov   ax,0x8 
        mov   ds,ax
        mov   es,ax
        mov   ss,ax
        mov   esp,0x7C00
;*****************************
; Turn floppy off (if space).
;*****************************

        mov   dx,3F2h
        mov   al,0
        out   dx,al

;*****************************
; fade background screen.
;*****************************

fade_screen:
        mov   edx,[ModeInfo_PhysBasePtr]
        mov   edi,edx
        xor   eax,eax
        mov   al,0xc5
        xor   ebx,ebx
        mov   bl,195
DoLoop:    
        mov   cx,640*2
        dec   eax    

        rep   stosd

        dec   ebx
        jnz   DoLoop
;*****************************
; Just loop.
;*****************************
		
        jmp   $

;*************************************
; GDT.
;*************************************

gdt:        dw    0x0000, 0x0000, 0x0000, 0x0000
sys_data:   dw    0xFFFF, 0x0000, 0x9200, 0x00CF
sys_code:   dw    0xFFFF, 0x0000, 0x9800, 0x00CF
gdt_end:

gdtr:       dw gdt_end - gdt - 1
       dd gdt 


;*************************************
; Make program 510 byte's + 0xaa55
;*************************************

times 510- ($-start)  db 0
dw 0xaa55

;*************************************
; Put uninitialized data here.
;*************************************

include 'vesa.inc'