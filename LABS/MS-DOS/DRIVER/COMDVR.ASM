Title COMDVR Driver for IBM COM Ports
;		Jim Kyle, 1987
;			Based on ideas from many sources.....
;				including Mike Higgins, CLM March 1985;  
;               public-domain INTBIOS program from BBS's;    
;               COMBIOS.COM from CIS Programers SIG; and
;               ADVANCED MS-DOS by Ray Duncan.
Subttl          MS-DOS Driver Definitions

                Comment     *   This comments out the Dbg macro.... *
Dbg             MACRO       Ltr1, Ltr2, Ltr3                        ; used only to debug driver...  
                Local       Xxx
                Push        Es                                      ; save all regs used
                Push        Di
                Push        Ax
                Les         Di, Cs:Dbgptr                           ; get pointer to CRT
                Mov         Ax, Es:[di]
                Mov         Al, Ltr1                                ; move in letters
                Stosw
                Mov         Al, Ltr2
                Stosw
                Mov         Al, Ltr3
                Stosw
                Cmp         Di, 1600                                ; top 10 lines only
                Jb          Xxx
                Xor         Di, Di
Xxx:            Mov         Word Ptr Cs:Dbgptr, Di
                Pop         Ax
                Pop         Di
                Pop         Es
Endm
                                                                    ; asterisk ends commented-out region
;
;               Device Type Codes
DevChr          Equ         8000h                                   ; this is a character device
DevBlk          Equ         0000h                                   ; this a block (disk) device  
DevIoc          Equ         4000h                                   ; this device accepts IOCTL requests
DevNon          Equ         2000h                                   ; non-IBM disk driver (block only)
DevOTB          Equ         2000h                                   ; MS-DOS 3.x out until busy suported (char)
DevOCR          Equ         0800h                                   ; MS-DOS 3.x open/close/rm supported
DevX32          Equ         0040h                                   ; MS-DOS 3.2 functions supported
DevSpc          Equ         0010h                                   ; accepts special interrupt 29h
DevClk          Equ         0008h                                   ; this is the CLOCK device
DevNul          Equ         0004h                                   ; this is NUL device
DevSto          Equ         0002h                                   ; this is standard output
DevSti          Equ         0001h                                   ; this is standard input
;
;               Error Status BITS
StsErr          Equ         8000h                                   ; general error
StsBsy          Equ         0200h                                   ; device busy
StsDne          Equ         0100h                                   ; request completed
;
;               Error Reason values for lower-order bits
ErrWp           Equ         0                                       ; write protect error
ErrUu           Equ         1                                       ; unknown unit
ErrDnr          Equ         2                                       ; drive not ready
ErrUc           Equ         3                                       ; unknown command
ErrCrc          Equ         4                                       ; cyclical redundancy check error
ErrBsl          Equ         5                                       ; bad drive rquest structure length
ErrSl           Equ         6                                       ; seek error
ErrUm           Equ         7                                       ; unknown media
ErrSnf          Equ         8                                       ; sector not found
ErrPop          Equ         9                                       ; printer out of paper
ErrWf           Equ         10                                      ; write fault
ErrRf           Equ         11                                      ; read fault
ErrGf           Equ         12                                      ; general faliure
;
;               Structure of an I/O request packet header.
;
Pack            Struc
Len             Db          ?                                       ; length of record
Prtno           Db          ?                                       ; unit code
Code            Db          ?                                       ; command code
Stat            Dw          ?                                       ; retur status
Dosq            Dd          ?                                       ; (unused MS-DOS queue link pointer)
Devq            Dd          ?                                       ; (unused driver queue link pointer)
Media           Db          ?                                       ; media code on read/write
Xfer            Dw          ?                                       ; xfer address offset 
Xseg            Dw          ?                                       ; xfer address segment
Count           Dw          ?                                       ; transfer byte count
Sector          Dw          ?                                       ; starting sector value (block only)
Pack            Ends  
                
Subttl          IBM-PC Hardware Driver Definitions
page
;
;               8259 data
PIC_b           Equ         020h                                    ; port for EOI
PIC_e           Equ         021h                                    ; port for Int enabling
EOI             Equ         020h                                    ; EOI control word
;
;               8250 port offsets
RxBuf           Equ         0F8h                                    ; base address
Baud1           Equ         RxBuf+1                                 ; baud divisor high byte
IntEn           Equ         RxBuf+1                                 ; interrupt enable register
IntId           Equ         RxBuf+2                                 ; interrupt identification register
Lctrl           Equ         RxBuf+3                                 ; line control register
Mctrl           Equ         RxBuf+4                                 ; modem control register
Lstat           Equ         RxBuf+5                                 ; line status register
Mstat           Equ         RxBuf+6                                 ; modem status register
;
;               8250 LCR constants
Dlab            Equ         10000000b                               ; divisor latch access bit
SetBrk          Equ         01000000b                               ; send break control bit
StkPar          Equ         00100000b                               ; stick parity control bit
EvnPar          Equ         00010000b                               ; even parity bit
GenPar          Equ         00001000b                               ; generate parity bit
Xstop           Equ         00000100b                               ; extra stop bit
Wd8             Equ         00000011b                               ; word length = 8
Wd7             Equ         00000010b                               ; word length = 7
Wd6             Equ         00000001b                               ; word length = 6
;
;               8250 LSR constants
xsre            Equ         01000000b                               ; xmt SR empty
xhre            Equ         00100000b                               ; xmt HR empty 
BrkRcv          Equ         00010000b                               ; break received
FrmErr          Equ         00001000b                               ; framing error
ParErr          Equ         00000100b                               ; parity error
OveRun          Equ         00000010b                               ; overrun error
rdta            Equ         00000001b                               ; receive data ready
AnyErr          Equ         BrkRcv+FrmErr+ParErr+OveRun
;
;               8250 MCR constants
LpBk            Equ         00010000b                               ; UART out loops to in (test)
Usr2            Equ         00001000b                               ; gates 8250 interrupts
Usr1            Equ         00000100b                               ; aux user1 output
SetRTS          Equ         00000010b                               ; sets RTS output
SetDTR          Equ         00000001b                               ; sets DTR output
;
;               8250 MSR constants
CDlvl           Equ         10000000b                               ; carrier detect level
RIlvl           Equ         01000000b                               ; ring indicator level
DSRlvl          Equ         00100000b                               ; DSR level
CTSlvl          Equ         00010000b                               ; CTS level
CDchg           Equ         00001000b                               ; Carrier detect change
RIchg           Equ         00000100b                               ; Ring Indicator change
DSRchg          Equ         00000010b                               ; DSR change
CTSchg          Equ         00000001b                               ; CTS change
;
;               8250 IER constants
S_Int           Equ         00001000b                               ; enable status interrupt
E_Int           Equ         00000100b                               ; enable error interrupt
X_Int           Equ         00000010b                               ; enable transmit interrupt
R_Int           Equ         00000001b                               ; enable receive interrupt
Allint          Equ         00001111b                               ; enable all interrupts
;
Subttl          Definitions for THIS Driver
page
;
;               Bit definitions for the output status byte
;                       ( this driver only )
LinIdl          Equ         0ffh                                    ; if all bits off, xmitter is idle
LinXof          Equ         1                                       ; output is suspended by XOFF
LinDSR          Equ         2                                       ; output is suspended until DSR comes on again
LinCTS          Equ         4                                       ; output is suspended until CTS comes on again 
;
;               Bit definitions for the input status byte 
;                       ( this driver only )
BadInp          Equ         1                                       ; input line error have ben detected
LostDt          Equ         2                                       ; receiver buffer overflowed, data lost
OffLin          Equ         4                                       ; device is off line now
;
;               Bit definitions for the special characteristics words
;                       ( this driver only )
;               InSpec controls how input from the UART is treated
;
InEpc           Equ         0001h                                   ; errors translate to codes with parity bit on
;
;               OutSpec controls how output to the UART is treated
;
OutDSR          Equ         0001h                                   ; DSR is used to throtle output data
OutCTS          Equ         0002h                                   ; CTS is used to throtle output data
OutXon          Equ         0004h                                   ; XON/XOFF is used to throttle output data
OutCdf          Equ         0010h                                   ; carrier detect is off-line signal
OutDrf          Equ         0020h                                   ; DSR is off-line signal
;
Unit            Struc                                               ; each unit has a structure defining its state:
Port            Dw          ?                                       ; I/O port address
Vect            Dw          ?                                       ; interrupt vector offset (NOT interrupt number!)
Isradr          Dw          ?                                       ; offset to interrupt service routine
OtStat          Db          Wd8                                     ; default LCR bit settings during INIT,
                                                                    ; output status bits after
InStat          Db          Usr2+SetRTS+SetDTR                      ; MCR bit settings during INIT,
                                                                    ; input status bits after
InSpec          Dw          InEpc                                   ; special mode bits for INPUT
OutSpec         Dw          OutXon                                  ; special mode bits for OUTPUT
Baud            Dw          96                                      ; current baud rate divisor value (1200 b)
Ifirst          Dw          0                                       ; offset of first character in input buffer
Iavail          Dw          0                                       ; offset of next avaliable byte
Ibuf            Dw          ?                                       ; point to input buffer
Ofirst          Dw          0                                       ; offset of first character in output buffer
Oavail          Dw          0                                       ; offset of next avail byte in output buffer 
Obuf            Dw          ?                                       ; pointer to output buffer
Unit            ends

;
;               Beginning of driver code and data
;
Driver          Segment
                Assume      Cs:driver, Ds:driver, Es:driver
                Org         0                                       ; drivers start at 0
                
                Dw          Async2-1                                ; pointer to next device
                Dw          DevChr + DevIoc                         ; character device with IOCTL
                Dw          Strtegy                                 ; offset of strategy routine
                Dw          Request1                                ; offset of interrupt entry point 1
                Db          'ASY1    '                              ; device 1 name
Async2:
                Dw          -1, -1                                  ; pointer to next device: MS-DOS fills in
                Dw          DevChr + DevIOC                         ; character device with IOCTL
                Dw          Strtegy                                 ; offset of strategy routine
                Dw          Request2                                ; offset of interrupt entry point 2
                Db          'ASY2    '                              ; device 2 name
                
Dbgptr          Dd          0b0000000h
;
;               Following is the storage area for the request packet pointer
;
PackHd          Dd          0
;
;               baud rate conversion table
Asy_baudt       Dw          50,2304                                 ; first value is desired baud rate
                Dw          75,1536                                 ; second is divisor register value
                Dw         100,1047
                Dw         134, 857
                Dw         150, 786
                Dw         300, 384
                Dw         600, 192
                Dw        1200,  96
                Dw        1800,  64
                Dw        2000,  58
                Dw        2400,  48
                Dw        3600,  32
                Dw        4800,  24
                Dw        7200,  16
                Dw        9600,  12
                
;table of structures
;               ASY1 defaults to the COM1 port, INT 0Ch vector, XON, 
;               no parity, 8 databits, 1 stop bit, and 1200 baud
Asy_tab1:
                Unit        <3f8h,30h,asy1isr,,,,,,,,in1buf,,,out1buf>  
                
;               ASY2 defaults to the COM2 port, INT 0Bh vector, XON, 
;               no parity, 8 databits, 1 stop bit, and 1200 baud
Asy_tab2:
                Unit        <2f8h,2ch,asy2isr,,,,,,,,in2buf,,,out2buf> 

Bufsiz          Equ         256                                     ; input buffer size
Bufmsk          =           Bufsiz-1                                ; mask for calculating offsets modulo bufsiz
In1buf          Db          Bufsiz  DUP (?)
Out1buf         Db          Bufsiz  DUP (?)
In2buf          Db          Bufsiz  DUP (?)
Out2buf         Db          Bufsiz  DUP (?)
;
;               Following is a table of offsets to all the driver functions

Asy_funcs:
                Dw          Init                                    ; 0 initialize driver
                Dw          Mchek                                   ; 1 media check (block only)
                Dw          BldBPB                                  ; 2 build BPB (block only)
                Dw          Ioctlin                                 ; 3 IOCTL read
                Dw          Read                                    ; 4 read
                Dw          Ndread                                  ; 5 nondestructive read
                Dw          Rxstat                                  ; 6 input status
                Dw          Inflush                                 ; 7 flush input buffer
                Dw          Write                                   ; 8 write
                Dw          Write                                   ; 9 write with verify
                Dw          Txstat                                  ; 10 output status
                Dw          Txflush                                 ; 11 flush output buffer
                Dw          Ioctlout                                ; 12 IOCTL write
;               Following are not used in this driver.....
                Dw          Zexit                                   ; 13 open (3.x only, not used)
                Dw          Zexit                                   ; 14 close (3.x only, not used)
                Dw          Zexit                                   ; 15 rem med (3.x only, not used)
                Dw          Zexit                                   ; 16 out until bsy (3.x only, not used)
                Dw          Zexit                                   ; 17
                Dw          Zexit                                   ; 18
                Dw          Zexit                                   ; 19 generic IOCTL request (3.2 only)
                Dw          Zexit                                   ; 20
                Dw          Zexit                                   ; 21
                Dw          Zexit                                   ; 22
                Dw          Zexit                                   ; 23 get logical drive map (3.2 only)
                Dw          Zexit                                   ; 24 get logical drive map (3.2 only)
                
Subttl          Driver Code
Page
;
;               The Strategy routine itself:
;
Strtegy        Proc        Far
;               Dbg         'S','R',''
                Mov         Word Ptr Cs:PackHd, Bx                  ; store the offset
                Mov         Word Ptr Cs:PackHd+2, Es                ; store the segment
                ret 
Strtegy        Endp
;
Request1:                                                           ; Async1 has been requested
                Push        Si                                      ; save SI
                Lea         Si, Asy_tab1                            ; get the device unit table address
                Jmp         Short Gen_request
                                             
Request2:                                                           ; async2 has been requested
                Push        Si                                      ; save SI
                Lea         Si, Asy_tab2                            ; get unit table two's address
                
Gen_request:
;               Dbg         'R','R',''
                pushf                                               ; save all regs
                cld
                Push        Ax
                Push        Bx
                Push        Cx
                Push        Dx
                Push        Di
                Push        Bp
                Push        Ds
                Push        Es
                Push        Cs
                Pop         Ds
                Les         Bx, PackHd                              ; get packet pointer
                Lea         Di, Asy_funcs                           ; point DI to jump table
                Mov         Al, Es:code[Bx]                         ; command code
                Cbw
                Add         Ax, Ax                                  ; double to word
                Add         Di, Ax
                Jmp         [Di]                                    ; go do it
;
;               Exit from driver request
;
ExitP           Proc        Far
Bsyexit:
                Mov         Ax, StsBsy
                Jmp         Short Exit
                
Mchek:
BldBPB:
Zexit:          Xor         Ax, Ax
Exit:           Les         Bx, PackHd                              ; get packet pointer
                Or          Ax, StsDne  
                Mov         Es:Stat[Bx], Ax                         ; set return status
                Pop         Es                                      ; restore registers
                Pop         Ds
                Pop         Bp
                Pop         Di
                Pop         Dx
                Pop         Cx
                Pop         Bx
                Pop         Ax
                Popf
                Pop         Si
                ret
ExitP           Endp

Subttl          Driver Service Routines
Page

;               Read data from device

Read:
;               Dbg         'R','d',''
                Mov         Cx, Es:Count[Bx]                        ; get requested nbr
                Mov         Di, Es:Xfer[Bx]                         ; get target pointer
                Mov         Dx, Es:Xseg[Bx]
                Push        Bx                                      ; save for count fixup
                Push        Es
                Mov         Es, Dx
                Test        InStat[Si], BadInp Or LostDt
                Je          No_lerr                                 ; no error so far....
                Add         Sp, 4                                   ; error, flush SP
                And         InStat[Si], Not ( BadInp Or LostDt )
                Mov         Ax, ErrRf                               ; error, report it
                Jmp         Exit
No_lerr:
                Call        Get_in                                  ; go for one
                Or          Ah, Ah
                Jnz         Got_all                                 ; none to get now
                Stosb                                               ; store it
                Loop        No_lerr
Got_all:
                Pop         Es
                Pop         Bx
                Sub         Di, Es:Xfer[Bx]                         ; calc number stored
                Mov         Es:Count[Bx], Di                        ; return as count
                Jmp         Zexit
                
;               Nondestructive read from device

Ndread:
                Mov         Di, ifirst[Si]
                Cmp         Di, iavail[Si]
                Jne         Ndget
                Jmp         Bsyexit                                 ; buffer empty
Ndget:
                Push        Bx
                Mov         Bx, ibuf[si]
                Mov         Al, [Bx+Di]
                Pop         Bx
                Mov         Es:media[Bx], Al                        ; return char
                Jmp         Zexit
                
;               Input status request

Rxstat:
                Mov         Di, ifirst[Si]
                Cmp         Di, iavail[Si]
                Jne         Rxful
                Jmp         Bsyexit                                 ; buffer empty
Rxful:
                Jmp         Zexit                                   ; have data
                
;               Input flush request

Inflush:
                Mov         Ax, iavail[Si]
                Mov         Ifirst[Si], Ax
                Jmp         Zexit
                
;               Output data to device

Write:
;               dbg         'W','r',''
                Mov         Cx, Es:Count[Bx]
                Mov         Di, Es:Xfer[Bx]
                Mov         Ax, Es:Xseg[Bx]
                Mov         Es, Ax
Wlup:
                Mov         Al, Es:[Di]                             ; get the byte
                Inc         Di
Wwait:
                Call        Put_out                                 ; put away
                Cmp         Ah, 0
                Jne         Wwait                                   ; wait for room!
                Call        Start_output                            ; get it going
                Loop        Wlup
                
                Jmp         Zexit
                
;               Output status request

Txstat:
                Mov         Ax, Ofirst[Si]
                Dec         Ax
                And         Ax, Bufmsk
                Cmp         Ax, Oavail[Si]
                Jne         Txroom
                Jmp         Bsyexit                                 ; buffer full
Txroom:
                Jmp         Zexit                                   ; room exists
                
;               IOCTL read request, return line parameters

Ioctlin:
                Mov         Cx, Es:Count[Bx]
                Mov         Di, Es:Xfer[Bx]
                Mov         Dx, Es:Xseg[Bx]
                Mov         Es, Dx
                Cmp         Cx, 10
                Je          Doiocin
                Mov         Ax, Errbsl
                Jmp         Exit
Doiocin:
                Mov         Dx, Port[Si]                            ; base port
                Mov         Dl, Lctrl                               ; line status
                Mov         Cx, 4                                   ; LCR, MCR, LSR, MSR
Getport:
                In          Al, Dx
                Stos        Byte Ptr [Di]
                Inc         Dx
                Loop        Getport
                
                Mov         Ax, InSpec[Si]                          ; spec in flags
                Stos        Word Ptr [Di]
                Mov         Ax, OutSpec[Si]                         ; out flags
                Stos        Word Ptr [Di]
                Mov         Ax, Baud[Si]                            ; baud rate
                Mov         Bx, Di
                Mov         Di, Offset Asy_baudt+2
                Mov         Cx, 15
Baudcin:
                Cmp         [Di], Ax
                Je          Yesnb
                Add         Di, 4
                Loop        Baudcin
Yesnb:
                Mov         Ax, -2[Di]
                Mov         Di, Bx
                Stos        Word Ptr [Di]
                Jmp         Zexit
                
;               Flush output buffer request

Txflush:
                Mov         Ax, Oavail[Si]
                Mov         Ofirst[Si], Ax
                Jmp         Zexit
                
;               IOCTL request: change line parameters for this driver

Ioctlout:
                Mov         Cx, Es:Count[Bx]
                Mov         Di, Es:Xfer[Bx]
                Mov         Dx, Es:Xseg[Bx]
                Mov         Es, Dx
                Cmp         Cx, 10
                Je          Doiocout
                Mov         Ax, Errbsl
                Jmp         Exit
                
Doiocout:
                Mov         Dx, Port[Si]                            ; base port
                Mov         Dl, Lctrl                               ; line ctrl
                Mov         Al, Es:[Di]
                Inc         Di
                Or          Al, Dlab                                ; set baud
                Out         Dx, Al
                Clc
                Jnc         $+2
                Inc         Dx                                      ; mdm ctrl
                Mov         Al, Es:[Di]
                Or          Al, Usr2                                ; Int gate
                Out         Dx, Al
                Add         Di, 3                                   ; skip LSR, MSR
                Mov         Ax, Es:[Di]
                Add         Di, 2
                Mov         InSpec[si], Ax
                Mov         Ax, Es:[Di]
                Add         Di, 2
                Mov         OutSpec[Si], Ax
                Mov         Ax, Es:[Di]                             ; set baud
                Mov         Bx, Di
                Mov         Di, Offset Asy_baudt
                Mov         Cx, 15
Baudcout:
                Cmp         [Di], Ax
                Je          Yesoutb
                Add         Di, 4
                Loop        Baudcout
                
                Mov         Dl, Lctrl                               ; line ctrl
                In          Al, Dx                                  ; get LCR data
                And         Al, Not Dlab                            ; strip
                Clc
                Jnc         $+2
                Out         Dx, Al                                  ; put back
                Mov         Ax, ErrUm                               ; "unknown media"
                Jmp         Exit
                
Yesoutb:
                Mov         Ax, 2[Di]                               ; get divisor
                Mov         Baud[Si], Ax                            ; save to report later
                Mov         Dx, Port[Si]                            ; set divisor
                Out         Dx, Al
                Clc
                Jnc         $+2
                Inc         Dx
                Mov         Al, Ah
                Out         Dx, Al
                Clc
                Jnc         $+2
                Mov         Dl, Lctrl                               ; line ctrl
                in          Al, Dx                                  ; get LCR data
                And         Al, Not Dlab                            ; strip
                Clc
                Jnc         $+2
                Out         Dx, Al                                  ; put back
                Jmp         Zexit
                
Subttl          Ring Buffer Routines
Page

Put_out         Proc        Near                                    ; puts AL into output ring buffer
                Push        Cx
                Push        Di
                Pushf
                Cli
                Mov         Cx, Oavail[Si]                          ; put ptr
                Mov         Di, Cx
                Inc         Cx                                      ; bump
                And         Cx, Bufmsk
                Cmp         Cx, Ofirst[Si]                          ; overflow?
                Je          Poerr                                   ; yes, don't
                Add         Di, Obuf[Si]                            ; no
                Mov         [Di], Al                                ; put in buffer
                Mov         Oavail[Si], Cx
;               Dbg         'p','o',''
                Mov         Ah, 0
                Jmp         Short Poret
Poerr:
                Mov         Ah, -1
Poret:
                Popf
                Pop         Di
                Pop         Cx
                Ret
Put_out         Endp

Get_out         Proc        Near                                    ; gets next character from output ring buffer
                Push        Cx
                Push        Di
                Pushf
                Cli
                Mov         Di, Ofirst[Si]                          ; get ptr
                Cmp         Di, Oavail[Si]                          ; put ptr
                Jne         Ngoerr
                Mov         Ah, -1                                  ; empty
                Jmp         Short Goret
Ngoerr:
;               Dbg         'g','o',''
                Mov         Cx, Di
                Add         Di, Obuf[Si]
                Mov         Al, [Di]                                ; get char
                Mov         Ah, 0
                Inc         Cx                                      ; bump ptr
                And         Cx, Bufmsk                              ; wrap
                Mov         Ofirst[Si], Cx
Goret:
                Popf
                Pop         Di
                Pop         Cx
                Ret
Get_out         Endp

Put_in          Proc        Near
                Push        Cx
                Push        Di
                Pushf
                Cli
                Mov         Di, Iavail[Si]
                Mov         Cx, Di
                Inc         Cx
                And         Cx, Bufmsk
                Cmp         Cx, Ifirst[Si]
                Jne         Npierr
                Mov         Ah, -1
                Jmp         Short Piret
Npierr:
                Add         Di, ibuf[Si]
                Mov         [Di], Al
                Mov         Iavail[Si], Cx
;               Dbg         'p','i',''
                Mov         ah, 0
Piret:
                Popf
                Pop         Di
                Pop         Cx
                Ret
Put_in          Endp

Get_in          Proc        Near                                    ; gets one from input ring buffer into AL
                Push        Cx
                Push        Di
                Pushf
                Cli
                Mov         Di, Ifirst[Si]
                Cmp         Di, Iavail[Si]
                Je          Gierr
                Mov         Cx, Di
                Add         Di, Ibuf[Si]
                Mov         Al, [Di]
                Mov         Ah, 0
;               Dbg         'g','i',''
                Inc         Cx
                And         Cx, Bufmsk
                Mov         Ifirst[Si], Cx
                Jmp         Short Giret
Gierr:
                Mov         Ah, -1
Giret:
                Popf
                Pop         Di
                Pop         Cx
                Ret
Get_in          Endp

Subttl          Interrup Dispatcher Routine
Page

Asy1isr:
                Sti
                Push        Si
                Lea         Si, Asy_tab1
                Jmp         Short Int_serve
                
Asy2isr:
                Sti
                Push        Si
                Lea         Si, Asy_tab2 
                
Int_serve:
                Push        Ax                                      ; save all regs
                Push        Bx
                Push        Cx
                Push        Dx
                Push        Di
                Push        Ds
                Push        Cs                                      ; set DS = CS
                Pop         Ds 
Int_exit:
;               Dbg         'I','x',''
                Mov         Dx, Port[Si]                            ; base address
                Mov         Di, IntId                               ; check Int ID
                In          Al, Dx
                Cmp         Al, 00h
                Je          Int_modem
                jmp         Int_mo_no
Int_modem:
;               Dbg         'M','S',''
                Mov         Dl, Mstat
                In          Al, Dx                                  ; read MSR content
                Test        Al, CDlvl                               ; carrier present?
                Jnz         Msdsr                                   ; yes, test for DSR
                Test        OutSpec[Si], OutCdf                     ; no, is CD off line?
                Jz          Msdsr
                Or          InStat[Si], Offlin
Msdsr:
                Test        Al, DSRlvl                              ; DSR present?
                Jnz         Dsron                                   ; yes, handle it
                Test        OutSpec[Si], OutDSR                     ; no, is DSR throttle?
                Jz          Dsroff
                Or          OtStat[Si], LinDSR                      ; yes, throttle down
Dsroff:
                Test        OutSpec[Si], OutDrf                     ; is DSR off line?
                Jz          Mscts
                Or          InStat[Si], Offlin                      ; yes, set flag
                Jmp         Short Mscts   
Dsron:
                Test        OtStat[Si], LinDSR                      ; throttled for DSR?
                Jz          Mscts
                Xor         OtStat[Si], LinDSR                      ; yes, clear it out
                Call        Start_output
Mscts:
                Test        Al, CTSlvl                              ; CTS present?
                Jnz         Ctson                                   ; yes, handle it
                Test        OutSpec[Si], OutCTS                     ; no, is CTS throttle?
                Jz          Int_exit2
                Or          OtStat[Si], LinCTS                      ; yes, shut it down
                Jmp         Short Int_exit2
Ctson:
                Test        OtStat[Si], LinCTS                      ; throttled for CTS?
                Jz          Int_exit2
                Xor         OtStat[Si], LinCTS                      ; yes, clear it out
                Jmp         Short Int_exit1
Int_mo_no:
                Cmp         Al, 02h
                Jne         Int_tx_no
Int_txmit:
;               Dbg         'T','x',''
Int_exit1:
                Call        Start_output                            ; try to send another
Int_exit2:
                Jmp         Int_exit
Int_tx_no:
                Cmp         Al, 04h
                Jne         Int_rec_no
Int_receive:
;               Dbg         'R','x',''
                Mov         Dx, Port[Si]
                In          Al, Dx                                  ; take char from 8250
                Test        OutSpec[Si], OutXon                     ; is XON/XOFF enabled?
                Jz          Stuff_in                                ; no
                Cmp         Al, 'S' And 01FH                        ; yes, is this XOFF?
                Jne         Isq                                     ; no, check for XON
                Or          OtStat[Si], LinXof                      ; yes, disable output
                Jmp         Int_exit2                               ; don´t store this one
Isq:
                Cmp         Al, 'Q' And 01FH                        ; is this XON?
                Jne         Stuff_in                                ; no, save it
                Test        OtStat[Si], LinXof                      ; yes, waiting?
                Jz          Int_exit2                               ; no, ignore it
                Xor         OtStat[Si], LinXof                      ; yes, clear the XOFF bit
                Jmp         Int_exit1                               ; and try to resume xmit
Int_rec_no:
                Cmp         Al, 06h
                Jne         Int_done
Int_rxstat:
;               Dbg         'E','R',''
                Mov         Dl, Lstat
                In          Al, Dx
                Test        InSpec[Si], InEpc                       ; return them as codes?
                Jz          Nocode                                  ; no just set error alarm
                And         Al, AnyErr                              ; yes, mask off all but error bits
                Or          Al, 080h
Stuff_in:
                Call        Put_in                                  ; put input char buffer
                Cmp         Ah, 0                                   ; did it fit?
                Je          Int_exit3                               ; yes, all ok
                Or          InStat[Si], LostDt                      ; no, set DataLost bit
Int_exit3:
                Jmp         Int_exit
Nocode:
                Or          InStat[Si], BadInp
                Jmp         Int_exit3
Int_done:
                Clc
                Jnc         $+2
                Mov         Al, EOI                                 ; all done now
                Out         PIC_b, Al
                Pop         Ds                                      ; restore regs
                Pop         Di
                Pop         Dx
                Pop         Cx
                Pop         Bx
                Pop         Ax
                Pop         Si
                Iret
                
Start_output    Proc        Near
                Test        OtStat[Si], LinIdl                      ; blocked?
                Jnz         Dont_start                              ; yes, no output
                Mov         Dx, Port[Si]                            ; no, check UART
                Mov         Dl, Lstat
                In          Al, Dx
                Test        Al, Xhre                                ; empty?
                Jz          Dont_start                              ; no
                Call        Get_out                                 ; yes, anything waiting?
                Or          Ah, Ah
                Jnz         Dont_start                              ; no
                Mov         Dl, RxBuf                               ; yes, send it out
                Out         Dx, Al
;               Dbg         's','o',''
Dont_start:
                ret
Start_output    Endp

Subttl          Initialization Request Routine
Page

Init:           Lea         Di, $                                   ; release rest...
                Mov         Es:Xfer[Bx], Di 
                Mov         Es:Xseg[Bx], Cs
                
                Mov         Dx, Port[Si]                            ; base port
                Mov         Dl, Lctrl
                Mov         Al, Dlab                                ; enable divisor
                Out         Dx, Al
                Clc
                Jnc         $+2
                Mov         Dl, RxBuf
                Mov         Ax, Baud[Si]                            ; set baud
                Out         Dx, Al
                Clc
                Jnc         $+2
                Inc         Dx
                Mov         Al, Ah
                Out         Dx, Al
                Clc
                Jnc         $+2
                
                Mov         Dl, Lctrl                               ; set LCR
                Mov         Al, OtStat[Si]                          ; from table
                Out         Dx, Al
                Mov         OtStat[Si], 0                           ; clear status
                Clc
                Jnc         $+2
                Mov         Dl, IntEn                               ; IER
                Mov         Al, AllInt                              ; enable ints in 8250
                Out         Dx, Al
                Clc
                Jnc         $+2
                Mov         Dl, Mctrl                               ; set MCR
                Mov         Al, InStat[Si]                          ; form table
                Out         Dx, Al
                Mov         InStat[Si], 0                           ; clear status
                
ClRgs:          Mov         Dl, Lstat                               ; clear LSR
                In          Al, Dx
                Mov         Dl, RxBuf                               ;clear RX reg
                In          Al, Dx
                Mov         Dl, Mstat                               ; clear MSR
                In          Al, Dx
                Mov         Dl, IntId                               ; IID reg
                In          Al, Dx
                In          Al, Dx
                Test        Al, 1                                   ; int pending?
                Jz          ClRgs                                   ; yes, repeat
                
                Cli
                Xor         Ax, Ax                                  ; set int vec
                Mov         Es, Ax
                Mov         Di, Vect[Si]
                Mov         Ax, IsrAdr[Si]                          ; from table
                Stosw
                Mov         Es:[Di], Cs
                
                In          Al, PIC_e                               ; get 8259
                And         Al, 0E7h                                ; COM1 / COM2 mask
                Clc
                Jnb         $+2
                Out         PIC_e, Al
                Sti
                
                Mov         Al, EOI                                 ; now send EOI just in case
                Out         Pic_b, Al
                
;               Dbg         'D','I',''                              ; driver installed
                Jmp         Zexit
                
Driver          Ends
                End