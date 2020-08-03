
; INT1587.ASM | FASM (R) code | 626 Bytes
; Ultimate INT $15 / AH=$87 test (R)
; (CL) 2009-11-28 by DOS386 | Abuse at your own risk !!!

; WARNING: This tool does one arguably exotic task very well !!!!!!!!!!!!!!!!

; http://board.flatassembler.net/topic.php?t=9738

; ----------------------------------------------------------------------

define pope  pop
define popef popf

macro movntq mdst, msrc {
  if mdst eq cs
    err "CS is not a valid destination"
  end if
  if mdst in <ds,es,ss> & msrc in <cs,ds,es,ss>
    push  msrc
    pope  mdst
  else
    if mdst in <ax,bx,cx,dx,si,di,bp> & msrc eq 0
      xor  mdst, mdst
    else
      mov  mdst, msrc
    end if
  end if
} ; endmacro

macro cmpntq minp, mref {
  if minp in <bl,cl,dl,ah,bh,ch,dh,ax,bx,cx,dx,si,di,bp> & mref eq 0
    test minp, minp
  else
    cmp  minp, mref
  end if
} ; endmacro

; ----------------------------------------------------------------------

; ASS'ume: really nothing AKA BUGGER all ;-D

; ----------------------------------------------------------------------

; System requirements :
; - FreeDOS 1.1, EDR-DOS 7.01.08, RxDOS 7.30 or compatible
; - At least 80386 CPU (checked) in RM or faulty "V86"
; - Graphics with VESA 2.0 (only partially checked)
; - 640x480x16bpp mode (usually $0111) with both BANK'ruptcy
;   (also size must be 64 KiB) and LFB support, and BPSL=1'280

; This works in real mode as well as with EMM386, even with "NOVCPI",
; but doesn't wotk with "NOCHECK" hack disabling PCI MMIO.

; Usage: just run the executable and enjoy the effects. There are no
; commandline parameters and no control of running program.

; ----------------------------------------------------------------------

; INT $10 - VESA HyperVGA BIOS - GET HyperVGA MODE INFORMATION
; In: AX = $4F01 | CX = HyperVGA video mode (see #04082 for bitfields)
;     ES:DI -> 256-byte buffer for mode information (see #00079)
; Return: AL = $4F if function supported
;         AH = status: 0 successful, ES:DI buffer filled  | 1 failed
; Bit(s) Description    (Table 04082)
; 15     preserve display memory on mode change
; 14     (VBE >= 2.0) use linear (flat) frame buffer
; 8 to 0 video mode number ($00xx are non-VESA modes, $01xx are VESA-defined)
; Format of VESA HyperVGA mode information:
; Offset Size    Description     (Table 00079)
; $00    WORD    mode attributes (see #00080) <<<============
; $02    BYTE    window attributes, window A (see #00081)
; $03    BYTE    window attributes, window B (see #00081)
; $04    WORD    window granularity in KiB
; $06    WORD    window size in KiB <<<============ This is the bank size !!!
; $08    WORD    start segment of window A (0 if not supported)
; $0A    WORD    start segment of window B (0 if not supported)
; $0C    DWORD   -> FAR window posi function (equivalent to AX=$4F05)
; $10    WORD    bytes per scan line <<<============
; ---remainder optional for VESA modes 1.0/1.1, needed for OEM modes---
; $12    WORD    width in pixels (graphics) or chars (text) <<<============
; $14    WORD    height in pixels (graphics) or chars (text) <<<============
; $16    BYTE    width of character cell in pixels
; $17    BYTE    height of character cell in pixels
; $18    BYTE    number of memory planes
; $19    BYTE    number of bits per pixel <<<============
; $1A    BYTE    number of banks (CRAP, usually 1) #####
; $1B    BYTE    memory model type (see #00082)
; $1C    BYTE    size of bank in KiB (CRAP, usually 0) #####
; $1D    BYTE    number of image pages that will fit in video RAM - 1 (CRAP)
; $1E    BYTE    reserved (0 for VBE 1.0 to 2.0, 1 for VBE 3.0)
; ---VBE >= 1.2 ---
; $1F    BYTE    red mask size
; $20    BYTE    red field position
; $21    BYTE    green mask size
; $22    BYTE    green field size
; $23    BYTE    blue mask size
; $24    BYTE    blue field size
; $25    BYTE    reserved mask size
; $26    BYTE    reserved mask position
; $27    BYTE    direct color mode info
; ---VBE >= 2.0 ---
; $28    DWORD   physical address of linear video buffer <<<============
; $2C    DWORD   pointer to start of offscreen memory
; $30    WORD    KiB of offscreen memory
; Bitfields for VESA HyperVGA mode attributes:
; Bit(s) Description     (Table 00080)
; 0      mode supported by present hardware configuration
; 1      optional information available (must be = 1 for VBE >= 1.2)
; 2      BIOS output supported
; 3      set if color, clear if monochrome
; 4      set if graphics mode, clear if text mode
; ---VBE >= 2.0 ---
; 5      mode is not VGA-compatible
; 6      bank-switched mode not supported
; 7      linear framebuffer mode supported
; 8      double-scan mode available (e.g. 320x200 and 320x240)

; INT $10 - VESA HyperVGA BIOS - SET HyperVGA VIDEO MODE
; AX = $4F02
; BX = new video mode (see #04082,#00083,#00084)
; ES:DI -> (VBE 3.0+) CRTC information block, bit mode bit 11 set (strange)
; Return: AL = $4F if function supported
;         AH = status: 0 successful | 1 miserably failed

; The format of VBE mode numbers is as follows:
;       D0-D8     =    Mode number
;                      If D8 = 0, this is not a VESA defined mode
;                      If D8 = 1, this is a VESA defined mode
;       D9-D13    =    Reserved by VESA for future expansion (= 0)
;       D14       =    Linear/Flat Frame Buffer Select
;                      If D14 == 0, Use VGA Frame Buffer
;                      If D14 == 1, Use Linear/Flat Frame Buffer
;       D15       =    Preserve Display Memory Select
;                      If D15 == 0, Clear display memory
;                      If D14 == 1, Preserve display memory

; 4.5. Function 2 - Set VBE Mode
; This required function initializes the controller and sets a VBE mode.
; The format of VESA VBE mode numbers is described earlier in this
; document. If the mode cannot be set, the BIOS should leave the
; graphics environment unchanged and return a failure error code.
; Input:    AX   = $4F02     Set VBE Mode
;           BX   =           Desired Mode to set
;                D0-D8  =    Mode number
;                D9-D13 =    Reserved (must be 0)
;                D14    = 0  Use windowed frame buffer model
;                       = 1  Use linear/flat frame buffer model
;                D15    = 0  Clear display memory
;                       = 1  Don't clear display memory
; Output:   AX   =           VBE Return Status
; Note: All other registers are preserved.

; VESA BUG's:
; - Some VESA's ignore the b14 bit and always open the access through both
;   BANK'ing at ($000A'0000) and the LFB (at some high address)
; - Some VESA's ignore the b15 bit and fail to clear the screen or do it
;   incompletely
; - LFB is usually at > 2 GiB but there are PC's having it as low as
;   at 1 GiB AKA $4000'0000
; - LFB address is specified per mode but no PC has been observed yet
;   having different LFB addresses for different modes
; - Some VESA's in PC's and BOCHS (!!!) report faulty modes, having faulty
;   values in various mode fields like BPSL or LFB address (can be ZERO !!!)
; - The docs on B.S. VESA are a mess, there is no usable explanation about
;   "window" vs "bank", the "bank size" is usually ZERO
; - The famous "window A" is in some implementations of VESA not readable,
;   but "window B" works (always ???), so screenshooters must use whatever
;   is readable rather than just A
; - BANK size is usually 64 KiB but a few VESA's have been observed having
;   less, as just 16 KiB (apprently even legal according to the spec)
; - Many cards make just a minimal subset of features implemented in the card
;   hardware and even eligible for VESA support actually also available
;   through VESA, many old PCI cards have LFB in the hardware but no VESA 2.0
;   and no VESA LFB (driver helps), many newer AGP and PCIE cards report much
;   less memory than they actually have, and report just a small subset of
;   modes (only 24bpp instead of 32bpp, only lower resolution, ...), also
;   H & V frequencies can rarely be set using VESA, although VESA 3.0 has
;   support for such and also pretty all cards allow this usig their private
;   non-VESA Windaube "drivers", not to talk about YUV support and hardware
;   scaling ...

; INT $15 / AH=$87 - SYSTEM - COPY EXTENDED MEMORY
; CX = number of words to copy (max $8000)
; ES:SI -> GDCT global descriptor table, bloat = $30 = #48 BYTE's
; Return: CF set on error | CF clear if successful | AH = status
; Notes: - Copy is done in protected mode with interrupts disabled by the
;          default BIOS handler; many "386" memory managers perform the
;          copy with interrupts enabled
;        - Some EMM386 have a strange "NOCHECK" switch disabling access
;          to PCI MMIO, only RAM (+ ROM and ISA MMIO) will work then
; Errors: $00 source copied into destination
;         $01 parity error
;         $02 interrupt error
;         $03 address line 20 gating failed
;         $80 invalid command (PC, PCJR) or limit violation (JAM386)
;         $86 unsupported function (XT, PS30)
; $00 16 BYTE's zeros (used by BIOS)
; $10    WORD   source segment limit in bytes (2*CX-1 or greater or $FFFF)
; $12  3 BYTE's 24-bit "seg*16+off" or physical source addr, low byte first
; $15    BYTE   source segment access rights $93
; $16    WORD   (286) zeros
;               (386+) extended access rights and high byte of src address
; $18    WORD   dest segment limit in bytes (2*CX-1 or greater or $FFFF)
; $1A  3 BYTE's 24-bit "seg*16+off" or physical dest address, low byte first
; $1D    BYTE   destination segment access rights $93
; $1E    WORD   (286) zero
;               (386+) extended access rights and high byte of dest address
; $20 16 BYTE's zeros (used by BIOS to build CS and SS descriptors)

; INT $21 / AH=$48 - DOS 2+ - ALLOCATE MEMORY
; In: BX = number of paragraphs to allocate
; Return: CF clear if successful | AX = segment of allocated block
;         CF set on error | AX = error code (7,8) (see #01680 at AH=$59)
;         BX = size of largest available block
; Notes:  DOG 2.1-6.0 coalesces free blocks while scanning for a block to hog
;         ".COM" programs are initially allocated the largest available memory
;         block, and usually can't hog any additinal useful amount anymore
; SeeAlso: AH=$49,AH=$4A,AH=$58,AH=$83

; ----------------------------------------------------------------------

; Our test figure hogs exactly 64 KiB , not divisible by 1'280 Bytes, this
; means: 1280*51 = 65'280 | 51 Lines and 256 Bytes left or 51+1/5 lines :-(

; ----------------------------------------------------------------------

; Program messages:
; "!" - "Welcome to INT $15 / AH=$87 test"
; "3" - "At least 80386 required" (fatal)
; "R" - "Real mode"
; "V" - "V86 with VCPI"
; "W" - "V86 without VCPI (f**k)"
; "H" - "Hogging buffer OK"
; "h" - "Hogging buffer failed" (fatal)
; "S" - "VESA mode search OK, mode and phys:"
; "s" - "VESA mode search failed" (fatal)
; "G" - "Figure generation done"
; "@" - ???
; "I" - "Return status from INT $15:"
; "f" - "VESA mode setting failed" (fatal)
; "X" - "Exiting, bye"

; ----------------------------------------------------------------------

ccstacktop = $1200

format binary as "EXE" ; MZ header $20 ; Program $0400 ; Heap 0 ; Stack $1000
use16
org 0

  db "MZ"          ; Mark's Sigi
  dw 114           ; Bytes in last block (0 is full, includes header size)
  dw 2             ; Blocks per 512 Bytes (includes header size)
  db 0,0           ; No relocs
  db 2,0           ; Header size
  dw $1000         ; Min (Heap + Stack)
  dw $1000         ; Max (Heap + Stack)
  dw 0             ; Stack segment: SS=CS !!!
  dw ccstacktop    ; Stack size (almost 4 KiB) / pointer in bytes !!!
  db 0,0,0,0,0,0   ; CHK, IP, CS
  dw $1C           ; Useless reloc offset
  db 0,0           ; Useless "overlay"
  db 0,0,0,0       ; Padding / empty reloc

org 0 ; Again :-D

; ----------------------------------------------------------------------

; [8086]

        ; Boast "!"

        call   sseol
        mov    al, 33       ; "!"
        call   ssstatuschar
        call   ssdelay15

        ; Test for 80386 (includes CLD and STI)

        mov    ax, $7202    ; 3   -> 3
        push   ax
        popef               ; % This is not 100% safe from "V86" mess,
        pushf               ; % but sufficient here
        pope   bx           ; 4x1 -> 7
        cmp    ax, bx       ; 2   -> 9
        je     short cpu_ok ; 2   -> 11 | OK we have at least 80386

        ; CPU bad

        mov    al, 51       ; "3"
        jmp    near fatal_give_up
        ;------------------------

        ; CPU good - test for "V86" and VCPI

; [80386]

cpu_ok:
        smsw   ax           ; MOVNTQ AX, CR0
        shr    ax, 1
        jc     short got_v86

        mov    al, 82       ; "R"
        jmp    short result_V86_vcpi
        ;---------------------------

got_v86:
        mov    ax, $3567    ; Get INT $67 vector
        int    $21          ; Result in ES:BX
        mov    ax, es       ; % Avoid residual risk of crash
        or     ax, bx       ; % by INT $67 if it points to 0 in "V86"
        jz     short no_vcpi

        mov    ax, $DE00    ; Check for VCPI host
        int    $67          ; Some versions of Windaube dislike this call :-D
        cmpntq ah, 0        ; AH=0 would mean: VCPI available
        jne    short no_vcpi

        mov    al, 86       ; "V" (got VCPI)
        jmp    short result_V86_vcpi
        ;---------------------------

no_vcpi:
        mov    al, 87       ; "W" (got V86 but no VCPI)

result_V86_vcpi:
        call   ssstatuschar
        call   ssdelay15

        ; Hog buffer, save result into BP

        mov    ah, $48      ; Hog memory
        mov    bx, $1000    ; 64 KiB
        int    $21
        jnc    short hog_ok
        mov    al, 104      ; "h"
        jmp    near fatal_give_up
        ;------------------------

hog_ok:
        mov    bp, ax
        mov    al, 72       ; "H"
        call   ssstatuschar
        call   ssdelay15

        ; Brute-force search for suitable VESA mode

        ; 0-att16 6-bank16 $10-bpsl16 $12-xx16 $14-yy16 $19-bpp8 $28-phys32

        ; On success leave high "phys" in AX and "mode" in CX

        ; Also stack is left trashed on success !!!

        mov    si, $0100

brute_loop:
        mov    cx, si       ; Mode
        cmp    cx, $0100
        je     short swap_0100_0111
        cmp    cx, $0111
        jne    short no_silly_swap

swap_0100_0111:
        xor    cx, $0011    ; Reduce risk of trouble and speed up finding

no_silly_swap:
        mov    sp, ccstacktop - $0200   ; Reserve $0200 Bytes
        movntq es, cs
        mov    di, sp
        mov    ax, $4F01
        int    $10        ; AX command | CX mode | ES:DI buffer
        cmp    ax, $004F
        jne    short bad_mode

        pope   ax         ; Att b0=1(sup) b3=1(col) b4=1(gra) b6=0 b7=1(lfb)
        xor    al, 64     ; Invert "b6" from "NO BS" to "YES, got also BS"
        and    al, 217    ; %11011001
        cmp    al, 217
        jne    short bad_mode

        add    sp, 4
        pope   ax         ; +6 (bankruptcy size)
        cmp    al, 64     ; Hey, I don't care about AH
        jne    short bad_mode

        add    sp, 8
        pope   ax         ; +$10 ("bpsl")
        cmp    ax, 1280
        jne    short bad_mode

        pope   ax         ; +$12 ("xx16")
        cmp    ax, 640
        jne    short bad_mode
        pope   ax         ; +$14 ("yy16")
        cmp    ax, 480
        jne    short bad_mode

        pope   ax         ; +$16
        pope   ax         ; +$18 | "bpp8" in +$19 now AH
        cmp    ah, 16
        jne    short bad_mode

        add    sp, $0E
        pope   ax               ; +$28 | "phys" LFB low !!!
        cmpntq ax, 0
        jne    short bad_mode   ; Low 16 bits must be ZERO
        pope   ax               ; +$2A | "phys" LFB high !!!
        cmp    ax, $4000
        jae    short l_and_g_we_got_him ; :-)))))))))))))))))))))))))))))))))

bad_mode:
        inc    si
        cmp    si, $0200
        jb     short brute_loop

        mov    sp, ccstacktop   ; Restore stack
        mov    al, 115          ; "s"
        jmp    near fatal_give_up
        ;------------------------

        ; Report search success, save "phys" in FS and "mode" in GS

l_and_g_we_got_him:
        mov    sp, ccstacktop   ; Restore stack
        mov    fs, ax           ; Backup upper 16 bits of LFB address in FS
        mov    gs, cx           ; Mode
        mov    al, 83           ; "S"
        call   ssstatuschar

        ; Boast with 2 numbers

        mov    ax, gs       ; Mode
        call   sshex16
        mov    al, 32
        call   ssonecharal
        mov    ax, fs       ; LFB
        call   sshex16
        add    ax, 5        ; 5 * 65'536 = 256 * 1'280 | Move 256 lines down
        mov    fs, ax       ; LFB
        call   sseol
        call   ssdelay30    ; More interesting info, wait longer

        ; Generate test picture 640 x (51+1/5)x 16 bpp

        ; Hogged memory block for buffer seg addr is in BP (British Petrol)

        mov    es, bp
        movntq di, 0

        mov    cx, 1280
        mov    al, 255
        rep    stosb        ; 1 line

        movntq bx, 0        ; BH is YY

aa0:    movntq cx, 0        ; CX is XX

aa1:    mov    ax, cx       ; 0 to 639
        mov    bl, 20
        div    bl           ; Quotient AL (0 to 31) | Remainder AH (f*** off)
        mov    ah, al       ; AH is RR (5 bits)
        shl    ah, 3        ; Now RR in top 5 bits
        sub    al, 31       ; "-31" to 0
        neg    al           ; 31 to 0 | AL is BB (5 bits)
        mov    dx, ax       ; Backup AX (with RR and BB) into DX
        mov    al, bh       ; 0 to 48 (upper 5 bits in AH still have RR ...)
        add    al, 15       ; 15 to 63
        shl    ax, 5        ; Now GG (6 bits) in correct bits, RR fully out
        or     ax, dx       ; Merge DX (with RR and BB) into AX (with GG)
        stosw               ; Write it

        inc    cx
        cmp    cx, 640
        jnz    short aa1    ; BCK (XX)

        inc    bh
        cmp    bh, 49
        jnz    short aa0    ; BCK (YY)

        mov    cx, 1512     ; Last 24 bytes AKA 12 pixels are reserved :-)
        mov    al, 255
        rep    stosb        ; Almost (1+1/5) lines
        mov    ax, 63488    ; %11111'000000'00000 -> RR
        stosw
        stosw
        stosw
        mov    ax, 2016     ; %00000'111111'00000 -> GG
        stosw
        stosw
        stosw
        mov    ax, 31       ; %00000'000000'11111 -> BB
        stosw
        stosw
        stosw
        mov    ax, $FFFF    ; WW
        stosw
        stosw
        stosw

        ; Boast "G"

        mov    al, 71       ; "G"
        call   ssstatuschar
        call   ssdelay30    ; Longer delay before screen switch

        ; Activate the B.S.

        mov    ax, $4F02
        mov    bx, gs       ; B.S. AKA B***-S*** ":-(
        int    $10          ; AX command | BX mode
        cmp    ax, $004F
        jne    short vesa_bugged  ; FWD

        ; Copy 64 KiB

        mov    ds, bp       ; Source seg
        mov    ax, $A000
        mov    es, ax       ; Dest seg
        mov    cx, $8000
        movntq si, 0
        movntq di, 0
        rep    movsw        ; Copy

        ; Wait

        mov    cl, 120      ; 6 s
        call   ssdelaycl

        ; Clear 64 KiB (some bugged VESA's don't)

        ; ES is still $A000

        mov    cx, $8000
        movntq di, 0
        movntq ax, 0
        rep    stosw        ; Clear

        ; Back to text mode

        call   ssbttm       ; Includes "ssdelay30"

        ; Boast "@"

        mov    al, 64       ; "@"
        call   ssstatuschar
        call   ssdelay30    ; Longer delay before screen switch

        ; Activate the LFB

        mov    ax, $4F02
        mov    bx, gs       ; Pick mode ($0100...$01FF, usually $0111)
        or     bh, $40      ; ORNTQ BX, $4000 | LFB :-)
        int    $10          ; AX command | BX mode
        cmp    ax, $004F
        je     short vesa_lfb_ok

vesa_bugged:
        call   ssbttm       ; Includes "ssdelay30"
        mov    al, 102      ; "f"
        jmp    short fatal_give_up
        ;-------------------------

vesa_lfb_ok:

        ; Prepare for writing GDCT and INT $15

        ; Scratch free some space on the stack

        mov    sp, ccstacktop - $0200 ; Reserve $0200 Bytes (only $30 needed)
        movntq es, cs
        mov    di, sp       ; For writing
        mov    si, sp       ; For INT $15 (don't touch below)

        ; Write the magic stuff for INT $15

        ; Hogged memory block for buffer seg addr is in BP (British Petrol)

        ; Augmented LFB address (high 16 bits) is in FS (Ferrovie dello Stato)

        mov    cx, 8
        movntq ax, 0
        rep    stosw        ; 16 BYTE's wasted | REP STOSW exits with CX==0
        dec    ax
        stosw               ; Limit (apparently of SunSet Limited (R) ...)
        mov    ax, bp       ; Source seg
        shl    ax, 4        ; Low 16 bits
        stosw
        shr    bp, 12       ; High 8 bits (we are in low memory)
        xchg   ax, bp       ; BP trashed now
        mov    ah, $93      ; Rights (YES, indeed not Lefts here ...)
        stosw
        movntq ax, 0
        stosw               ; "386" Junk
        dec    ax
        stosw               ; Limit (apparently of SunSet Limited (R) ...)
        inc    ax
        stosw               ; Lower 16 bits of LFB are ZERO
        mov    ax, fs       ; High 16 bits
        mov    ah, $93      ; Rights (YES, indeed not Lefts here ...)
        stosw
        mov    ax, fs       ; High 16 bits
        mov    al, 0        ; "386" junk
        stosw
        mov    cl, 8        ; CH==0
        movntq ax, 0
        rep    stosw        ; 16 BYTE's wasted | REP STOSW exits with CX==0

        ; Do the COPY !!!

        ; And restore stack

        mov    ah, $87
        mov    ch, $80      ; CX=$8000 (CL==0 see above) | Full 64 KiB
        int    $15
        jc     short @f     ; ERR
        mov    ah, $FF      ; OK
@@:     shr    ax, 8        ; Status in AL | AH==0 | 255 means OK
        mov    bp, ax       ; Status in BP (<=255)

        mov    sp, ccstacktop   ; Restore stack

        ; Wait & back to text mode

        mov    cl, 120      ; 6 s
        call   ssdelaycl
        call   ssbttm

        ; Boast "I" and status from INT $15

        mov    al, 73       ; "I"
        call   ssstatuschar
        xchg   ax, bp       ; Trashing BP but no longer any relevance ...
        call   sshex16      ; Report status ($FF is OK)
        call   sseol
        call   ssdelay15

        ; Boast "X"

        mov    al, 88       ; "X"

        ; Success and failure end

fatal_give_up:

        call   ssstatuschar
        call   ssdelay15

        ; EOF

        mov    ax, $4C00
        int    $21
        ;---------

; ----------------------------------------------------------------------

; SUB SSBTTM (not "BTTR" ...)

ssbttm:
        mov    ax, 3          ; AH=0 | AL=mode
        int    $10
        ; and pass

; SUB SSDELAY30 (trashing AX CX DS)

ssdelay30:
        mov    cl, 30
        db     $A9            ; TESTNTQ AX, stuff
        ; quasi-pass

; SUB SSDELAY15 (trashing AX CX DS)

ssdelay15:
        mov    cl, 15
        ; and pass

; SUB SSDELAYCL (trashing AX CX DS)

ssdelaycl:
        mov    ch, 0          ; Or use DEC CL, would also cost 2 Bytes
        movntq ax, 0
        mov    ds, ax
bb0:    mov    al, [$046C]
bb1:    cmp    al, [$046C]
        je     short bb1
        loop   short bb0
        ret
        ;----

; SUB SSHEX16

sshex16:
        push   cx

        mov    cx, 1028     ; "MOVNTQ CL, 4" + "MOVNTQ CH, 4"
@@:     rol    ax, cl       ; 8086 compatible, after 4 ROL's original back
        push   ax
        and    al, $0F
        cmp    al, 10       ; Now must be and is AL<=15 | Decimal "10" !!!
        sbb    al, $69      ; Securely Bugged Backup
        das                 ; Digital Attack System | ASCII result in AL
        call   ssonecharal
        pope   ax
        dec    ch           ; & No LOO'p on CH :-(
        jnz    short @b     ; &

        pope   cx
        ret
        ;----

; SUB SSSTATUSCHAR

ssstatuschar:

        call   ssonecharal
        ; and pass

; SUB SSEOL

sseol:
        mov    al, 13
        call   ssonecharal
        mov    al, 10
        ; and pass

; SUB SSONECHARAL

ssonecharal:

        ; pushf            ; opt
        push   ax
        push   bx
        ; push   dx

        mov    ah, $0E        ; "TTY" BIOS service, char in AL
        movntq bx, 0
        int    $10            ; BIOS screen stuff

        ; mov    dl, al
        ; mov    ah, 2        ; DOS service, char in DL
        ; int    $21          ; Here

        ; pope   dx
        pope   bx
        pope   ax
        ; popef            ; opt

        ret
        ;----

; ----------------------------------------------------------------------

