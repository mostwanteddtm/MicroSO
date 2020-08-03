;**************************************************************************** 
;* 
;*                         SuperVGA Test Library 
;* 
;*                  Copyright (C) 1993 SciTech Software 
;*                          All rights reserved. 
;* 
;* Filename:    $RCSfile: svga.asm $ 
;* Version:     $Revision: 1.2 $ 
;* 
;* Language:    80386 Assembler 
;* Environment: IBM PC (MS DOS) 
;* 
;* Description: Assembly language support routines for the SuperVGA test 
;*              library. 
;* 
;* $Id: svga.asm 1.2 1993/10/22 08:58:40 kjb release $ 
;* 
;**************************************************************************** 
 
        IDEAL 
        JUMPS 
        P386                    ; Use 386 instructions 
 
        MODEL   large 
 
CRTC            EQU 3D4h        ; Port of CRTC registers 
VGABufferSeg    EQU 0A000h      ; Segment of VGA display memory 
 
        DATASEG 
 
        COMM    _maxx:WORD 
        COMM    _maxy:WORD 
        COMM    _maxcolor:DWORD 
        COMM    _bytesperline:WORD 
        COMM    _pagesize:DWORD 
        COMM    _curBank:WORD 
        COMM    _bankSwitch:DWORD 
        COMM    _extendedflipping:WORD 
        COMM    _bankAdjust:WORD 
        COMM    _writeBank:DWORD; Relocated write bank routine 
        COMM    _readBank:DWORD ; Relocated read bank routine 
        COMM    _pageFlip:DWORD ; Relocated page flip routine 
 
OriginOffset    dw  0           ; Starting offset within bank 
BankOffset      dw  0           ; Starting bank in video memory 
 
        CODESEG 
 
MACRO   procstart name          ; Set up model independant proc 
PROC    name 
        PUBLIC name 
ENDM 
 
MACRO   procend name            ; End procedure macro 
ENDP    name 
ENDM 
 
;---------------------------------------------------------------------------- 
; void putPixel16(int x,int y,long color) 
;---------------------------------------------------------------------------- 
; Routine sets the value of a pixel in native VGA graphics modes. 
; 
; Entry:        x       -   X coordinate of pixel to draw 
;               y       -   Y coordinate of pixel to draw 
;               color   -   Color of pixel to draw 
; 
;---------------------------------------------------------------------------- 
procstart   __putPixel16 
 
        ARG     x:WORD, y:WORD, color:DWORD 
 
        push    bp                  ; Set up stack frame 
        mov     bp,sp 
 
; Compute the pixel's address in video buffer 
 
        mov     ax,[y] 
        mov     bx,[x] 
        mul     [_bytesPerLine]     ; DX:AX := y * BytesPerLine 
 
        mov     cl,bl               ; CL := low-order byte of x 
 
        shr     bx,3                ; BX := x/8 
        add     bx,ax 
        adc     dx,0                ; DX:BX := y*BytesPerLine + x/8 
        add     bx,[OriginOffset]   ; DX:BX := byte offset in video buffer 
        adc     dx,[BankOffset] 
 
        cmp     dl,[BYTE _curBank] 
        je      @@NoChange 
 
        mov     ax,dx 
        call    setBank 
 
@@NoChange: 
        mov     ax,VGABufferSeg 
        mov     es,ax               ; ES:BX := byte address of pixel 
 
        mov     ah,1                ; AH := unshifted bit mask 
        and     cl,7                ; CL := x & 7 
        xor     cl,7                ; CL := # bits to shift left 
 
; set Graphics Controller Bit Mask register 
 
        shl     ah,cl               ; AH := bit mask in proper postion 
        mov     dx,3CEh             ; GC address register port 
        mov     al,8                ; AL := Bit Mask Register number 
        out     dx,ax 
 
; set Graphics Controller Mode register 
 
        mov     ax,0205h            ; AL := Mode register number 
                                    ; AH := Write mode 2 (bits 0,1) 
                                    ;   Read mode 0 (bit 3) 
        out     dx,ax 
 
; set data rotate/Function Select register 
 
        mov     ax,3                ; AL := Data Rotate/Func select reg # 
        out     dx,ax 
 
; set the pixel value 
 
        mov     al,[es:bx]          ; latch one byte from each bit plane 
        mov     al,[BYTE color]     ; AL := pixel value 
        mov     [es:bx],al          ; update all bit planes 
 
; restore default Graphics Controller registers 
 
        mov     ax,0FF08h           ; default bit mask 
        out     dx,ax 
 
        mov     ax,0005             ; default mode register 
        out     dx,ax 
 
        mov     ax,0003             ; default function select 
        out     dx,ax 
 
        pop     bp 
        ret 
 
procend     __putPixel16 
 
;---------------------------------------------------------------------------- 
; void putPixel256(int x,int y,long color) 
;---------------------------------------------------------------------------- 
; Routine sets the value of a pixel in native VGA graphics modes. 
; 
; Entry:        x       -   X coordinate of pixel to draw 
;               y       -   Y coordinate of pixel to draw 
;               color   -   Color of pixel to draw 
; 
;---------------------------------------------------------------------------- 
procstart   __putPixel256 
 
        ARG     x:WORD, y:WORD, color:DWORD 
 
        push    bp                  ; Set up stack frame 
        mov     bp,sp 
 
        mov     ax,[y] 
        mul     [_bytesperline] 
        add     ax,[x] 
        adc     dx,0                ; DX:AX := y * BytesPerLine + x 
        add     ax,[OriginOffset] 
        adc     dl,[BYTE BankOffset]; DL := bank number 
        mov     bx,ax               ; BX := Offset in buffer 
        cmp     dl,[BYTE _curBank] 
        je      @@NoChange 
 
        mov     ax,dx 
        call    setBank 
 
@@NoChange: 
        mov     ax,VGABufferSeg 
        mov     es,ax               ; ES:BX := byte address of pixel 
        mov     al,[BYTE color] 
        mov     [es:bx],al          ; Replace the pixel 
        pop     bp 
        ret 
 
procend     __putPixel256 
 
;---------------------------------------------------------------------------- 
; void putPixel32k(int x,int y,long color) 
;---------------------------------------------------------------------------- 
; Routine sets the value of a pixel in native VGA graphics modes. 
; 
; Entry:        x       -   X coordinate of pixel to draw 
;               y       -   Y coordinate of pixel to draw 
;               color   -   Color of pixel to draw 
; 
;---------------------------------------------------------------------------- 
procstart   __putPixel32k 
 
        ARG     x:WORD, y:WORD, color:DWORD 
 
        push    bp                  ; Set up stack frame 
        mov     bp,sp 
 
        mov     ax,[y] 
        mul     [_bytesperline] 
        mov     bx,[x] 
        shl     bx,1 
        add     ax,bx 
        adc     dx,0                ; DX:AX := y * BytesPerLine + x * 2 
        add     ax,[OriginOffset] 
        adc     dl,[BYTE BankOffset]; DL := bank number 
        mov     bx,ax               ; BX := Offset in buffer 
        cmp     dl,[BYTE _curBank] 
        je      @@NoChange 
 
        mov     al,dl 
        call    setBank 
 
@@NoChange: 
        mov     ax,VGABufferSeg 
        mov     es,ax               ; ES:BX := byte address of pixel 
        mov     ax,[WORD color] 
        mov     [es:bx],ax          ; Replace the pixel 
        pop     bp 
        ret 
 
procend     __putPixel32k 
 
;---------------------------------------------------------------------------- 
; void putPixel64k(int x,int y,long color) 
;---------------------------------------------------------------------------- 
; Routine sets the value of a pixel in native VGA graphics modes. 
; 
; Entry:        x       -   X coordinate of pixel to draw 
;               y       -   Y coordinate of pixel to draw 
;               color   -   Color of pixel to draw 
; 
;---------------------------------------------------------------------------- 
procstart   __putPixel64k 
 
        ARG     x:WORD, y:WORD, color:DWORD 
 
        push    bp                  ; Set up stack frame 
        mov     bp,sp 
 
        mov     ax,[y] 
        mul     [_bytesperline] 
        mov     bx,[x] 
        shl     bx,1 
        add     ax,bx 
        adc     dx,0                ; DX:AX := y * BytesPerLine + x * 2 
        add     ax,[OriginOffset] 
        adc     dl,[BYTE BankOffset]; DL := bank number 
        mov     bx,ax               ; BX := Offset in buffer 
        cmp     dl,[BYTE _curBank] 
        je      @@NoChange 
 
        mov     al,dl 
        call    setBank 
 
@@NoChange: 
        mov     ax,VGABufferSeg 
        mov     es,ax               ; ES:BX := byte address of pixel 
        mov     ax,[WORD color] 
        mov     [es:bx],ax          ; Replace the pixel 
        pop     bp 
        ret 
 
procend     __putPixel64k 
 
;---------------------------------------------------------------------------- 
; void putPixel16m(int x,int y,long color) 
;---------------------------------------------------------------------------- 
; Routine sets the value of a pixel in native VGA graphics modes. 
; 
; Entry:        x       -   X coordinate of pixel to draw 
;               y       -   Y coordinate of pixel to draw 
;               color   -   Color of pixel to draw 
; 
;---------------------------------------------------------------------------- 
procstart   __putPixel16m 
 
        ARG     x:WORD, y:WORD, color:DWORD 
 
        push    bp                  ; Set up stack frame 
        mov     bp,sp 
 
        mov     ax,[y] 
        mul     [_bytesperline] 
        mov     bx,[x] 
        add     ax,bx 
        adc     dx,0 
        shl     bx,1 
        add     ax,bx 
        adc     dx,0                ; DX:AX := y * BytesPerLine + x * 3 
        add     ax,[OriginOffset] 
        adc     dl,[BYTE BankOffset]; DL := bank number 
        mov     bx,ax               ; BX := Offset in buffer 
        cmp     dl,[BYTE _curBank] 
        je      @@NoChange 
 
        mov     al,dl 
        call    setBank 
 
@@NoChange: 
        mov     ax,VGABufferSeg 
        mov     es,ax               ; ES:BX := byte address of pixel 
        mov     al,[BYTE color] 
        mov     [es:bx],al          ; Replace the first byte 
        cmp     bx,0FFFFh 
        jne     @@NotSplit1 
 
; Arrghh!! We have a case where a single pixel can be split across a 
; bank boundary, if the bytes per line value is 1920. This can cause the 
; machine to hang (and produce strange pixels). 
 
        inc     dl 
        mov     al,dl 
        call    setBank         ; Change video banks 
 
@@NotSplit1: 
        mov     al,[BYTE color+1] 
        mov     [es:bx+1],al        ; Replace the middle 
        cmp     bx,0FFFEh 
        jne     @@NotSplit2 
 
        inc     dl 
        mov     al,dl 
        call    setBank     ; Change video banks 
 
@@NotSplit2: 
        mov     al,[BYTE color+2] 
        mov     [es:bx+2],al        ; Replace the last byte 
        pop     bp 
        ret 
 
procend     __putPixel16m 
 
;---------------------------------------------------------------------------- 
; void clear16(void) 
;---------------------------------------------------------------------------- 
; Routine to clear the screen. Works even if the display contains more than 
; one bank, so will work for 1024x768 and 1280x1024 video modes. 
;---------------------------------------------------------------------------- 
procstart   __clear16 
 
        push    bp                  ; Set up stack frame 
        mov     bp,sp 
        push    si                  ; Save registers 
        push    di 
 
; Setup graphics controller 
 
        mov     dx,3CEh             ; DX := Graphics Controller I/O port 
 
        mov     ah,0                ; AH := Background color 
        xor     al,al               ; AL := 0 (Set/Reset register number) 
        out     dx,ax               ; load set/reset register 
 
        mov     ax,0F01h            ; AH := 1111b (mask for Enable set/reset) 
                                    ; AL := 1 (enable Set/reset reg number) 
        out     dx,ax               ; load enable set/reset reg 
 
        mov     ax,[_maxy] 
        inc     ax 
        mul     [_bytesperline]     ; DX:AX := number of bytes to fill 
        mov     bx,ax               ; BX := bytes in last bank to fill 
        mov     dh,dl               ; DH := number of full banks to fill 
 
        mov     ax,VGABufferSeg 
        mov     es,ax 
        mov     di,[OriginOffset]   ; ES:DI -> video buffer 
        mov     ax,[BankOffset]     ; AX := starting bank number 
        cld                         ; Moves go up in memory 
 
        or      dh,dh               ; More than one bank to fill? 
        jz      @@SingleBank        ; No, only fill a single bank 
 
; Fill all of the full 64k banks first 
 
@@OuterLoop: 
        call    setBank 
        mov     cx,4000h            ; Need to set 4000h double words per bank 
    rep stosd 
        inc     al 
        dec     dh 
        jnz     @@OuterLoop 
 
; Now fill the last partial bank 
 
@@SingleBank: 
        call    setBank 
        mov     cx,bx 
        shr     cx,2                ; CX := number of double words to set 
    rep stosd 
 
; Restore graphics controller 
 
        mov     dx,3CEh             ; DX := Graphics Controller I/O port 
        xor     ax,ax               ; AH := 0, AL := 0 
        out     dx,ax               ; Restore default Set/Reset register 
 
        inc     ax                  ; AH := 0, AL := 1 
        out     dx,ax               ; Restore enable Set/Reset register 
 
        pop     di 
        pop     si 
        pop     bp 
        ret 
 
procend     __clear16 
 
;---------------------------------------------------------------------------- 
; void clear256(void) 
;---------------------------------------------------------------------------- 
; Routine to clear the screen. Assumes pages begin on bank boundaries 
; for simplicity of coding. 
;---------------------------------------------------------------------------- 
procstart   __clear256 
 
        push    di 
        mov     ax,[_maxy] 
        inc     ax 
        mul     [_bytesperline]     ; DX:AX := number of bytes to fill 
        mov     bx,ax               ; BX := bytes in last bank to fill 
        mov     dh,dl               ; DH := number of full banks to fill 
 
        mov     ax,VGABufferSeg 
        mov     es,ax 
        mov     di,[OriginOffset]   ; ES:DI -> video buffer 
        mov     dl,[BYTE BankOffset]; DL := starting bank number 
        cld                         ; Moves go up in memory 
 
        or      dh,dh               ; More than one bank to fill? 
        jz      @@SingleBank        ; No, only fill a single bank 
 
; Fill all of the full 64k banks first 
 
@@OuterLoop: 
        mov     al,dl 
        call    setBank 
        xor     eax,eax             ; Clear to black 
        mov     cx,4000h            ; Need to set 4000h double words per bank 
    rep stosd 
        inc     dl 
        dec     dh 
        jnz     @@OuterLoop 
 
; Now fill the last partial bank 
 
@@SingleBank: 
        mov     al,dl 
        call    setBank 
        xor     eax,eax             ; Clear to black 
        mov     cx,bx 
        shr     cx,2                ; CX := number of double words to set 
    rep stosd 
 
        pop     di 
        ret 
 
procend     __clear256 
 
;---------------------------------------------------------------------------- 
; void clear32k(void) 
;---------------------------------------------------------------------------- 
; Routine to clear the screen. Assumes pages begin on bank boundaries 
; for simplicity of coding. 
;---------------------------------------------------------------------------- 
procstart   __clear32k 
 
        push    di 
        mov     ax,[_maxy] 
        inc     ax 
        mul     [_bytesperline]     ; DX:AX := number of bytes to fill 
        mov     bx,ax               ; BX := bytes in last bank to fill 
        mov     dh,dl               ; DH := number of full banks to fill 
 
        mov     ax,VGABufferSeg 
        mov     es,ax 
        mov     di,[OriginOffset]   ; ES:DI -> video buffer 
        mov     dl,[BYTE BankOffset]; DL := starting bank number 
        cld                         ; Moves go up in memory 
 
; Fill all of the full 64k banks first 
 
@@OuterLoop: 
        mov     al,dl 
        call    setBank 
        xor     eax,eax             ; Clear to black 
        mov     cx,4000h            ; Need to set 4000h double words per bank 
    rep stosd 
        inc     dl 
        dec     dh 
        jnz     @@OuterLoop 
 
; Now fill the last partial bank 
 
        mov     al,dl 
        call    setBank 
        xor     eax,eax             ; Clear to black 
        mov     cx,bx 
        shr     cx,2                ; CX := number of double words to set 
    rep stosd 
 
        pop     di 
        ret 
 
procend     __clear32k 
 
;---------------------------------------------------------------------------- 
; void clear64k(void) 
;---------------------------------------------------------------------------- 
; Routine to clear the screen. Assumes pages begin on bank boundaries 
; for simplicity of coding. 
;---------------------------------------------------------------------------- 
procstart   __clear64k 
 
        push    di 
        mov     ax,[_maxy] 
        inc     ax 
        mul     [_bytesperline]     ; DX:AX := number of bytes to fill 
        mov     bx,ax               ; BX := bytes in last bank to fill 
        mov     dh,dl               ; DH := number of full banks to fill 
 
        mov     ax,VGABufferSeg 
        mov     es,ax 
        mov     di,[OriginOffset]   ; ES:DI -> video buffer 
        mov     dl,[BYTE BankOffset]; DL := starting bank number 
        cld                         ; Moves go up in memory 
 
; Fill all of the full 64k banks first 
 
@@OuterLoop: 
        mov     al,dl 
        call    setBank 
        xor     eax,eax             ; Clear to black 
        mov     cx,4000h            ; Need to set 4000h double words per bank 
    rep stosd 
        inc     dl 
        dec     dh 
        jnz     @@OuterLoop 
 
; Now fill the last partial bank 
 
        mov     al,dl 
        call    setBank 
        xor     eax,eax             ; Clear to black 
        mov     cx,bx 
        shr     cx,2                ; CX := number of double words to set 
    rep stosd 
 
        pop     di 
        ret 
 
procend     __clear64k 
 
;---------------------------------------------------------------------------- 
; void clear16m(void) 
;---------------------------------------------------------------------------- 
; Routine to clear the screen. Assumes pages begin on bank boundaries 
; for simplicity of coding. 
;---------------------------------------------------------------------------- 
procstart   __clear16m 
 
        push    di 
        mov     ax,[_maxy] 
        inc     ax 
        mul     [_bytesperline]     ; DX:AX := number of bytes to fill 
        mov     bx,ax               ; BX := bytes in last bank to fill 
        mov     dh,dl               ; DH := number of full banks to fill 
 
        mov     ax,VGABufferSeg 
        mov     es,ax 
        xor     di,di               ; ES:DI -> video buffer 
        mov     dl,[BYTE BankOffset]; DL := starting bank number 
        cld                         ; Moves go up in memory 
 
; Fill all of the full 64k banks first 
 
@@OuterLoop: 
        mov     al,dl 
        call    setBank 
        xor     eax,eax             ; Clear to black 
        mov     cx,4000h            ; Need to set 4000h double words per bank 
    rep stosd 
        inc     dl 
        dec     dh 
        jnz     @@OuterLoop 
 
; Now fill the last partial bank 
 
        mov     al,dl 
        call    setBank 
        xor     eax,eax             ; Clear to black 
        mov     cx,bx 
        shr     cx,2                ; CX := number of double words to set 
    rep stosd 
 
        pop     di 
        ret 
 
procend     __clear16m 
 
;---------------------------------------------------------------------------- 
; void _copyTest16(void) 
;---------------------------------------------------------------------------- 
; Routine to copy the top half of video memory to the bottom half of 
; video memory. To ensure that we a moving across a bank boundary in 
; 16 color modes, we copy the data to the second video page. 
;---------------------------------------------------------------------------- 
procstart   __copyTest16 
 
        push    si                  ; Save registers 
        push    di 
        push    ds 
 
        mov     ax,[_maxy] 
        inc     ax 
        shr     ax,1                ; AX := (Yres+1) / 2 
        mul     [_bytesperline] 
        mov     cx,ax               ; CX := Number of bytes to move 
 
; Set up graphics controller 
 
        mov     dx,3CEh             ; DX := Graphics Controller address port 
        mov     ax,0105h            ; AH := 1 (read mode 0, write mode 1) 
                                    ; AL := 5 (Mode register number) 
        out     dx,ax               ; Set up mode 
 
        mov     di,[WORD _pagesize] ; ES:DI := offset into destination buffer 
        mov     ax,[WORD _pagesize+2] 
        add     di,cx 
        adc     al,0 
        call    setBank             ; Set the read/write bank number 
 
        xor     si,si               ; DS:SI := offset into source buffer 
        xor     ax,ax 
        call    setReadBank         ; Set the read bank number 
 
        mov     ax,VGABufferSeg 
        mov     ds,ax               ; DS:SI -> source buffer 
        mov     es,ax               ; ES:DI -> destination buffer 
        cld                         ; Moves go up in memory 
 
    rep movsb                       ; Move all data in bank FAST! 
 
; Restore default graphics controller state 
 
        mov     ax,0005h            ; default mode register value 
        out     dx,ax 
 
        pop     ds 
        pop     di 
        pop     si 
        ret 
 
procend     __copyTest16 
 
;---------------------------------------------------------------------------- 
; void _copyTest256(void) 
;---------------------------------------------------------------------------- 
; Routine to copy the top half of video memory to the bottom half of 
; video memory, to test moving data across bank boundaries using separate 
; read/write banks. To simplify the coding we move the first 100 scan 
; lines down to start at scanline 205. This ensure allows us to move data 
; from bank 0 to bank 2 in 640x??? display modes. 
;---------------------------------------------------------------------------- 
procstart   __copyTest256 
 
        push    si                  ; Save registers 
        push    di 
        push    ds 
 
        mov     ax,100 
        mul     [_bytesperline] 
        mov     cx,ax               ; CX := Number of bytes to move 
        shr     cx,1                ; CX := Number of words to move 
 
        mov     ax,205 
        mul     [_bytesperline] 
        mov     di,ax               ; DI := offset into destination bank 
        mov     al,dl 
        call    setBank             ; Set the read/write bank number 
 
        xor     si,si               ; DS:SI := offset into source buffer 
        xor     al,al 
        call    setReadBank         ; Set the read bank number 
 
        mov     ax,VGABufferSeg 
        mov     ds,ax               ; DS:SI -> source buffer 
        mov     es,ax               ; ES:DI -> destination buffer 
        cld                         ; Moves go up in memory 
 
    rep movsw                       ; Move all data in bank FAST! 
 
        pop     ds 
        pop     di 
        pop     si 
        ret 
 
procend     __copyTest256 
 
;---------------------------------------------------------------------------- 
; void setActivePage(int which) 
;---------------------------------------------------------------------------- 
; Routine to set the video page for active output. 
; 
; Entry:        page    - Page number of page to use 
; 
;---------------------------------------------------------------------------- 
procstart   _setActivePage 
 
        ARG     which:WORD 
 
        push    bp                  ; Set up stack frame 
        mov     bp,sp 
 
; Calculate 18 bit address of page in video memory 
 
        xor     eax,eax 
        mov     ax,[which]          ; EAX := page number 
        mul     [_pagesize]         ; EDX:EAX := result 
        mov     [OriginOffset],ax   ; Save video buffer offset 
        shr     eax,16 
        mov     [BankOffset],ax     ; Save video bank offset 
 
        pop     bp 
        ret 
 
procend     _setActivePage 
 
;---------------------------------------------------------------------------- 
; void setVisualPage(int which) 
;---------------------------------------------------------------------------- 
; Routine to set the visible video page. 
; 
; Entry:        page    - Page number of page to use 
; 
;---------------------------------------------------------------------------- 
procstart       _setVisualPage 
 
        ARG     which:WORD 
 
        push    bp                  ; Set up stack frame 
        mov     bp,sp 
        push    si 
 
; Calculate 18 bit address of page in video memory 
 
        xor     eax,eax 
        mov     ax,[which]          ; EAX := page number 
        mul     [_pagesize]         ; EAX := starting address in memory 
        mov     edx,eax 
        shr     edx,16              ; DX:AX := starting address in memory 
 
        cmp     [_extendedflipping],0 
        je      @@VGAFlip           ; We have no extended page flipping 
 
        cmp     [WORD _pageFlip+2],0 
        je      @@VBEFlip 
 
; Set up to call the relocated version of the page flip routine loaded 
; on the heap. This allows us to bypass the int10h interface for speed 
; (well, not much different in real mode, but in protected mode this 
; will be significant). 
 
        cmp     [WORD _maxColor],15 
        je      @@Colors16 
        shr     eax,2               ; Adjust to lie on plane boundary 
        mov     edx,eax 
        shr     edx,16              ; DX:AX := starting address in memory 
 
@@Colors16: 
        push    dx                  ; Save top bits of address 
 
; Wait for display enable to be active (active low), to be sure that 
; both halves of the start address will take place in one frame. We 
; preload a few values here to save time after the DE has been 
; detected. 
 
        mov     cl,0Ch              ; CL := Start Address High register 
        mov     ch,ah               ; CH := high byte of new address 
        mov     bh,al               ; BH := low byte of new address 
        mov     bl,0Dh              ; BL := Start Address Low register 
        mov     dx,03DAh            ; DX := video status port 
 
@@WaitDE: 
        in      al,dx 
        test    al,1 
        jnz     @@WaitDE            ; Wait for Display Enable 
 
        cli 
        pop     si                  ; SI := Bits 16+ for SuperVGA's 
        call    [_pageFlip]         ; Program the start address 
        sti 
        jmp     @@Done 
 
@@VBEFlip: 
        div     [_bytesperline]     ; AX := starting scanline, 
                                    ; DX := starting byte 
        mov     cx,dx 
        cmp     [WORD _maxcolor],0Fh 
        je      @@16Color 
        cmp     [WORD _maxcolor],0FFh 
        je      @@SetIt 
        cmp     [WORD _maxcolor+2],0FFh 
        je      @@16MColor 
 
        shr     cx,1                ; CX := starting pixel in buffer 
        jmp     @@SetIt 
 
@@16Color: 
        shl     cx,3                ; CX := starting pixel in buffer 
        jmp     @@SetIt 
 
@@16MColor: 
        xor     dx,dx 
        mov     ax,cx 
        mov     cx,3 
        div     cx 
        mov     cx,ax               ; CX := starting pixel in buffer 
 
@@SetIt: 
        mov     bx,ax               ; BX := starting scanline in buffer 
 
; Wait for display enable to be active (active low), to be sure that 
; both halves of the start address will take place in one frame. 
 
        mov     dx,03DAh            ; DX := video status port 
 
@@WaitDEVBE: 
        in      al,dx 
        test    al,1 
        jnz     @@WaitDEVBE         ; Wait for Display Enable 
 
        mov     ax,04F07h 
        mov     dx,bx               ; DX := starting scanline number 
        xor     bx,bx               ; BX := 0 - set display start 
        int     10h                 ; Set the display start address 
        jmp     @@Done 
 
@@VGAFlip: 
        mov     bx,ax               ; BX := bottom 16 bits of address 
 
 
; Wait for display enable to be active (active low), to be sure that 
; both halves of the start address will take place in one frame. We 
; preload a few values here to save time after the DE has been 
; detected. 
 
        mov     cl,0Ch              ; CL := Start Address High register 
        mov     ch,bh               ; CH := high byte of new address 
        mov     bh,bl               ; BH := low byte of new address 
        mov     bl,0Dh              ; BL := Start Address Low register 
        mov     dx,03DAh            ; DX := video status port 
 
@@WaitDEVGA: 
        in      al,dx 
        test    al,1 
        jnz     @@WaitDEVGA         ; Wait for Display Enable 
 
        cli 
        mov     dx,03D4h            ; DX := CRTC I/O port (3D4h) 
        mov     ax,bx 
        out     dx,ax 
        mov     ax,cx 
        out     dx,ax 
        sti 
 
; Now wait for the start of the vertical sync, to ensure that the old 
; page will be invisible before anything is drawn on it. 
 
@@Done: 
        mov     dx,03DAh            ; DX := video status port 
@@WaitStartVert: 
        in      al,dx               ; Wait for start of vertical retrace 
        test    al,8 
        jz      @@WaitStartVert 
 
@@Exit: 
        pop     si 
        pop     bp 
        ret 
 
procend     _setVisualPage 
 
;---------------------------------------------------------------------------- 
; setBank   Sets the read/write bank from assembly language 
;---------------------------------------------------------------------------- 
; 
; Entry:        AX  - New read/write bank number 
; 
; Exit:         AX  - New read/write bank number 
; 
; Registers:    All preserved! 
; 
;---------------------------------------------------------------------------- 
procstart   setBank 
 
        mov     [_curBank],ax       ; Save current write bank number 
        cmp     [WORD _writeBank+2],0 
        je      @@VESABank 
        call    [_writeBank]        ; Call relocated version 
        ret 
 
@@VESABank: 
        push    ax 
        push    bx 
        push    dx 
        mul     [_bankAdjust]       ; Adjust to VESA granularity 
        push    ax 
        mov     dx,ax               ; DX := bank number 
        xor     bx,bx               ; BX := select window A 
        call    [_bankSwitch]       ; Set write window 
 
; Note that some VESA BIOSes and TSR's set the first window to be 
; write only and the second window to be read only, so we need to set both 
; windows for most common operations to the same value. The Universal 
; VESA VBE sets both the read and write banks to the same value for 
; Window A, and changed the read bank only for Window B, hence the second 
; call is _not_ required when the Universal VESA VBE is installed. You can 
; determine what the window does by looking at the WindowAAttributes in 
; the SuperVGAInfo block returned by function 00h. You could use this 
; information to optimise bank switching when using faster VBE's like 
; the Universal VESA VBE (but I have no bothered to do that here). 
 
        pop     dx 
        inc     bx 
        call    [_bankSwitch]       ; Set read window 
        pop     dx 
        pop     bx 
        pop     ax 
        ret 
 
procend     setBank 
 
;---------------------------------------------------------------------------- 
; setReadBank   Sets the read bank from assembly language 
;---------------------------------------------------------------------------- 
; 
; Entry:        AX  - New read bank number 
; 
; Exit:         AX  - New read bank number 
; 
; Registers:    All preserved! 
; 
;---------------------------------------------------------------------------- 
procstart   setReadBank 
 
        mov     [_curBank],-1       ; Ensure banking will be re-loaded 
        cmp     [WORD _readBank+2],0 
        je      @@VESABank 
        call    [_readBank]         ; Call relocated version 
        ret 
 
@@VESABank: 
        push    ax 
        push    bx 
        push    dx 
        mov     dx,ax               ; DX := bank number 
        mov     bx,1                ; BX := select window B 
        call    [_bankSwitch] 
        pop     dx 
        pop     bx 
        pop     ax 
        ret 
 
procend     setReadBank 
 
;---------------------------------------------------------------------------- 
; void setBank(int bank) 
;---------------------------------------------------------------------------- 
; Sets the new read/write bank number from C 
;---------------------------------------------------------------------------- 
procstart   _setBank 
 
        ARG     bank:WORD 
 
        push    bp 
        mov     bp,sp 
        mov     ax,[bank] 
        call    setBank 
        pop     bp 
        ret 
 
procend     _setBank 
 
;---------------------------------------------------------------------------- 
; void setReadBank(int bank) 
;---------------------------------------------------------------------------- 
; Sets the new reading bank number from C 
;---------------------------------------------------------------------------- 
procstart   _setReadBank 
 
        ARG     bank:WORD 
 
        push    bp 
        mov     bp,sp 
        mov     ax,[bank] 
        call    setReadBank 
        pop     bp 
        ret 
 
procend     _setReadBank 
 
;---------------------------------------------------------------------------- 
; void *getFontVec(void) 
;---------------------------------------------------------------------------- 
; Gets a pointer to the currently installed bitmap font from the BIOS. 
;---------------------------------------------------------------------------- 
procstart   _getFontVec 
 
        push    bp 
        mov     ax,1130h 
        mov     bx,0600h 
        int     10h 
        mov     dx,es 
        mov     ax,bp               ; DX:AX -> installed font 
        pop     bp 
        ret 
 
procend     _getFontVec 
 
        END 