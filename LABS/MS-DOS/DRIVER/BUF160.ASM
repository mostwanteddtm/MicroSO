 title BUF160
 page 58,132
;
; BUF160.ASM
;
;**********************************************************************
; Compilation flags
;********************************************************************** 

TRANSFER equ 1 ;Enables keyboard buffer transfer v1.4
 ; procedure if enabled (1) v1.4
USE286 equ 0 ;Should we use 286 (and later) v1.5
 ; CPU specific instructions? v1.5
PRIVATESTACK equ 1 ;Use own stack? v1.6
PROGNAME equ 'BUF160'
VERSION equ 'v1.6a, 29 January 1992'
;**********************************************************************
; General equates
;**********************************************************************
BUFSIZE equ 160 ;What is the size of the keyboard buffer
STACKSZ equ 100h ;What is the size of the private buffer
SUCCESS equ 0100h
ERROR equ 8100h
BUSY equ 0300h
CR equ 13 ;Carriage Return
LF equ 10 ;Line Feed
TERM equ '$' ;DOS printing terminator character
;**********************************************************************
; Data structures
;**********************************************************************
dqq struc
ofs dw ?
segw dw ? ;changed from 'seg' to keep MASM 5.0 happy v1.4
dqq ends
rqq struc ;Request header structure
len db ? ;length of request block (bytes)
unit db ? ;unit #
code db ? ;driver command code
status dw ? ;status return
q1 dd ? ;8 reserved bytes
q2 dd ?
mdesc db ? ;donno
trans dd ?
count dw ?
rqq ends
;**********************************************************************
; Pointers to BIOS data segment, v1.4 

;**********************************************************************
BIOS_DATA_SEG equ 40H ;MASM had prob using BIOS_DATA in calculations,
 ; so this typeless constant introduced. v1.6
BIOS_DATA SEGMENT AT BIOS_DATA_SEG
 org 1AH
BUFFER_GET dw ? ;org 1ah
BUFFER_PUT dw ? ;org 1ch
 org 80H
BUFFER_START dw ? ;org 80h
BUFFER_END dw ? ;org 82h
BIOS_DATA ENDS
;**********************************************************************
; The actual program
;**********************************************************************
Cseg segment byte
 assume cs:Cseg,ds:Cseg,es:Cseg,ss:Cseg
 org 0 ; no offset, it's a .SYS file
start equ $ ; define start=CS:0000
IF USE286 ; v1.5
 .286
 %OUT Compiling 286 code ...
ELSE
 %OUT Compiling generic 8086 code ...
ENDIF
IF PRIVATESTACK
 %OUT Using private stack ...
ELSE
 %OUT Not using private stack ...
ENDIF
IF TRANSFER
 %OUT Including keyboard transfer code ...
ELSE
 %OUT Not including keyboard transfer code ...
ENDIF
 public header
header label near
 dd -1 ;pointer to next device
 dw 8000h ;type device
 dw Strat ;strategy entry point
 dw Intr ;interrupt entry point
 db 'KBUFFER ' ;device name 

 public req
req dd ? ;store request header vector here
 public queue_start,queue_end
queue_start dw BUFSIZE dup (0) ;our expanded keyboard buffer
queue_end equ $ - start ;calculate offset as typeless constant
IF PRIVATESTACK ; v1.6
stack_end db STACKSZ dup (0) ;use our own private data stack
stack_start equ $
oldss dw 0
oldsp dw 0
oldax dw 0
ENDIF
;*********************************************************************
; Strategy procedure
; Save the pointer to the request header for Intr in the req area.
; Enters with pointer in es:bx
;*********************************************************************
 public Strat
Strat proc far
 mov cs:[req].ofs,bx
 mov cs:[req].segw,es ; v1.4
 ret
Strat endp
;**********************************************************************
; The main interrupt (driver)
; This is the actual driver. Processes the command contained in the
; request header. (Remember, req points to the request header.)
;**********************************************************************
 public Intr
 ASSUME ds:Cseg, es:NOTHING ; v1.4
Intr proc far
IF PRIVATESTACK ;If using private stack, process
 mov cs:oldax, ax ; v1.6
 cli ; turn ints off
 mov ax, ss
 mov cs:oldss, ax 

 mov cs:oldsp, sp
 mov sp, offset stack_start
 mov ax, cs
 mov ss, ax
 sti ; turn ints back on
 mov ax, cs:oldax
ENDIF
 push ds ;save everything in sight
 push es
IF USE286
 pusha ; v1.5
ELSE
 push ax
 push bx
 push cx
 push dx
 push di
 push si
ENDIF
 mov ax,cs
 mov ds,ax ;DS=code segment
 les bx,req ;point to request hdr v1.4a
 mov si,offset cmd_table ;our function table
 mov cl,es:[bx].code ;get command
 xor ch,ch ;clear msb v1.4
 shl cx,1 ;*2 for word addresses
 add si,cx ;add to table base
 call word ptr [si] ;call our function v1.4a
 les bx,cs:req ;get back request hdr vector
 mov es:[bx].status,ax ;return status
IF USE286
 popa ; v1.5
ELSE
 pop si ;clean everything up
 pop di
 pop dx
 pop cx
 pop bx
 pop ax
ENDIF
 pop es
 pop ds 

IF PRIVATESTACK
 mov ax, cs:oldss ; v1.6
 cli ; turn ints off
 mov ss, ax
 mov sp, cs:oldsp
 mov ax, cs:oldax
 sti ; turn ints on
ENDIF
 ret
 public cmd_table
cmd_table: ;command routing table
 dw Cmd_Init ;0=initialization (we do that)
 dw Cmd_None ;1=media check (always SUCCESS)
 dw Cmd_None ;2=build BIOS param block (ditto)
 dw Cmd_None ;3=IO control input (ditto)
 dw Cmd_None ;4=input from device (ditto)
 dw Cmd_None ;5=nondest input no-wait (ditto)
 dw Cmd_None ;6=input status (ditto)
 dw Cmd_None ;7=flush input queue (ditto)
 dw Cmd_Output ;8=output to device (we do that)
 dw Cmd_Output ;9=output with verify (same thing)
 dw Cmd_Output_Status ;A=output status (we do that)
 dw Cmd_None ;B=flush output queue (always SUCCESS)
 dw Cmd_None ;C=IO control output (ditto)
;*********************************************************************
; Cmd_Output procedure
;*********************************************************************
 public Cmd_Output
Cmd_Output proc near
 mov ax,BIOS_DATA
 mov ds,ax ;BIOS data area
 ASSUME ds:BIOS_DATA ;keep MASM happy v1.4
 mov cx,es:[bx].count
 les bx,es:[bx].trans
Output_Loop:
 mov al,es:[bx]
 inc bx
 cli
 mov di,BUFFER_PUT ;next free space v1.4
 call Buf_Wrap ;add 2, check for wraparound
 cmp di,BUFFER_GET ;is the buffer full? v1.4
 sti ;ints back on v1.4
 je Output_Error ;buffer is full, error v1.4 

 xchg BUFFER_PUT,di ;save the old, get the new v1.4
 xor ah,ah
 mov [di],ax ; v1.4
 loop Output_Loop
 public Cmd_None ; v1.4
Cmd_None: ;share this code v1.4
 mov ax,SUCCESS
 ret
Output_Error:
 mov ax,ERROR
 ret
Cmd_Output endp
;*********************************************************************
; Buf_Wrap procedure
;*********************************************************************
 public Buf_Wrap
Buf_Wrap proc near
 inc di
 inc di
 cmp di,BUFFER_END ;hit end yet? v1.4
 je Wrap ;>=, wrap around v1.4
 ret
Wrap:
 mov di,BUFFER_START ;force ptr to start v1.4
 ret
Buf_Wrap endp
;*********************************************************************
; Cmd_Output_Status procedure
;*********************************************************************
 public Cmd_Output_Status
Cmd_Output_Status proc near
 mov ax,BIOS_DATA
 mov ds,ax
 mov di,BUFFER_PUT ;ptr to next free space v1.4
 call Buf_Wrap ;wraparound if necessary
 cmp di,BUFFER_GET ;same as next char to get? v1.4
 jne Cmd_None ;ok, return SUCCESS v1.4a
 mov ax,BUSY
 ret
Cmd_Output_Status endp 

 public last_code
last_code label near
;*********************************************************************
; Initialization (installation) procedure
;*********************************************************************
 public Cmd_Init
Cmd_Init proc near
 mov ax,cs
 mov ds,ax
 mov es,ax ; v1.4a
 ASSUME ds:Cseg,es:Cseg ; v1.4a
; Is our new keyboard buffer within reach of the near pointers in
;BIOS_DATA?
 cmp ax,(0fffh+BIOS_DATA_SEG-queue_end/10h); v1.6
 ja Init_Error ;No, too far away
 mov dx,offset banner ;Yes, 'Buf160 loaded'
 mov ah,9 ;DOS display msg
 int 21h
 mov bx,0 ;Initialize size of buf v1.5
 mov cx,BIOS_DATA ;PRESERVE THIS! v1.4
 mov ds,cx ;BIOS data area
 ASSUME ds:BIOS_DATA ; v1.4
 cli ;turn off ints v1.6a
IF TRANSFER
 public Transfer_Buffer
Transfer_Buffer:
 mov si,BUFFER_GET ;next key to read v1.4
 mov dx,BUFFER_PUT ;next empty space v1.4a
 mov di,offset queue_start ;gonna stuff here v1.4a
 cld ;insure fwd v1.4
Transfer_Loop:
 cmp si,dx ;hit empty yet? v1.4a
 je Transfer_Done ;yep, transfer complete
 lodsw ;snarf the kbd word
 stosw ;stuff in OUR buffer v1.4a
 inc bx ;increment counter v1.5
 inc bx ;increment counter v1.5 

 cmp si,BUFFER_END ;hit kbd buffer's end yet? v1.4
 jne Transfer_Loop ; nope, keep going
 mov si,BUFFER_START ;yep, wrap around to start v1.4
 jmp Transfer_Loop ; and keep going
 public Transfer_Done
Transfer_Done:
ENDIF
 mov ax,cs ;Code Segment
 sub ax,cx ; calculate difference b/w bios & this
IF USE286
 shl ax,4 ; v1.5
ELSE
 shl ax,1 ;remainder * 16 (paras to bytes)
 shl ax,1
 shl ax,1
 shl ax,1
ENDIF
 mov cx,ax ;CX = driver starting offset
 add ax,offset queue_start ;AX = queue_start offset
 mov BUFFER_START,ax ;init BIOS buffer pointers v1.4
 mov BUFFER_GET,ax ; v1.4
 add ax,bx ;here'e next free space
 mov BUFFER_PUT,ax ;tell BIOS v1.4
 mov ax,cx ;get back driver starting offset v1.4a
 add ax,queue_end ;code start + queue end v1.4a
 mov BUFFER_END,ax ;tell BIOS v1.4
 sti ;restore ints v1.6a
 les bx,cs:[req] ;complete driver header
 mov es:[bx].trans.ofs,offset last_code ;driver end
 jmp short Stuff_Seg ;share code, return success v1.4a
 public Init_Error
 ASSUME ds:Cseg,es:Cseg ; v1.4
Init_Error:
 mov dx,offset msg_err ;'Buf160 too far...'
 mov ah,9 ;display msg
 int 21h
 les bx,cs:[req] ;complete driver header v1.6
 IF 0 ;not sure if it works.
 mov es:[bx].trans.ofs,0 

 ELSE
 mov es:[bx].trans.ofs,offset last_code
 ENDIF
Stuff_Seg: ; v1.4a
 mov es:[bx].trans.segw,cs ; v1.4
 mov ax,SUCCESS
 ret
Cmd_Init endp
 public banner, msg_err
banner db PROGNAME,' ',VERSION,' installed.',CR,LF ;v1.4
 db 'Keyboard now has buffer of 160 characters.'
IF PRIVATESTACK
 db ' Using private stack.'
ENDIF
 db CR,LF,CR,LF,TERM
msg_err db PROGNAME,' too far from BIOS data area.' ;v1.4
 db CR,LF,CR,LF,TERM
Intr endp
Cseg ends
 end 