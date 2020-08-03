
; ______________________________________________________________________________________
;|																						|
;|						Template para compilacao com o MASM 6.15						|
;|______________________________________________________________________________________|

.286
.MODEL TINY 
_Text SEGMENT PUBLIC USE16
	ASSUME DS:_TEXT,ES:_TEXT 

.DATA
          bank     dw 0

.CODE

ORG 100h

;---------------------------------------------------------------------------------------
;									EntryPoint
;----------------------------------------------------------------------------------------------

main:

            mov     ax, 4F02h                       ;set vesa 1.0 screen mode
            mov     bx, 103h                        ;FOR 800X600 THIS SHOULD BE "103h" 
            int     10h
            
            mov     si, 0A000h
            mov     ds, si                          ;sets up registers  
            mov     cx, 8
            
mainloop:   mov     dx, word ptr bank
            call    window
            xor     bx, bx
            mov     al, 0CCh
            call    static
            inc     bank
            loop    mainloop
            
            jmp     $
            
window:     mov     ax, 4F05h                       ;vesa 1 window select
            mov     bx, 0
            int     10h                             ;dx is the reqired window
            ret
            
static:     mov     [bx], al                        ;(4*2^16)+45056 pixels
            inc     bx
            cmp     bx, 00000
            jne     static
            ret


END main

_TEXT ENDS