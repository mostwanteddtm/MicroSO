;LOADEXE.ASM 
;Easy Way to get Any OS to Load a .EXE File 
;By Shawn T. Cook 
;Version 1.0 

;simply reads the .EXE to 8000:0  
;then does some stuff and runs the .EXE 

;Shows a 'E' if not a MZ header... 


Org 0x0100 


RunEXE:         

        push    cs 
        push    cs 
        pop     ds 
        pop     es
        
        mov     ah, 02h
        mov     al, 02h
        mov     ch, 00h
        mov     dh, 00h
        mov     cl, 01h
        mov     dl, 00h
        mov     bx, 0x8000 
        mov     es, bx
        xor     bx, bx
        int     13h

        mov     ax, 0x8000
        mov     es, ax

        cmp     es:[0], 5A4Dh           ; "MZ" signature?
        je      RelocateEXE             ; yes, it's an EXE program

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Setup and Run COM program ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

        mov     ax, es
        sub     ax, 10h                 ; "org 100h" stuff :)
        mov     es, ax
        mov     ds, ax
        mov     ss, ax
        xor     sp, sp
        push    es
        push    100h
        jmp     Run

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Relocate, setup and run EXE program ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

RelocateEXE:
        mov     ds, ax

        add     ax, ds:[08h]            ; ax = image base
        mov     cx, ds:[06h]            ; cx = reloc items
        mov     bx, ds:[18h]            ; bx = reloc table pointer

        jcxz    RelocationDone

ReloCycle:
        mov     di, ds:[bx]             ; di = item ofs
        mov     dx, ds:[bx+2]           ; dx = item seg (rel)
        add     dx, ax                  ; dx = item seg (abs)

        push    ds
        mov     ds, dx                  ; ds = dx
        add     ds:[di], ax             ; fixup
        pop     ds

        add     bx, 4                   ; point to next entry
        loop    ReloCycle

RelocationDone:

        mov     bx, ax
        add     bx, ds:[0Eh]
        mov     ss, bx                  ; ss for EXE
        mov     sp, ds:[10h]            ; sp for EXE

        add     ax, ds:[16h]            ; cs
        push    ax
        push    ds:[14h]                ; ip
Run:
        mov     dl, 0                   ; let program know boot drive
        sti
        retf