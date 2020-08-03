.386p   ;allow USE32 and 386 instructions

INCLUDE A20.INC

ERROR equ -1

;first define all segments that will be needed
code16seg segment use16 'code'
code16seg ends
data16seg segment use16
data16seg ends
stack16seg segment use16 stack
  db 1024 dup (?)
  TOS16 equ $   ;top of stack
stack16seg ends

code32seg segment use32 'code'
code32seg ends
data32seg segment use32
data32seg ends
stack32seg segment use32 'stack'
  db 1024 dup (?)
  TOS32 equ $   ;top of stack
stack32seg ends

;put all segments in one
segs16 group code16seg,data16seg,stack16seg
segs32 group code32seg,data32seg,stack32seg

assume cs:segs16,ds:segs16,ss:segs16,es:NOTHING

DESC STRUCT   				; DEFINE OUR DESCRIPTOR STRUCTURE
	LIMIT_LO 	DW ?    	; LIMIT BITS 15-0
	BASE_LO 	DW ?     	; BASE BITS 15-0
	BASE_MID 	DB ?    	; BASE BITS 23-16
	TYPE1 		DB ?       	; TYPE OF SELECTOR
	LIMIT_HI 	DB ?    	; LIMIT BITS 19-16 AND OTHER INFO
	BASE_HI 	DB ?     	; BASE BITS 31-24
DESC ENDS

callstruct struct  ;used in calling rmode
  _edi dd ?     ;0
  _esi dd ?     ;4
  _ebp dd ?     ;8
  _res dd ?     ;0ch reserved
  _ebx dd ?     ;10h
  _edx dd ?     ;14h
  _ecx dd ?     ;18h
  _eax dd ?     ;1ch
  _flg dw ?     ;20h flags
  _es dw ?      ;22h segments (NOT selectors)
  _ds dw ?      ;24h "
  _fs dw ?      ;26h "
  _gs dw ?      ;28h "
  _ip dw ?      ;2ah ignored when calling INT
  _cs dw ?      ;2ch "
  _sp dw ?      ;2eh must be 0 to use system stacks
  _ss dw ?      ;30h "
callstruct ends

data16seg segment use16  ;start defining our 16bit data

;define our GDTR
  gdtr label fword
  gdt_limit dw gdt_size-1
  gdt_addr dd ?
;define our IDTR
  idtr label fword
  idt_limit dw idt_size-1
  idt_addr dd ?
;define the default IDTR (this is used while in RMODE)
  rm_idtr label fword
  dw 3ffh  ;limit
  dd 0     ;addr

;define our GDT
  gdt_start equ $
  null desc <0,0,0,0,0,0>
    ;this is the 1st GDT entry called NULL which we can not use
  code16 desc <0ffffh,?,?,10011010b,0h,?>
    ;Limit=64 KBs (this is a 16bit segment so only IP is used while running)
    ;Base=? (this will be setup later in the program)
    ;10011?10b = P=1 (present), DPL=0, S=1(code/data segment) T=1 (code)
    ;            C=1(conforming), R=1 (readable), A=0 (not accessed)
    ;0h = limit bits 19-16=0, G=0 (1byte granularity), D=0 (16bit segment)
  data16 desc <0ffffh,?,?,10010010b,0h,?>
    ;Limit=64 KBs
    ;Base=? (this will be setup later in the program)
    ;10010010b = P=1 (present), DPL=0, S=1(code/data segment) T=0 (data)
    ;            E=0 (do not expand down), W=1 (writable), A=0 (not accessed)
    ;0h = limit bits 19-16=0, G=0 (1byte granularity), D=0 (16bit segment)
  vid desc <0ffffh,8000h,0bh,10010010b,0h,0>
    ;Limit=64 KBs
    ;Base=0b8000h (makes it easy to access video RAM while in PMODE-16)
    ;10010010b = P=1 (present), DPL=0, S=1(code/data segment) T=0 (data)
    ;            E=0 (do not expand down), W=1 (writable), A=0 (not accessed)
    ;0h = limit bits 19-16=0, G=0 (1byte granularity), D=0 (16bit segment)
  code32 desc <0ffffh,?,?,10011010b,11001111b,?>
    ;Limit=4 GBs (0ffffh * 4k = 4 GBs)
    ;Base=?
    ;     the beginning of memory)
    ;10011110b = P=1 (present), DPL=0, S=1(code/data segment) T=1 (code)
    ;            C=1(conforming), R=1 (readable), A=0 (not accessed)
    ;11001111b = limit bits 19-16=0fh, G=1 (4k granularity), D=1 (32bit segment)
  data32 desc <0ffffh,?,?,10010010b,11001111b,?>
    ;Limit=4 GBs
    ;Base=?
    ;10010010b = P=1 (present), DPL=0, S=1(code/data segment) T=0 (data)
    ;            E=0 (do not expand down), W=1 (writable), A=0 (not accessed)
    ;11001111b = limit bits 19-16=0fh, G=1 (4k granularity), D=1 (32bit segment)
  zero32 desc <0ffffh,0,0,10010010b,11001111b,0>
    ;Limit=4 GBs
    ;Base=0h (easy access to rmode memory)
    ;10010010b = P=1 (present), DPL=0, S=1(code/data segment) T=0 (data)
    ;            E=0 (do not expand down), W=1 (writable), A=0 (not accessed)
    ;11001111b = limit bits 19-16=0fh, G=1 (4k granularity), D=1 (32bit segment)
  ldt desc <0,0,0,10000010b,0h,0>
    ;this is what will be loaded into our LDTR.  Because we don't want
    ;to use the LDT this is setup so that our LDT is empty
    ;Limit=1 byte (limits of 0 are not possible)
    ;Base=0
    ;10000010b = P=1 (present), DPL=0, S=0(system segment), TYPE=2 (LDT)
    ;       0h = limit bits 19-16=0, G=0 (1byte granularity), D=0 (16bit segment)
  gdt_size equ ($-gdt_start)

;define our IDT
  idt_start equ $
  idt desc 256 dup (<?,selcode16,0,10001110b,0,0>)
  idt_size equ ($-idt_start)

;define our intrmatrix
ints db 256 dup (0cch)                 ;this is what each of the default
                                       ;INT descriptors pts to
                                       ;0cch = int 3 (one-byte opcode)
                                       ;so ALL INTs goto the INT 3 handler
                                       ;which will direct the INT to rmode

;define our selectors as EQU
  selcode16 equ (offset code16-gdt_start)
  seldata16 equ (offset data16-gdt_start)
  selvid equ    (offset vid -gdt_start)
  seldata32 equ (offset data32-gdt_start)
  selzero32 equ (offset zero32-gdt_start)
  selcode32 equ (offset code32-gdt_start)
  selldt equ    (offset ldt   -gdt_start)

;define our selectors as DW
  _selcode16  dw selcode16
  _seldata16  dw seldata16
  _selvid     dw selvid
  _seldata32  dw seldata32
  _selzero32  dw selzero32
  _selcode32  dw selcode32
  _selldt     dw selldt


;define our raw switching routines
  pm_2_rm dd offset pm_2_rm_rx         ;by default our switching routines
          dd selcode16                 ;will be for raw/xms but later it may
  rm_2_pm dw offset rm_2_pm_rx         ;become VCPI
          dw segs16

;define our pm 2 rm stacks
  pm2rm_stkend dw ?       ;Last avail stack   (ss)
  pm2rm_stkcur dw ?       ;Current            (ss)
  pm2rm_stklen dw 80h     ;incremental(para)  (sp)
  pm2rm_stks dw 8         ;# of stacks

;.data
;define other variables needed
mode db 0        ;defines what drivers are installed
  MODE_RAW equ 0 ;none
  MODE_XMS equ 1 ;XMS (himem.sys)

xms_max dw 1024  ;Max RAM to Alloc is 1024 KBs
xms_min dw 64    ;Min RAM to Alloc is 64 KBs
xms_left dw ?    ;int 15h will report this much is free
xms_base dd ?    ;the start of our XMS RAM we have alloc
xms_size dd ?    ;the size of our XMS RAM
xms_call dd ?    ;seg:off to call XMS driver
xms_emb dw ?     ;our EMB handle alloc'ed from XMS

cpu db ?         ;detected CPU  (3=386 4=486 5=586)

prg_base16 dd ?                        ;segs16 * 10h
prg_base32 dd ?                        ;segs32 * 10h

old_int15h dd ?                        ;old rmode int 15h handler
old_int21h dd ?                        ;old rmode int 21h handler

int3vector dd offset ints+3
           dd selcode16
picslave  db 70h                       ; PIC slave base interrupt
picmaster db 8h                        ; PIC master base interrupt

psp dw ?                               ;program segment prefix

;messages
msg_welcome db 'DOS extender Tutorial : Stage #2',13,10,'$'
msg_xms_low db 'Insufficent XMS memory found!',13,10,'$'
msg_xms_lock db 'Unable to lock XMS memory block!',13,10,'$'
msg_80386 db '80386 or better required!',13,10,'$'
msg_v86 db 'Another PMODE software is already loaded!',13,10,'$'
msg_clean_boot db 'Please use a clean boot to use this tutorial!',13,10,'$'
msg_a20 db 'Unable to enable A20!',13,10,'$'
data16seg ends

code16seg segment use16  ;start the 16bit code segment

;this section is used to report errors and quit the program
exit16error:


start16 proc                      ;this is where our program starts

  push es                         ;save the PSP

  cld

  mov ax,cs
  mov ds,ax         
  mov es,ax                       ;set DS=ES=CS

  pop psp                         ;load PSP from stack

  mov dx,offset msg_welcome       ;-+
  mov ah,9                        ; |
  int 21h                         ;print Welcome message

;enable the a20 so we can access RAM above 1MB.
  call enablea20
  cmp ax,ERROR
  jnz r3
  mov dx,offset msg_a20
  jmp exit16error
r3:
  
  xor eax,eax
  mov ax,cs
  shl eax,4                            ; convert to linear addr
  mov prg_base16,eax

  xor eax,eax
  mov ax,segs32
  shl eax,4                            ; convert to linear addr
  mov prg_base32,eax

;setup all our descriptors
  mov eax,prg_base16
  mov code16.base_lo,ax
  mov data16.base_lo,ax
  shr eax,16
  mov code16.base_mid,al
  mov data16.base_mid,al
;  mov code16.base_hi,ah               ;not needed since AH will always be 0
;  mov data16.base_hi,ah               ; "

  mov eax,prg_base32
  mov code32.base_lo,ax
  mov data32.base_lo,ax
  shr eax,16
  mov code32.base_mid,al
  mov data32.base_mid,al
;  mov code32.base_hi,ah               ; "
;  mov data32.base_hi,ah               ; "

;setup GDT and IDT base
  mov eax,prg_base16
  add eax,gdt_start
  mov gdt_addr,eax
  mov eax,prg_base16
  add eax,idt_start
  mov idt_addr,eax

;setup pm_2_rm stacks
  ;first find end of RAM after EXE
  xor eax,eax
  xor ebx,ebx
  mov bx,segs32
  mov ax,TOS32
  shr ax,4
  add bx,ax                          ;bx => end of program in RAM
  shl ax,4
  cmp ax,TOS32
  jz s1
  inc bx
s1:
  ;add the pm_2_rm stacks
  mov pm2rm_stkend,bx
  mov ax,pm2rm_stks
  mul pm2rm_stklen
  add bx,ax
  mov pm2rm_stkcur,bx

;setup IDT
  mov di,offset idt
  mov si,offset ints
  xor cx,cx
  mov dx,word ptr picslave
i1:
  mov [di],si
  test cl,0f8h
  jz i2             ;1st 8 INTs?    (why? - BUG!)
  mov bl,cl
  and bl,0f8h       ;isolate high 5 bits
  cmp bl,dh
  jz i2             ;low IRQs?
  cmp bl,dl
  jz i2             ;high IRQs?
  or byte ptr[di+5],1   ;set as a trap gate
i2:
  add di,8
  inc si
  inc cl
  jnz i1
;setup other INTs
  mov word ptr[idt+3*8],offset int3h

  cli   ;no more IRQs allowed past this point

  lidt [idtr]
  lgdt [gdtr]

;clear NT and IOPL
  pushf
  mov bp,sp
  and word ptr [bp+1],08fh ;40h = NT bit , 30h = IOPL bits
  popf 

;goto PMODE!
  mov eax,cr0
  or al,1           ;set PM bit
  mov cr0,eax       ;we are now in 16bit PMODE
  
;setup a IRETD that will jump into our 32bit segment

  pushfd
  push dword ptr selcode32
  push dword ptr offset start32
  iretd   ;goto 32bit segment

start16 endp

;-----------------------------------------------------------------------------
; pm 2 rm & rm 2 pm   switching proc for RAW/XMS
; save/restore procs

pm_2_rm_rx proc  ;switches to Rmode  (raw/xms)

;  AX = new DS
;  CX = new ES
;  DX = new SS
;  BX = new SP
;  SI = new CS
;  DI = new IP

  push ax   ;save AX
  mov ds,cs:_selzero32
  xor eax,eax
  mov ax,dx
  shl eax,4
  movzx ebx,bx
  add eax,ebx
  pushf
  cli
  pop ds:[eax-2]
  mov ds:[eax-4],si
  mov ds:[eax-6],di
  pop di    ;pop ax into di
  lidt cs:rm_idtr
  mov ax,seldata16
  mov ds,ax
  mov es,ax
  mov fs,ax
  mov gs,ax
  mov ss,ax
  sub ebx,6   ;make room for iret data
  mov esp,ebx
  mov eax,cr0
  and al,0feh
  mov cr0,eax     ;now in rmode
  db 0eah
  dw $+4,segs16
  mov ss,dx
  mov ds,di       ;ax was poped into di
  mov es,cx
  xor ax,ax
  mov fs,ax
  mov gs,ax
  iret            ;goto target addr in real mod
pm_2_rm_rx endp

rm_2_pm_rx proc  ;switches to Pmode from Rmode

;  AX  = new DS
;  CX  = new ES
;  DX  = new SS
;  EBX = new ESP
;  SI  = new CS
;  EDI = new EIP

  pushfd
  cli
  push ax
  lgdt cs:gdtr
  lidt cs:idtr
  mov eax,cr0
  or al,1
  mov cr0,eax
  db 0eah
  dw $+4,selcode16
  pop ds
  mov es,cx
  xor ax,ax
  mov fs,ax
  mov gs,ax
  pop eax
  mov ss,dx                       ; load protected mode SS:ESP
  mov esp,ebx
  and ah,0bfh                     ; set NT=0 in old EFLAGS
  push ax                         ; set current FLAGS
  popf
  push eax                        ; store old EFLAGS
  push esi                        ; store protected mode target CS
  push edi                        ; store protected mode target EIP
  iretd                           ; go to targed addx in protected mode
rm_2_pm_rx endp

sr_state_rx proc
  retf   ;nothing to save/restore
sr_state_rx endp

;this proc was copied almost directly from PMODE v3.07 - why reinvent the
;wheel?
int3h proc
  ;this will redir INTs (and IRQs) to rmode
  cmp dword ptr[esp],offset ints            ;I added these extra checks in case
  jb do3                               ;this kernel is debugged later
  cmp dword ptr[esp],offset ints+255
  ja do3
  cmp word ptr[esp+4],selcode16            ;was it from our ints table or is it
  jz redir                             ; an embedded int 3?
;continue on to normal INT 3 handler
do3:
  jmp fword ptr int3vector                  ; JMP FAR sel:off32 handler
;redirect to proper handler in rmode
redir:
  mov [esp+8],eax                      ; store EAX for later POPAD
  mov eax,[esp]                        ; get address in redirection matrix
  add esp,8                            ; discard EIP and CS from INT 3
  push ecx                             ;-+
  push edx                             ; |
  push ebx                             ; |
  push esp                             ; |
  push ebp                             ; |
  push esi                             ; |
  push edi                             ;store rest of registers for POPAD
  push ds                              ;-+
  push es                              ; |
  push fs                              ; |
  push gs                              ;store all segment registers

  mov ds,cs:_selzero32                 ; DS -> 0 (beginning of memory)
  mov edi,cs:prg_base16                ; EDI = offset of SEGS16 from 0

  mov dx,cs:pm2rm_stkcur               ; DX = SS for real mode redirection
  xor ebp,ebp                          ;-+
  mov bp,dx                            ; |
  shl ebp,4                            ; EBP -> top of real mode stack

  mov bx,cs:pm2rm_stklen               ; get size of real mode stack
  sub dx,bx                            ; adjust DX to next stack location
  sub ds:pm2rm_stkcur[edi],bx          ; update ptr for possible reenterancy
  shl bx,4                             ; set real mode SP to top of stack

  cmp dx,cs:pm2rm_stkend               ; exceeded real mode stack space?
  jz critical_error                    ; if yes, critical error (hang)

  mov ds:[ebp-2],ss                    ; store SS:ESP on real mode stack
  mov ds:[ebp-6],esp

  sub ax,offset ints+1                 ; AX = int number
                                       ; the +1 is because the next instruct
                                       ; to return to is after the one-byte
                                       ; int 3 opcode
  mov ah,al                            ;-+
  and ah,0f8h                          ; AH = high 5 bits of int number

  cmp ah,cs:picslave                   ; high IRQ?
  jz redir_irq                         ; if yes, do IRQ
  cmp ah,cs:picmaster                  ; low IRQ?
  jnz redir_int                        ; if no, do INT (with general regs)
;-----------------------------------------------------------------------------
redir_irq:                             ; an IRQ redirection
  mov ds:irqnum[edi],al                ; modify code with interrupt number

  mov si,segs16                        ; real mode target CS:IP
  mov di,offset r1       
  sub bx,6                             ; adjust real mode SP for stored vars

  db 66h                               ; JMP DWORD PTR, as in 32bit offset,
  jmp word ptr cs:pm_2_rm              ;  not seg:16bit offset

r1:
  db 0cdh                              ; INT irqnum
irqnum db ?

  mov ax,selzero32                     ; DS selector value for protected mode
  mov cx,ax                            ; ES selector value for protected mode
  pop ebx                              ; get protected mode SS:ESP from stack
  pop dx
  mov si,selcode16                     ; target CS:EIP in protected mode
  mov edi,offset r2

  jmp cs:rm_2_pm                       ; go back to protected mode

r2:
  mov edi,cs:prg_base16                ; reslease real mode stack
  mov ax,cs:pm2rm_stklen
  add ds:pm2rm_stkcur[edi],ax

  pop gs                               ;-+
  pop fs                               ; |
  pop es                               ; |
  pop ds                               ; |
  popad                                ;restore all registers
  iretd

;-----------------------------------------------------------------------------
redir_int:                             ; an INT redirection
  mov ds:intnum[edi],al                ; modify code with interrupt number

  mov es,cs:_selzero32                 ; copy registers from protected mode
  lea edi,[ebp-26h]                    ;  stack to real mode stack
  lea esi,[esp+8]                      ; esp+8 => popad
  mov ecx,8
  cld
  rep movsd es:[edi],ss:[esi]          ; note the SS override!

  mov si,segs16                        ; real mode target CS:IP
  mov di,offset i1
  sub bx,26h                           ; adjust real mode SP for stored vars

  db 66h                               ; JMP DWORD PTR, as in 32bit offset,
  jmp word ptr cs:pm_2_rm              ;  not seg:16bit offset

i1:
  popad                                ; load regs with int call values

  db 0cdh                              ; INT intnum
intnum db ?

  pushad                               ; store registers on stack
  pushf                                ; store flags on stack
  cli
  cld

  xor eax,eax                          ; EAX = linear ptr to SS
  mov ax,ss
  shl eax,4
  movzx ebp,sp                         ; EBP = SP

  mov ebx,[bp+22h]                     ; get protected mode SS:ESP from stack
  mov dx,[bp+26h]

  add ebp,eax                          ; EBP -> stored regs on stack

  mov ax,selzero32                     ; DS selector value for pmode zero32
  mov cx,dx                            ; ES selector value for pmode stack
  mov si,selcode16                     ; target CS:EIP in protected mode
  mov edi,offset i2

  jmp cs:rm_2_pm                       ; go back to protected mode

i2:
  mov ax,ds:[ebp]                      ; move return FLAGS from real mode
  and ax,8d5h                          ;  stack to protected mode stack
  mov bx,[esp+30h]
  and bx,not 8d5h
  or ax,bx                             ; merge pmode/rmode flags
  mov [esp+30h],ax                     ; put flags onto IRETD

  lea esi,[ebp+2]                      ;DS:ESI => rmode pushad
  lea edi,[esp+8]                      ;ES:EDI => pmode popad
  mov ecx,8
  db 67h                               ;-+
  rep movsd                            ; copy from rmode stack to pmode stack

  mov edi,cs:prg_base16                ; release  real mode stack
  mov ax,cs:pm2rm_stklen
  add ds:pm2rm_stkcur[edi],ax

  pop gs                               ;-+
  pop fs                               ; |
  pop es                               ; |
  pop ds                               ; |
  popad                                ; restore all regs
  iretd
int3h endp

critical_error proc                    ; some unrecoverable error
 
critical_error endp

int21h_rm proc  ;INT 21h handler (rmode)
  
int21h_rm endp

code16seg ends

assume cs:segs32,ds:segs32,ss:segs32,es:NOTHING

data32seg segment use32
  x dd 0     ;coords of cursor on screen
  y dd 0
  timer dw 0

;32bit messages
  msg32_timer db ' = TIMER',13,0
  msg32_welcome db 'Welcome to 32bit PMODE!',13,0
  msg32_kbd db 'Test out the keyboard, press ESC to quit!',13,0
  key db ?,0
data32seg ends

code32seg segment use32

start32 proc
;reload all segment regs with 32bit selectors
  mov ax,seldata32
  mov ds,ax
  mov ss,ax
  mov fs,ax
  mov gs,ax
  mov esp,TOS32
  mov ax,selvid
  mov es,ax

  call clrscr   ;clear the screen

  mov esi,offset msg32_timer
  call print

  mov esi,offset msg32_welcome
  call print

  mov ax,selcode32
  mov edx,offset timer_irq
  mov bl,8
  call setint

  sti  ;enable IRQs

g1:
  mov ecx,0ffffh
  loop $            ;make a small delay so IRQ#0 will have a chance to
                    ;occur while in pmode

  mov ah,0bh
  int 21h
  cmp al,0
  jz g1         ;no key avail?

  mov ax,0
  int 16h

  cmp ah,1      ;is it the ESC scan code?
  jz quit       ;yes then quit
  mov key,al
  mov esi,offset key
  call print
  jmp g1

quit:
  mov ax,4c00h
  int 21h  ;quit program

start32 endp

clrscr proc
  xor edi,edi         ;linear addr of 0b800:0  (base=0b8000h)
  mov ecx,80*25
  mov ax,720h         ;07h=white on black 20h=spaces
  rep stosw
  mov x,0
  mov y,0
  ret
clrscr endp

;esi = string to print
print proc
p0:
  mov edi,y
  imul edi,edi,80*2    ;80*2 = # bytes/row (in text mode)d
  add edi,x
  add edi,x            ;add twice to skip over color bytes too
p1:
  cmp byte ptr[esi],0
  jz p3
  cmp byte ptr[esi],13
  jz p13
  movsb                ;ds:esi => es:edi
  inc edi              ;skip over color byte
  inc x
  cmp x,80
  jnz p1
p2:                    ;skip to next line
  mov x,0
  inc y
  cmp y,25
  jnz p0
  mov y,0
  jmp p0
p13:
  inc esi
  jmp p2
p3:
  ret
print endp

timer_irq proc
  ;this is carled during IRQ#0
  push eax
  push es
  push ds
  mov es,cs:_selvid
  mov ds,cs:_seldata32
  mov ax,timer
  inc timer
  mov byte ptr es:[0],al
  mov al,20h
  out 20h,al                           ;ack IRQ
  pop ds
  pop es
  pop eax
  iretd
timer_irq endp

setint proc
  ;sets one of the exception handlers to a new 32bit location
  ;by default all INTs goto rmode
  ;in : AX=selector
  ;   :EDX=offset
  ;   : BL=INT #  (currently only 0-31 are allowed - we will make our IDT
  ;                full size -256 vektorz- in the next tutorial) 
  movzx ebx,bl
  mov cx,seldata16
  mov ds,cx
  mov esi,offset idt
  mov [esi+ebx*8],dx                   ; set the offset (0-15)
  mov [esi+ebx*8+2],ax                 ; set the selector
  shr edx,16
  mov [esi+ebx*8+6],dx                 ; set the offset (16-31)
  mov cx,seldata32
  mov ds,cx
  ret
setint endp

code32seg ends

end start16     ;start program in segs16:start16

