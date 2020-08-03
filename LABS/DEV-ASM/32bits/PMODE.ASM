comment #*****************************
Program by  Neal Margulis -- Use MASM 5.0
#*************************************
.386p

descriptor STRUCT
    limit_0_15  dw  0      ;  lowest 16 bits of segment limit
    base_0_15   dw  0      ;  lowest 16 bits of base
    base_16_23  db  0      ;  base bits 16-23
    access      db  0      ;  Present bit, priv. level, type
    gran        db  0      ;  G bit, D/B bit , limit bits 16-19
    base_24_31  db  0      ;  base bits 24-31
descriptor ENDS

code_seg_access equ 09AH   ; Present, DPL=0, non-conforming,read/exec
data_seg_access equ 092H   ; Present, DPL=0, Expand-Up,writeable

; have screenbase equal B8000H for EGA or B0000H for monochrome
screenbase   EQU  0B8000H
screenseg    EQU  0B800H

CSEG segment word  use16 'code'
assume  cs:CSEG,ds:CSEG

       mov ax,CSEG
       mov ds, ax

; Make entries in GDT for PMODE segment as code or data
       mov ax, seg PMODE
       and eax, 0FFFFh
       shl eax, 4H
       mov ebx, eax
       shr eax, 16
       mov gdt_PM_1.base_0_15, bx
       mov gdt_PM_2.base_0_15, bx
       mov gdt_PM_1.base_16_23,al
       mov gdt_PM_2.base_16_23,al

; Make entry in GDT for C3 segment as code
       mov ax,seg C3
       and eax, 0FFFFH
       shl eax, 4H
       mov ebx, eax
       shr eax, 16
       mov gdt_c3_5.base_0_15, bx
       mov gdt_c3_5.base_16_23,al

; Set up gdtr for lgdt instruction
       mov ax, cs
       and eax, 0FFFFH
       shl eax, 4H
       add eax, offset gdttbl
       mov dword ptr gdtaddr+2,eax
       lgdt fword ptr gdtaddr               ; set GDT address
A20_ON:

       cld                         ; Clear direction flag
       cli                         ; Disable interrupts

; Enter Protected Mode
        mov     eax,cr0
        or      eax,1
        mov     cr0,eax            ; Enable protected mode

              ;flush prefetch queue
        DB 0EAH,0H,0H,08H,0H       ; jmp to PMODE and execute

gdtaddr label   qword
        dw      48
        dd      ?
        dw      0

; global descriptor table

gdttbl   label   dword
gdt_null  descriptor <,,,,,>  ;   GDT entry 0 (null descriptor)
gdt_PM_1  descriptor <0FFFFH,,,code_seg_access,0C0H,0>  ;  D bit ON
gdt_PM_2  descriptor <0FFFFH,,,data_seg_access,08FH,>  ;
gdt_3     descriptor <0FFFFH,0,0,data_seg_access,08FH,0>
gdt_rm_4  descriptor <0FFFFH,0,0,data_seg_access,08fH,0>
gdt_c3_5  descriptor <0FFFFH,,,code_seg_access,080H,0>  ;  D bit OFF

CSEG ends

PMODE segment para public use32 'code'
    assume cs:PMODE
        mov ax, 18h         ;selector 18H is 4 Gigabyte data segment with base at 0
        mov es, ax
        mov fs, ax
        mov ax, 10h         ;  Data segment with base at 'c2seg'
        mov ds, ax
        mov cx, 025h
        mov     edi,screenbase  ;  Addressing screen memory from protected mode
display:mov byte ptr es:[edi],'P'
        add     edi,2
        mov     byte ptr es:[edi],'M'
        add     edi,2
        mov     byte ptr es:[edi],' '
        add     edi,2
        loopne display

        db      0eah, 0h, 0h, 0h, 0h,28h, 0h ; jmp to c3 and execute

align 16

                pdat  db 0ach
lastpm  label dword
PMODE ends

c3 segment para public use16 'code'
    assume cs:c3

        mov ax, 20h         ; Change segments back to have valid
        mov es, ax          ;  real mode attributes.
        mov ds, ax
        mov fs, ax
        mov eax,cr0
        and eax, 07ffffffeh
        mov cr0,eax               ; enter real mode
        jmp far ptr flushrl       ; flush queue
 flushrl:
         mov ax, screenseg        ; Address screen memory from real mode
         mov ds, ax
         sub edi, 0b8000h
         mov si,di
        mov byte ptr ds:[si],'C'    ;  Write to screen
        add si,2
        mov byte ptr ds:[si],'3'

A20_off:

        mov ah, 04ch                    ;  DOS termination
        mov al, 01h
        int 21h
c3 ends

end
