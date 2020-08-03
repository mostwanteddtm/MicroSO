;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
;  Hugi 28: Hugi USB
;
;  The example.asm for Hugi Compo #28
;
;  This example does and tries to explain the process of getting
;   the device descriptor of a USB device.
;  It first finds the UHCI controller on the PCI bus, enables the
;   PCI, and gets the Base address and the Interrupt number.
;
;  It then, sets up the UHCI controller, a stack frame, and gets
;   the device descriptor of an attached device.
;
;  More detail to this process is within the comments to each particular
;   task below.
;
;         Version: 1.01.00
;            Date: 11 June 2009
;  Assembled with: NBASM http://www.fysnet.net/newbasic.htm
;          Author:  Ben Lunt (Sniper)
;
;  This code is intended for the Hugi Compo 28, and/or for those who
;   are learning about the USB and UHCI controller.  This code can not
;   be redistributed or copied for any other reason unless you have
;   direct concent from the author.
;


;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
; we are a .com file
.model tiny

;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
; EQUates

; The PCI Bus IO ports
PCI_ADDR   equ 0CF8h
PCI_DATA   equ 0CFCh

COMMAND    equ  0
STATUS     equ  2
INTERRUPT  equ  4
FRAME_NUM  equ  6
FRAME_ADDY equ  8
SOF        equ 12
PORT0      equ 16
PORT1      equ 18

IS_QUEUE   equ (1<<1)

;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
; Structs

UHCI_Q     struct
           horz      dword;
           vert      dword;
UHCI_Q     ends

UHCI_TD    struct
           link_ptr  dword;
           stats     dword;
           info      dword;
           buffer    dword;
           resv     dup 16;
UHCI_TD    ends

;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
; code stars here

.code         ;
.386          ; we will use (and assume) we are a .386 or better
.stack 512    ; leave 512 bytes for the stack

           org 100h  ; .com files start at 100h

           ; =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
           ; this is a NBASM directive to add the code
           ;  to free all memory past our code below
           .start

           ; =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
           ; First thing would be to find the UHCI controller on the PCI Bus
           ; We will do this using the PCI alone.  We could use the PCI
           ; BIOS services, ax = 0B1xxh, but I prefer to use the PCI itself.
           ; Using ports 0xCF8 and 0xCFC, we can read/write to the PCI Bus.
           ; We first write to the ADDRess port using the following bits:
           ;  Bit(s) 1: 0 reserved (should be written as zeros)
           ;         7: 2 config register number (see #00878 in RBIL)
           ;        10: 8 function number
           ;        15:11 device number
           ;        23:16 bus number
           ;        30:24 reserved (should be written as zeros)
           ;        31    enable configuration space mapping
           ; We must read in a dword at a time, with bits 7:2 detailing
           ;  which dword offset to read.           ;
           ; We assume there are at least 2 bus's, 32 devices per bus,
           ;  and 8 functions per device.
           xor  bx,bx               ; bh = bus, bl = dev
           xor  cl,cl               ; cl = function

           ; =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
           ; read in the ID word (first word in config space)
pci_main_loop:                        
           mov  dl,2                ; we want a 16-bit value returned
           xor  ch,ch               ; first offset we want is zero
           call pci_read            ; read the word
           cmp  ax,0FFFFh           ; if value is 0FFFFh, then no device
           je   short pci_no_device ;  at this location

           ; =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
           ; if vendor_id is not 0FFFFh, then there is a device there
           ; read in the class
           mov  dl,1
           mov  ch,11
           call pci_read            ; read the word
           cmp  al,0Ch              ;
           jne  short pci_no_device

           ; =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
           ; read in the sub_class
           mov  dl,1
           mov  ch,10
           call pci_read            ; read the word
           cmp  al,03h              ;
           jne  short pci_no_device

           ; =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
           ; read in the proto
           mov  dl,1
           mov  ch,9
           call pci_read            ; read the word
           cmp  al,00h              ; [1] See note at eof
           jne  short pci_no_device

           ; =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
           ; found UHCI device.
           mov  si,offset s_found_uhci_dev
           call prt_string
           jmp  short found_uhci

pci_no_device:
           inc  cl                  ; increment to next function
           cmp  cl,8                ; if it is 8, move to next device
           jb   short pci_main_loop ;
           xor  cl,cl               ; func = 0
           inc  bl                  ; increment to next device
           cmp  bl,32               ; if it is 32, move to next bus
           jb   short pci_main_loop ;
           xor  bl,bl               ; dev = 0
           inc  bh                  ; increment to next bus
           cmp  bh,2                ; if it is 2, then we didn't find the UHCI
           jb   short pci_main_loop ;

           mov  si,offset s_no_uhci_found
           call prt_string

           .exit

;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
; We found a UHCI device, so get the base address and the int number.
; Get and save the IO Base and Interrupt number
; Write 0005h to the PCI status register to allow access
; Also write 8F00h to the Legacy register in the config space
;
found_uhci:
           mov  dl,2                ; the IO base is 2 bytes in size
           mov  ch,20h              ; base4 is at offset 32
           call pci_read            ; read the word
           and  al,0FCh             ; clear out the last 2 bits
           mov  io_base,ax          ; save the io base

           mov  dl,1                ; the int num is 1 byte in size
           mov  ch,3Ch              ;  and is at offset 60
           call pci_read            ; read the byte
           mov  int_num,al          ; save the int number

           mov  eax,0005h           ; write 0005h to the access register
           mov  dl,2                ; is a word
           mov  ch,04h              ; at offset 04
           call pci_write           ; write it

           mov  eax,8F00h           ; write 8F00h to the legacy register
           mov  dl,2                ; is a word
           mov  ch,0C0h             ; at offset C0h
           call pci_write           ; write it

;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
; reset the controller by setting bit 2 (GRESET) in the command register
;  waiting at least 10ms, then reseting the bit.
           mov  dx,io_base
           add  dx,COMMAND
           mov  ax,(1<<2)           ; bit 2 (GRESET)
           out  dx,ax

           ; now wait for at least 10ms
           call delay55ms

           ; clear the register (setting it to default values)
           mov  dx,io_base
           add  dx,COMMAND
           xor  ax,ax
           out  dx,ax

;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
; we now need to set up a frame list.  Per the rules, we need to
;  allocate it using DOS
           ; =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
           ; since the frame address requires alignment of 4096,
           ;  we allocate (4096 * 2) bytes
           mov  ah,48h
           mov  bx,((4096*2)>>4)
           int  21h
           jnc  short @f

           mov  si,offset s_no_memory
           call prt_string
           .exit

           ; =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
           ; save the address for the mfree call and
           ; convert to 32-bit and write to the controller
@@:        mov  frame_addr,ax
           and  eax,0FFFFh
           shl  eax,4
           add  eax,4095
           and  eax,(~4095)
           mov  dx,io_base
           add  dx,FRAME_ADDY
           out  dx,eax
           shr  eax,4
           mov  frame_addra,ax

           ; =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
           ; mark each frame as 'T'erminated
           push es
           mov  ax,frame_addra
           mov  es,ax
           xor  di,di
           mov  eax,1
           mov  cx,1024
           rep
           stosd
           pop  es

           ; =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
           ; Set the IOC interrupt bit enable
           ; *We must set all four bit to get Bochs to work*
           ; (Ben: Fix Bochs)
           mov  dx,io_base
           add  dx,INTERRUPT
           mov  ax,000Fh
           out  dx,ax

           ; =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
           ; Start the UHCI controller.
           mov  dx,io_base
           add  dx,COMMAND
           mov  ax,01
           out  dx,ax

;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
; This is where the main loop starts.  We find a port with the ConnectChange
;  bit set, clear it, see if connection is made, and get the descriptor.

           ; =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
           ; A few things to start with.
           mov word port,10h        ; Port = 10h

           ; =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
main_loop: ; set up the address in dx
           mov  dx,io_base
           add  dx,port

           ; test the connect status change bit
           in   ax,dx
           test ax,(1<<1)            ; connect status change bit
           jz   no_device_attached

           ; reset the connect status change bit
           mov  ax,(1<<1)
           out  dx,ax

           ; test the connect status bit
           in   ax,dx
           test ax,(1<<0)
           jz   no_device_attached

;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
; there is a connection, reset, and send the packet
           ; =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
           ; first reset the port
           mov  ax,(1<<9)
           out  dx,ax

           ; now wait for at least 50ms
           call delay55ms

           ; clear the reset
           in   ax,dx
           and  ax,(~(1<<9))
           out  dx,ax

           ; now wait for at least 50ms
           call delay55ms

           ; =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
           ; enable the device
           in   ax,dx
           or   ax,(1<<2)
           out  dx,ax

           ; =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
           ; we can not assume it is a LS device,
           ;  so get the LS bit in the PORTS[x] register.
           ; we set/clear the bit in ecx for or'ing
           xor  ecx,ecx
           in   ax,dx
           test ax,(1<<8)
           jz   short @f
           or   ecx,(1<<26)
@@:
           ; =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
           ; set up our frame TD's
           ; We already have then hard coded in our data section,
           ;  but need to fix up the addresses.
           xor  eax,eax             ; get the segment address
           mov  ax,cs               ; 
           shl  eax,4               ; convert to 32-bit address

           ; Setup_TD
           mov  edx,eax
           add  edx,offset TD0      ;
           mov  Setup_TD.link_ptr,edx
           or   Setup_TD.stats,ecx  ; set/or don't set LS bit
           mov  edx,offset Setup_Packet
           add  edx,eax
           mov  Setup_TD.buffer,edx

           ; TD0
           mov  edx,eax
           add  edx,offset TD1
           mov  TD0.link_ptr,edx
           or   TD0.stats,ecx  ; set/or don't set LS bit
           mov  edx,(Device_Descriptor + 0)
           add  edx,eax
           mov  TD0.buffer,edx

           ; TD1
           mov  edx,eax
           add  edx,offset TD2
           mov  TD1.link_ptr,edx
           or   TD1.stats,ecx  ; set/or don't set LS bit
           mov  edx,(Device_Descriptor + 8)
           add  edx,eax
           mov  TD1.buffer,edx

           ; TD2
           mov  edx,eax
           add  edx,offset Status_TD
           mov  TD2.link_ptr,edx
           or   TD2.stats,ecx  ; set/or don't set LS bit
           mov  edx,(Device_Descriptor + 16)
           add  edx,eax
           mov  TD2.buffer,edx

           ; Status_TD
           or   Status_TD.stats,ecx  ; set/or don't set LS bit

           ; =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
           ; Set up the Queue Head
           mov  edx,offset Setup_TD
           add  edx,eax
           mov  dword Queue.horz,1
           mov  Queue.vert,edx

           ; =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
           ; point the first frame in the list to our queue.
           push es
           mov  es,frame_addra
           add  eax,offset Queue   ; eax still = 'base address'
           or   eax,IS_QUEUE       ; is a queue
           mov  es:[0],eax
           pop  es

           ; =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
           ; wait for the interrupt to happen
           mov  dx,io_base
           add  dx,2
@@:        call delay55ms
           in   ax,dx
           test ax,1
           jz   short @b

           ; =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
           ; print that the interrupt fired
           mov  si,offset s_fired
           call prt_string

           ; =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
           ; now mark the frame pointer as terminated
           push es
           mov  es,frame_addra
           mov  eax,00000001
           mov  es:[0],eax
           pop  es

           ; =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
           ; now print it out.
           mov  si,offset crlf
           call prt_string

           mov  si,offset Device_Descriptor
           mov  cx,7
@@:        lodsb
           call prt_byte
           mov  ah,02
           mov  dl,' '
           int  21h
           loop @b

           lodsb
           call prt_byte
           mov  ah,02
           mov  dl,'-'
           int  21h

           mov  cx,8
@@:        lodsb
           call prt_byte
           mov  ah,02
           mov  dl,' '
           int  21h
           loop @b

           push si
           mov  si,offset crlf
           call prt_string
           pop  si

           mov  cx,2
@@:        lodsb
           call prt_byte
           mov  ah,02
           mov  dl,' '
           int  21h
           loop @b

           ; =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
           ; we are done with this one, so loop until
           ;  we find a connect status change bit set again.

           ; =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
           ; move to next port and loop
no_device_attached:
           add  word port,02h
           cmp  word port,12h
           jbe  main_loop

           ; =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
           ; start at the first port again.
           mov  word port,10h

           ; =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
           ; if we are now past the forth port,
           ;  check for a key press. If key press,
           ;  then end, else reset to the first port,
           ;  and loop again.
           mov  ah,01h
           int  16h
           jz   main_loop

;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
; user pressed a key, so do the clean up and exit

           ; =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
           ; stop the controller
           mov  dx,io_base
           add  dx,COMMAND
           xor  ax,ax
           out  dx,ax

           ; =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
           ; free the address we used for the frame_addr
           push es
           mov  ah,49h
           mov  es,frame_addr
           int  21h
           pop  es

           ; =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
           ; done, so exit cleanly
           .exit

;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
; if we wait for the BIOS time_stamp to increment at least
;  once, we have waited at least 1/18.2 of a second or 55ms
;  and at most 1/9.1 of a second, or 109ms
delay55ms  proc near uses es
           xor  ax,ax
           mov  es,ax
           mov  ax,es:[046Ch]   ; wait the first time for the actual tick
@@:        cmp  ax,es:[046Ch]
           je   short @b
           mov  ax,es:[046Ch]   ; wait the second time for another tick
@@:        cmp  ax,es:[046Ch]
           je   short @b
           ret
delay55ms  endp


;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
; read from the PCI config space
; on entry:
;  bh = bus
;  bl = dev
;  cl = func
;  ch = offset in bytes (0, 1, 2, ,255)
;  dl = size in bytes to return
; on return
;  eax = read value in (dl) bytes
pci_read   proc near uses cx edx
           push dx                  ; save size wanted in dl
           mov  eax,8000h
           mov  al,bh               ; bus
           shl  eax,5
           or   al,bl               ; dev
           shl  eax,3
           or   al,cl               ; func
           shl  eax,6
           push cx                  ;
           shr  ch,2                ; make dword based
           or   al,ch               ; offset
           pop  cx                  ; 
           shl  eax,2               ; last two bits are zero.
           mov  dx,PCI_ADDR
           out  dx,eax
           mov  dl,ch               ; last 2 bits of offset
           and  dx,0003h
           add  dx,PCI_DATA
           in   eax,dx
           pop  dx                  ; restore size wanted in dl
           mov  cl,4
           sub  cl,dl
           shl  cl,3
           mov  edx,0FFFFFFFFh
           shr  edx,cl
           and  eax,edx
           ret
pci_read   endp

;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
; write to the PCI config space
; on entry:
;  bh = bus
;  bl = dev
;  cl = func
;  ch = offset in bytes (0, 1, 2, ,255)
;  dl = size in bytes
; eax = value to write
; on return
;  nothing
pci_write  proc near uses cx ebx edx
           push eax                 ; save value to write
           push dx                  ; save size wanted in dl
           mov  eax,8000h
           mov  al,bh               ; bus
           shl  eax,5
           or   al,bl               ; dev
           shl  eax,3
           or   al,cl               ; func
           shl  eax,6
           push cx                  ;
           shr  ch,2                ; make dword based
           or   al,ch               ; offset
           pop  cx                  ; 
           shl  eax,2               ; last two bits are zero.
           mov  dx,PCI_ADDR
           out  dx,eax
           mov  dl,ch               ; last 2 bits of offset
           and  dx,0003h
           add  dx,PCI_DATA
           in   eax,dx
           pop  cx                  ; restore size wanted in cl
           shl  cl,3
           mov  ebx,0FFFFFFFFh
           shl  ebx,cl
           and  eax,ebx
           pop  ebx
           or   eax,ebx
           out  dx,eax
           ret
pci_write  endp

;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
; print a string
; on entry:
;  ds:si -> asciiz string
; on return:
;  nothing
prt_string proc near uses ax dx si
           mov  ah,02                   ; DOS print char service
@@:        lodsb                        ; Get character & point to next one
           or   al,al                   ; End of string?
           jz   short @f                ; Yes, so exit
           mov  dl,al                   ; 
           int  21h                     ; Output a character
           jmp  short @b                ; Keep doing it
@@:        ret
prt_string endp

;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
; print a byte in hex format
; on entry:
;  al = value
; on return:
;  nothing
prt_byte   proc near uses ax cx dx
           mov  cx,02
@@:        rol  al,04          ;
           push ax             ;
           and  al,0Fh         ;
           daa                 ;
           add  al,0F0h        ;
           adc  al,40h         ;
           mov  ah,02          ;
           mov  dl,al          ;
           int  21h            ;
           pop  ax             ;
           loop @b             ;
           ret
prt_byte   endp

;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
; data

io_base    dw 0000h    ; the io base for the UHCI
int_num    db 00h      ; interrupt number to use

frame_addr  dw 0000h   ; segment address of allocated memory
frame_addra dw 0000h   ; segment address of aligned memory

port       dw  0000h   ; port number offset 0x10 or 0x12

.para ; must be paragraph aligned
Queue      st  UHCI_Q

.para
Setup_TD   st  UHCI_TD uses  000000000h                \ ; calc'd at run time
                             ((3<<27) | (80h<<16))     \ ; C_ERR | STATUS
                             ((7<<21) | (0<<19) | 2Dh) \ ; Len = 8, Data0, Setup
                             000000000h                  ; calc'd at run time

TD0        st  UHCI_TD uses  000000000h                \ ; calc'd at run time
                             ((3<<27) | (80h<<16))     \ ; C_ERR | STATUS
                             ((7<<21) | (1<<19) | 69h) \ ; Len = 8, Data1, In
                             000000000h                  ; calc'd at run time

TD1        st  UHCI_TD uses  000000000h                \ ; calc'd at run time
                             ((3<<27) | (80h<<16))     \ ; C_ERR | STATUS
                             ((7<<21) | (0<<19) | 69h) \ ; Len = 8, Data0, In
                             000000000h                  ; calc'd at run time

TD2        st  UHCI_TD uses  000000000h                \ ; calc'd at run time
                             ((3<<27) | (80h<<16))     \ ; C_ERR | STATUS
                             ((1<<21) | (1<<19) | 69h) \ ; Len = 2, Data1, In
                             000000000h                  ; calc'd at run time

Status_TD  st  UHCI_TD uses  000000001h                \ ; terminate
                             ((3<<27) | (1<<24) | (80h<<16)) \ ; C_ERR | IOC | STATUS
                             ((7FFh<<21) | (1<<19) | 0E1h) \ ; Len = 0, Data1, Out
                             000000000h                  ; calc'd at run time

Device_Descriptor  dup 18,0

Setup_Packet  db 80h    ; dev->host, type=standard, recipient=device
              db  6     ; get descriptor
              db  0     ; index = 0
              db  1     ;  type = device
              dw  0     ; value = 0 (not used)
              dw  18    ; 18 bytes

;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
; strings
s_no_uhci_found  db 13,10,"We didn't find a UHCI...",0
s_found_uhci_dev db 13,10,'Found a UHCI device: ',0
s_no_memory      db 13,10,'No memory found.',0
s_fired          db 13,10,'Interrupt fired.',0

crlf  db 13,10,0


.end
