; ProtMode.asm
; Copyright (C) 1998, Jean L. Gareau
;
; This program demonstrates how to switch from 16-bit real mode into
; 32-bit protected mode. Some real mode instructions are implemented with macros
; in order for them to use 32-bit operands.
;
; This program has been assembled with MASM 6.11:
; C:\>ML ProtMode32.asm

 .386P ; Use 386+ privileged instructions
 ;-----------------------------------------------------------------------------;
 ; Macros (to use 32-bit instructions while in real mode) ;
 ;-----------------------------------------------------------------------------;

LGDT32 MACRO Addr ; 32-bit LGDT Macro in 16-bit
	DB 66h ; 32-bit operand override
	DB 8Dh ; lea (e)bx,Addr
	DB 1Eh
	DD Addr
	DB 0Fh ; lgdt fword ptr [bx]
	DB 01h
	DB 17h
ENDM

FJMP32 MACRO Selector,Offset ; 32-bit Far Jump Macro in 16-bit
	DB 66h ; 32-bit operand override
	DB 0EAh ; far jump
	DD Offset ; 32-bit offset
	DW Selector ; 16-bit selector
ENDM

PUBLIC _EntryPoint ; The linker needs it.

_TEXT SEGMENT PARA USE32 PUBLIC 'CODE'
	ASSUME CS:_TEXT

ORG 5000h ; => Depends on code location. <=

;-----------------------------------------------------------------------------;
; Entry Point. The CPU is executing in 16-bit real mode. ;
;-----------------------------------------------------------------------------;

_EntryPoint:

LGDT32 fword ptr GdtDesc ; Load GDT descriptor

mov eax,cr0 ; Get control register 0
or ax,1 ; Set PE bit (bit #0) in (e)ax
mov cr0,eax ; Activate protected mode!
jmp $+2 ; To flush the instruction queue.

; The CPU is now executing in 16-bit protected mode. Make a far jump in order to
; load CS with a selector to a 32-bit executable code descriptor.

FJMP32 08h,Start32 ; Jump to Start32 (below)

; This point is never reached. Data follow.

GdtDesc: ; GDT descriptor
dw GDT_SIZE - 1 ; GDT limit
dd Gdt ; GDT base address (below)

Start32:

;-----------------------------------------------------------------------------;
; The CPU is now executing in 32-bit protected mode. ;
;-----------------------------------------------------------------------------;

; Initialize all segment registers to 10h (entry #2 in the GDT)

mov ax,10h ; entry #2 in GDT
mov ds,ax ; ds = 10h
mov es,ax ; es = 10h
mov fs,ax ; fs = 10h
mov gs,ax ; gs = 10h
mov ss,ax ; ss = 10h

; Set the top of stack to allow stack operations.

mov esp,8000h ; arbitrary top of stack

; Other initialization instructions come here.
; ...

; This point is never reached. Data follow.

;-----------------------------------------------------------------------------;
; GDT ;
;-----------------------------------------------------------------------------;

; Global Descriptor Table (GDT) (faster accessed if aligned on 4).

ALIGN 4

Gdt:

; GDT[0]: Null entry, never used.

dd 0
dd 0

; GDT[1]: Executable, read-only code, base address of 0, limit of FFFFFh,

; granularity bit (G) set (making the limit 4GB)

dw 0FFFFh ; Limit[15..0]
dw 0000h ; Base[15..0]
db 00h ; Base[23..16]
db 10011010b ; P(1) DPL(00) S(1) 1 C(0) R(1) A(0)
db 11001111b ; G(1) D(1) 0 0 Limit[19..16]
db 00h ; Base[31..24]

; GDT[2]: Writable data segment, covering the save address space than GDT[1].

dw 0FFFFh ; Limit[15..0]
dw 0000h ; Base[15..0]
db 00h ; Base[23..16]
db 10010010b ; P(1) DPL(00) S(1) 0 E(0) W(1) A(0)
db 11001111b ; G(1) B(1) 0 0 Limit[19..16]
db 00h ; Base[31..24]

GDT_SIZE EQU $ - offset Gdt ; Size, in bytes

_TEXT ENDS
END