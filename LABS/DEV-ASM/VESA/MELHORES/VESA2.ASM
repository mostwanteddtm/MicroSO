
; ______________________________________________________________________________________
;|																						|
;|						Template para compilacao com o MASM 6.15						|
;|______________________________________________________________________________________|

.286
.MODEL TINY 
_Text SEGMENT PUBLIC USE16
	ASSUME DS:_TEXT,ES:_TEXT 

.DATA
            color    db         0 
            Row      db         0
.CODE

ORG 100h

;---------------------------------------------------------------------------------------
;									EntryPoint
;---------------------------------------------------------------------------------------

main:               mov     ax, 4F02h 
                    mov     bx, 101h 
                    int     10h 

                    mov     dx, 0A000h 
                    mov     es, dx 
                    call    window 

StartAgain:         xor     dx, dx 
                    mov     [color], 0 
                          
MainLoop:           push    dx 
                    call    window 
                    xor     bx, bx 
                    inc     [color] 
                    mov     al, [color] 
                    call    static 

                    pop     dx 
                    cmp     dx, 4 
                    je      StartAgain 
                    inc     dx  ;<** here is box number 
                    mov     ah, 01h 
                    int     16h 
                    jz      MainLoop 
                    mov     ah, 00h 
                    int     16h 
                    mov     ax, 0003h 
                    int     10h 

                    int     20h 
                    
window:             mov     ax, 4F05h 
                    mov     bx, 0 
                    int     10h 
                    xor     bx, bx 
                    ret 

static:             stosb 
                    inc     bx 
                    cmp     bx, 00000h 
                    jne     static 
                    ret 

END main

_TEXT ENDS
