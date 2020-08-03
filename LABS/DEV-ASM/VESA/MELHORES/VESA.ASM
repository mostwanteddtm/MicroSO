; ______________________________________________________________________________________
;|																						|
;|						Template para compilacao com o MASM 6.15						|
;|______________________________________________________________________________________|

.286
.MODEL TINY 
_Text SEGMENT PUBLIC USE16
	ASSUME DS:_TEXT,ES:_TEXT 

.DATA
 

.CODE

ORG 100h

;---------------------------------------------------------------------------------------
;									EntryPoint
;---------------------------------------------------------------------------------------

main:

            mov     ax, 4F02h                       ;set vesa 1.0 screen mode
            mov     bx, 103h                        ;FOR 800X600 THIS SHOULD BE "103h" 
            int     10h
            
            mov     dx, 0A000h
            mov     ds, dx                          ;sets up registers
            call    window
            
rain:       xor     dx, dx                          ;(pages-1)
            
mainloop:   push    dx
            call    window
            xor     bx, bx
            mov     al, 0CCh
            call    static
            pop     dx
            cmp     dx, 7                           ;FOR 800X600 CHANGE THIS TO 7
            je      rain
            inc     dx
            mov     ah,01h
            int     16h
            jz      mainloop
            
            mov     ax, 0003h
            int     10h
            
            int     20h
            
window:     mov     ax, 4F05h                       ;vesa 1 window select
            mov     bx, 0
            int     10h                             ;dx is the reqired window
            xor     bx, bx
            ret
            
static:     mov     [bx], al                        ;(4*2^16)+45056 pixels
            inc     bx
            cmp     bx, 00000
            jne     static
            ret

END main

_TEXT ENDS
