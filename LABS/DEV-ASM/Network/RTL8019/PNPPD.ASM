
;################################################################################
;
;  Title:        RTL8019 Plug-And-Play Packet Driver
;
;  History:      V1.00  --   1994.07.29
;                V1.10  --   1994.09.05
;                V1.20  --   1994.10.05
;                V1.30  --   1995.07.05
;
;  Notes:        All changed codes are marked with the release date 'DD/MM/YY'.
;                In other words, you may search '07/12/90' if you want to find
;                the changed codes of a source program released on 1990.07.12,
;
;################################################################################
;
;
;  Name:          PNPPD.100
;
;  Version:       V1.00
;
;  Released By:   tflin
;
;  Release Date:  1994.07.29
;
;  Changed File:
;
;  Reason:        New release version.
;
;  Comment:       When 2 or more 8019 cards are installed. This program will use
;                the one which has lower PnP serial Number.
;
;################################################################################
;
;
;  Name:          PNPPD.110
;
;  Version:       V1.10
;
;  Released By:   tflin
;
;  Release Date:  1994.09.05
;
;  Changed File:  EXE/PNPPD.COM
;                 SOURCE/PNPPD.ASM
;                 SOURCE/TAIL.ASM
;
;  Reason:       1. Driver supports at most 4 RTL8019 Cards.
;
;                2. Fixed the bug when in PnP environments, Jumper/Jumpless Card
;                will not be found.
;
;                3. In multiple-card case, driver will print out all cards'
;                information and prompt user to select one.
;
;  Comment:      1. After the driver runs, CSN values of PnP Cards will be
;                preserved. For Jumper/Jumpless cards, CSNs are set back to 0.
;################################################################################
;
;
;  Name:          PNPPD.120
;
;  Version:       V1.20
;
;  Released By:   Jasper
;
;  Release Date:  1994.10.05
;
;  Changed File:  EXE/PNPPD.COM
;                 SOURCE/PNPPD.ASM
;
;  Reason:       1. Driver supports up to 8 RTL8019 Cards.
;
;                2. Uses direct IO scanning method to locate 8019 cards.
;
;
;################################################################################
;
;
;  Name:          PNPPD.130
;
;  Version:       V1.30
;
;  Released By:   C.C.Liu
;
;  Release Date:  1994.07.05
;
;  Changed File:  EXE/PNPPD.COM
;                 SOURCE/PNPPD.ASM
;                 SOURCE/TAIL.ASM
;
;  Reason:       1. Processing parameters about commnd line.
;
;                2. Add help option  -h .
;
;################################################################################

version equ     4
;History:76,1 0

;  The following people have contributed to this code: David Horne, Eric
;  Henderson, and Bob Clements.

;  Copyright, 1988-1992, Russell Nelson, Crynwr Software

;   This program is free software; you can redistribute it and/or modify
;   it under the terms of the GNU General Public License as published by
;   the Free Software Foundation, version 1.
;
;   This program is distributed in the hope that it will be useful,
;   but WITHOUT ANY WARRANTY; without even the implied warranty of
;   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;   GNU General Public License for more details.
;
;   You should have received a copy of the GNU General Public License
;   along with this program; if not, write to the Free Software
;   Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.

        include defs.asm

code    segment word public
        assume  cs:code, ds:code

;*****************************************************************************
;
;       NE2000 controller board offsets
;       IO port definition (BASE in io_addr)
;*****************************************************************************
NE_DATAPORT     EQU     10h             ; NE2000 Port Window.
NE_RESET        EQU     1fh             ; Issue a read for reset
EN_OFF          equ     0h

        include 8390.inc

; Shared memory management parameters

SM_TSTART_PG    equ     040h    ; First page of TX buffer
SM_RSTART_PG    equ     046h    ; Starting page of RX ring
SM_RSTOP_PG     equ     080h    ; Last page +1 of RX ring

pause_  macro
;       jmp     $+2
;
; The reason for the pause_ macro is to establish a minimum time between
; accesses to the card hardware. The assumption is that the fetch and execution
; of the jmp $+2 instruction will provide this time. In a fast cache machine
; this may be a false assumption. In a fast cache machine, there may be
; NO REAL TIME DIFFERENCE between the two I/O instruction streams below:
;
;       in      al,dx           in      al,dx
;       jmp     $+2
;       in      al,dx           in      al,dx
;
; To establish a minimum delay, an I/O instruction must be used. A good rule of
; thumb is that ISA I/O instructions take ~1.0 microseconds and MCA I/O
; instructions take ~0.5 microseconds. Reading the NMI Status Register (0x61)
; is a good way to pause on all machines.
;
; The National 8390 Chip (NIC) requires 4 bus clocks between successive
; chip selects (National DP8390 Data Sheet Addendum, June 1990 -- it took them
; long enough to figure this out and tell everyone) or the NIC behaves badly.
; Therefor one I/O instruction should be inserted between each successive
; NIC I/O instruction that could occur 'back - to - back' on a fast cache
; machine.
;   - gft - 910529
;
        push    ax
        in      al, 61h
        pop     ax
;
endm

reset_8390      macro
        loadport
        setport NE_RESET
        in      al,dx
        longpause
        out     dx,al           ; should set command 21, 80

        endm

terminate_board macro
        endm

        public  int_no, io_addr
int_no          db      2,0,0,0         ;must be four bytes long for get_number.
io_addr         dw      0300h,0         ; I/O address for card (jumpers)

        public  driver_class, driver_type, driver_name, driver_function, parameter_list
driver_class    db      BLUEBOOK, IEEE8023, 0           ;from the packet spec
driver_type     dw      54              ;from the packet spec
driver_name     db      'PNPPD ',0,0,0,0      ;name of the driver.
driver_function db      2
parameter_list  label   byte
        db      1       ;major rev of packet driver
        db      9       ;minor rev of packet driver
        db      14      ;length of parameter list
        db      EADDR_LEN       ;length of MAC-layer address
        dw      GIANT   ;MTU, including MAC headers
        dw      MAX_MULTICAST * EADDR_LEN       ;buffer size of multicast addrs
        dw      0       ;(# of back-to-back MTU rcvs) - 1
        dw      0       ;(# of successive xmits) - 1
int_num dw      0       ;Interrupt # to hook for post-EOI
                        ;processing, 0 == none,

;;        extrn   is_186: byte            ;=0 if 808[68], =1 if 80[123]86.
is_16_slot      db      1

;
;       Block input routine
;       CX = byte count, es:di = buffer location, ax = buffer address

        public  block_input
block_input:
        push    ax              ; save buffer address
        loadport
        setport EN_CCMD
        pause_
        mov     al,ENC_NODMA+ENC_PAGE0+ENC_START
        out     dx,al
        setport EN0_RCNTLO      ; remote byte count 0
        pause_
        mov     al,cl
        out     dx,al
        setport EN0_RCNTHI
        pause_
        mov     al,ch
        out     dx,al
        pop     ax              ; get our page back
        setport EN0_RSARLO
        pause_
        out     dx,al           ; set as hi address
        setport EN0_RSARHI
        pause_
        mov     al,ah
        out     dx,al
        setport EN_CCMD
        pause_
        mov     al,ENC_RREAD+ENC_START  ; read and start
        out     dx,al
        setport NE_DATAPORT
        pause_
;;        cmp     is_186,0
        cmp     is_16_slot,0
        jnz     read_186
read_loop:
        in      al,dx           ; get a byte
        stosb                   ; save it
        loop    read_loop
        ret
read_186:
        shr     cx,1            ; word count
        .286
        rep     insw
        .8086
        jnc     read_186_1              ;is there an extra byte?
        in      ax,dx                   ;yes, read the next word and store a
        stosb                           ;  byte.
read_186_1:
        ret
;
;       Block output routine
;       CX = byte count, ds:si = buffer location, ax = buffer address

block_output:
        assume  ds:nothing
        push    ax              ; save buffer address
        inc     cx              ; make even
        and     cx,0fffeh
        loadport
        setport EN_CCMD
        pause_
        mov     al,ENC_NODMA+ENC_START
        out     dx,al           ; stop & clear the chip
        setport EN0_RCNTLO      ; remote byte count 0
        pause_
        mov     al,cl
        out     dx,al
        setport EN0_RCNTHI
        pause_
        mov     al,ch
        out     dx,al
        pop     ax              ; get our page back
        setport EN0_RSARLO
        pause_
        out     dx,al           ; set as lo address
        setport EN0_RSARHI
        pause_
        mov     al,ah
        out     dx,al
        setport EN_CCMD
        pause_
        mov     al,ENC_RWRITE+ENC_START ; write and start
        out     dx,al
        setport NE_DATAPORT
        pause_
;;        cmp     is_186,0
        cmp     is_16_slot,0
        jnz     write_186
write_loop:
        lodsb                   ; get a byte
        out     dx,al           ; save it
        loop    write_loop
        jmp     short block_output_1
write_186:
        shr     cx,1            ; word count
        .286
        rep     outsw
        .8086
block_output_1:
        mov     cx,0
        setport EN0_ISR
tx_check_rdc:
        in      al,dx
        test    al,ENISR_RDC    ; dma done ???
        jnz     tx_start
        loop    tx_check_rdc
        stc
        ret
tx_start:
        clc
        ret


        include 8390.asm

        public  usage_msg
usage_msg       db      "Usage: PNPPD     [options] [packet_int_no(default=0x60)]",CR,LF,'$'

        public  copyright_msg
copyright_msg   db      "Packet driver for REALTEK 8019 Plug&Play Ethernet Card, version "
;  ;;;;;;;;;;;;; db      '0'+(majver / 10),'0'+(majver mod 10),".",'0'+version,".",'0'+dp8390_version,CR,LF,'$'
                db      "1.31 (950705)",CR,LF,'$'
                db      80 dup(20h)

int_no_name     db      "Interrupt(IRQ) number ",'$'
io_addr_name    db      "I/O port ",'$'

        extrn   set_recv_isr: near

;enter with si -> argument string, di -> word to store.
;if there is no number, don't change the number.
        extrn   get_number: near

;enter with dx -> name of word, di -> dword to print.
        extrn   print_number: near
;
; For PnP use varibles
;
; Jasper 10/05/94  {
;MAX_MEM_REGISTERS       equ     9
;MAX_IO_PORTS            equ     20
;MAX_IRQS                equ     7
;MAX_DMA_CHANNELS        equ     7
;
;Config_Info     struc
;        dBusID          dd      0
;        dDevID          dd      0
;        dSerialNum      dd      0
;        dLogicalID      dd      0
;        dFlags          dd      0
;
;        bCSN            db      0
;        bLogicalDevNumber       db      0
;        WReadDataPort   dw      0
;
;        wNumMemWindows  dw      0
;        dMemBase        dd      MAX_MEM_REGISTERS dup(0)
;        dMemLength      dd      MAX_MEM_REGISTERS dup(0)
;        wMemAttrib      dw      MAX_MEM_REGISTERS dup(0)
;        wNumIOPorts     dw      0
;        wIOPort_Base    dw      MAX_IO_PORTS    dup(0)
;        wIOPort_Length  dw      MAX_IO_PORTS    dup(0)
;        wNumIRQs        dw      0
;        bIRQRegisters   db      MAX_IRQS        dup(0)
;        bIRQAttrib      db      MAX_IRQS        dup(0)
;        wNumDMAs        dw      0
;        bDMALst         db      MAX_DMA_CHANNELS        dup(0)
;        wDMAAttrib      dw      MAX_DMA_CHANNELS        dup(0)
;Config_Info     ends
;
;CM_OK           db      0
;CM_Entry        dd      0
;ConfigBuf       Config_Info <>
;;
;; PnP I/O Port Addresses
;PnPAddress                      equ     279h
;PnPWrite                        equ     0a79h
;;PnP index registers
;SetRD                           equ     0h
;Isolation                       equ     1h
;ConfigCtrl                      equ     2h
;Wake                            equ     03h
;CSN                             equ     06h
;Activate                        equ     30h
;IOCheck                         equ     31h
;SetIO_1                         equ     60h
;SetIO_0                         equ     61h
;IRQLevel                        equ     70h
;CSNSAV                          equ     0F5h    ; RTL8019 defined
;RTResetCSN                      equ     0F6h    ; RTL8019 defined
;
 NICNotFound             db      'There is no 8019 PnP Card on your system !',0dh,0ah,'$',10 dup (20h)
;PnPDeviceNotFound       db      'Realtek 8019 PnP Card does not register to PnP Config Manager.',0Dh,0Ah,'$'
 PnPIRQTooBig            db      'The card is on an 8-bit slot. Please config IRQ less than 8.',0Dh,0Ah
;                        db           ' Or move it to a 16-bit ISA slot for IRQ larger than 8.',0Dh,0Ah,'$'
;DotString               db      '.$'
;PnPCMVersion            db      'PnP Configuration Manager of this system is version ','$'
;PnPCMNotPresent         db      'There is no PnP Configuration Manager present. Using Realtek PnP protocol.',0Dh,0Ah,'$'
;BoardConflictMessage1   db      'The 8019 card at I/O:','$'
;BoardConflictMessage2   db      ' is conflict with other device, please check it!!',0Dh,0Ah,'$'
;TooManyBoards           db      'More than 4 RTL8019 ethernet cards found. Driver will support only 4 cards.',0Dh,0Ah,'$'
; } Jasper 10/05/94
;
;       Print Board Data
BoardDataString1        db      'Found Card ','$'
BoardDataString2        db      ': EtherID=','$'
BoardDataString3        db      ',IO=','$'
BoardDataString4        db      ',IRQ=','$'
;BoardDataString5        db      ',PnPCSN=','$'         ; Jasper 10/05/94
BoardDataString6        db      ' on ','$'
BoardDataString7        db      '-bit slot.',0Dh,0Ah,'$'
;
PromptString1   db      'Please specify which card the driver attach (0-','$'
PromptString2   db      '):','$'
; Liu 7/05/95 {
        public          AttachString1
        public          AttachString3
AttachString1   db      CR,LF,'Driver is attached to card ','$'
;AttachString2   db      '. It is configurated as:',0Dh,0Ah,'$'
AttachString3   db      'Error : Parameter not recognized ,driver is NOT loaded',CR,LF,CR,LF,'$'
;} Liu 7/05/95
;---------------------------------------------------------
;       Wait 200ns*Number
;---------------------------------------------------------
; Jasper 10/05/94  {
;Slow    MACRO   Number
;        LOCAL   Slow_lp
;        push    cx
;        push    ax
;        mov     cx,Number
;Slow_lp:
;        in      al,61h
;        loop    Slow_lp
;        pop     ax
;        pop     cx
;
;        ENDM
;
;RTInitKey       db      0DAh,6Dh,36h,1Bh,8Dh,46h,23h,91h
;                db      48h,0A4h,0D2h,69h,34h,9Ah,4Dh,26h
;                db      13h,89h,44h,0A2h,51h,28h,94h,0CAh
;                db      65h,32h,19h,0Ch,86h,43h,0A1h,50h
;PnPID           db      9 dup(0)        ; PnP Serial ID and Checksum
;
;RD_Port         dw      203h            ; 203-3FFh (step 4)
;RD_Port_IO      db      80h             ; bit 2-9 of RD_Port for I/O (80-FFh)
;RD_Port_OK      db      0               ; Flag if RD_Port found
; } Jasper 10/05/94

BoardIndex      db      0
;SavedCSN        db      0                      ; Jasper 10/05/94
SavedIOBase     dw      0
BoardPROM       db      16 dup(0)

BoardDataStruct struc
;  CardCSN       db      0                      ; Jasper 10/05/94
  IRQ           db      0
  IOBase        dw      0
  NodeID        db      6 dup(0)
  SlotSize      db      0
BoardDataStruct ends
BoardDataLen     equ     size BoardDataStruct

BoardData       BoardDataStruct  8 dup (<>)     ; Jasper 10/05/94
       public   BoardChoice
BoardChoice     db      -1

IRQTable        db      9,3,4,5,10,11,12,15     ; Jasper 10/05/94

        extrn   decout: near
        extrn   wordout: near
        extrn   byteout: near
        extrn   digout: near
        extrn   crlf: near
        extrn   print_ether_addr: near
        public  parse_args
parse_args:
;exit with nc if all went well, cy otherwise.

;
;       Use PnP Config Manager to get our card's config
;
        movseg  es,cs
;        mov     bx,1000h
;        mov     ah,4Ah                          ; Reallocate memory to 64K
;        int     21h                             ; ES == CS already
;
;        push    es
;        xor     di,di                           ; ES:DI-> 0:0
;        mov     es,di
;        mov     bx,34h
;        mov     ax,1684h                        ; Get PnP Config Manager Entry Point
;        int     2Fh
;        mov     ax,es
;        or      ax,di                           ; If ES:DI is still 0:0
;        mov     word ptr CM_Entry,di
;        mov     word ptr CM_Entry+2,es
;        pop     es
;        jnz     Int2f_OK
;        jmp     CM_NotPresent
;Int2f_OK:
;        xor     ax,ax
;        call    [CM_Entry]
;        or      ax,ax
;        jnz     CM_Entry_OK
;        jmp     CM_NotPresent
;CM_Entry_OK:
;        mov     bx,ax                           ; Save the version to BX
;        mov     CM_OK,1                         ; Turn on CM_OK Flag
;        mov     dx,offset PnPCMVersion
;        mov     ah,9
;        int     21h
;        mov     cl,'0'                          ; Prepare to remove leading 0
;        mov     al,bh
;        call    byteout
;        mov     dx, offset DotString
;        mov     ah,9
;        int     21h
;        mov     cl,'0'
;        mov     al,bl
;        call    byteout
;        mov     dx, offset DotString
;        mov     ah,9
;        int     21h
;        call    crlf
;
;        xor     bx, bx                          ; Device index starts with 0
;Get_Device_Config:
;        mov     di, offset ConfigBuf
;        mov     ax,1
;        call    [CM_Entry]
;        or      ax,ax
;        jz      Still_Have_CM_Device
;        jmp     No_more_CM_Device
;Still_Have_CM_Device:
;        mov     dx, ConfigBuf.wIOPort_Base
;        add     dx,0Ah
;        in      al,dx
;        cmp     al,'P'
;        je      CM_PassChipID1
;        jmp     Try_Next
;CM_PassChipID1:
;        inc     dx
;        in      al,dx
;        cmp     al,'p'
;        je      CM_PassChipID2
;        jmp     Try_Next
;CM_PassChipID2:
;        mov     RD_Port_OK,1                    ; Turn on RD_Port_OK flag
;        mov     ax,ConfigBuf.wReadDataPort
;        mov     RD_Port,ax                      ; Save the RD_Port of PnP_CM
;        shr     ax,2
;        mov     RD_Port_IO,al                   ; Save RD_Port_IO,too
;
;        mov     di,offset BoardData             ; Adjust DI to right position
;        mov     cl,BoardIndex
;        and     cx,0fh
;        cmp     cx,0
;        je      Save_CM_Board_Data
;Add_CM_BoardData_lp:
;        add     di,BoardDataLen
;        loop    Add_CM_BoardData_lp
;Save_CM_Board_Data:
;        mov     al,ConfigBuf.bCSN               ; Save CardCSN
;        mov     [di].CardCSN,al
;
;        mov     al, ConfigBuf.bIRQRegisters
;        mov     [di].IRQ,al                     ; Save IRQ
;
;        mov     ax, ConfigBuf.wIOPort_Base
;        mov     [di].IOBase,ax                  ; Save IOBase
;        mov     SavedIOBase,ax
;
;        mov     dx,SavedIOBase
;        mov     al,21h
;        out     dx,al
;        add     dx,0eh                          ; DX--> DCR
;        mov     al,49h
;        out     dx,al
;
;        mov     dx,SavedIOBase
;        add     dx,08                           ; DX--> RemoteAddress0
;        xor     al,al
;        out     dx,al
;        inc     dx
;        out     dx,al
;        inc     dx                              ; DX--> RemoteByteCount
;        mov     al, 16*2
;        out     dx,al
;        inc     dx
;        xor     al,al
;        out     dx,al
;
;        mov     dx,SavedIOBase
;        mov     al,09
;        out     dx,al
;        add     dx,10h
;        push    di                              ; Saved DI
;        mov     di,offset BoardPROM
;        mov     cx,16
;        .286
;   rep  insb
;        .8086
;        mov     si,offset BoardPROM
;        pop     di                              ; Take back DI
;        cmp     BYTE PTR [si]+14,'W'
;        jne     CM_In_8_Slot
;        mov     [di].SlotSize,16
;        jmp     short CM_Set_Slot_OK
;CM_In_8_Slot:
;        mov     [di].SlotSize,8
;CM_Set_Slot_OK:
;        lea     di,[di].NodeID
;        mov     cx,3
;   rep  movsw                                   ; Move to BoardData.NodeID
;
;        inc     BoardIndex
;Try_Next:
;        inc     bx
;        jmp     Get_Device_Config
;No_more_CM_Device:
;;        mov     dx,offset PnPDeviceNotFound
;;        stc
;;        ret
;
;CM_NotPresent:
;        cmp     CM_OK,1
;        je      Print_PnPCMNotPresent_OK
;        mov     dx, offset PnPCMNotPresent
;        mov     ah,9
;        int     21h
;Print_PnPCMNotPresent_OK:
;                                        ; Do our own PnP initialization
;        mov     dx,PnPAddress
;        mov     al,ConfigCtrl
;        out     dx,al
;        mov     dx,PnPWrite
;        mov     al,02h
;        out     dx,al                   ; Go to Wait-4-Key State
;
;        mov     dx,PnPAddress
;        xor     al,al
;        out     dx,al
;        out     dx,al                   ; 2 successive 0 for reset Key
;        mov     cx,32
;        cld
;        mov     si,offset RTInitKey
;        .286
;   rep  outsb                           ; Send out Realtek init Key
;        .8086
;Next_RD_Port:
;        cmp     CM_OK,1
;        je      CSN_Already_0           ; Search Jumperless/Jumper only
;        mov     dx,PnPAddress
;        mov     al,RTResetCSN           ; Use RT Reset CSN
;        out     dx,al
;        mov     dx,PnPWrite
;        mov     al,04h                  ; temporay reset our cards CSN
;        out     dx,al
;CSN_Already_0:
;        mov     dx,PnPAddress
;        mov     al,Wake                 ; Wake 0
;        out     dx,al
;        mov     dx,PnPWrite
;        xor     al,al
;        out     dx,al
;
;        cmp     RD_Port,3ffh
;        jb      short Continue_Try_Isolation
;        jmp     No_more_Card
;Continue_Try_Isolation:
;        ;cmp     RD_Port_OK,1           ; If we are searching Jumper(less)
;        ;jz      Pass_Set_RD_Port       ; card, we must set RD_Port.
;
;        mov     dx,PnPAddress
;        mov     al,SetRD
;        out     dx,al
;        mov     dx,PnPWrite
;        mov     al,RD_Port_IO           ; Set I/O Read Port
;        out     dx,al
;Pass_Set_RD_Port:
;        mov     di,offset PnPID         ; clear PnPID
;        xor     al,al
;        mov     cx,9
;   rep  stosb
;
;        mov     dx,PnPAddress
;        mov     al,Isolation
;        out     dx,al
;        Slow    1000                    ; Wait 1ms
;        xor     cx,cx                   ; set cx=0
;        mov     dx,RD_Port
;Isolation_lp:
;        in      al,dx
;        cmp     al,55h
;        je      Iso_Pass1
;        in      al,dx
;        jmp     Iso_next
;Iso_Pass1:
;        in      al,dx
;        cmp     al,0AAh
;        jne     Iso_next
;        mov     bx,cx
;        shr     bx,3
;        lea     di,PnPID[bx]
;        push    cx                      ; Will use cl for shl, Save CX
;        and     cx,07h
;        mov     al,1
;        shl     al,cl
;        or      [di],al
;        pop     cx                      ; Take Back CX
;Iso_next:
;        Slow    250                     ; Wait 250 us
;        inc     cx
;        cmp     cx,72
;        jb      Isolation_lp
;
;        mov     si,offset PnPID
;        call    VerifyPnPID
;        jnc     PnPID_OK
;        cmp     RD_Port_OK,0
;        je      Set_Next_RD_Port
;        jmp     No_more_Card            ; if RD_Port is OK, no more card
;
;Set_Next_RD_Port:                       ; Read Port Conflict
;        add     RD_Port,4
;        inc     RD_Port_IO
;        mov     ax,RD_Port
;        and     al,0Fh
;        cmp     al,0Fh
;        jne     Avoid_F_OK
;        add     RD_Port,4
;        inc     RD_Port_IO
;Avoid_F_OK:
;        mov     ax,RD_Port
;        test    al,10h
;        jz      Avoid_RDMA_OK
;        add     ax,10h
;        mov     RD_Port,ax
;        add     RD_Port_IO,4
;Avoid_RDMA_OK:
;        jmp     Next_RD_Port
;
;PnPID_OK:
;        mov     RD_Port_OK,1
;        cmp     BoardIndex,3
;        jbe     Have_space
;        jmp     No_BoardData_space
;Have_space:
;        mov     dx,PnPAddress
;        mov     al,CSNSAV
;        out     dx,al
;        mov     dx,RD_Port
;        in      al,dx
;        mov     SavedCSN,al
;
;        mov     dx,PnPAddress
;        mov     al,CSN
;        out     dx,al
;        mov     dx,PnPWrite
;        mov     al,BoardIndex
;        add     al,60h                  ; CSN=BoardIndex+60h
;        out     dx,al                   ; Now our card is in Config mode
;
;        mov     dx,PnPAddress           ; Get Card I/O address
;        mov     al,SetIO_1
;        out     dx,al
;        mov     dx,RD_Port
;        in      al,dx
;        mov     ah,al
;        mov     dx,PnPAddress
;        mov     al,SetIO_0
;        out     dx,al
;        mov     dx,RD_Port
;        in      al,dx
;        mov     SavedIOBase,ax
;
;        mov     dx,PnPAddress           ; Disable I/O Range Check
;        mov     al,IOCheck              ; before we activate the Card
;        out     dx,al
;        mov     dx,PnPWrite
;        xor     al,al
;        out     dx,al
;        mov     dx,PnPAddress           ; Activate our Card
;        mov     al,Activate
;        out     dx,al
;        mov     dx,PnPWrite
;        mov     al,1
;        out     dx,al
;
;        mov     ax,SavedIOBase          ; We have an inactivate card
;        and     ax,0FF0h                ;   which makes RD_Port conflict
;        mov     bx,RD_Port              ;   after its activation.
;        and     bx,0FF0h                ; This case should happen when
;        cmp     ax,bx                   ;   the card is a PnP card.
;        jne     Check_ChipID
;        mov     RD_Port_OK,0
;        add     RD_Port,4
;        inc     RD_Port_IO
;        mov     BoardIndex,0
;        jmp     Next_RD_Port            ; Totally re-do our search
;
;Check_ChipID:
;        mov     dx,SavedIOBase          ; Check Chip's ID
;        mov     al,21h
;        out     dx,al
;        add     dx,0ah
;        in      al,dx
;        cmp     al,'P'
;        je      PassChipID1
;        jmp     Device_Conflict
;PassChipID1:
;        inc     dx
;        in      al,dx
;        cmp     al,'p'
;        jne     Device_Conflict
;                                        ; Passed ChipID("Pp") check
;        mov     cl,BoardIndex
;        and     cx,0Fh
;        mov     di,offset BoardData
;        cmp     cx,0
;        je      Save_BoardData
;Add_BoardData_lp:
;        add     di,BoardDataLen
;        loop    Add_BoardData_lp
;Save_BoardData:
;        mov     al,SavedCSN             ; Save CardCSN
;        mov     [di].CardCSN,al
;
;        mov     dx,PnPAddress           ; Get Card's IRQ
;        mov     al,IRQLevel
;        out     dx,al
;        mov     dx,RD_Port
;        in      al,dx
;        mov     [di].IRQ,al             ; Save IRQ
;
;        mov     dx,SavedIOBase          ; Save IOBase
;        mov     [di].IOBase,dx
;
;        add     dx,0eh                          ; DX--> DCR
;        mov     al,49h
;        out     dx,al
;
;        mov     dx,SavedIOBase
;        add     dx,08                           ; DX--> RemoteAddress0
;        xor     al,al
;        out     dx,al
;        inc     dx
;        out     dx,al
;        inc     dx                              ; DX--> RemoteByteCount
;        mov     al, 16*2
;        out     dx,al
;        inc     dx
;        xor     al,al
;        out     dx,al
;
;        mov     dx,SavedIOBase
;        mov     al,09
;        out     dx,al
;        add     dx,10h
;        push    di                              ; Saved DI
;        mov     di,offset BoardPROM
;        mov     cx,16
;        .286
;   rep  insb
;        .8086
;        mov     si,offset BoardPROM
;        pop     di                              ; Take back DI
;        cmp     BYTE PTR [si]+14,'W'
;        jne     In_8_Slot
;        mov     [di].SlotSize,16
;        jmp     short Set_Slot_OK
;In_8_Slot:
;        mov     [di].SlotSize,8
;Set_Slot_OK:
;        lea     di,[di].NodeID
;        mov     cx,3
;   rep  movsw
;
;        inc     BoardIndex
;Device_Conflict_back:
;        jmp     CSN_Already_0
;Device_Conflict:
;        mov     dx,offset BoardConflictMessage1
;        mov     ah,9
;        int     21h
;        mov     cl,'0'
;        mov     ax,SavedIOBase          ; IO value
;        call    wordout
;        mov     dx,offset BoardConflictMessage2
;        mov     ah,9
;        int     21h
;        jmp     Device_Conflict_back
;
;No_BoardData_space:
;        mov     dx,offset TooManyBoards
;        mov     ah,9
;        int     21h
;No_more_Card:                           ; Set cards back to their origin CSN
;
;        cmp     BoardIndex,0            ; If no card found
;        je      Back_SavedCSN_OK
;        xor     cx,cx
;        mov     ah,60h                  ; We set CSN=60h+BoardIndex
;        mov     di,offset BoardData
;Back_SavedCSN_lp:
;        mov     dx,PnPAddress
;        mov     al,Wake
;        out     dx,al
;        mov     dx,PnPWrite
;        mov     al,ah
;        out     dx,al                   ; Wake CSN 60+BoardIndex
;        mov     dx,PnPAddress
;        mov     al,CSN
;        out     dx,al
;        mov     dx,PnPWrite
;        mov     al,[di].CardCSN
;        out     dx,al                   ; Save Back SavedCSN
;        inc     cx
;        inc     ah
;        add     di,BoardDataLen
;        cmp     cl,BoardIndex
;        jb      Back_SavedCSN_lp
;Back_SavedCSN_OK:
;        mov     dx,PnPAddress           ; Set our card back to WAIT FOR KEY
;        mov     al,ConfigCtrl
;        out     dx,al
;        mov     dx,PnPWrite
;        mov     al,02
;        out     dx,al

        mov     dx, 200h                        ; IOBase starts with 200h
Scan_ID:
        add     dx,0Ah
        in      al,dx
        cmp     al,'P'
        je      CM_PassChipID1
        sub     dx, 0ah
        jmp     Try_Next
CM_PassChipID1:
        inc     dx
        in      al,dx
        cmp     al,'p'
        je      CM_PassChipID2
        sub     dx, 0bh
        jmp     Try_Next
CM_PassChipID2:
        sub     dx, 0bh
        mov     di,offset cs:BoardData         ; Adjust DI to right position
        mov     cl,BoardIndex
        and     cx,0fh
        cmp     cx,0
        je      Save_CM_Board_Data
Add_CM_BoardData_lp:
        add     di,BoardDataLen
        loop    Add_CM_BoardData_lp
Save_CM_Board_Data:
        mov     al, 0e1h
        out     dx, al                          ; switch to page 3
        add     dx, 4                           ;
        in      al, dx                          ;

        and     al, 70h                         ; get IRQS2_0
        shr     al, 1                           ;
        shr     al, 1                           ;
        shr     al, 1                           ;
        shr     al, 1                           ;
        mov     ah, 0                           ;

        mov     si, offset cs:IRQTable          ; get IRQ from IRQTable
        add     si, ax                          ;
        mov     al, [si]                        ;

        mov     [di].IRQ,al                     ; Save IRQ

        sub     dx, 4                           ; switch to page 0
        mov     al, 21h                         ;
        out     dx, al                          ;

        mov     ax, dx
        mov     [di].IOBase,ax                  ; Save IOBase
        mov     SavedIOBase,ax

        mov     dx,SavedIOBase
        mov     al,21h
        out     dx,al
        add     dx,0eh                          ; DX--> DCR
        mov     al,49h
        out     dx,al

        mov     dx,SavedIOBase
        add     dx,08                           ; DX--> RemoteAddress0
        xor     al,al
        out     dx,al
        inc     dx
        out     dx,al
        inc     dx                              ; DX--> RemoteByteCount
        mov     al, 16*2
        out     dx,al
        inc     dx
        xor     al,al
        out     dx,al

        mov     dx,SavedIOBase
        mov     al,09
        out     dx,al
        add     dx,10h
        push    di                              ; Saved DI
        mov     di,offset cs:BoardPROM
        mov     cx,16
In_ID_loop:
        in      al,dx
        stosb
        loop    In_ID_loop
;  rep  insb
        mov     si,offset cs:BoardPROM
        pop     di                              ; Take back DI
        cmp     BYTE PTR [si]+14,'W'
        jne     CM_In_8_Slot
        mov     [di].SlotSize,16
        jmp     short CM_Set_Slot_OK
CM_In_8_Slot:
        mov     [di].SlotSize,8
CM_Set_Slot_OK:
        lea     di,[di].NodeID
        mov     cx,3
   rep  movsw                                   ; Move to BoardData.NodeID

        mov     dx, SavedIOBase
        inc     BoardIndex
Try_Next:
        add     dx, 20h
        cmp     dx, 3e0h
        ja      ScanComplete
        jmp     Scan_ID
ScanComplete:

        cmp     BoardIndex,0
        jne     Print_BoardData
        mov     dx,offset NICNotFound
        stc
        ret
Print_BoardData:
        xor     cx,cx
        mov     di,offset BoardData
Print_BoardData_lp:
        push    cx                      ; Save CX, some print will destroy it
        mov     dx,offset BoardDataString1
        mov     ah,9
        int     21h
        mov     al,cl                   ; BoardIndex
        call    digout
        mov     dx,offset BoardDataString2
        mov     ah,9
        int     21h
        lea     si,[di].NodeID          ; NodeID
        call    print_ether_addr
        mov     dx,offset BoardDataString3
        mov     ah,9
        int     21h
        mov     ax,[di].IOBase          ; IO
        mov     cl,'0'                  ; For remove leading zero
        call    wordout
        mov     dx,offset BoardDataString4
        mov     ah,9
        int     21h
        mov     al,[di].IRQ             ; IRQ
        call    digout
; Jasper 10/05/94 {
;        mov     dx,offset BoardDataString5
;        mov     ah,9
;        int     21h
;        mov     al,[di].CardCSN         ; CSN
;        call    byteout
; } Jasper 10/05/94
        mov     dx,offset BoardDataString6
        mov     ah,9
        int     21h
        mov     al,[di].SlotSize        ; SlotSize
        and     ax,0FFh
        xor     dx,dx                           ;DX:AX=num
        push    di                              ; DI will be destroyed
        call    decout
        pop     di                              ; Tack back DI
        mov     dx,offset BoardDataString7
        mov     ah,9
        int     21h
        pop     cx                      ; Take Back CX
        inc     cx
        add     di,BoardDataLen
        cmp     cl,BoardIndex
        jb      Print_BoardData_lp

        cmp     BoardIndex,1
        je      One_Card_Only
;;        call    MatchEtherID
;;        cmp     BoardChoice,-1
;;        jne     BoardChoice_OK
        call    PromptBoardChoice
        jmp     short BoardChoice_OK
One_Card_Only:
        mov     BoardChoice,0
BoardChoice_OK:
;       mov     dx,offset AttachString1
;       mov     ah,9
;       int     21h
;       mov     al,BoardChoice
;       call    digout
;       mov     dx, offset AttachString2
;       mov     ah,9
;       int     21h

;
;       Set io_addr and int_no
;
        mov     di,offset BoardData
        mov     cl,BoardChoice
        and     cx,0Fh
        cmp     cx,0
        je      BoardDataOffset_OK
Add_BoardData_Offset:
        add     di,BoardDataLen
        loop    Add_BoardData_Offset
BoardDataOffset_OK:
        mov     ax,[di].IOBase                  ; Set IOAddress1
        mov     io_addr,ax

        mov     al,[di].IRQ                     ; Set IntLine1
        mov     int_no,al
PnP_Installed:
        clc
        ret

;***********************************
; On Entry:
;
;   si --> PnPID (8 data, 1 check sum)
;
; On return:
;   if PnPID OK => carry is clear
;            Bad => carry is set
;***********************************
;VerifyPnPID    proc
;        mov     al,6Ah
;        xor     cx,cx
;
;PnPVerifyLoop:
;        test    al,02h
;        jz      short Bit1_zero
;        mov     ah,1
;        jmp     short Got_Bit1
;Bit1_zero:
;        xor     ah,ah
;Got_Bit1:
;        mov     dl,al
;        xor     ah,dl                   ; Bit0 xor Bit1 in AH bit 1
;
;        mov     dx,cx
;        shr     dx,3
;        mov     di,si
;        add     di,dx                   ; EDI -> Byte number
;        push    cx                      ; shl will use cl, Save CX
;        and     cx,07                   ; cl==the bit in Byte
;        mov     dl,1
;        shl     dl,cl                   ; DL is the Flag
;        pop     cx                      ; Take back CX
;        test    [di],dl
;        jz      Input_zero
;        mov     dl,1
;        jmp     short Got_Input
;Input_zero:
;        xor     dl,dl
;Got_Input:                              ; input bit in DL
;        xor     ah,dl
;        shr     ah,1                    ; Result in Carry
;        rcr     al,1
;
;        inc     cx
;        cmp     cx,64                   ; all 8 Byte done ?
;        jb      short PnPVerifyLoop
;
;        cmp     al,[si]+8
;        je      short PnPIDGood
;        stc
;        ret
;PnPIDGood:
;        clc
;        ret
;VerifyPnPID    endp
;******************************************
; Prompt for user key-in a choice
;******************************************
PromptBoardChoice       proc
        mov     dx,offset PromptString1
        mov     ah,9
        int     21h
        mov     al,BoardIndex
        dec     al
        mov     bl,al
        mov     cl,'0'                  ; For removing leading zero
        call    byteout
        mov     dx,offset PromptString2
        mov     ah,9
        int     21h
Get_BoardChoice_lp:
        xor     ah,ah
        int     16h
        mov     dl,al                   ; Save ASCII code to DL
        sub     al,30h
        cmp     al,0
        jl      Get_BoardChoice_lp
        cmp     al,bl
        jg      Get_BoardChoice_lp
        mov     BoardChoice,al          ; Save value to BoardChoice
        mov     ah,2
        int     21h                     ; Print the good choice
        call    crlf
        ret
PromptBoardChoice       endp

        extrn   etopen_diagn: byte

init_card:
;get the board data. This is (16) bytes starting at remote
;dma address 0. Put it in a buffer called board_data.
        assume  ds:code
        or      endcfg,ENDCFG_WTS

        loadport
        mov     al,endcfg
        setport EN0_DCFG
        pause_
        out     dx,al

        mov     cx,10h          ; get 16 bytes,
        movseg  es,ds
        mov     di,offset board_data

        setport EN_CCMD
        pause_
        mov     al,ENC_NODMA+ENC_PAGE0+ENC_START
        out     dx,al
        setport EN0_RCNTLO      ; remote byte count 0
        pause_
        mov     al,20h          ; count is actually doubled.
        out     dx,al
        setport EN0_RCNTHI
        pause_
        xor     al,al           ; high byte of count is zero.
        out     dx,al

        mov     ax,0            ; from address 0

        setport EN0_RSARLO
        pause_
        out     dx,al           ; set as hi address
        setport EN0_RSARHI
        pause_
        mov     al,ah
        out     dx,al
        setport EN_CCMD
        pause_
        mov     al,ENC_RREAD+ENC_START  ; read and start
        out     dx,al
        setport NE_DATAPORT
        pause_
sp_read_loop:
        in      al,dx           ; get a byte
        stosb                   ; save it
        loop    sp_read_loop

;;        push    ds              ; Copy from card's address to current address
;;        pop     es

        mov si, offset board_data       ; address is at start
        mov di, offset rom_address
        mov cx, EADDR_LEN       ; Copy one address length
        rep     movsb           ; ..

        cmp     byte ptr [board_data+14],'W'
        je      in_16_ISA
        mov     is_16_slot,0            ; Set our flag flase
        and     endcfg,NOT ENDCFG_WTS   ; Set DCR to byte transfer
        mov     sm_rstop_ptr,60h        ; Set the PSTOP to 60h only
        cmp     int_no,8                ; Check if IRQ is less than 8
        jb      in_16_ISA
        mov     di,offset int_no        ; Print the wrong IRQ number
        mov     dx,offset int_no_name
        call    print_number
        mov     dx,offset PnPIRQTooBig  ; Prepare error message
        stc
        ret
in_16_ISA:
        clc
        ret

        public  print_parameters
print_parameters:
;echo our command-line parameters
        mov     di,offset int_no
        mov     dx,offset int_no_name
        call    print_number
        mov     di,offset io_addr
        mov     dx,offset io_addr_name
        call    print_number
        ret

code    ends

        end
