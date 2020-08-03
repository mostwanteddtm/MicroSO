;https://www.daniweb.com/programming/software-development/threads/238046/assembler-tasm-switching-from-real-mode-to-protected-mode-and-back
.386p
data segment 'data' use16
message db 'H',7,'e',7,'l',7,'l',7,'o',7
message_1=$-message
rest_scr=25*80
GDT label byte
db 8 dup(0)
GDT_flatCS db 0FFh,0FFh,0,0,0,10011010b,11001111b,0
GDT_flatDS db 0FFh,0FFh,0,0,0,10010010b,11001111b,0
GDT_16bitCS db 0FFh,0FFh,0,0,0,10011010b,0,0
GDT_16bitDS db 0FFh,0FFh,0,0,0,10010010b,0,0
GDT_1=$-GDT
gdtr dw GDT_1-1
dd ?
data ends
RM_seg segment para public 'code' use16
assume CS:RM_seg,SS:RM_stack,ds:data
start:
mov ax,data
mov ds,ax
in al,92h
or al,2
out 92h,al
xor eax,eax
mov ax,PM_seg
shl eax,4
add eax,offset PM_entry
mov dword ptr cs:pm_entry_off,eax
xor eax,eax
mov ax,ds
shl eax,4
push eax
mov word ptr GDT_16bitDS+2,ax
shr eax,16
mov byte ptr GDT_16bitDS+4,al
xor eax,eax
mov ax,cs
shl eax,4
mov word ptr GDT_16bitCS+2,ax
shr eax,16
mov byte ptr GDT_16bitCS+4,al
pop eax
add eax,offset GDT
mov dword ptr gdtr+2,eax
lgdt fword ptr gdtr
cli
in al,70h
or al,80h
out 70h,al
mov eax,cr0
or al,1
mov cr0,eax
db 66h
db 0EAh
pm_entry_off dd ?
dw SEL_flatCS
RM_return:
mov eax,cr0
and al,0FEh
mov cr0,eax
db 0EAh
dw $+4
dw RM_seg
in al,70h
and al,07FH
out 70h,al
sti
mov ah,0
int 16h
mov ah,4Ch
int 21h
SEL_flatCS equ 00001000b
SEL_flatDS equ 00010000b
SEL_16bitCS equ 00011000b
SEL_16bitDS equ 00100000b
RM_seg ends
PM_seg segment public 'CODE' use32
assume cs:PM_seg
PM_entry:
mov ax,SEL_16bitDS
mov ds,ax
mov ax,SEL_flatDS
mov es,ax
mov edi,0B8000h
mov ecx,rest_scr
mov ax,720h
rep stosw
mov esi,offset message
mov edi,0B8500h
mov ecx,message_1
rep movsb
db 0EAh
dd offset RM_return
dw SEL_16bitCS
PM_seg ends
RM_stack segment stack 'STACK' use16
db 100h dup(?)
RM_stack ends
end start