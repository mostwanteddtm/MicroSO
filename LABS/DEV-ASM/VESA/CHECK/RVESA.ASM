

main:
     Textseg        DW 0
     Textoff        DW 0
     Curpage        DW 0
     Gransize       DW 0
     Granmult       DW 0

;InitVESA
;declare sub InitVESA (byval Gransize%)

STRUC [bp]
     DW   ?,?,?,?,?  ; DI, ES, SI, DS, BP
     DD   ?    ; Caller
     IV_Gransize    DW   ? ;2
ENDS

public initvesa
initvesa:
     push bp,ds,si,es,di
     mov bp,sp
     mov ax,IV_Gransize
     mov cs:Gransize,ax
     xor dx,dx
     mov cx,ax
     mov ax,64
     div cx
     mov cs:Granmult,ax ;Aha. Heres for granularities smaller than 64K

     pop di,es,si,ds,bp
     retf 2

;Drawblock
;declare sub Drawblock (byval x%, byval y%, byval Xsize%, byval Ysize%, byval Colour%)

STRUC [bp]
     DW   ?,?,?,?,?  ; DI, ES, SI, DS, BP
     DD   ?    ; Caller
     DB_Colour      DW   ? ;10
     DB_Ysize       DW   ? ;8
     DB_Xsize       DW   ? ;6
     DB_Y           DW   ? ;4
     DB_X           DW   ? ;2
ENDS

public drawblock
drawblock:
     push bp,ds,si,es,di
     mov bp,sp

     mov ax,0a000h
     mov es,ax
     
     mov ax,DB_Y  ;Calculate memory address
     mov cx,640
     mul cx
     add ax,DB_X
     if c inc dx  ;Watch out! (IF) is an A86 mnemoutic
                  ;This checks the carry flag and increments DX if set.
     
     ;Ah heck, isn't that convientent, the page needed (64K only) in DX
     ;and the offset in AX?
     push dx,ax
     mov ax,dx
     xor dx,dx
     mov cx,cs:Granmult
     mul cx ;Aha, now we've got it set up for ANY gran size!
     mov cs:Curpage,ax

     
     mov dx,ax
     mov bx,0
     mov ax,04f05h
     int 010h

     pop ax,dx
     ;And wow, the AX is still cool for use with the OFFSET - no matter
     ;what gran size!!
     mov di,ax ;Set up index
     
     mov cx,DB_Xsize
     mov bx,DB_Ysize
     mov ax,DB_Colour
     xor ah,ah

rowloop:
     mov dx,di
     add dx,cx
     jc pagesplit ;DARN! I hate that - a page split right in the middle of a
                  ;row!
     push di,cx
     rep stosb
     pop cx,di
     add di,640
     jc pges2  ;A split on a row is not that bad... =)
     jmp nextline

pges2:
     push dx,ax,bx
     mov dx,cs:Curpage
     mov ax,cs:Granmult
     add dx,ax
     mov cs:Curpage,dx
     mov bx,0
     mov ax,04f05h
     int 010h
     pop bx,ax,dx
     jmp nextline

pagesplit:
     push cx,di
     sub cx,dx
     rep stosb

     push dx,ax,bx
     mov dx,cs:Curpage
     mov ax,cs:Granmult
     add dx,ax
     mov cs:Curpage,dx
     mov bx,0
     mov ax,04f05h
     int 010h
     pop bx,ax,dx
     
     mov di,0
     mov cx,dx
     rep stosb
     
     pop di
     add di,640
     pop cx

nextline:
     dec bx
     cmp bx,0
     ja rowloop

     pop di,es,si,ds,bp
     retf 10


;Putblock
;declare sub Putblock (byval x%, byval y%, byval Xsize%, byval Ysize%, byval Segment%, byval Offset%)

STRUC [bp]
     DW   ?,?,?,?,?  ; DI, ES, SI, DS, BP
     DD   ?    ; Caller
     PB_Offset      DW   ? ;12
     PB_Segment     DW   ? ;10
     PB_Ysize       DW   ? ;8
     PB_Xsize       DW   ? ;6
     PB_Y           DW   ? ;4
     PB_X           DW   ? ;2
ENDS

public putblock
putblock:
     push bp,ds,si,es,di
     mov bp,sp

     mov ax,0a000h
     mov es,ax
     
     mov ax,PB_Y  ;Calculate memory address
     mov cx,640
     mul cx
     add ax,PB_X
     if c inc dx  ;Watch out! (IF) is an A86 mnemoutic
                  ;This checks the carry flag and increments DX if set.
     
     ;Ah heck, isn't that convientent, the page needed (64K only) in DX
     ;and the offset in AX?
     push dx,ax
     mov ax,dx
     xor dx,dx
     mov cx,cs:Granmult
     mul cx ;Aha, now we've got it set up for ANY gran size!
     mov cs:Curpage,ax

     mov dx,ax
     mov bx,0
     mov ax,04f05h
     int 010h
     pop ax,dx
     ;And wow, the AX is still cool for use with the OFFSET - no matter
     ;what gran size!!
     mov di,ax ;Set up index
     
     mov cx,PB_Xsize
     mov bx,PB_Ysize
     
     mov si,PB_Offset
     mov ax,PB_Segment
     mov ds,ax
     
     

rowloopp:
     mov dx,di
     add dx,cx
     jc pagesplitp ;DARN! I hate that - a page split right in the middle of a
                  ;row!
     push di,cx
     rep movsb
     pop cx,di
     add di,640
     jc pges2p  ;A split on a row is not that bad... =)
     jmp nextlinep

pges2p:
     push dx,ax,bx
     mov dx,cs:Curpage
     mov ax,cs:Granmult
     add dx,ax
     mov cs:Curpage,dx
     mov bx,0
     mov ax,04f05h
     int 010h
     pop bx,ax,dx
     jmp nextlinep

pagesplitp:
     push cx,di
     sub cx,dx
     rep movsb

     push dx,ax,bx
     mov dx,cs:Curpage
     mov ax,cs:Granmult
     add dx,ax
     mov cs:Curpage,dx
     mov bx,0
     mov ax,04f05h
     int 010h
     pop bx,ax,dx
     
     mov di,0
     mov cx,dx
     rep movsb
     
     pop di
     add di,640
     pop cx

nextlinep:
     dec bx
     cmp bx,0
     ja rowloopp

     pop di,es,si,ds,bp
     retf 12


;Getblock
;declare sub Getblock (byval x%, byval y%, byval Xsize%, byval Ysize%, byval Segment%, byval Offset%)

STRUC [bp]
     DW   ?,?,?,?,?  ; DI, ES, SI, DS, BP
     DD   ?    ; Caller
     GB_Offset      DW   ? ;12
     GB_Segment     DW   ? ;10
     GB_Ysize       DW   ? ;8
     GB_Xsize       DW   ? ;6
     GB_Y           DW   ? ;4
     GB_X           DW   ? ;2
ENDS

public getblock
getblock:
     push bp,ds,si,es,di
     mov bp,sp

     mov ax,GB_Segment
     mov es,ax
     mov di,GB_Offset     

     mov ax,PB_Y  ;Calculate memory address
     mov cx,640
     mul cx
     add ax,PB_X
     if c inc dx  ;Watch out! (IF) is an A86 mnemoutic
                  ;This checks the carry flag and increments DX if set.
     
     ;Ah heck, isn't that convientent, the page needed (64K only) in DX
     ;and the offset in AX?
     push dx,ax
     mov ax,dx
     xor dx,dx
     mov cx,cs:Granmult
     mul cx ;Aha, now we've got it set up for ANY gran size!
     mov cs:Curpage,ax

     mov dx,ax
     mov bx,1 
     ;^^^^ Making this to 1 instead of 0, selects WINDOW B.  On my cruddy
     
     ;video card, Window A is writable ONLY and Window B is readable ONLY.
     ;Actually, now that I think about it.... thats a good idea... Think,
     ;you could do offscreen PAGING (Also memory moves) fast with this
     ;sucker.... I like my video card.... (I'm sure other video cards work
     ;this way too!)  =)
     ;BTW, this LITTLE glitch caused a BUG in your VESA routines.....

     mov ax,04f05h
     int 010h 
     pop ax,dx
     ;And wow, the AX is still cool for use with the OFFSET - no matter
     ;what gran size!!
     mov si,ax ;Set up index
     
     mov cx,PB_Xsize
     mov bx,PB_Ysize
     
     mov ax,0a000h
     mov ds,ax

rowloopg:
     mov dx,si
     add dx,cx
     jc pagesplitg ;DARN! I hate that - a page split right in the middle of a
                  ;row!
     push si,cx
     rep movsb
     pop cx,si
     add si,640
     jc pges2g  ;A split on a row is not that bad... =)
     jmp nextlineg

pges2g:
     push dx,ax,bx
     mov dx,cs:Curpage
     mov ax,cs:Granmult
     add dx,ax
     mov cs:Curpage,dx
     mov bx,1
     mov ax,04f05h
     int 010h
     pop bx,ax,dx
     jmp nextlineg

pagesplitg:
     push cx,si
     sub cx,dx
     rep movsb

     push dx,ax,bx
     mov dx,cs:Curpage
     mov ax,cs:Granmult
     add dx,ax
     mov cs:Curpage,dx
     mov bx,1
     mov ax,04f05h
     int 010h
     pop bx,ax,dx
     
     mov si,0
     mov cx,dx
     rep movsb
     
     pop si
     add si,640
     pop cx

nextlineg:
     dec bx
     cmp bx,0
     ja rowloopg

     pop di,es,si,ds,bp
     retf 12

;Putmask
;declare sub Putmask (byval x%, byval y%, byval Xsize%, byval Ysize%, byval Segment%, byval Offset%)

STRUC [bp]
     DW   ?,?,?,?,?  ; DI, ES, SI, DS, BP
     DD   ?    ; Caller
     PM_Offset      DW   ? ;12
     PM_Segment     DW   ? ;10
     PM_Ysize       DW   ? ;8
     PM_Xsize       DW   ? ;6
     PM_Y           DW   ? ;4
     PM_X           DW   ? ;2
ENDS

public putmask
putmask:
     push bp,ds,si,es,di
     mov bp,sp

     mov ax,0a000h
     mov es,ax
     
     mov ax,PM_Y  ;Calculate memory address
     mov cx,640
     mul cx
     add ax,PM_X
     if c inc dx  ;Watch out! (IF) is an A86 mnemoutic
                  ;This checks the carry flag and increments DX if set.
     
     ;Ah heck, isn't that convientent, the page needed (64K only) in DX
     ;and the offset in AX?
     push dx,ax
     mov ax,dx
     xor dx,dx
     mov cx,cs:Granmult
     mul cx ;Aha, now we've got it set up for ANY gran size!
     mov cs:Curpage,ax

     mov dx,ax
     mov bx,0
     mov ax,04f05h
     int 010h
     pop ax,dx
     ;And wow, the AX is still cool for use with the OFFSET - no matter
     ;what gran size!!
     mov di,ax ;Set up index
     
     mov cx,PM_Xsize
     mov bx,PM_Ysize
     
     mov si,PM_Offset
     mov ax,PM_Segment
     mov ds,ax

rowloopm:
     mov dx,di
     add dx,cx
     jc pagesplitm ;DARN! I hate that - a page split right in the middle of a
                  ;row!
     push di,cx
     call drawline ;Hey, your probably thinking about now.... DANG!!!
                   ;Has Dean NEVER heard of the CALL instruction or something?
                   ;He uses the SAME redundant routines..... Well... I have
                   ;a few excuses:
                   ;1) Inline code is FASTER
                   ;2) These CALLS are used only for conveince
                   ;3) Did I mention that Inline code is FASTER?
                   ;4) Hey, no offense, but my VESA routines DO MORE....
                   ;   BUT, its all in 16-bit code, and the ASM file
                   ;   is SMALLER - even with the gargantuous comments!
     pop cx,di
     
     add di,640
     jc pges2m  ;A split on a row is not that bad... =)
     jmp nextlinem

pges2m:
     push dx,bx
     mov dx,cs:Curpage
     mov ax,cs:Granmult
     add dx,ax
     mov cs:Curpage,dx
     mov bx,0
     mov ax,04f05h
     int 010h
     pop bx,dx
     jmp nextlinem

pagesplitm:
     push cx,di
     
     cmp cx,dx
     sub cx,dx
     
     call drawline

     push dx,bx
     mov dx,cs:Curpage
     mov ax,cs:Granmult
     add dx,ax
     mov cs:Curpage,dx
     mov bx,0
     mov ax,04f05h
     int 010h
     pop bx,dx
     
     mov di,0
     mov cx,dx

     call drawline

     pop di
     add di,640
     pop cx

nextlinem:
     dec bx
     cmp bx,0
     ja rowloopm

     pop di,es,si,ds,bp
     retf 12


public drawline
drawline:
     cmp cx,0
     je skipcall
inlooper:
     mov al,ds:[si]
     cmp al,0
     if ne mov es:[di],al
     inc si
     inc di
     loopnz inlooper
skipcall:
     ret

;Puttext
;declare sub Puttext (byval x%, byval y%, byval Xsize%, byval Ysize%, byval Segment%, byval Offset%, byval Colour%)

STRUC [bp]
     DW   ?,?,?,?,?  ; DI, ES, SI, DS, BP
     DD   ?    ; Caller
     PT_Colour      DW   ? ;14
     PT_Offset      DW   ? ;12
     PT_Segment     DW   ? ;10
     PT_Ysize       DW   ? ;8
     PT_Xsize       DW   ? ;6
     PT_Y           DW   ? ;4
     PT_X           DW   ? ;2
ENDS

public puttext
puttext:
     push bp,ds,si,es,di
     mov bp,sp

     mov ax,0a000h
     mov es,ax
     
     mov ax,PT_Y  ;Calculate memory address
     mov cx,640
     mul cx
     add ax,PT_X
     if c inc dx  ;Watch out! (IF) is an A86 mnemoutic
                  ;This checks the carry flag and increments DX if set.
     
     ;Ah heck, isn't that convientent, the page needed (64K only) in DX
     ;and the offset in AX?
     push dx,ax
     mov ax,dx
     xor dx,dx
     mov cx,cs:Granmult
     mul cx ;Aha, now we've got it set up for ANY gran size!
     mov cs:Curpage,ax

     mov dx,ax
     mov bx,0
     mov ax,04f05h
     int 010h
     pop ax,dx
     ;And wow, AX is still cool for use with the OFFSET - no matter
     ;what gran size!!
     mov di,ax ;Set up index
     
     mov cx,PT_Xsize
     mov bx,PT_Ysize
     
     mov ax,PT_Colour
     xchg ah,al
     
     mov si,PT_Offset
     push ax
     mov ax,PT_Segment
     mov ds,ax
     pop ax
rowlooppt:
     mov dx,di
     add dx,cx
     jc pagesplitpt ;DARN! I hate that - a page split right in the middle of a
                  ;row!
     push di,cx
     call drawlinept
     pop cx,di
     
     add di,640
     jc pges2pt  ;A split on a row is not that bad... =)
     jmp nextlinept

pges2pt:
     push dx,ax,bx
     mov dx,cs:Curpage
     mov ax,cs:Granmult
     add dx,ax
     mov cs:Curpage,dx
     mov bx,0
     mov ax,04f05h
     int 010h
     pop bx,ax,dx
     jmp nextlinept

pagesplitpt:
     push cx,di
     sub cx,dx
          
     call drawlinept
     
     push dx,ax,bx
     mov dx,cs:Curpage
     mov ax,cs:Granmult
     add dx,ax
     mov cs:Curpage,dx
     mov bx,0
     mov ax,04f05h
     int 010h
     pop bx,ax,dx
     
     mov di,0
     mov cx,dx

     call drawlinept

     pop di
     add di,640
     pop cx

nextlinept:
     dec bx
     cmp bx,0
     ja rowlooppt

     pop di,es,si,ds,bp
     retf 12


public drawlinept
drawlinept:
     cmp cx,0
     je skippt
inlooperpt:
     mov al,ds:[si]
     cmp al,0
     if ne mov es:[di],ah
     inc si
     inc di
     loopnz inlooperpt
skippt:
     ret

;Xorblock
;declare sub Xorblock (byval x%, byval y%, byval Xsize%, byval Ysize%, byval Colour%)

STRUC [bp]
     DW   ?,?,?,?,?  ; DI, ES, SI, DS, BP
     DD   ?    ; Caller
     XB_Colour      DW   ? ;10
     XB_Ysize       DW   ? ;8
     XB_Xsize       DW   ? ;6
     XB_Y           DW   ? ;4
     XB_X           DW   ? ;2
ENDS

public xorblock
xorblock:
     push bp,ds,si,es,di
     mov bp,sp

     mov ax,0a000h
     mov es,ax
     
     mov ax,XB_Y  ;Calculate memory address
     mov cx,640
     mul cx
     add ax,XB_X
     if c inc dx  ;Watch out! (IF) is an A86 mnemoutic
                  ;This checks the carry flag and increments DX if set.
     
     ;Ah heck, isn't that convientent, the page needed (64K only) in DX
     ;and the offset in AX?
     push dx,ax
     mov ax,dx
     xor dx,dx
     mov cx,cs:Granmult
     mul cx ;Aha, now we've got it set up for ANY gran size!
     mov cs:Curpage,ax

    
     mov dx,ax
     mov bx,0
     mov ax,04f05h
     push dx,ax
     int 010h
     
     pop ax,dx
     mov bx,1
     int 010h
     
     pop ax,dx
     ;And wow, the AX is still cool for use with the OFFSET - no matter
     ;what gran size!!
     mov di,ax ;Set up index
     
     mov cx,XB_Xsize
     mov bx,XB_Ysize
     mov ax,XB_Colour
     mov ah,al

rowlooping:
     mov dx,di
     add dx,cx
     jc pagespliting ;DARN! I hate that - a page split right in the middle of a
                  ;row!
     push di,cx
     call xorline
     pop cx,di
     add di,640
     jc pges2ing  ;A split on a row is not that bad... =)
     jmp nextlineing

pges2ing:
     push dx,ax,bx
     mov dx,cs:Curpage
     mov ax,cs:Granmult
     add dx,ax
     mov cs:Curpage,dx
     xor bx,bx
     mov ax,04f05h
     push dx,ax
     int 010h
     pop ax,dx
     
     mov bx,1
     int 010h

     pop bx,ax,dx
     jmp nextlineing

pagespliting:
     push cx,di
     sub cx,dx
     call xorline

     push dx,ax,bx
     mov dx,cs:Curpage
     mov ax,cs:Granmult
     add dx,ax
     mov cs:Curpage,dx
     xor bx,bx
     mov ax,04f05h
     push dx,ax
     int 010h
     pop ax,dx     
     
     mov bx,1
     int 010h
     pop bx,ax,dx
     
     xor di,di
     mov cx,dx
     call xorline
     
     pop di
     add di,640
     pop cx

nextlineing:
     dec bx
     cmp bx,0
     ja rowlooping

     pop di,es,si,ds,bp
     retf 10

public xorline
xorline:
     cmp cx,0
     je skipxorline
xorloop:
     mov al,es:[di]
     xor al,ah
     mov es:[di],al
     inc di
     loopnz xorloop
skipxorline:
     ret

;Dpoint
;declare sub Dpoint (byval x%, byval y%, byval Colour%)

STRUC [bp]
     DW   ?,?,?,?,?  ; DI, ES, SI, DS, BP
     DD   ?    ; Caller
     DP_Colour      DW   ? ;6
     DP_Y           DW   ? ;4
     DP_X           DW   ? ;2
ENDS

public dpoint
dpoint:
     push bp,ds,si,es,di
     mov bp,sp

     mov ax,0a000h
     mov es,ax
     
     mov ax,DP_Y  ;Calculate memory address
     mov cx,640
     mul cx
     add ax,DP_X
     if c inc dx  ;Watch out! (IF) is an A86 mnemoutic
                  ;This checks the carry flag and increments DX if set.
     
     ;Ah heck, isn't that convientent, the page needed (64K only) in DX
     ;and the offset in AX?
     push dx,ax
     mov ax,dx
     xor dx,dx
     mov cx,cs:Granmult
     mul cx ;Aha, now we've got it set up for ANY gran size!
     cmp ax,cs:Curpage
     je skipall
     
     mov cs:Curpage,ax
     
     mov dx,ax
     mov bx,0
     mov ax,04f05h
     int 010h
 
skipall:          
     pop ax,dx
     ;And wow, the AX is still cool for use with the OFFSET - no matter
     ;what gran size!!
     
     mov di,ax ;Set up index
     
     mov ax,DP_Colour
     mov es:[di],al
     
     pop di,es,si,ds,bp
     retf 6

;Gpoint
;declare function Gpoint (byval x%, byval y%)

STRUC [bp]
     DW   ?,?,?,?,?  ; DI, ES, SI, DS, BP
     DD   ?    ; Caller
     GP_Y           DW   ? ;4
     GP_X           DW   ? ;2
ENDS

public gpoint
gpoint:
     push bp,ds,si,es,di
     mov bp,sp

     mov ax,0a000h
     mov es,ax
     
     mov ax,DP_Y  ;Calculate memory address
     mov cx,640
     mul cx
     add ax,DP_X
     if c inc dx  ;Watch out! (IF) is an A86 mnemoutic
                  ;This checks the carry flag and increments DX if set.
     
     ;Ah heck, isn't that convientent, the page needed (64K only) in DX
     ;and the offset in AX?
     push dx,ax
     mov ax,dx
     xor dx,dx
     mov cx,cs:Granmult
     mul cx ;Aha, now we've got it set up for ANY gran size!
     cmp ax,cs:Curpage
     je skipallg
     
     mov cs:Curpage,ax
     
     mov dx,ax
     mov bx,1 ;There it is AGAIN!!
     mov ax,04f05h
     int 010h
 
skipallg:          
     pop ax,dx
     ;And wow, the AX is still cool for use with the OFFSET - no matter
     ;what gran size!!
     
     mov di,ax ;Set up index
     
     mov al,es:[di]
     xor ah,ah
     
     pop di,es,si,ds,bp
     retf 4


