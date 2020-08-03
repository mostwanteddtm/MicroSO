;********************************************; 
_PLOTPIXEL proc NEAR                         ; 
; Turn on the pixel at (px,py) and set it to ; 
; color Pcolor                               ; 
;********************************************; 
px	equ	[bp+8] 
py	equ	[bp+6] 
pcolor 	equ	[bp+4] 
 
	push	bp 
	mov	bp,sp 
	mov	si,pcolor 
        call    SetGraph 
	mov	Dx,py 
	mov	Cx,px 
 
	call	Point 
	call	ResetGraph 
	pop	bp 
	ret     6 
_PLOTPIXEL endp 
 
 
;*************************************************; 
_RAWPLOT proc Near                                ; 
; Point plotting routine called by other routines ; 
; in the high level and other ASM modules.        ; 
; X = Cx                                          ; 
; Y = Dx                                          ; 
; SI = color                                      ; 
; called for bitmap routine in pascal zoom := 1   ; 
;*************************************************; 
      push    ax 
      push    bx 
      push    cx 
      push    dx 
 
      Call    SetGraph 
      call    point 
      call    ResetGraph 
 
      pop     dx 
      pop     cx 
      pop     bx 
      pop     ax 
      ret 
_RAWPLOT endp 
 
 
;*********************************************; 
_DRAW proc NEAR                               ; 
; Use Bresenhams line drawing algorithmn do   ; 
; draw a line between (x1,y1) and (x2,y2). No ; 
; assumptions about the slope of the line are ; 
; made.                                       ; 
;Procedure Draw(x1,y1,x2,y2,color:integer);   ; 
;*********************************************; 
x1	equ	[bp+12] 
y1	equ	[bp+10] 
x2	equ	[bp+8] 
y2	equ	[bp+6] 
dcolor	equ	[bp+4] 
deltax	equ	[bp-2] 
deltay	equ	[bp-4] 
incr1	equ	[bp-6] 
incr2	equ	[bp-8] 
incr3	equ	[bp-10] 
xend	equ	[bp-12] 
yend	equ	[bp-14] 
 
	push	bp 
	mov	bp,sp 
	sub	sp,14 
 
	mov	si,dcolor	;si = color 
        call    SetGraph 
	mov	ax,y2		;get y2 
	sub	ax,y1		;y2 := y2 - y1 
	jns	noychang	;jump if y2 > y1 
	neg	ax 
noychang: 
	mov	deltay,ax	;save deltay 
 
	mov	ax,x2		;get x2 
	sub	ax,x1		;x2 := x2 - x1 
	jns	noxchang	;jump if x2 > x1 
	neg	ax 
noxchang: 
	mov	deltax,ax	;save deltax 
	cmp	ax,deltay	;jump if abs(deltax) > abs(deltay) 
	jg	firstLoop 
	jmp	secLoop 
 
FirstLoop: 
	mov	ax,x1	 
	cmp	ax,x2		;jump if x1 <= x2 
	jle	biggerx 
	mov	cx,x2		;x := x2 
	mov	dx,y2		;y := y2 
	mov	ax,x1 
	mov	Xend,ax		;xend := x1 
	mov	ax,y1 
	sub	ax,y2		;Deltay = y1-y2 
	mov	Deltay,ax 
	Jmp short Fin1 
biggerx: 
	mov	cx,x1		;x = x1 
	mov	dx,y1		;y = y1 
	mov	ax,x2 
	mov	Xend,ax		;xend := x2 
	mov	ax,y2 
	sub	ax,y1		;Deltay = y2-y1 
	mov	Deltay,ax 
Fin1: 
	shl	ax,1 
	mov	incr1,ax	;Incr1 := (deltay shl 1) 
	sub	ax,Deltax 
	mov	di,ax		;Dirc := (deltay shl 1) - deltax 
	mov	ax,deltay 
	sub	ax,deltax 
	shl	ax,1 
	mov	incr2,ax	;incr2 := (deltay-deltax) shl 1 
	mov	ax,deltay 
	add	ax,deltax 
	shl	ax,1 
	mov	incr3,ax	;incr3 := (deltay+deltax) shl 1 
 
	call	point 
main: 
	cmp	cx,xend 
	jge	finishF		;jump if x >= xend 
 
	inc	cx		;x := x + 1 
	cmp	di,0 
	jl	pt2		;jump if dirc < 0 
 
pt1:	mov	ax,deltay 
	cmp	ax,0		;Jump if deltay > 0 
	jg	part11 
	add	di,incr1 
	Jmp short endloop 
part11: 
	inc	dx		;y := y +1; 
	add	di,incr2 
	Jmp short endloop 
 
pt2:	mov	ax,deltay 
	cmp	ax,0		;Jump if deltay < 0 
	jl	part21 
	add	di,incr1	;dirc := dirc + incr1 
	Jmp short endloop 
part21: 
	dec	dx		;y := y - 1; 
	add	di,incr3	;dirc := dirc + incr3 
endloop: 
	call	point 
	Jmp short main 
 
FinishF: 
	jmp	Finish 
 
SecLoop: 
	mov	ax,y1		;ax = y1 
	cmp	ax,y2		;jump	if y1 <= y2 
	jle	biggerx2 
	mov	cx,x2  		;x := x2 
	mov	dx,y2  		;y := y2 
	mov	ax,y1 
	mov	Yend,ax		;Yend := Y1 
	mov	ax,x1 
	sub	ax,x2  		;Deltax = x1-x2 
	mov	Deltax,ax 
	Jmp short Fin2 
biggerx2: 
	mov	cx,x1  		;x = x1 
	mov	dx,y1  		;y = y1 
	mov	ax,y2 
	mov	Yend,ax		;Yend := Y2 
	mov	ax,x2 
	sub	ax,x1  		;Deltax = x2-x1 
	mov	Deltax,ax 
Fin2: 
	shl	ax,1 
	mov	incr1,ax   	;Incr1 := (deltax shl 1) 
	sub	ax,Deltay 
	mov	di,ax		;Dirc := (deltax shl 1) - deltay 
	mov	ax,deltax 
	sub	ax,deltay 
	shl	ax,1 
	mov	incr2,ax   	;incr2 := (deltax-deltay) shl 1 
	mov	ax,deltax 
	add	ax,deltay 
	shl	ax,1 
	mov	incr3,ax   	;incr3 := (deltax+deltay) shl 1 
 
	call	point 
main2: 
	cmp	dx,yend 
	jge	finish		;jump if y >= yend 
 
	inc	dx		;y := y + 1 
	cmp	di,0 
	jl	Spt2		;jump if dirc < 0 
 
Spt1: mov	ax,deltax 
	cmp	ax,0		;Jump if deltax > 0 
	jg	Spart11 
	add	di,incr1 
	Jmp short endloop2 
Spart11: 
	inc	cx		;x := x +1; 
	add	di,incr2 
	Jmp short endloop2 
 
Spt2: mov	ax,deltax 
	cmp	ax,0		;Jump if deltax < 0 
	jl	Spart21 
	add	di,incr1   	;dirc := dirc + incr1 
	Jmp short endloop2 
Spart21: 
	dec	cx		;x := x - 1; 
	add	di,incr3   	;dirc := dirc + incr3 
endloop2: 
	call	point 
	Jmp short main2 
 
finish: 
	call	ResetGraph 
	mov	sp,bp 
	pop	bp 
	ret     10 
_DRAW endp 
 
;************************************************; 
_FASTCHAR proc Near                              ; 
; Draws a 5x7 pixel character at ftx,fty.        ; 
; ftseg and ftofs specify the memory location of ; 
; the bitmap data. Only active pixels are drawn. ; 
; if ftorien is 0 the character is horizontal, if; 
; not then draw it vertical.                     ; 
; The ftch is the character.                     ; 
; This routine is device independant except for  ; 
; the ResetGraph Call and relies on the TextPoint; 
; sub-routine to be correct.                     ; 
;************************************************; 
ftorien	equ	[bp+18] 
ftseg	equ	[bp+16] 
ftofs	equ	[bp+14] 
ftch	equ	[bp+12] 
ftx	equ	[bp+10] 
fty	equ	[bp+8] 
ftcolor	equ	[bp+6] 
	push	ds 
	push	bp 
	mov	bp,sp 
 
	mov	si,ftcolor	;si = color 
        call    SetGraph 
 
	mov	bx,ftofs	;get Offset 
	mov	ax,ftseg	;get seg	position of text array 
	mov	ds,ax 
	mov	ax,ftorien	;get orien 0 = hor 1 = ver 
	or	ax,ax		 
	jz	Horizontal 
	jmp	vertical 
 
Horizontal: 
	mov	cx,ftx		;get x 
	inc	cx 
	inc	cx 
	mov	ftx,cx		;put new (missing first 2 bits) 
	mov	dx,fty		;get y 
	inc	dx		;top line blank 
	mov	fty,dx		;put y 
 
 
	mov	ax,ftch		;get character 
	and	ax,127 
	sub	ax,32		;normalize for dc 
	shl	ax,1 
	shl	ax,1 
	shl	ax,1 
	inc	ax		;first character always blank 
	add	bx,ax		;bx now points at first byte in char 
	mov	di,8		;8 lines in character 
 
mainLoop: 
	mov	al,ds:0[bx]	;Get Byte 
	or	al,al		;if zero then add 8 to x and jump to end 
	jz	Empty 
 
NotEmpty: 
	test	al,020H		;if bit set then plot 
	jz	test1 
	call	point		;plot it 
test1: 
	Inc	cx		;x := x + 1; 
	test	al,010H 
	jz	test2 
	call	point		;plot it 
test2: 
	Inc	cx		;x := x + 1; 
	test	al,08 
	jz	test3 
	call	point		;plot it 
test3: 
	Inc	cx		;x := x + 1; 
	test	al,04 
	jz	test4 
	call	point		;plot it 
test4: 
	Inc	cx		;x := x + 1; 
	test	al,02 
	jz	empty 
	call	point		;plot it 
empty: 
	Inc	bx		;Point at next byte in array; 
	mov	cx,ftx		;get x back 
	inc	dx		;y := y + 1; 
 
	dec	di		;decrement line count 
	jnz	mainloop 
 
	mov	ax,ftch		;get character back 
	test	ax,80h		;if high bit set then invert line 
	jnz	doit1 
	jmp	endit 
doit1: 
	mov	cx,ftx		;get x 
	dec	cx 
	dec	cx 
	mov	dx,fty		;get y 
	dec	dx 
	dec	dx 
	call	point		;plot(x,y-2) 
	inc	cx 
	call	point		;plot(x+1,y-2) 
	inc	cx 
	call	point		;plot(x+2,y-2) 
	inc	cx 
	call	point		;plot(x+3,y-2) 
	inc	cx 
	call	point		;plot(x+4,y-2) 
	inc	cx 
	call	point		;plot(x+5,y-2) 
	inc	cx 
	call	point		;plot(x+6,y-2) 
	inc	cx 
	call	point		;plot(x+7,y-2) 
	jmp	endit 
 
Vertical: 
	mov	dx,fty		;get y 
	dec	dx		 
	dec	dx 
	mov	fty,dx		;put new y(missing first 2 bits) 
	mov	cx,ftx		;get x 
	dec	cx		;top line blank 
	mov	ftx,cx		;put x 
 
	mov	ax,ftch		;get character 
	and	ax,127 
	sub	ax,32		;normalize for dc 
 
	shl	ax,1 
	shl	ax,1 
	shl	ax,1 
	inc	ax		;first character always blank 
	add	bx,ax		;bx now points at first byte in char 
	mov	di,8		;8 lines in character 
 
mainLoopV: 
	mov	al,ds:0[bx]	;Get Byte 
	or	al,al		;if zero then add 8 to x and jump to end 
	jz	EmptyV 
 
NotEmptyV: 
	test	al,020H		;if bit set then plot 
	jz	testV1 
	call	point		;plot it 
testV1: 
	dec	dx		;y := y + 1; 
	test	al,010H 
	jz	testV2 
	call	point		;plot it 
testV2: 
	dec	dx		;y := y + 1; 
	test	al,08 
	jz	testV3 
	call	point		;plot it 
testV3: 
	dec	dx		;y := y + 1; 
	test	al,04 
	jz	testV4 
	call	point		;plot it 
testV4: 
	dec	dx		;y := y + 1; 
	test	al,02 
	jz	emptyV 
	call	point		;plot it 
emptyV: 
	Inc	bx		;Point at next byte in array; 
	mov	dx,fty 		;get y back 
	inc	cx		;x := x + 1; 
 
	dec	di		;decrement line count 
	jnz	mainloopV 
 
	mov	ax,ftch		;get character back 
	test	ax,80h		;if high bit set then invert line 
	jz	endit 
 
	mov	dx,fty 		;get y 
	inc	dx 
	inc	dx 
	mov	cx,ftx 		;get x 
	dec	cx 
	dec	cx 
	call	point		;plot(x-2,y-2) 
	dec	dx 
	call	point		;plot(x+1,y-2) 
	dec	dx 
	call	point		;plot(x+2,y-2) 
	dec	dx 
	call	point		;plot(x+3,y-2) 
	dec	dx 
	call	point		;plot(x+4,y-2) 
	dec	dx 
	call	point		;plot(x+5,y-2) 
	dec	dx 
	call	point		;plot(x+6,y-2) 
	dec	dx 
	call	point		;plot(x+7,y-2) 
	jmp short endit 
endit: 
 
	call	ResetGraph 
	pop	bp 
	pop	ds 
	ret     14 
_FASTCHAR endp 
 
 
;************************************************; 
_FULLCHAR proc Near                              ; 
; Draws a 5x7 pixel character at btx,bty.        ; 
; btseg and btofs specify the memory location of ; 
; the bitmap data. All pixel (active or passive  ; 
; are drawn.                                     ; 
; Passive pixels are drawn in the btback color,  ; 
; active pixels are drawn in the btcolor color   ; 
; The ftch is the character.                     ; 
; This routine is device independant except for  ; 
; the ResetGraph Call and relies on the TextPoint; 
; sub-routine to be correct.                     ; 
;************************************************; 
btback	equ	[bp+18] 
btseg	equ	[bp+16] 
btofs	equ	[bp+14] 
btch	equ	[bp+12] 
btx	equ	[bp+10] 
bty	equ	[bp+8] 
btcolor	equ	[bp+6] 
 
	push	ds 
	push	bp 
	mov	bp,sp 
 
        mov     si,btcolor 
        call    Setgraph 
	mov	bx,btofs	;get Offset 
	mov	ax,btseg	;get seg	position of text array 
	mov	ds,ax 
 
	mov	cx,btx		;get x 
	inc	cx 
	inc	cx 
	mov	btx,cx		;put new (missing first 2 bits) 
	mov	dx,bty		;get y 
	sub	dx,8 
 
	mov	ax,btch		;get character 
	and	ax,127 
	sub	ax,32		;normalize for dc 
	shl	ax,1 
	shl	ax,1 
	shl	ax,1 
	inc	ax		;first Line of character always blank 
	add	bx,ax		;bx now TextPoints at first byte in char 
	mov	di,8		;8 lines in character 
 
TmainLoop: 
	mov	al,ds:0[bx]	;Get Byte 
	Mov	si,btback 
	test	al,020H		;if bit set then plot 
	jz	Plot1 
	mov	si,btcolor 
Plot1: 
	call	TextPoint 
 
	Inc	cx 
	Mov	si,btback 
	test	al,010H 
	jz	Plot2 
	mov	si,btcolor 
Plot2: 
	call	TextPoint 
 
	Inc	cx 
	Mov	si,btback 
	test	al,08 
	jz	Plot3 
	mov	si,btcolor 
Plot3: 
	call	TextPoint 
 
	Inc	cx 
	Mov	si,btback 
	test	al,04 
	jz	Plot4 
	mov	si,btcolor 
Plot4: 
	call	TextPoint 
 
	Inc	cx 
	Mov	si,btback 
	test	al,02 
	jz	Plot5 
	mov	si,btcolor 
Plot5: 
	call	TextPoint 
 
	Inc	bx 
	mov	cx,btx 
	inc	dx 
 
	dec	di 
	jnz	Tmainloop 
 
	call	ResetGraph 
	pop	bp 
	pop	ds 
	ret     14 
_FULLCHAR endp 
 
;******************************************** 
_GetDriverType proc NEAR                    ; 
; Returns then Type of driver. 0 = Graphics ; 
;                              1 = Printer  ; 
;                              2 = Plotter  ; 
;                              3 = Locator  ; 
;******************************************** 
      mov      ax,0 
      ret 
_GetDriverType endp 
 
 
;*********************************************** 
_BIGCOLORS proc NEAR                           ; 
; returns the maximum number of colors that    ; 
; the driver supports. Must Not be larger than ; 
; 16.                                          ; 
;**********************************************; 
      mov      ax,MaxColors 
      ret 
_BIGCOLORS endp 
 
;*********************************************** 
_BIGBACKCOLORS proc NEAR                       ; 
; returns the maximum number of colors that    ; 
; the background can be set to.                ; 
; Must not be larger than 16.                  ; 
;**********************************************; 
      mov      ax,MaxBackColors 
      ret 
_BIGBACKCOLORS endp 
 
 
 
;********************************************; 
_XBIG proc NEAR                              ; 
; Returns the highest x-coordinate that the  ; 
; driver supports.                           ; 
;********************************************; 
      mov      ax,MaxX-1 
      ret 
_XBIG endp 
 
 
 
;********************************************; 
_YBIG proc NEAR                              ; 
; Returns the highest y-coordinate that the  ; 
; driver supports.                           ; 
;********************************************; 
      mov      ax,MaxY-StatusLine-1 
      ret 
_YBIG endp 
 
 
;***********************************************; 
_MENUMEMREQUIRED proc NEAR                      ; 
; Returns the amount of memory required by the  ; 
; save menu routine to store the screen space   ; 
; under the menu.  (320x200 pixels)             ; 
;***********************************************; 
      mov      ax,MenuMem 
      ret 
_MENUMEMREQUIRED endp 
 
 
 
;**************************************************; 
_COLORSETS proc NEAR                               ; 
; Returns the number of color sets that the driver ; 
; supports. For example the CGA driver has 2 set of; 
; 4 colors each.                                   ; 
;**************************************************; 
      mov      ax,MaxSets 
      ret 
_COLORSETS endp 
 
 
;*********************************************; 
_Arc proc NEAR                                ; 
; Use Bresenhams circle drawing algorithmn    ; 
; procedure Arc(xc,yc,segments,radius,color)  ; 
;*********************************************; 
xc	equ	[bp+12] 
yc	equ	[bp+10] 
segs    equ	[bp+8] 
radius	equ	[bp+6] 
acolor	equ	[bp+4] 
 
	push	bp 
	mov	bp,sp 
 
	mov	si,dcolor	       ;si = color 
        call    SetGraph 
 
        mov     cx,0                   ;x := 0; 
        mov     dx,radius              ;y := radius; 
 
        mov     di,3 
        sub     di,radius              ;di := 3 - 2 * Radius; 
        sub     di,radius 
 
MainArcLoop: 
        cmp     cx,dx 
        jle     DoArc                 ;while x <= y do 
        jmp     EndArc 
DoArc: 
        push    cx 
        push    dx 
        mov     ax,cx                 ;ax = x offset 
        mov     bx,dx                 ;bx = y offset 
 
        test    word ptr segs,8 
        jz      seg1 
 
        mov     cx,xc 
        add     cx,ax 
        mov     dx,yc 
        add     dx,bx 
        call    point                  ;Plot(xc+x,yc+y) 
        mov     cx,xc 
        add     cx,bx 
        mov     dx,yc 
        add     dx,ax 
        call    point                  ;Plot(xc+y,yc+x) 
 
Seg1:   test    word ptr segs,4 
        jz      seg2 
 
        mov     cx,xc 
        sub     cx,ax 
        mov     dx,yc 
        add     dx,bx 
        call    point                  ;Plot(xc-x,yc+y) 
        mov     cx,xc 
        sub     cx,bx 
        mov     dx,yc 
        add     dx,ax 
        call    point                  ;Plot(xc-y,yc+x) 
 
Seg2:   test    word ptr segs,2 
        jz      seg3 
 
        mov     cx,xc 
        sub     cx,ax 
        mov     dx,yc 
        sub     dx,bx 
        call    point                  ;Plot(xc-x,yc-y) 
        mov     cx,xc 
        sub     cx,bx 
        mov     dx,yc 
        sub     dx,ax 
        call    point                  ;Plot(xc-y,yc-x) 
 
 
Seg3:   test    word ptr segs,1 
        jz      seg4 
 
        mov     cx,xc 
        add     cx,ax 
        mov     dx,yc 
        sub     dx,bx 
        call    point                  ;Plot(xc+x,yc-y) 
        mov     cx,xc 
        add     cx,bx 
        mov     dx,yc 
        sub     dx,ax 
        call    point                  ;Plot(xc+y,yc-x) 
Seg4: 
        pop     dx 
        pop     cx 
 
        or      di,di                   ;if di < 0 then 
        jns     digreatz 
        mov     ax,cx                   ;di := di + (4 * x) + 6; 
        add     di,cx 
        add     di,cx 
        add     di,cx 
        add     di,cx 
        add     di,6 
        jmp     endtest 
 
digreatz: 
        mov     ax,cx 
        sub     ax,dx                   ;di := di + 4 * (x-y) + 10; 
        add     di,ax 
        add     di,ax 
        add     di,ax 
        add     di,ax 
        add     di,10 
        dec     dx 
endtest: 
        inc     cx 
        jmp     MainArcLoop 
EndArc: 
        call	ResetGraph 
        pop     bp 
        ret     10 
 
_ARC    endp 