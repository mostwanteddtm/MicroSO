; (C)opyright Erdogan Tan - 19/11/2002

; IRQ15.ASM (IRQ15.COM)
; Monitors INT 77h (INTRQ for Port 170h) for any ATA/ATAPI Device INTRQs

; NOTE: Read status register for stopping the INTRQ (repetive IRQ15)

; TSR (Terminate and Stay Resident) Type MS-DOS (TR-DOS) Program
; (If INT 20h would be used instead of INT 27h, program would be
; standalone...)



		PAGE    60,132



;ÄÄÄÄÄÄÄÄÄÄ CODE_SEG_1  ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

CODE_SEG_1	segment para public
		assume  CS:CODE_SEG_1, DS:CODE_SEG_1, SS:CODE_SEG_1, ES:CODE_SEG_1


		org	100h


;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
;±
;±		ENTRY POINT
;±
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±


;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
;±
;±		PROCEDURE proc_start
;±
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±

proc_start      proc    near
start:		; N-Ref=0
                jmp     load

var_INT77h_off: dw      0
var_INT77h_seg: dw      0

proc_start	endp


;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
;±
;±              PROCEDURE proc_handler
;±
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±

proc_handler    proc    near


INT77h_handler:
                push    ax
                push    bx
                push    cx
                push    dx
                push    si
                push    ds
                push    cs
                pop     ds

                mov dx, 177h ; IDE Port 177h (STATUS Register)
                mov cx, 4    ; For example,not required more for stop INTRQ
    loc_read_status:
                in al, dx
                ; For a real status check, BSY, ERR and DRQ etc. would be.
                loop loc_read_status

                mov si, offset Msg_IRQ15
loc_print:          
                lodsb                        ; Load byte at DS:SI to AL
		and     AL,AL            
                jz      short loc_exit       ; If AL = 00h then return
		mov     AH,0Eh                  
		mov     BX,07h             
                int     10h                  ; BIOS Service func ( ah ) = 0Eh
                                             ; Write char as TTY
                                             ;AL-char BH-page BL-color
		jmp     short loc_print           
loc_exit:
                pop     ds
                pop     si
                pop     dx
                pop     cx
                pop     bx
                pop     ax

                jmp     Dword ptr CS:var_INT77h_off

Msg_IRQ15:
                db      " IRQ 15 ... (c) Erdogan Tan - 2002"
                db      0Dh, 0Ah, 0h

proc_handler    endp


;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
;±
;±              PROCEDURE proc_load
;±
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±

proc_load       proc    near
load:          
                xor     BX,BX
                mov     ES,BX
                mov     BP,1DCh
                mov     AX, offset INT77h_handler
                mov     DX, Word ptr ES:[BP]
                cmp     AX,DX
                jnz     short pass_INT77h_segment_ctrl
                mov     BX,DS
                cmp     Word ptr ES:[BP]+2,BX
                jz      short loc_exit_0
pass_INT77h_segment_ctrl:
                mov     word ptr ES:[BP],AX
                mov     Word Ptr [var_INT77h_off],DX 
                mov     DX, Word ptr ES:[BP]+2
                mov     Word Ptr [var_INT77h_seg],DX
                mov     DX,DS
                mov     word ptr ES:[BP]+2,DX

                mov     SI,offset Msg_IRQ_Handler_Replaced
loc_print_0:
                lodsb                           ; Load byte at DS:SI to AL
		and     AL,AL            
                jz      short loc_exit_0         ; If AL = 00h then return
		mov     AH,0Eh                  
		mov     BX,07h             
		int     10h                     ; BIOS Service func ( ah ) = 0Eh
						; Write char as TTY
						;AL-char BH-page BL-color
                jmp     short loc_print_0           
loc_exit_0:
                mov     DX,offset load  
		int	27h			; Terminate and stay resident
						;DX-offset of non-resident part
Msg_IRQ_Handler_Replaced:
                db      "IRQ 15 (INT 77h) Handler has been replaced..."
                db      0Ah, 0Dh, 0h

proc_load       endp

CODE_SEG_1	ends


		end	start
