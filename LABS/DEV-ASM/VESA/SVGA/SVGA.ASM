        .486p

; Publics for PB

        public     GetVBE
        public     GetOEMStr
        public     CopyOEMString
        public     CountModes
        public     CopyModes
        public     GetMIB
        public     Text
        public     SetVESAMode
        public     SetSVGAPixel
        public     CalcJ

; externals

        extrn      Get$Loc: FAR          ; internal PB functions
        extrn      Get$Alloc: FAR

modeinfoblock      struc                 ; Mode Info Block
  ModeAtt          dw ?                  ; mode attributes
  WinaAtt          db ?                  ; window A attribute
  WinbAtt          db ?                  ; window B attribute
  WinGran          dw ?                  ; window granularity
  WinSize          dw ?                  ; window size
  WinaSeg          dw ?                  ; window A segment
  WinbSeg          dw ?                  ; window B segment
  WinFuncPtr       dd ?                  ; bank switch address
  bpsl             dw ?                  ; bytes per scan line
  xres             dw ?                  ; horizontal resolution
  yres             dw ?                  ; vertical resolution
  xchar            db ?                  ; character cell width
  ychar            db ?                  ; character cell height
  numplanes        db ?                  ; number of planes
  bpp              db ?                  ; bits per pixel
  numbanks         db ?                  ; number of banks
  memmodel         db ?                  ; memory model
  banksize         db ?                  ; bank size in KB
  noip             db ?                  ; number of image pages
  res1             db 1                  ; reserved page function
  redms            db ?                  ; color red mask in bits
  redfp            db ?                  ; red mask LSB position
  greenms          db ?                  ; color green mask in bits
  greenfp          db ?                  ; green mask LSB position
  bluems           db ?                  ; color blue mask in bits
  bluefp           db ?                  ; blue mask LSB position
  rsvdms           db ?                  ; color reserved mask in bits
  rsvdfp           db ?                  ; reserved mask LSB position
  dcmi             db ?                  ; direct color mode attributes
  physbaseptr      dd ?                  ; flat frame buffer address
  res2             dd 0                  ; always set to 0
  res3             dw 0                  ; always set to 0
  LinBPSL          dw ?                  ; bytes per scan line linear modes
  BnkNOIP          db ?                  ; number images banked modes
  LinNOIP          db ?                  ; number images linear modes
  LinRMS           db ?                  ; red mask linear modes
  LinRFP           db ?                  ; LSB red mask linear modes
  LinGMS           db ?                  ; green mask linear modes
  LinGFP           db ?                  ; LSB green mask linear modes
  LinBMS           db ?                  ; blue mask linear modes
  LinBFP           db ?                  ; LSB blue mask linear modes
  LinRsvMS         db ?                  ; reserved mask linear modes
  LinRsvFP         db ?                  ; LSB reserved mask
  MPClock          dd ?                  ; maximum pixel clock in Hz
  res4             db 189 DUP (?)        ; remainder Mode Info Block
modeinfoblock      ends

DATA    segment word use16 public 'DATA'

sbuf    db 256 DUP (?)                   ; string buffer
mib     modeinfoblock <>                 ; Mode Info Block 

DATA    ends


code16  segment para public use16
        assume  cs:code16, ds:DATA

; FUNCTION GetVBE
; Purpose:         Fill the VBE information block.
; Input:           [bp+6] = offset address VBE information block
;                  [bp+8] = segment address VBE information block
; Output:          TRUE    ===> VBE information block filled
;                  FALSE   ===> Function failed
GetVBE  proc far
        push       bp
        mov        bp, sp
        push       es
        push       di
        les        di, [bp+6]            ; es:di -> VBE information block
        mov        ax, 4f00h             ; Function: Return VBE information
        int        10h                   ; transfer to VESA
        cmp        al, 4fh               ; function supported?
        jne        GetVBE2               ; no: jump
        or         ah, ah                ; function succesful?
        jnz        GetVBE2               ; no: jump
        mov        ax, 1                 ; yes: set function result TRUE

GetVBE1:

        pop        di
        pop        es
        pop        bp
        ret        4

GetVBE2:

        xor        ax, ax                ; set function result FALSE
        jmp        short GetVBE1
GetVBE          endp

; FUNCTION GetOEMStr
; Purpose:         Get the OEM string from VBE information block.
; Input:           [bp+6] = address OEM string
; Output:          ax = string length OEM string
;                  ax = 0 ===> no OEM string available
GetOEMStr proc far
        push       bp
        mov        bp, sp
        push       ds
        push       es
        push       di
        push       si
        mov        ax, ds               
        mov        es, ax                ; segment into es
        lds        si, [bp+6]            ; ds:si -> OEM string
        mov        di, offset sbuf       ; es:di -> buffer
        xor        cx, cx                ; counter = 0

GetOEMStr1:

        mov        al, ds:[si]           ; read 1 byte
        cmp        al, 0                 ; last byte?
        jz         GetOEMStr2            ; yes: jump
        mov        byte ptr es:[di], al  ; no: copy byte
        inc        cx                    ; update counter
        inc        si                    ; update pointers
        inc        di
        jmp        short GetOEMStr1
        
GetOEMStr2:

        mov        ax, cx                ; load string length
        pop        si
        pop        di
        pop        es
        pop        ds
        pop        bp
        ret        4        
GetOEMStr endp

; FUNCTION CopyOEMString
; Purpose:         Copy OEM string into a PB string.
; Input:           [bp+6]  = string length
; Output:          ax = string handle ===> success
;                  ax = 0             ===> failed
CopyOEMString proc far
        push       bp
        mov        bp, sp
        sub        sp, 2                 ; temporary storage
        push       ds
        push       es
        push       di
        push       si
        mov        ax, [bp+6]            ; get string length
        push       ax                    ; length at stack
        call       Get$Alloc             ; allocate string space
        or         ax, ax                ; space available?
        jz         CopyOEMString3        ; no: jump
        mov        [bp-2], ax            ; save new handle
        push       ax                    ; handle at stack
        call       Get$Loc               ; determine string address
                                         ; dx:ax = string address
                                         ; cx    = string length
        mov        es, dx
        mov        di, ax                ; es:di -> destinaton
        mov        ax, seg sbuf
        mov        ds, ax
        mov        si, offset sbuf       ; ds:si -> source
        
CopyOEMString1:

        mov        al, ds:[si]           ; read 1 byte
        mov        byte ptr es:[di], al  ; write 1 byte
        inc        di                    ; update pointers and counter
        inc        si
        dec        cx
        jnz        CopyOEMString1
        mov        ax, [bp-2]            ; load string handle

CopyOEMString2:

        pop        si
        pop        di
        pop        es
        pop        ds
        mov        sp, bp        
        pop        bp
        ret        2

CopyOEMString3:

        xor        ax, ax                ; indicate error
        jmp        short CopyOEMString2
CopyOEMString endp

; FUNCTION CountModes
; Purpose:         Count modes from mode list.
; Input:           [bp+6]  = pointer to mode list.
; Output:          ax = number of modes ===> success
;                  ax = 0               ===> failed
CountModes proc far
        push       bp
        mov        bp, sp
        push       ds
        push       si
        lds        si, [bp+6]            ; ds:si -> mode list
        xor        cx, cx                ; counter = 0
        
CountModes1:

        mov        ax, ds:[si]           ; read mode
        cmp        ax, 0ffffh            ; last entry?
        jz         CountModes2           ; yes: jump
        add        si, 2                 ; update pointers and counter
        inc        cx
        jmp        short CountModes1

CountModes2:

        mov        ax, cx                ; load function result
        pop        si
        pop        ds
        pop        bp
        ret        4
CountModes endp

; SUB CopyModes
; Purpose:         Read the mode list.
; Input:           [bp+6]  = pointer to mode list.
;                  [bp+10] = list length
;                  [bp+12] = offset mode array
;                  [bp+14] = segment mode array
; Output:          VESA mode list in array.
CopyModes proc far
        push       bp
        mov        bp, sp
        push       ds
        push       es
        push       di
        push       si
        lds        si, [bp+6]            ; ds:si -> source
        les        di, [bp+12]           ; es:di -> destination
        mov        cx, [bp+10]           ; cx = word counter

CopyModes1:

        mov        ax, ds:[si]           ; read mode
        mov        word ptr es:[di], ax  ; write mode
        add        si, 2                 ; update pointers
        add        di, 2 
        dec        cx                    ; update counter
        jnz        CopyModes1
        pop        si
        pop        di
        pop        es
        pop        ds
        pop        bp
        ret        10
CopyModes endp

; FUNCTION GetMIB
; Purpose:         Get Mode Info Block.
; Input:           [bp+6]  = offset Mode Info Block
;                  [bp+8]  = segment Mode Info Block
;                  [bp+10] = VESA mode
; Output:          TRUE    ===> Mode Info Block filled
;                  FALSE   ===> Function failed
GetMIB  proc far
        push       bp
        mov        bp, sp
        push       es
        push       di
        push       cx
        mov        ax, 4f01h             ; get mode information
        mov        cx, [bp+10]           ; cx = VESA Mode
        les        di, [bp+6]            ; es:di -> Mode Info Block
        int        10h                   ; transfer to VESA driver
        cmp        al, 4fh               ; function supported?
        jne        GetMIB2               ; no: jump
        or         ah, ah                ; function successful?
        jnz        GetMIB2               ; no: jump
        mov        ax, 1                 ; function result TRUE

GetMIB1:

        pop        cx
        pop        di
        pop        es
        pop        bp
        ret        6

GetMIB2:

        xor        ax, ax                ; function result FALSE
        jmp        short GetMIB1
GetMIB  endp

; SUB Text
; Purpose:         Set the text mode.
; Input:           None
; Output:          text mode
Text    proc far
        mov        ax, 0003h             ; ax = mode number
        int        10h                   ; transfer to BIOS
        ret
Text    endp

; FUNCTION SetVESAMode
; Purpose:         Set the appropriate VESA mode.
; Input:           [bp+6] = mode to set
; Output:          VESA mode
SetVESAMode proc far
        push       bp
        mov        bp, sp
        push       es
        push       di
        push       bx
        push       cx

        ; es:di -> Mode Info Block
 
        push       ds
        pop        es
        mov        di, offset mib.ModeAtt
        mov        cx, [bp+6]            ; cx = VESA Mode
        mov        ax, 4f01h             ; FUNCTION: get mode info
        int        10h                   ; get Mode Info Block again
        mov        bx, [bp+6]            ; bx = VESA Mode
        mov        ax, 4f02h             ; FUNCTION: set SVGA mode
        int        10h                   ; transfer to VESA
        cmp        al, 4fh               ; function supported?
        jne        SetVESAMode2          ; no: jump
        or         ah, ah                ; function successful?
        jnz        SetVESAMode3          ; no: jump
        xor        ax, ax                ; indicate success

SetVESAMode1:

        pop        cx
        pop        bx
        pop        di
        pop        es
        pop        bp
        ret        2

SetVESAMode2:

        mov        ax, 4                 ; function not supported
        jmp        short SetVESAMode1 

SetVESAMode3:

        mov        al, ah                ; load error number
        xor        ah, ah
        jmp        short SetVESAMode1 
SetVESAMode endp

; SUB SetSVGApixel
; Purpose:         Set a pixel in a 8 bit SVGA mode.
; Input:           [bp+6]  = color
;                  [bp+8]  = screen row
;                  [bp+10] = screen column
; Output:          Pixel at screen.
SetSVGAPixel proc far
        push       bp
        mov        bp, sp
        push       es
        push       di
        pushf
        cld                              ; set direction forward
        movzx      eax, [mib.bpsl]       ; eax = bytes per scan line (bpsl)
        movzx      edx, word ptr [bp+8]  ; edx = y (row)
        movzx      ebx, word ptr [bp+10] ; ebx = x (column)
        mul        edx                   ; edx:eax = y*bpsl
        add        eax, ebx              ; add column
        adc        edx, 0                ; add with carry
        movzx      ebx, [mib.WinGran]    ; granularity in KB
        shl        ebx, 10               ; ebx = granularity in byte
        div        ebx
        mov        di, dx                ; di = offset
        mov        dx, ax                ; dx = bank
        mov        es, [mib.WinaSeg]     ; es:di -> video RAM
        push       dx                    ; save bank
        sub        bx, bx                ; bh = 0 (set Window)
                                         ; bl = 0 (Window A)
        call       [mib.WinFuncPtr]      ; set Window A
        pop        dx                    ; restore bank
        mov        bl, 1                 ; bl = 1 (Window B)
        call       [mib.WinFuncPtr]      ; set Window B
        mov        ax, [bp+6]            ; al = color
        stosb                            ; set pixel
        popf
        pop        di
        pop        es
        pop        bp
        ret        6
SetSVGAPixel endp

; SUB CalcJ
; Purpose:         Calculates the values of the j-loop.
; Input:           [bp+6]  = address qimag
;                  [bp+10] = address qreal
;                  [bp+14] = zimag
;                  [bp+18] = zreal
; Output:          New values for qimag and qreal
CalcJ   proc far
        push       bp
        mov        bp, sp
        push       es
        push       bx
        push       cx
        les        bx, [bp+6]            ; es:bx -> qimag
        mov        cx, 13                ; cl = shift counter
        mov        eax, [bp+14]          ; eax = zimag
        imul       eax, eax              ; eax = zimag*zimag*m
        shr        eax, cl               ; eax = zimag*zimag/m
        mov        dword ptr es:[bx], eax; write new qimag
        les        bx, [bp+10]           ; es:bx -> qreal
        mov        eax, [bp+18]          ; eax = zreal
        imul       eax, eax              ; eax = zreal*zrel*m
        shr        eax, cl               ; eax = zreal*zreal/m
        mov        dword ptr es:[bx], eax; write new qreal
        pop        cx
        pop        bx
        pop        es
        pop        bp
        ret        16
CalcJ   endp

code16  ends
        end

