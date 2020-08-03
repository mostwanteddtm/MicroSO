
.286
.model tiny
.data
.code
org 100h
.STARTUP                    					;Make it a .com file 

        mov     ax, cs
        mov     ds, ax
        mov     es, ax
        push    es 

        mov     ax, 4f02h                  
	    mov		bx, 103h
        int     10h 
		
        mov     dx, 0A000h
		mov     ds, dx                          ;sets up registers
		call    window
		mov     cx, 10
rain:   xor     dx, dx                          ;(pages-1)
            
mainloop:   
		push    dx
		call    window
		xor     bx, bx
		mov     al, 0dCh
		call    static
		pop     dx
		cmp     dx, 7                           ;FOR 800X600 CHANGE THIS TO 7
		je      rain
		inc     dx
		loop    mainloop
		 
		jmp     init
            
window: mov     ax, 4F05h                       ;vesa 1 window select
		mov     bx, 0
		int     10h                             ;dx is the reqired window
		xor     bx, bx
		ret
            
static: mov     [bx], al                        ;(4*2^16)+45056 pixels
		inc     bx
		cmp     bx, 00000
		jne     static
		ret

init:   
		mov     ax, 4F05h                       ;vesa 1 window select
		mov     bx, 0
		xor		dx, dx
		int     10h
		
        mov     ax, cs
        mov     ds, ax
        mov     es, ax     
        mov     bp, offset font_data

        mov     word ptr [font_data],bp      	; Fill the variable with the pointer to the specified font(8x16). 
        mov     word ptr [font_data+2],es    	; ^^^^^^^^ 

        push    0A000h                   		;Setup es for writing to the screen(A000h = start of screen buffer). 
        pop     es                       		;^^^^ 
        mov     di, 0             				;Start location to start writing pixels. 64 lines down and 48 across. 
        mov     si, offset _hello                ;Set si up with location of the "Hello, World!" string. 
  draw_text:  
        lodsb                            		;Load a byte of the string into al. 
        test    al,al                    		;Is it zero? 
        jz      done                     		;If so, we're done. 
        push    ds 		
        push    si                       		;If not, push ds and si 
        lds     si,[font_data]           		;Load DS:SI the font data SEGMENT:OFFSET.So now DS points to the font segment, and SI is the offset. 
        xor     ah,ah                    		;zero out the top of ax 
        shl     ax,4                     		;Multiply the current byte of the string by 16(hint, the font is 8x16, stored as 8 pixels per byte) 
        add     si,ax                    		;Add that to the start offset of the font data. SI now points to the start of the pixel data for the current character.
        mov     bx,16   
   draw_character:  
        mov     dl,[si]  
        mov     cx,8
        push    di 
    draw_row:  
        shl     dl,1  
        jnc     next_point  
		mov		al, 0fh
        mov     byte ptr es:[di],al
        mov     byte ptr es:[di+1],al   
      next_point:  
        add     di,1  
        loop    draw_row  
        inc     si
        pop     di 
        add     di, 800  
        ;add     di,(320-8)*2  
        dec     bx   
        jnz     draw_character  
        ;sub     di,320*2*16-(8+1)*2 
        sub     di, (800*16) - 8
        pop     si 
        pop     ds  
        jmp     draw_text  
  done: 
        xor     ah,ah                    		; 
        int     16h                      		;Wait for a keypress 
		
        mov     ax,3                     		;Set mode 3, the normal console mode 
        int     10h                      		;^^^^^^^^^^^ 
        int     20h                      		        ;And....exit. 

_hello      db 'Iniciando o desenvolvimento com o VESA Bios Extensions 800x600 px',0 
 
font_data   dd 0
; terminus 4.38 (8x16, normal)
; quickly converted for FreeDOS (GNUchcp/loadfnt)

; 0000:
db 12h dup(0), 7Eh, 81h, 0A5h, 2 dup(81h), 0BDh, 99h, 81h
		db 7Eh,	7 dup(0), 7Eh, 0FFh, 0DBh, 2 dup(0FFh),	0C3h, 0E7h
		db 0FFh, 7Eh, 8	dup(0),	36h, 4 dup(7Fh), 3Eh, 1Ch, 8, 8	dup(0)
		db 8, 1Ch, 3Eh,	7Fh, 3Eh, 1Ch, 8, 7 dup(0), 18h, 2 dup(3Ch)
		db 3 dup(0E7h),	3Ch, 2 dup(18h), 3Ch, 7	dup(0),	18h, 3Ch
		db 7Eh,	2 dup(0FFh), 7Eh, 2 dup(18h), 3Ch, 0Ah dup(0)
		db 18h,	2 dup(3Ch), 18h, 7 dup(0), 5 dup(0FFh),	0E7h, 0C3h
		db 81h,	0E7h, 7	dup(0FFh), 4 dup(0), 3Ch, 66h, 2 dup(42h)
		db 66h,	3Ch, 6 dup(0), 4 dup(0FFh), 0C3h, 99h, 2 dup(0BDh)
		db 99h,	0C3h, 6	dup(0FFh), 2 dup(0), 0Fh, 7, 0Dh, 19h
		db 3Ch,	3 dup(66h), 3Ch, 7 dup(0), 3Ch,	3 dup(66h), 3Ch
		db 18h,	7Eh, 2 dup(18h), 7 dup(0), 3Fh,	33h, 3Fh, 3 dup(30h)
		db 70h,	0F0h, 0E0h, 7 dup(0), 7Fh, 63h,	7Fh, 3 dup(63h)
		db 67h,	0E7h, 0E6h, 60h, 6 dup(0), 2 dup(18h), 0DBh, 3Ch
		db 0E7h, 3Ch, 0DBh, 2 dup(18h),	7 dup(0), 40h, 60h, 70h
		db 7Ch,	7Fh, 7Ch, 70h, 60h, 40h, 7 dup(0), 1, 3, 7, 1Fh
		db 7Fh,	1Fh, 7,	3, 1, 7	dup(0),	18h, 3Ch, 7Eh, 3 dup(18h)
		db 7Eh,	3Ch, 18h, 7 dup(0), 22h, 3 dup(77h), 2 dup(22h)
		db 0, 2	dup(22h), 7 dup(0), 7Eh, 3 dup(94h), 7Ch, 3 dup(14h)
		db 3Eh,	6 dup(0), 3Eh, 63h, 30h, 1Ch, 36h, 2 dup(63h)
		db 36h,	1Ch, 6,	63h, 3Eh, 0Bh dup(0), 3	dup(7Fh), 7 dup(0)
		db 18h,	3Ch, 7Eh, 3 dup(18h), 7Eh, 3Ch,	18h, 6 dup(0)
		db 18h,	3Ch, 7Eh, 6 dup(18h), 8	dup(0),	6 dup(18h), 7Eh
		db 3Ch,	18h, 9 dup(0), 0Ch, 6, 0FFh, 6,	0Ch, 0Bh dup(0)
		db 18h,	30h, 7Fh, 30h, 18h, 0Ch	dup(0),	3 dup(60h), 7Fh
		db 0Bh dup(0), 24h, 66h, 0FFh, 66h, 24h, 0Bh dup(0), 2 dup(18h)
		db 2 dup(3Ch), 2 dup(7Eh), 0Ah dup(0), 2 dup(7Eh), 2 dup(3Ch)
		db 2 dup(18h), 18h dup(0), 8, 3	dup(1Ch), 2 dup(8), 0
		db 2 dup(8), 6 dup(0), 2 dup(66h), 2 dup(22h), 0Dh dup(0)
		db 2 dup(24h), 7Eh, 3 dup(24h),	7Eh, 2 dup(24h), 5 dup(0)
		db 2 dup(0Ch), 3Fh, 43h, 41h, 40h, 3Eh,	1, 2 dup(41h)
		db 3Eh,	2 dup(0Ch), 7 dup(0), 61h, 63h,	6, 0Ch,	18h, 33h
		db 63h,	7 dup(0), 38h, 44h, 48h, 30h, 20h, 52h,	4Ch, 46h
		db 39h,	6 dup(0), 2 dup(60h), 2	dup(20h), 0Dh dup(0), 0Ch
		db 10h,	5 dup(20h), 10h, 0Ch, 7	dup(0),	18h, 4,	5 dup(2)
		db 4, 18h, 9 dup(0), 66h, 3Ch, 0FFh, 3Ch, 66h, 0Ah dup(0)
		db 3 dup(8), 7Fh, 3 dup(8), 0Eh	dup(0),	3 dup(18h), 30h
		db 0Bh dup(0), 7Fh, 11h	dup(0),	2 dup(18h), 7 dup(0), 1
		db 3, 6, 0Ch, 18h, 30h,	60h, 0C0h, 80h,	7 dup(0), 1Ch
		db 22h,	5 dup(41h), 22h, 1Ch, 7	dup(0),	1Ch, 7 dup(4)
		db 1Fh,	7 dup(0), 3Eh, 41h, 1, 2, 4, 8,	10h, 21h, 7Fh
		db 7 dup(0), 3Eh, 41h, 2 dup(1), 1Eh, 2	dup(1),	41h, 3Eh
		db 7 dup(0), 6,	0Ah, 12h, 22h, 42h, 7Fh, 2 dup(2), 0Fh
		db 7 dup(0), 7Fh, 3 dup(40h), 7Eh, 2 dup(1), 41h, 3Eh
		db 7 dup(0), 1Eh, 20h, 2 dup(40h), 7Eh,	3 dup(41h), 3Eh
		db 7 dup(0), 7Fh, 41h, 1, 2, 4,	8, 10h,	2 dup(20h), 7 dup(0)
		db 3Eh,	3 dup(41h), 3Eh, 3 dup(41h), 3Eh, 7 dup(0), 3Eh
		db 3 dup(41h), 3Fh, 2 dup(1), 2, 3Ch, 8	dup(0),	2 dup(18h)
		db 2 dup(0), 2 dup(18h), 0Ah dup(0), 2 dup(18h), 3 dup(0)
		db 2 dup(18h), 30h, 7 dup(0), 6, 0Ch, 18h, 30h,	60h, 30h
		db 18h,	0Ch, 6,	0Ah dup(0), 7Eh, 2 dup(0), 7Eh,	9 dup(0)
		db 60h,	30h, 18h, 0Ch, 6, 0Ch, 18h, 30h, 60h, 7	dup(0)
		db 3Eh,	2 dup(41h), 6, 2 dup(4), 0, 2 dup(0Eh),	7 dup(0)
		db 3Eh,	2 dup(41h), 4Fh, 49h, 4Fh, 2 dup(40h), 3Eh, 7 dup(0)
		db 8, 1Ch, 36h,	2 dup(22h), 3Eh, 2 dup(22h), 77h, 7 dup(0)
		db 7Eh,	3 dup(21h), 3Eh, 3 dup(21h), 7Eh, 7 dup(0), 1Eh
		db 23h,	41h, 4 dup(40h), 21h, 1Eh, 7 dup(0), 7Eh, 7 dup(21h)
		db 7Eh,	7 dup(0), 7Fh, 2 dup(21h), 24h,	3Ch, 24h, 2 dup(21h)
		db 7Fh,	7 dup(0), 7Fh, 2 dup(21h), 24h,	3Ch, 24h, 2 dup(20h)
		db 78h,	7 dup(0), 1Eh, 23h, 41h, 2 dup(40h), 4Fh, 41h
		db 21h,	1Eh, 7 dup(0), 77h, 3 dup(22h),	3Eh, 3 dup(22h)
		db 77h,	7 dup(0), 3Eh, 7 dup(8), 3Eh, 7	dup(0),	0Fh, 5 dup(2)
		db 2 dup(42h), 3Ch, 7 dup(0), 77h, 22h,	24h, 28h, 30h
		db 28h,	24h, 22h, 73h, 7 dup(0), 70h, 5	dup(20h), 2 dup(21h)
		db 7Fh,	7 dup(0), 0C3h,	2 dup(66h), 2 dup(5Ah),	3 dup(42h)
		db 0E7h, 7 dup(0), 67h,	2 dup(32h), 3Ah, 2Ah, 2Eh
		db 2 dup(26h), 72h, 7 dup(0), 3Eh, 7 dup(41h), 3Eh, 7 dup(0)
		db 7Eh,	3 dup(21h), 3Eh, 3 dup(20h), 70h, 7 dup(0), 1Ch
		db 22h,	5 dup(41h), 36h, 9, 36h, 6 dup(0), 7Eh,	3 dup(21h)
		db 3Eh,	22h, 2 dup(21h), 71h, 7	dup(0),	3Dh, 43h, 41h
		db 20h,	1Ch, 2,	41h, 61h, 5Eh, 7 dup(0), 7Fh, 2	dup(49h)
		db 5 dup(8), 1Ch, 7 dup(0), 0E7h, 7 dup(42h), 3Ch, 7 dup(0)
		db 0E7h, 6 dup(42h), 24h, 18h, 7 dup(0), 0E7h, 4 dup(42h)
		db 2 dup(5Ah), 2 dup(66h), 7 dup(0), 0E7h, 42h,	2 dup(24h)
		db 18h,	2 dup(24h), 42h, 0E7h, 7 dup(0), 77h, 2	dup(22h)
		db 14h,	4 dup(8), 1Ch, 7 dup(0), 7Fh, 41h, 42h,	4, 8, 10h
		db 21h,	41h, 7Fh, 7 dup(0), 3Ch, 7 dup(30h), 3Ch, 7 dup(0)
		db 40h,	60h, 70h, 38h, 1Ch, 0Eh, 7, 3, 1, 7 dup(0), 3Ch
		db 7 dup(0Ch), 3Ch, 5 dup(0), 8, 1Ch, 36h, 63h,	17h dup(0)
		db 0FFh, 4 dup(0), 2 dup(18h), 0Ch, 12h	dup(0),	3Eh, 2
		db 3Eh,	2 dup(42h), 3Dh, 7 dup(0), 60h,	2 dup(20h), 3Eh
		db 3 dup(21h), 31h, 6Eh, 0Ah dup(0), 3Eh, 41h, 2 dup(40h)
		db 41h,	3Eh, 7 dup(0), 6, 2 dup(2), 1Eh, 22h, 2	dup(42h)
		db 46h,	3Bh, 0Ah dup(0), 3Eh, 41h, 7Fh,	40h, 41h, 3Eh
		db 7 dup(0), 1Eh, 3 dup(20h), 7Ch, 3 dup(20h), 78h, 0Ah	dup(0)
		db 3Fh,	3 dup(42h), 3Eh, 2 dup(2), 3Ch,	5 dup(0), 60h
		db 2 dup(20h), 2Ch, 32h, 3 dup(22h), 77h, 8 dup(0), 0Ch
		db 0, 1Ch, 4 dup(4), 1Fh, 8 dup(0), 6, 0, 0Eh, 5 dup(2)
		db 3Ch,	6 dup(0), 60h, 20h, 27h, 22h, 24h, 38h,	24h, 22h
		db 77h,	7 dup(0), 1Ch, 7 dup(4), 1Fh, 0Ah dup(0), 0E6h
		db 2 dup(5Ah), 2 dup(42h), 0E3h, 0Ah dup(0), 6Ch, 32h
		db 3 dup(22h), 77h, 0Ah	dup(0),	3Eh, 4 dup(41h), 3Eh, 0Ah dup(0)
		db 6Eh,	31h, 2 dup(21h), 3Eh, 2	dup(20h), 78h, 8 dup(0)
		db 3Bh,	46h, 2 dup(42h), 3Eh, 2	dup(2),	0Fh, 8 dup(0)
		db 6Eh,	32h, 3 dup(20h), 78h, 0Ah dup(0), 3Eh, 43h, 38h
		db 0Eh,	63h, 3Eh, 7 dup(0), 3 dup(10h),	7Eh, 3 dup(10h)
		db 11h,	0Eh, 0Ah dup(0), 66h, 3	dup(22h), 26h, 3Bh, 0Ah	dup(0)
		db 0E7h, 3 dup(42h), 24h, 18h, 0Ah dup(0), 0E7h, 42h, 2	dup(5Ah)
		db 2 dup(66h), 0Ah dup(0), 77h,	22h, 1Ch, 14h, 22h, 77h
		db 0Ah dup(0), 77h, 3 dup(22h),	14h, 8,	10h, 78h, 8 dup(0)
		db 7Fh,	41h, 6,	18h, 21h, 7Fh, 7 dup(0), 0Eh, 3	dup(18h)
		db 70h,	3 dup(18h), 0Eh, 7 dup(0), 4 dup(18h), 0, 4 dup(18h)
		db 7 dup(0), 70h, 3 dup(18h), 1Ch, 3 dup(18h), 70h, 7 dup(0)
		db 3Bh,	6Eh, 11h dup(0), 8, 1Ch, 36h, 3	dup(63h), 7Fh
		db 6 dup(0), 1Eh, 33h, 61h, 2 dup(60h),	61h, 63h, 3Eh
		db 6, 3, 3Eh, 5	dup(0),	2 dup(66h), 0, 5 dup(66h), 3Bh
		db 6 dup(0), 6,	0Ch, 18h, 0, 3Eh, 63h, 7Fh, 60h, 63h, 3Eh
		db 5 dup(0), 8,	1Ch, 36h, 63h, 0, 3Eh, 2, 3Eh, 2 dup(42h)
		db 3Dh,	7 dup(0), 2 dup(66h), 0, 3Ch, 6, 3Eh, 2	dup(66h)
		db 3Bh,	6 dup(0), 30h, 18h, 0Ch, 0, 3Ch, 6, 3Eh, 2 dup(66h)
		db 3Bh,	6 dup(0), 1Ch, 36h, 1Ch, 0, 3Ch, 6, 3Eh, 2 dup(66h)
		db 3Bh,	0Ah dup(0), 3Ch, 66h, 60h, 66h,	3Ch, 6,	3Ch, 4 dup(0)
		db 8, 1Ch, 36h,	63h, 0,	3Eh, 41h, 7Fh, 40h, 41h, 3Eh, 7	dup(0)
		db 2 dup(66h), 0, 3Eh, 63h, 7Fh, 60h, 63h, 3Eh,	6 dup(0)
		db 30h,	18h, 0Ch, 0, 3Eh, 63h, 7Fh, 60h, 63h, 3Eh, 7 dup(0)
		db 2 dup(36h), 0, 1Ch, 4 dup(0Ch), 1Eh,	5 dup(0), 8, 1Ch
		db 36h,	63h, 0,	1Ch, 4 dup(4), 1Fh, 6 dup(0), 60h, 30h
		db 18h,	0, 38h,	4 dup(18h), 3Ch, 6 dup(0), 2 dup(63h)
		db 8, 1Ch, 36h,	2 dup(63h), 7Fh, 2 dup(63h), 5 dup(0)
		db 1Ch,	36h, 1Ch, 0, 1Ch, 36h, 2 dup(63h), 7Fh,	2 dup(63h)
		db 5 dup(0), 0Ch, 18h, 30h, 0, 7Fh, 33h, 30h, 3Eh, 30h
		db 33h,	7Fh, 0Ah dup(0), 7Ch, 12h, 7Eh,	90h, 92h, 6Ch
		db 7 dup(0), 1Fh, 29h, 48h, 4Ah, 7Eh, 4Ah, 48h,	49h, 0EFh
		db 5 dup(0), 8,	1Ch, 36h, 63h, 0, 3Eh, 4 dup(41h), 3Eh
		db 7 dup(0), 2 dup(63h), 0, 3Eh, 4 dup(63h), 3Eh, 6 dup(0)
		db 30h,	18h, 0Ch, 0, 3Eh, 4 dup(63h), 3Eh, 5 dup(0), 8
		db 1Ch,	36h, 63h, 0, 66h, 3 dup(22h), 26h, 3Bh,	6 dup(0)
		db 30h,	18h, 0Ch, 0, 5 dup(66h), 3Bh, 7	dup(0),	2 dup(63h)
		db 0
		db 4 dup(63h), 3Fh, 3, 6, 3Ch, 4 dup(0), 2 dup(63h), 1Ch
		db 36h,	4 dup(63h), 36h, 1Ch, 6	dup(0),	2 dup(63h), 0
		db 6 dup(63h), 3Eh, 6 dup(0), 2	dup(18h), 7Eh, 0C3h, 2 dup(0C0h)
		db 0C3h, 7Eh, 2	dup(18h), 6 dup(0), 1Ch, 36h, 2	dup(30h)
		db 78h,	3 dup(30h), 73h, 7Eh, 7	dup(0),	77h, 2 dup(22h)
		db 14h,	8, 7Fh,	8, 7Fh,	8, 1Ch,	6 dup(0), 0FCh,	3 dup(42h)
		db 7Ch,	40h, 44h, 4Eh, 0E4h, 2 dup(4), 3, 3 dup(0), 0Eh
		db 11h,	3 dup(10h), 7Eh, 4 dup(10h), 90h, 60h, 4 dup(0)
		db 0Ch,	18h, 30h, 0, 3Ch, 6, 3Eh, 2 dup(66h), 3Bh, 6 dup(0)
		db 0Ch,	18h, 30h, 0, 38h, 4 dup(18h), 3Ch, 6 dup(0), 0Ch
		db 18h,	30h, 0,	3Eh, 4 dup(63h), 3Eh, 6	dup(0),	0Ch, 18h
		db 30h,	0, 5 dup(66h), 3Bh, 7 dup(0), 3Bh, 6Eh,	0, 6Ch
		db 32h,	3 dup(22h), 77h, 5 dup(0), 3Bh,	6Eh, 0,	67h, 2 dup(32h)
		db 3Ah,	2Ah, 2Eh, 2 dup(26h), 72h, 5 dup(0), 3Ch, 2 dup(6Ch)
		db 3Eh,	0, 7Eh,	0Ah dup(0), 38h, 2 dup(6Ch), 38h, 0, 7Ch
		db 0Bh dup(0), 2 dup(70h), 0, 2	dup(20h), 60h, 2 dup(82h)
		db 7Ch,	0Bh dup(0), 7Fh, 2 dup(60h), 0Dh dup(0), 7Fh, 2	dup(3)
		db 8 dup(0), 0C0h, 40h,	41h, 42h, 44h, 0E8h, 16h, 29h
		db 42h,	84h, 8,	0Fh, 4 dup(0), 0C0h, 40h, 41h, 42h, 44h
		db 0E8h, 12h, 26h, 4Ah,	9Fh, 2 dup(2), 5 dup(0), 2 dup(8)
		db 0, 2	dup(8),	3 dup(1Ch), 8, 9 dup(0), 1Bh, 36h, 6Ch
		db 36h,	1Bh, 0Bh dup(0), 6Ch, 36h, 1Bh,	36h, 6Ch, 7 dup(0)
		db 11h,	44h, 11h, 44h, 11h, 44h, 11h, 44h, 11h,	44h, 11h
		db 44h,	11h, 44h, 11h, 44h, 55h, 0AAh, 55h, 0AAh, 55h
		db 0AAh, 55h, 0AAh, 55h, 0AAh, 55h, 0AAh, 55h, 0AAh, 55h
		db 0AAh, 0DDh, 77h, 0DDh, 77h, 0DDh, 77h, 0DDh,	77h, 0DDh
		db 77h,	0DDh, 77h, 0DDh, 77h, 0DDh, 77h, 17h dup(18h)
		db 0F8h, 0Dh dup(18h), 0F8h, 18h, 0F8h,	8 dup(18h), 7 dup(36h)
		db 0F6h, 8 dup(36h), 7 dup(0), 0FEh, 8 dup(36h), 5 dup(0)
		db 0F8h, 18h, 0F8h, 8 dup(18h),	5 dup(36h), 0F6h, 6, 0F6h
a66666666666666	db '666666666666666666666666',0
		db 4 dup(0), 0FEh, 6, 0F6h, 0Dh	dup(36h), 0F6h,	6, 0FEh
		db 8 dup(0), 7 dup(36h), 0FEh, 8 dup(0), 5 dup(18h), 0F8h
		db 18h,	0F8h, 0Fh dup(0), 0F8h,	0Fh dup(18h), 1Fh, 8 dup(0)
		db 7 dup(18h), 0FFh, 0Fh dup(0), 0FFh, 0Fh dup(18h), 1Fh
		db 8 dup(18h), 7 dup(0), 0FFh, 8 dup(0), 7 dup(18h), 0FFh
		db 0Dh dup(18h), 1Fh, 18h, 1Fh,	8 dup(18h)
a66666667666666	db '66666667666666666666670?',0
		db 0Ch dup(0), 3Fh, 30h, 37h, 0Dh dup(36h), 0F7h, 0, 0FFh
		db 0Dh dup(0), 0FFh, 0,	0F7h
a66666666666667	db '666666666666670766666666',0
		db 4 dup(0), 0FFh, 0, 0FFh, 8 dup(0), 5	dup(36h), 0F7h
		db 0, 0F7h, 8 dup(36h),	5 dup(18h), 0FFh, 0, 0FFh, 8 dup(0)
		db 7 dup(36h), 0FFh, 0Dh dup(0), 0FFh, 0, 0FFh,	8 dup(18h)
		db 7 dup(0), 0FFh, 0Fh dup(36h), 3Fh, 8	dup(0),	5 dup(18h)
		db 1Fh,	18h, 1Fh, 0Dh dup(0), 1Fh, 18h,	1Fh, 8 dup(18h)
		db 7 dup(0), 3Fh, 0Fh dup(36h),	0FFh, 8	dup(36h), 5 dup(18h)
		db 0FFh, 18h, 0FFh, 0Fh	dup(18h), 0F8h,	0Fh dup(0), 1Fh
		db 8 dup(18h), 10h dup(0FFh), 8	dup(0),	8 dup(0FFh), 10h dup(0F0h)
		db 10h dup(0Fh), 8 dup(0FFh), 0Dh dup(0), 3Bh, 6Eh, 2 dup(6Ch)
		db 6Eh,	3Bh, 9 dup(0), 3Eh, 63h, 7Eh, 2	dup(63h), 7Eh
		db 2 dup(60h), 20h, 5 dup(0), 7Fh, 2 dup(63h), 6 dup(60h)
		db 9 dup(0), 7Fh, 6 dup(36h), 7	dup(0),	7Fh, 63h, 30h
		db 18h,	0Ch, 18h, 30h, 63h, 7Fh, 0Ah dup(0), 3Eh, 4 dup(6Ch)
		db 38h,	9 dup(0), 4 dup(33h), 3Eh, 2 dup(30h), 60h, 8 dup(0)
		db 3Bh,	6Eh, 5 dup(0Ch), 7 dup(0), 7Eh,	18h, 3Ch, 3 dup(66h)
		db 3Ch,	18h, 7Eh, 7 dup(0), 1Ch, 36h, 2	dup(63h), 7Fh
		db 2 dup(63h), 36h, 1Ch, 7 dup(0), 1Ch,	36h, 3 dup(63h)
		db 36h,	1Ch, 2 dup(36h), 77h, 6	dup(0),	1Eh, 30h, 18h
		db 0Ch,	3Eh, 3 dup(66h), 3Ch, 0Ah dup(0), 7Eh, 2 dup(0DBh)
		db 7Eh,	9 dup(0), 3, 6,	7Eh, 2 dup(0DBh), 0F3h,	7Eh, 60h
		db 0C0h, 7 dup(0), 1Ch,	30h, 2 dup(60h), 7Ch, 2	dup(60h)
		db 30h,	1Ch, 9 dup(0), 3Eh, 7 dup(63h),	8 dup(0), 7Fh
		db 0, 2	dup(7Fh), 0, 7Fh, 8 dup(0), 3 dup(18h),	0FFh, 3	dup(18h)
		db 0, 0FFh, 7 dup(0), 30h, 18h,	0Ch, 6,	0Ch, 18h, 30h
		db 0, 0FFh, 7 dup(0), 0Ch, 18h,	30h, 60h, 30h, 18h, 0Ch
		db 0, 0FFh, 7 dup(0), 0Eh, 2 dup(1Bh), 13h dup(18h), 2 dup(0D8h)
		db 70h,	7 dup(0), 2 dup(18h), 2	dup(0),	0FFh, 2	dup(0)
		db 2 dup(18h), 9 dup(0), 3Bh, 6Eh, 0, 3Bh, 6Eh,	8 dup(0)
		db 38h,	2 dup(6Ch), 38h, 11h dup(0), 2 dup(18h), 0Fh dup(0)
		db 30h,	9 dup(0), 0Fh, 5 dup(0Ch), 0ECh, 6Ch, 3Ch, 1Ch
		db 6 dup(0), 0D8h, 5 dup(6Ch), 0Ah dup(0), 70h,	0D8h, 30h
		db 60h,	0C8h, 0F8h, 0Dh	dup(0),	6 dup(3Ch), 16h	dup(0)

; EOF


end