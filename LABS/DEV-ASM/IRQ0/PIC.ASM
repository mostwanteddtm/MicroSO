;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; PIC.asm - Contains the Programmable Interrupt Controller interface routines
;;           for the kernel.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

IRQMap      dd 0FFFFFFFFh   ; 32bit (LSb to MSb) map of IRQs: 1 = Off, 0 = On

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; RemapPICToProtectedMode - Remaps IRQs from the BIOS defaults interrupts to
;;                           INT 20h - 2Fh.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

RemapPICToProtectedMode:

    push eax
    
    mov al,11h              ; Initialization Command Word (ICW) 1
    out 20h,al              ; Into first PIC
    out 0A0h,al             ; Into casscaded second PIC

    mov al,20h              ; Load starting interrupt 20h (ICW2)
    out 21h,al              ; Into first PIC
    mov al,28h              ; Load starting interrupt 28h
    out 0A1h,al             ; Into second PIC

    mov al,04h              ; ICW3
    out 21h,al              ; First PIC
    mov al,02h              ; ICW3
    out 0A1h,al             ; Second PIC

    mov al,01h              ; ICW4
    out 21h,al              ; First PIC
    out 0A1h,al             ; Second PIC
    
    pop eax
    
    ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; RemapPICToRealMode - Remaps IRQs from the BIOS defaults interrupts to
;;                           INT 20h - 2Fh.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

RemapPICToRealMode:

    push eax
    
    mov al,11h              ; Initialization Command Word (ICW) 1
    out 20h,al              ; Into first PIC
    out 0A0h,al             ; Into casscaded second PIC

    mov al,08h              ; Load starting interrupt 08h (ICW2)
    out 21h,al              ; Into first PIC
    mov al,70h              ; Load starting interrupt 70h
    out 0A1h,al             ; Into second PIC

    mov al,04h              ; ICW3
    out 21h,al              ; First PIC
    mov al,02h              ; ICW3
    out 0A1h,al             ; Second PIC

    mov al,01h              ; ICW4
    out 21h,al              ; First PIC
    out 0A1h,al             ; Second PIC
    
    pop eax
    
    ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; DisableAllIRQs - Disables all IRQs regardless of masking:
;;
;; Operation Command Word 1: 
;;
;;  |7|6|5|4|3|2|1|0|  OCW1 - IMR Interrupt Mask Register
;;   | | | | | | | `---- 0 = service IRQ0 or IRQ8, 1 = mask off
;;   | | | | | | `----- 0 = service IRQ1 or IRQ9, 1 = mask off
;;   | | | | | `------ 0 = service IRQ2 or IRQA, 1 = mask off
;;   | | | | `------- 0 = service IRQ3 or IRQB, 1 = mask off
;;   | | | `-------- 0 = service IRQ4 or IRQC, 1 = mask off
;;   | | `--------- 0 = service IRQ5 or IRQD, 1 = mask off
;;   | `---------- 0 = service IRQ6 or IRQE, 1 = mask off
;;   `----------- 0 = service IRQ7 or IRQF, 1 = mask off
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    
DisableAllIRQs:

    push eax

    mov al,0FFh             ; Turn all IRQs off             
    out 21h,al              ; First PIC
    out 0A1h,al             ; Second PIC
    
    pop eax

    ret
    
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; EnableAllMaskedIRQs - Enables all masked IRQs.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

EnableAllMaskedIRQs:

    push eax
    push ebx

    cli

    mov ebx,[IRQMap]        ; Load current IRQ bitmap
    mov al,bl               ; First 8 IRQs mapped
    out 021h,al
    
    mov al,bh               ; Second 8 IRQs mapped
    out 0A1h,al
    
    sti
    
    pop ebx
    pop eax

    ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; EnableAllIRQs - Enables all IRQs.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

EnableAllIRQs:

    push eax

    cli

    mov al,0                    ; First 8 IRQs mapped
    out 021h,al
    
    mov al,0                ; Second 8 IRQs mapped
    out 0A1h,al
    
    sti
    
    pop eax

    ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; EnableAnIRQ - Enables one IRQ based on 32bits.
;;
;; Input:   EAX contains IRQ number to enable.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

EnableAnIRQ:

    push eax
    push ebx
    push ecx
    
    mov ecx,eax
    mov eax,1
    shl eax,cl
    not eax
    
    and eax,[IRQMap]
    mov [IRQMap],eax
    
    call EnableAllMaskedIRQs
    
    pop ecx
    pop ebx
    pop eax
    
    ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; DisableAnIRQ - Disables one IRQ based on 32bits.
;;
;; Input:   EAX contains IRQ number to disable.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

DisableAnIRQ:

    push eax
    push ebx
    push ecx

    mov ebx,eax
    mov eax,1
    mov ecx,ebx
    shl eax,cl

    or  eax,[IRQMap]
    mov [IRQMap],eax
    
    call EnableAllMaskedIRQs
    
    pop ecx
    pop ebx
    pop eax
    
    ret    
