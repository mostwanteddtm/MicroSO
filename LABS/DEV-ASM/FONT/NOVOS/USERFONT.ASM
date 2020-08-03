;
; Assembly code for user defined fonts in VGA BIOS.
; Written by Rudi B. Stranden : w1118-7
;
; I use subservice 10h for VGA interface function 11h (chargen).
; Consult the video BIOS reference manual for more definitions.
;
; The program creates 256 fonts in RAM-memory.
; After setting some registers and pointing es:bp to our font in memory
; we call video interrupt 10h to make the change.
;
; Reset back fonts:
; 1. Change to textmode (03h) and call video-interrupt 10h.
; 2. Reboot your system
; 3. <TBA>
;

.286
.model tiny
.code
org 100h

main:
;
; Make predefined font (8x16). each font takes up 16 bytes,
; where each byte represents the row of pixels in the font.
; "The fonts are actually just bits that are incrementet so they
; just look scrambled." We are in standard textmode (03h).
;
xor ax,ax	;clear this register
mov bp,offset font	;set base pointer to font-offset

makefnt:
  mov [bp],al	;load bitpattern into memory
  inc bp	;increase basepointer
  inc ax	;increase bitpattern
  cmp ax,01000h	;compare to 16*256 = 4096
jnz makefnt	;jump if not cl equal to zero

;
; Setting up the calling registers - 
; es:bp points to our character table in memory
;
mov ax,1110h	;low bits are subservice	
mov bl,0	;some index to a user font buffer
mov bh,16	;bytes per char (also our height)
mov cx,256	;character count (we want change all 256, yes?)
xor dx,dx	;important to clear this (since we want the offset to be zero)
mov bp,offset font	;set base pointer to font-offset
hmm:
  int 10h	;call interrupt 10h 256 times.
  add bp,16	;basepointer should jump to next char (which is bp+=16 bytes)
  inc dl	;index to next char (starting index is 1, hence it wraps
  cmp dl,0ffh	;around to 0 and breaks).
jne hmm		;jump if not dl equal to zero

;
; Output all 256 characters to the screen, to see how they look:
;
push 0b800h	;push 0b800h to stack
pop es		;pop stack value to es. es is now: 0b800h
mov ah,07h	;gray (low four bits are fg, high are bg)
xor al,al	;reset these bits
xor di,di	;------"---------
write:
  stosw		;store ax at addr es:di(0b800h:di)
  cmp al,0ffh	;compare al with 255
  add al,1	;add one to al
jnz write	;loop 256 times

;
; Wait for escape-keypress to quit
;
;keypress:
;  in al,60h
;  dec al
;jnz keypress

;
; Go back to textmode : resets back to default BIOS fonts
;
;mov ax,0003h
;int 10h

ret
  font db ?	;some starting place in memory where we want to save our fonts
end main
