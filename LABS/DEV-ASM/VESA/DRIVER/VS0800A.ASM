.286  
  
CODE  SEGMENT BYTE PUBLIC  
      ASSUME CS:CODE  
  
;================================================;  
; Protel Graphics Driver: VESA 800x600 v1.01     ;  
;                                                ;  
; Copyright (c) Y.B.Chen                         ;  
; Email: ybchen@email.com.cn                     ;  
;================================================;  
  
public    GETDRIVERTYPE  
public    DRAW  
public    HLINE  
public    VLINE  
public    PLOTPIXEL  
public    READPIXEL  
public    CLEARGRAPH  
public    GRAPHMODE  
public    TEXTMODE1  
public    FULLCHAR  
public    FASTCHAR  
public    SAVEMENU  
public    LOADMENU  
public    XBIG  
public    YBIG  
public    BIGCOLORS  
public    BIGBACKCOLORS  
public    COLORSETS  
public    ARROWCURSOR  
public    SETBACKGROUND  
public    MENUMEMREQUIRED  
public    RAWPLOT  
public    ARC  
public    GETDRIVERNAME  
  
;*****************************************************************************  
; This Table is the external reference point for this driver. The order and  
; number of elements in it must not be changed or a program crash will result.  
;*****************************************************************************  
  
GETDRIVERTYPE:   JMP    _GETDRIVERTYPE  
DRAW:            JMP    _DRAW  
HLINE:           JMP    _HLINE  
VLINE:           JMP    _VLINE  
PLOTPIXEL:       JMP    _PLOTPIXEL  
READPIXEL:       JMP    _READPIXEL  
CLEARGRAPH:      JMP    _CLEARGRAPH  
GRAPHMODE:       JMP    _GRAPHMODE  
TEXTMODE1:       JMP    _TEXTMODE  
FULLCHAR:        JMP    _FULLCHAR  
FASTCHAR:        JMP    _FASTCHAR  
SAVEMENU:        JMP    _SAVEMENU  
LOADMENU:        JMP    _LOADMENU  
XBIG:            JMP    _XBIG  
YBIG:            JMP    _YBIG  
BIGCOLORS:       JMP    _BIGCOLORS  
BIGBACKCOLORS:   JMP    _BIGBACKCOLORS  
COLORSETS:       JMP    _COLORSETS  
ARROWCURSOR:     JMP    _ARROWCURSOR  
SETBACKGROUND:   JMP    _SETBACKGROUND  
MENUMEMREQUIRED: JMP    _MENUMEMREQUIRED  
RAWPLOT:         JMP    _RAWPLOT  
ARC:             JMP    _ARC  
  
; This gets all jumps tables and external/global definitions  
  
;*****************************************************************************  
; The Driver name below mus remain in the same position and have the same    ;  
; length between then quotes.                                                ;  
;*****************************************************************************  
  
GETDRIVERNAME    DB  32,'VESA 800x600 v1.01 - Y.B.Chen   '  
;________________________'~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~'  
  
MaxX          Equ 800          ;Number of Pix in X Direction  
MaxY          Equ 600          ;Number of Pix in Y Direction  
StatusLine    Equ 23           ;Number of Y Pix Reserved For Status Line  
MaxColors     Equ 15           ;Largest Color Number that the driver supports  
MaxBackColors Equ 15           ;Largest Background Color the driver supports  
MenuMem       Equ 320          ;Memory to store a screen menu (320*200)  
MaxSets       Equ 0            ;Number of available color sets  
GrMode        Equ 0103h        ;Graph Mode Number, 105h for 1024, 107h for 1280  
SaveSeg       Equ 8            ;12 for 1024, 20 for 1280  
  
INCLUDE GCOMMON.ASM  
;Gets RAWPLOT  
;     DRAW  
;     FASTCHAR  
;     FULLCHAR  
;     _PLOTPOINT  
;     _GETDRIVERTYPE  
;     _BIGCOLORS  
;     _BIGBACKCOLORS  
;     _XBIG  
;     _YBIG  
;     _COLORSETS  
  
;These routines are common for all graphics drivers  
  
;*************************************************;  
SetGraph Proc Near  
; This routines sets up the graphics system for  
; drawing. It Takes the color in SI and sets  
; segment registers and inits the hardware.  
;*************************************************;  
      mov     ax,0A000h;  
      mov     es,ax  
      or      si,si  
      jns     No_Xor  
  
      ;set to xor mode  
  
No_xor:  
      ret  
SetGraph Endp  
  
;*********************************************;  
ResetGraph proc Near                          ;  
; Resets the EGA hardware to state where an   ;  
; exit from the program would be acceptable.  ;  
; The Driver should always leave the hardware ;  
; in such a state.                            ;  
;*********************************************;  
      ; reset to normal (non xor) mode  
  
      ret  
ResetGraph endp  
  
;********************************************;  
_READPIXEL Proc NEAR                         ;  
; Return the color of the pixel at (Rpx,Rpy) ;  
; Return Ax = color                          ;  
;********************************************;  
Rpx   equ     [bp+6]  
Rpy   equ     [bp+4]  
  
      push    bp  
      mov     bp, sp  
      mov     ax, 0A000h  
      mov     es, ax  
  
      mov     ax, MaxX  
      mul     word ptr Rpy  
      add     ax, word ptr Rpx  
      adc     dx, 0            ;dx:ax = addr  
      call    setseg  
  
      mov     bx, ax  
      xor     ax, ax  
      mov     al, es:[bx]  
  
      pop     bp  
      ret     6  
_READPIXEL endp  
  
  
;*************************************;  
_CLEARGRAPH proc NEAR                 ;  
; Set all pixels on the screen to the ;  
; background color.                   ;  
;*************************************;  
       Call ResetGraph  
       mov  ax, 0a000h  
       mov  es, ax  
       mov  dx, SaveSeg  
  
clglp1:dec  dx  
       js   clrgend  
       call setseg  
       xor  ax, ax  
       xor  di, di  
       mov  cx, 8000h  
       cld  
       rep  stosw  
       jmp  clglp1  
  
clrgend:  
       ret  
_CLEARGRAPH endp  
  
;*********************************************  
_TEXTMODE proc NEAR                          ;  
; Places the graphics hardware into textmode ;  
;*********************************************  
      mov    ax,0003h  
      int    10h  
      ret  
_TEXTMODE endp  
  
;**********************************************;  
_GRAPHMODE proc NEAR                           ;  
; Places the graphics hardware into Graph Mode ;  
;**********************************************;  
      mov    ax,4f02h  ;set vesa mode  
      mov    bx,GrMode  
      int    10h  
      cmp    ax, 004fh  
      jne    GmEnd  
  
      call   GmInf  
GmInf:pop    bx                ;current ip value  
      sub    bx, offset GmInf  ;calc. how many bytes moved  
  
      mov    ax, cs  
      mov    es, ax  
      lea    di, MODEINF  
      add    di, bx            ;addr. adj  
      mov    cx, GrMode  
      mov    ax, 4f01h  
      int    10h  
      cmp    ax, 004fh  
      jne    GmEnd  
  
GmEnd:ret  
_GRAPHMODE endp  
  
;==============================================  
  
;*********************************************;  
_SAVEMENU proc NEAR                           ;  
; This routine saves the area of the top left ;  
; hand of the screen used to store data under ;  
; the pop-up menu.                            ;  
; The area is 320 pixels horizontal and 200   ;  
; pixels vertical                             ;  
; StoreOfs and storeSeg point to an area of   ;  
; memory where the screen data can be stored. ;  
;*********************************************;  
storeOfs equ [bp+6]  
storeSeg equ [bp+8]  
  
      push    ds  
      push    bp  
      mov     bp,sp  
  
      call    ResetGraph  
      call    smadj  
smadj:pop     ax  
      sub     ax, offset smadj  
      mov     bp, offset SMBUF   ;save menu buffer: SMBUF[MenuMem]  
      add     bp, ax             ;bp = buffer offset  
  
      xor     bx, bx             ;vram from  
      xor     di, di             ;vram to  
      mov     ax, cs  
      mov     ds, ax             ;data seg  
      mov     ax, 0a000h  
      mov     es, ax             ;vram seg  
  
      mov     cx, 200            ;200 lines  
      xor     dx, dx  
  
smlp0:push    cx  
      call    setseg  
  
      mov     si, bp             ;buffer ptr to save  
      mov     cx, MenuMem  
smlp1:mov     al, es:[bx]  
      mov     ds:[si], al  
      inc     si  
      inc     bx  
      jnz     smlx1  
      inc     dx  
      call    setseg  
smlx1:loop    smlp1  
  
      add     bx,MaxX-MenuMem    ;next line  
      jnc     smnla  
      inc     dx  
smnla:  
  
      push    dx  
        mov   dx,SaveSeg  
        call  setseg  
      pop     dx  
  
      mov     si, bp  
      mov     cx, MenuMem  
      rep     movsb  
      pop     cx  
      loop    smlp0  
  
      call    ResetGraph  
      pop     bp  
      pop     ds  
      ret     4  
_SAVEMENU endp  
  
  
;***********************************************;  
_LOADMENU proc NEAR                             ;  
; This routine retrives the stored screen data  ;  
; and places in into the area of the top left   ;  
; hand of the screen.                           ;  
; The area is 320 pixels horizontal and 200     ;  
; pixels vertical                               ;  
; LoadOfs and LoadSeg point to the area in mem  ;  
; where the data was stashed.                   ;  
;***********************************************;  
LoadOfs equ [bp+6]  
LoadSeg equ [bp+8]  
  
      push     ds  
      push     bp  
      mov      bp,sp  
  
      call     lmadj  
lmadj:pop      ax  
      sub      ax, offset lmadj  
      mov      bp, offset SMBUF  
      add      bp, ax           ;bp = buffer offset  
  
      xor      si, si           ;vram prt from  
      xor      bx, bx           ;vram prt to  
      mov      ax, cs  
      mov      es, ax           ;es = data seg  
      mov      ax, 0a000h  
      mov      ds, ax           ;dx = vram seg  
  
      mov      cx, 200  
      xor      dx, dx  
  
lmlp0:push     cx  
  
      push     dx  
        mov    dx, SaveSeg  
        call   setseg  
      pop      dx  
  
      mov      di, bp  
      mov      cx, MenuMem  
      rep      movsb  
  
      call     setseg  
  
      mov      cx, MenuMem  
      mov      di, bp  
lmlp1:mov      al, es:[di]      ;from temp. data buffer  
      mov      ds:[bx], al  
      inc      di  
      inc      bx  
      jnz      lmlx1  
      inc      dx  
      call     setseg  
lmlx1:loop     lmlp1  
  
      add      bx,MaxX-MenuMem  
      jnc      lmlx0  
      inc      dx  
lmlx0:pop      cx  
      loop     lmlp0  
  
      call    ResetGraph  
  
      pop     bp  
      pop     ds  
      ret     4  
_LOADMENU endp  
  
  
;*******************************************;  
_HLINE proc NEAR                            ;  
; Draws a horizontal line between 2 points  ;  
;(hlx1,hly) and (hlx2,hly)                  ;  
;*******************************************;  
hlx1    equ [bp+10]  
hlx2    equ [bp+8]  
hly equ [bp+6]  
hlcolor equ [bp+4]  
  
    push    bp  
    mov bp,sp  
  
        Mov     dx,hly       ;hly: 0..MaxY  
        cmp     dx,MaxY  
        jnb     Houtside  
  
HLtestx:Mov     cx,hlx1  
        cmp     cx,MaxX  
        jnb     Houtside  
        Mov     cx,hlx2  
        or      cx,0
        js      Houtside  
        Jmp     CoordsOK  
  
Houtside:jmp    Hfinish  
  
CoordsOK:  
        mov     cx, hlx1  
        or      cx, cx  
        jns     hl01  
        mov     word ptr hlx1, 0  
hl01:   mov     cx, MaxX-1  
        cmp     hlx2, cx  
        jbe     hl02  
        mov     word ptr hlx2, cx  
hl02:  
        mov     si,hlcolor      ;si = color  
        Call    SetGraph  
  
        mov     ax, hlx2  
        sub     ax, hlx1  
        jnz     HLbegin  
        inc     ax  
  
HLbegin:mov     cx, hlx1        ;x  
        mov     dx, hly         ;y  
        mov     si, hlcolor     ;c  
hllp1:  call    ppoint          ;(x,y,c) = cx, dx, si  
        inc     cx  
        dec     ax  
        jnz     hllp1  
  
Hfinish:call    ResetGraph  
    pop bp  
    ret     8  
_HLINE  endp  
  
  
;*******************************************;  
_VLINE proc NEAR                            ;  
; Draws a vertical line between 2 points    ;  
;(vlx,vly1) and (vlx,vly2)                  ;  
;********************************************  
vlx equ [bp+10]  
vly1    equ [bp+8]  
vly2    equ [bp+6]  
vlcolor equ [bp+4]  
  
    push    bp  
    mov bp,sp  
    mov si,vlcolor      ;si = color  
        Call    SetGraph  
  
        mov     ax, vly2  
        sub     ax, vly1  
        jnz     VLbegin  
        inc     ax  
  
VLbegin:mov     cx, vlx  
        mov     dx, vly1  
        mov     si, vlcolor  
vlppl1: call    ppoint          ;(x,y,c) = cx, dx, si  
        inc     dx  
        dec     ax  
        jnz     vlppl1  
  
Vfinish:call    ResetGraph  
    pop bp  
    ret     8  
_VLINE  endp  
  
;******************************************;  
_ARROWCURSOR proc NEAR                     ;  
; Draws a cursor on the screen at location ;  
; (acx,acy)                                ;  
;******************************************;  
acx   equ      [bp+6]  
acy   equ      [bp+4]  
      push     bp  
      mov      bp,sp  
  
      mov      si,-1  
      Call     SetGraph  
  
      mov     cx,acx                   ;get x  
      mov     dx,acy               ;get y  
  
      mov      bx,1                    ;y := 0  
      call     ArrowPoints  
  
      inc      dx                      ;y := 1  
      mov      bx,2  
      call     ArrowPoints  
  
      inc      dx                      ;y := 2  
      mov      bx,3  
      call     ArrowPoints  
  
      inc      dx                      ;y := 3  
      mov      bx,4  
      call     ArrowPoints  
  
      inc      dx                      ;y := 4  
      mov      bx,5  
      call     ArrowPoints  
  
      inc      dx                      ;y := 5  
      mov      bx,6  
      call     ArrowPoints  
  
      inc      dx                      ;y := 6  
      mov      bx,7  
      call     ArrowPoints  
  
      inc      dx                      ;y := 7  
      mov      bx,8  
      call     ArrowPoints  
  
      inc      dx                      ;y := 8  
      mov      bx,9  
      call     ArrowPoints  
  
      inc      dx                      ;y := 9  
      mov      bx,10  
      call     ArrowPoints  
  
      inc      dx                      ;y := 10  
      mov      bx,11  
      call     ArrowPoints  
  
      inc      dx                      ;y := 11  
      mov      bx,12  
      call     ArrowPoints  
  
      inc      dx                      ;y := 12  
      mov      bx,6  
      call     ArrowPoints  
  
      inc      dx                      ;y := 13  
      mov      bx,5  
      call     ArrowPoints  
  
      inc      dx                      ;y := 14  
      mov      bx,4  
      call     ArrowPoints  
  
      inc      dx                      ;y := 15  
      mov      bx,3  
      call     ArrowPoints  
  
      inc      dx                      ;y := 16  
      mov      bx,2  
      call     ArrowPoints  
  
      inc      dx                      ;y := 17  
      call     Point                   ;x := 0  
  
      call    ResetGraph  
      pop     bp  
      ret     4  
_ARROWCURSOR endp  
  
  
;*****************************************  
ArrowPoints Proc Near  
; Sub_Routine for ArrowCursor  
; X = cx  
; Yoffset = Dx  
; bx = count of x  
;*****************************************  
      Push    cx  
Ploop:  
      call    Point  
      inc     cx       ;next x  
      dec     bx  
      jnz     Ploop  
      pop     cx  
      ret  
ArrowPoints endp  
  
;********************************************************;  
_SETBACKGROUND Proc Near                                 ;  
; Sets the current background color to BackColor         ;  
; Procedure SetBackGround(BackColor,ColorSet : integer); ;  
;********************************************************;  
BackColor equ      [bp+6]  
ColorSet  equ      [bp+4]  
  
        push     bp  
        mov      bp,sp  
  
        mov cx, BackColor  
        cmp cx, 6  
        jne sbcl01  
        mov cx, 20  
        jmp sbcset  
  
sbcl01: cmp cx, 8  
        jb  sbcset  
        and cx, 0fh  
        add cx, 48  
  
sbcset: mov dx,3c7h  
        mov al,cl  
        out dx,al  
        inc dx  
        inc dx  
        in  al,dx  
        mov bh,al  
        in  al,dx  
        mov bl,al  
        in  al,dx  
        mov ah,al  
        dec dx  
        xor al,al  
        out dx,al  
        inc dx  
        mov al,bh  
        out dx,al  
        mov al,bl  
        out dx,al  
        mov al,ah  
        out dx,al  
  
        pop      bp  
        ret 4  
_SETBACKGROUND endp  
  
;********************************************;  
Point Proc Near                              ;  
; X = Cx                                     ;  
; Y = Dx                                     ;  
; SI = color                                 ;  
; Internal procedure called by Draw,PlotPixel;  
; and others to set a pixel to givan color.  ;  
; If the hardware can draw vectors DRAW may  ;  
; not need to call this routine.             ;  
;********************************************;  
      or      cx,0  
      js      outside  
      or      dx,0  
      js      outside  
      cmp     dx,MaxY-StatusLine       ;if y bigger than 329 then no carry  
      jnb     outside                  ;Jump if carry not set  
      cmp     cx,MaxX                  ;if x bigger than 639 then no carry  
      jnb     outside                  ;Jump if carry not set  
  
      call    ppoint  
outside:  
      ret  
Point endp  
  
  
;******************************************;  
TEXTPOINT Proc Near                        ;  
; X = Cx                                   ;  
; Y = Dx                                   ;  
; SI = color                               ;  
; Variation of point routine that allows   ;  
; plotting in the status line at the base  ;  
; of the screen.                           ;  
;******************************************;  
      or      cx,0  
      js      Toutside  
      or      dx,0  
      js      Toutside  
      cmp     dx,MaxY                  ;if y bigger then no carry  
      jnb     Toutside                 ;Jump if carry not set  
      cmp     cx,MaxX                  ;if x bigger then no carry  
      jnb     Toutside                 ;Jump if carry not set  
  
      call    ppoint  
Toutside:  
      ret  
TEXTPOINT endp  
  
;-------------------------------------------------  
ppoint proc near ; cx,dx,si  
;-------------------------------------------------  
       Push    dx  
       Push    cx  
       push    bx  
       push    ax  
  
       mov     ax, 0a000h  
       mov     es, ax  
       mov     ax, MaxX  
       mul     dx        ;y  
       mov     bx, cx    ;x  
       add     ax, bx    ;bx = offset  
       adc     dx, 0     ;dx:ax = address  
       call    setseg  
       mov     bx, ax  
       mov     ax, si  
        
       and     al,0fh  
       test    ah,80h  
       jnz     pptxor  
       mov     es:[bx],al  
       jmp     pptend  
pptxor:xor     es:[bx],al  
  
pptend:pop      ax  
       pop      bx  
       pop      cx  
       pop      dx  
  
       ret  
ppoint endp  
;-------------------------------------------------  
  
setseg proc near ;dx = VRAM seg (64k/seg)  
       push di  
       push ax  
  
       call coadj  
coadj: pop  di  
       sub  di, offset coadj  
  
       cmp  dx, cs:[di+WINSG]  
       je   ssend  
       mov  cs:[di+WINSG], dx  
  
       push bx  
       push cx  
       push dx  
  
       mov  ax, dx  
       xor  dx, dx  
       mov  bx, offset WinGranu  
       add  bx, di  
       mov  cx, cs:[bx]  
       shl  ax, 6                      ;AX *= 64  
       div  cx  
       mov  dx, ax                     ;DX = WinPos  
  
       ;-------------------------------------------  
       mov  al, cs:[di+WinAAttr]  
       test al, 1  
       jz   sswae  
       mov  bx, 0                      ;Select WinA  
       call dword ptr cs:[di+WinF5Ptr]  
sswae: ;-------------------------------------------  
       mov  al, cs:[di+WinBAttr]  
       test al, 1  
       jz   sswbe  
       mov  bx, 1                      ;Select WinB  
       call dword ptr cs:[di+WinF5Ptr]  
sswbe: ;-------------------------------------------  
  
       pop  dx  
       pop  cx  
       pop  bx  
  
ssend: pop  ax  
       pop  di  
       ret  
setseg endp  
;-------------------------------------------------  
  
WINSG    dw 0  
  
MODEINF label byte  
ModeAttr dw 0  
WinAAttr db 0  
WinBAttr db 0  
WinGranu dw 0  
WinSize  dw 0  
WinASeg  dw 0  
WinBSeg  dw 0  
WinF5Ptr dd 0  
LnBytes  dw 0  
  
SMBUF    db MenuMem dup(0)  
  
;-------------------------------------------------  
; Force the assembler to produce 4096 byte Binary file.  
;-------------------------------------------------  
  
CodeLength = $ - GETDRIVERTYPE  
db 4096-CodeLength DUP(0)  
  
CODE  ends  
      end                    