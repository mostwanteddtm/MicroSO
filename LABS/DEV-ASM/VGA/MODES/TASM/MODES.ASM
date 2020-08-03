;;
;;MODES.ASM - to switch from mode 03h (80x25x16 text) to mode 013h (320x200x256 graphics)
;;without using the VGA BIOS. This sample also demonstrates the setting of the text mode font,
;;and the use of a custom palette.
;;
;;(C) Copyright 1997 Anthony A.J.Williams. All Rights Reserved, This source code may be
;;freely distributed unmodified, so long as it is free of charge.
;;Any part of this code may be used in other programs provided that credit is given to me
;;
;;Thanks to David Lindauer for his help in debugging this program, and in providing me with
;;essential information.
;;


model large
stack 1024

ideal
smart
jumps

MISC = 03c2h
SEQUENCER = 03c4h
CRTC = 03d4h
GRAPHICS = 03ceh
FEATURE = 03dah
ATTRIB = 03c0h
PELADDRESSWRITE = 03c8h
PELDATAREG = 03c9h
STATUS = 03dah

GRREGWRMODE = 5
GRREGMISC = 6
SQREGMAPMASK = 2
SQREGMEMORY = 4

BYTESPERFONT = 16
PALETTELEN = 256
NUMSEQUENCER = 5
NUMCRTC = 19h
NUMGRAPHICS = 9
NUMATTRIB = 15h

VREND=011h
NOPROT=07fh

ENABLEATTRIB = 020h

CURSORTOPDATA = 17
CURSORBOTTOMDATA = 18

BIOSMODE = 049h
COLUMNS = 04ah
CURSORTOP = 061h
CURSORBOTTOM = 060h
PAGESIZE = 04ch
PAGEOFFSET = 04eh
PAGENUM = 062h
MODESELVAL = 065h

macro IODELAY
 REPT 8
  jmp $+2
 ENDM
endm

codeseg

p386

proc OutRegs                            ;Output CL registers to port DX
 xor al,al                              ;start at reg 0
@@loop:                                 ;
 mov ah,[si]                            ;load data
 inc si                                 ;update source
 out dx,ax                              ;output data
 IODELAY
 inc al                                 ;increase register number
 dec cl                                 ;decrease count
 jnz @@loop                             ;loop whilst still OK
 ret                                    ;and exit
endp                                    ;

proc SetModeRegs                        ;set VGA registers for mode data
                                        ;pointed to by SI
 mov dx,STATUS                          ;get retrace reg
@@1:                                    ;
 in al,dx                               ;get value
 IODELAY                                ;delay
 test al,8                              ;check for vertical retrace bit
 jnz @@1                                ;loop until clear
@@2:                                    ;
 in al,dx                               ;get value
 IODELAY                                ;delay
 test al,8                              ;check for retrace again
 jz @@2                                 ;loop until it's set this time
                                        ;so we get start of ret. to set mode
 mov es,[Seg0040]                       ;load BIOS segment
 xor ah,ah                              ;zero AH
 mov al,[si]                            ;load BIOS mode number
 seges mov [BIOSMODE],al                ;store mode number
 inc si                                 ;update SI
 mov al,[si]                            ;load number of columns
 seges mov [COLUMNS],al                 ;store number of columns
 inc si                                 ;update SI
 mov di,[si]                            ;load Screen Seg
 mov [VidSeg],di                        ;store video segment
 add si,2                               ;update SI
 mov al,[si+CURSORTOPDATA]              ;get cursor top data
 seges mov [CURSORTOP],al               ;store it
 mov al,[si+CURSORBOTTOMDATA]           ;get cursor bottom data
 seges mov [CURSORBOTTOM],al            ;store it
 mov dx,MISC                            ;get VGA MISC reg num
 mov al,[si]                            ;load AL
 inc si                                 ;update source
 out dx,al                              ;output to port
 IODELAY
 mov dx,FEATURE                         ;get Feature controller number
 mov al,[si]                            ;load data
 inc si                                 ;update source
 out dx,al                              ;output register data
 IODELAY
 mov dx,SEQUENCER                       ;get sequencer port number
 mov cl,NUMSEQUENCER                    ;get number of regs to set
 call OutRegs                           ;do them
 mov ah,[si+VREND]                      ;load CRTC VREND byte
 mov al,VREND                           ;load reg number
 and ah,NOPROT                          ;clear protection bit
 mov dx,CRTC                            ;CRTC port number
 out dx,ax                              ;no protection
 IODELAY
 mov cl,NUMCRTC                         ;number of CRTC regs
 call OutRegs                           ;output to port
 mov dx,GRAPHICS                        ;get graphics port number
 mov cl,NUMGRAPHICS                     ;get number of regs
 call OutRegs                           ;do it
 mov dx,FEATURE                         ;load feature controller port
 in al,dx                               ;reset attrib flip flop by reading
 IODELAY
 mov dx,ATTRIB                          ;attribute controller port
 mov cl,NUMATTRIB                       ;number of regs
 xor al,al                              ;clear AL
@@loop:                                 ;
 mov ah,[si]                            ;load AH
 out dx,al                              ;output to port
 IODELAY                                ;delay before register write
 xchg al,ah                             ;swap data/reg num
 out dx,al                              ;output to port
 xchg ah,al                             ;swap back
 inc al                                 ;next reg
 inc si                                 ;increase source
 cmp al,cl                              ;done yet?
 jb @@loop                              ;loop until done
 mov al,ENABLEATTRIB                    ;enable attribute register reads
 out dx,al                              ;do it
 IODELAY
 ret                                    ;and exit
endp                                    ;

proc WritePalette                       ;set up palette
 mov dx,PELADDRESSWRITE                 ;colour write reg
 xor al,al                              ;select bottom of map
 out dx,al                              ;do it
 IODELAY
 mov si,offset palette                  ;get palette data
 mov dx,PELDATAREG                      ;get data reg
 mov cx,PALETTELEN                      ;length of palette
@@loop:                                 ;
 mov al,[si]                            ;load Red
 inc si                                 ;update SI
 out dx,al                              ;write it
 IODELAY
 mov al,[si]                            ;load Green
 inc si                                 ;update SI
 out dx,al                              ;write it
 IODELAY
 mov al,[si]                            ;load Blue
 inc si                                 ;update SI
 out dx,al                              ;write it
 IODELAY
 dec cx                                 ;decrease count
 jnz @@loop                             ;loop until all done
 ret                                    ;then exit
endp                                    ;

proc SetFont                            ;
 mov dx,GRAPHICS                        ;get graphics port
 mov al,GRREGWRMODE                     ;get write mode reg
 out dx,al                              ;select the reg
 IODELAY                                ;delay a bit
 inc dx                                 ;change DX
 in al,dx                               ;get value
 IODELAY                                ;pause
 mov [oldmode],al                       ;store it
 dec dx                                 ;restore DX
 mov al,GRREGMISC                       ;get misc reg
 out dx,al                              ;select the reg
 IODELAY                                ;delay a bit
 inc dx                                 ;change DX
 in al,dx                               ;get value
 IODELAY                                ;pause
 mov [oldmisc],al                       ;store it
 dec dx                                 ;restore DX
 mov dx,SEQUENCER                       ;get sequencer port
 mov al,SQREGMAPMASK                    ;get map mask reg
 out dx,al                              ;select the reg
 IODELAY                                ;delay a bit
 inc dx                                 ;change DX
 in al,dx                               ;get value
 IODELAY                                ;pause
 mov [oldmask],al                       ;store it
 dec dx                                 ;restore DX
 mov al,SQREGMEMORY                     ;get memory selector reg
 out dx,al                              ;select the reg
 IODELAY                                ;delay a bit
 inc dx                                 ;change DX
 in al,dx                               ;get value
 IODELAY                                ;pause
 mov [oldmem],al                        ;store it
 mov dx,GRAPHICS                        ;select graphics port
 mov al,GRREGWRMODE                     ;get write mode reg
 mov ah,[oldmode]                       ;get old value
 and ah,0fch                            ;mask it
 out dx,ax                              ;set new value
 IODELAY                                ;pause
 mov al,GRREGMISC                       ;get misc reg
 mov ah,[oldmisc]                       ;get old value
 and ah,0f1h                            ;mask it
 or ah,4                                ;set a flag
 out dx,ax                              ;set it
 IODELAY                                ;pause
 mov dx,SEQUENCER                       ;select sequencer port
 mov al,SQREGMAPMASK                    ;get mask reg
 mov ah,4                               ;get new value
 out dx,ax                              ;set it
 IODELAY                                ;pause
 mov al,SQREGMEMORY                     ;get memory reg
 mov ah,[oldmem]                        ;get old value
 or ah,4                                ;set flag
 out dx,ax                              ;set value
 IODELAY                                ;pause
 mov ax,0a000h                          ;get seg of font mem
 mov es,ax                              ;in ES
 xor di,di                              ;zero destination
 mov si,offset f8x16                    ;get source
 xor ch,ch                              ;clear entries count
 cld                                    ;set direction flag correctly
@@loop1:                                ;
 push di                                ;save destination
 mov cl,BYTESPERFONT                    ;bytes per font
@@loop2:                                ;
 movsb                                  ;move a byte
 dec cl                                 ;decrease count
 jnz @@loop2                            ;loop until all done
 pop di                                 ;restore destination
 add di,32                              ;update it
 dec ch                                 ;decrease outer count
 jnz @@loop1                            ;loop until all done
 mov dx,GRAPHICS                        ;get graphics port
 mov al,GRREGWRMODE                     ;get 1st reg
 mov ah,[oldmode]                       ;get old value
 out dx,ax                              ;set it
 IODELAY                                ;pause
 mov al,GRREGMISC                       ;get 2nd reg
 mov ah,[oldmisc]                       ;get old value
 out dx,ax                              ;set it
 IODELAY                                ;pause
 mov dx,SEQUENCER                       ;get seq port
 mov al,SQREGMAPMASK                    ;get 3rd reg
 mov ah,[oldmask]                       ;get old value
 out dx,ax                              ;set it
 IODELAY                                ;pause
 mov al,SQREGMEMORY                     ;get 4th reg
 mov ah,[oldmem]                        ;get old value
 out dx,ax                              ;set it
 IODELAY                                ;pause
 ret                                    ;exit
endp

proc ClearScreen                        ;clears the vid mem
 mov es,[VidSeg]                        ;load segment of video memory
 xor eax,eax                            ;zero screen memory
 mov ecx,16384                          ;32K words
 xor edi,edi                            ;zero destination
 cld                                    ;going up
 rep stosd                              ;clear memory
 ret                                    ;and exit
endp                                    ;


startup:                                ;
 mov ax, seg TextMode                    ;get data segment
 mov ds,ax                              ;in DS

 mov ax, 13h
 int 10h
 
 xor ax, ax
 int 16h
 
;;
 mov si,offset TextMode                 ;get offset of mode reg data
 call SetModeRegs                       ;set mode
 ;call WritePalette                      ;set the palette
 call SetFont                           ;set the font
 call ClearScreen                       ;clear the screen
 mov es,[VidSeg]                        ;load ES  

 prn:
	xor ax, ax
	int 16h
	
	cmp aL, 1bh
	je fim
	
	seges mov [di],al                      ;store char
	seges mov [byte di+1],07h             ;and attribute
	
	add di, 2
	
	jmp prn
				
fim:
 mov ax, 4c00h
 int 21h


dataseg

Seg0040 dw 040h
VidSeg dw ?

oldmode db ?
oldmisc db ?
oldmask db ?
oldmem db ?

TextString db 'Text mode 03h 80x25',13,10,'$'

MCGAMode db 013h,40                     ;BIOS mode num, and num columns
 dw 0a000h
 db 063h,000h
 db 003h,001h,00fh,000h,00eh
 db 05fh,04fh,050h,082h,054h,080h,0bfh,01fh,000h,041h,000h,000h,000h,000h
 db 000h,000h,09ch,00eh,08fh,028h,040h,096h,0b9h,0a3h,0ffh
 db 000h,000h,000h,000h,000h,050h,007h,00fh,0ffh
 db 000h,001h,002h,003h,004h,005h,006h,007h,008h,009h,00ah,00bh,00ch,00dh
 db 00eh,00fh
 db 041h,000h,00fh,000h,000h

TextMode db 03h,80                      ;BIOS mode num, and num columns
 dw 0b800h
 db 067h,000h
 db 003h,000h,003h,000h,002h
 db 05fh,04fh,050h,082h,055h,081h,0bfh,01fh,000h,04fh,00eh,00fh,000h,000h
 db 000h,000h,09ch,00eh,08fh,028h,01fh,096h,0b9h,0a3h,0ffh
 db 000h,000h,000h,000h,000h,010h,00eh,000h,0ffh
 db 000h,001h,002h,003h,004h,005h,006h,007h,008h,009h,00ah,00bh,00ch,00dh
 db 00eh,00fh
 db 00ch,000h,00fh,008h,000h

palette db 000h,000h,000h               ;custom 256 colour palette
 db 000h,000h,02Ah
 db 000h,02Ah,000h
 db 000h,02Ah,02Ah
 db 02Ah,000h,000h
 db 02Ah,000h,02Ah
 db 02Ah,015h,000h
 db 02Ah,02Ah,02Ah
 db 015h,015h,015h
 db 015h,015h,03Fh
 db 015h,03Fh,015h
 db 015h,03Fh,03Fh
 db 03Fh,015h,015h
 db 03Fh,015h,03Fh
 db 03Fh,03Fh,015h
 db 03Fh,03Fh,03Fh
 db 000h,000h,000h
 db 000h,000h,00Ch
 db 000h,000h,019h
 db 000h,000h,025h
 db 000h,000h,032h
 db 000h,000h,03Fh
 db 000h,00Ch,000h
 db 000h,00Ch,00Ch
 db 000h,00Ch,019h
 db 000h,00Ch,025h
 db 000h,00Ch,032h
 db 000h,00Ch,03Fh
 db 000h,019h,000h
 db 000h,019h,00Ch
 db 000h,019h,019h
 db 000h,019h,025h
 db 000h,019h,032h
 db 000h,019h,03Fh
 db 000h,025h,000h
 db 000h,025h,00Ch
 db 000h,025h,019h
 db 000h,025h,025h
 db 000h,025h,032h
 db 000h,025h,03Fh
 db 000h,032h,000h
 db 000h,032h,00Ch
 db 000h,032h,019h
 db 000h,032h,025h
 db 000h,032h,032h
 db 000h,032h,03Fh
 db 000h,03Fh,000h
 db 000h,03Fh,00Ch
 db 000h,03Fh,019h
 db 000h,03Fh,025h
 db 000h,03Fh,032h
 db 000h,03Fh,03Fh
 db 00Ch,000h,000h
 db 00Ch,000h,00Ch
 db 00Ch,000h,019h
 db 00Ch,000h,025h
 db 00Ch,000h,032h
 db 00Ch,000h,03Fh
 db 00Ch,00Ch,000h
 db 00Ch,00Ch,00Ch
 db 00Ch,00Ch,019h
 db 00Ch,00Ch,025h
 db 00Ch,00Ch,032h
 db 00Ch,00Ch,03Fh
 db 00Ch,019h,000h
 db 00Ch,019h,00Ch
 db 00Ch,019h,019h
 db 00Ch,019h,025h
 db 00Ch,019h,032h
 db 00Ch,019h,03Fh
 db 00Ch,025h,000h
 db 00Ch,025h,00Ch
 db 00Ch,025h,019h
 db 00Ch,025h,025h
 db 00Ch,025h,032h
 db 00Ch,025h,03Fh
 db 00Ch,032h,000h
 db 00Ch,032h,00Ch
 db 00Ch,032h,019h
 db 00Ch,032h,025h
 db 00Ch,032h,032h
 db 00Ch,032h,03Fh
 db 00Ch,03Fh,000h
 db 00Ch,03Fh,00Ch
 db 00Ch,03Fh,019h
 db 00Ch,03Fh,025h
 db 00Ch,03Fh,032h
 db 00Ch,03Fh,03Fh
 db 019h,000h,000h
 db 019h,000h,00Ch
 db 019h,000h,019h
 db 019h,000h,025h
 db 019h,000h,032h
 db 019h,000h,03Fh
 db 019h,00Ch,000h
 db 019h,00Ch,00Ch
 db 019h,00Ch,019h
 db 019h,00Ch,025h
 db 019h,00Ch,032h
 db 019h,00Ch,03Fh
 db 019h,019h,000h
 db 019h,019h,00Ch
 db 019h,019h,019h
 db 019h,019h,025h
 db 019h,019h,032h
 db 019h,019h,03Fh
 db 019h,025h,000h
 db 019h,025h,00Ch
 db 019h,025h,019h
 db 019h,025h,025h
 db 019h,025h,032h
 db 019h,025h,03Fh
 db 019h,032h,000h
 db 019h,032h,00Ch
 db 019h,032h,019h
 db 019h,032h,025h
 db 019h,032h,032h
 db 019h,032h,03Fh
 db 019h,03Fh,000h
 db 019h,03Fh,00Ch
 db 019h,03Fh,019h
 db 019h,03Fh,025h
 db 019h,03Fh,032h
 db 019h,03Fh,03Fh
 db 025h,000h,000h
 db 025h,000h,00Ch
 db 025h,000h,019h
 db 025h,000h,025h
 db 025h,000h,032h
 db 025h,000h,03Fh
 db 025h,00Ch,000h
 db 025h,00Ch,00Ch
 db 025h,00Ch,019h
 db 025h,00Ch,025h
 db 025h,00Ch,032h
 db 025h,00Ch,03Fh
 db 025h,019h,000h
 db 025h,019h,00Ch
 db 025h,019h,019h
 db 025h,019h,025h
 db 025h,019h,032h
 db 025h,019h,03Fh
 db 025h,025h,000h
 db 025h,025h,00Ch
 db 025h,025h,019h
 db 025h,025h,025h
 db 025h,025h,032h
 db 025h,025h,03Fh
 db 025h,032h,000h
 db 025h,032h,00Ch
 db 025h,032h,019h
 db 025h,032h,025h
 db 025h,032h,032h
 db 025h,032h,03Fh
 db 025h,03Fh,000h
 db 025h,03Fh,00Ch
 db 025h,03Fh,019h
 db 025h,03Fh,025h
 db 025h,03Fh,032h
 db 025h,03Fh,03Fh
 db 032h,000h,000h
 db 032h,000h,00Ch
 db 032h,000h,019h
 db 032h,000h,025h
 db 032h,000h,032h
 db 032h,000h,03Fh
 db 032h,00Ch,000h
 db 032h,00Ch,00Ch
 db 032h,00Ch,019h
 db 032h,00Ch,025h
 db 032h,00Ch,032h
 db 032h,00Ch,03Fh
 db 032h,019h,000h
 db 032h,019h,00Ch
 db 032h,019h,019h
 db 032h,019h,025h
 db 032h,019h,032h
 db 032h,019h,03Fh
 db 032h,025h,000h
 db 032h,025h,00Ch
 db 032h,025h,019h
 db 032h,025h,025h
 db 032h,025h,032h
 db 032h,025h,03Fh
 db 032h,032h,000h
 db 032h,032h,00Ch
 db 032h,032h,019h
 db 032h,032h,025h
 db 032h,032h,032h
 db 032h,032h,03Fh
 db 032h,03Fh,000h
 db 032h,03Fh,00Ch
 db 032h,03Fh,019h
 db 032h,03Fh,025h
 db 032h,03Fh,032h
 db 032h,03Fh,03Fh
 db 03Fh,000h,000h
 db 03Fh,000h,00Ch
 db 03Fh,000h,019h
 db 03Fh,000h,025h
 db 03Fh,000h,032h
 db 03Fh,000h,03Fh
 db 03Fh,00Ch,000h
 db 03Fh,00Ch,00Ch
 db 03Fh,00Ch,019h
 db 03Fh,00Ch,025h
 db 03Fh,00Ch,032h
 db 03Fh,00Ch,03Fh
 db 03Fh,019h,000h
 db 03Fh,019h,00Ch
 db 03Fh,019h,019h
 db 03Fh,019h,025h
 db 03Fh,019h,032h
 db 03Fh,019h,03Fh
 db 03Fh,025h,000h
 db 03Fh,025h,00Ch
 db 03Fh,025h,019h
 db 03Fh,025h,025h
 db 03Fh,025h,032h
 db 03Fh,025h,03Fh
 db 03Fh,032h,000h
 db 03Fh,032h,00Ch
 db 03Fh,032h,019h
 db 03Fh,032h,025h
 db 03Fh,032h,032h
 db 03Fh,032h,03Fh
 db 03Fh,03Fh,000h
 db 03Fh,03Fh,00Ch
 db 03Fh,03Fh,019h
 db 03Fh,03Fh,025h
 db 03Fh,03Fh,032h
 db 03Fh,03Fh,03Fh
 db 002h,002h,002h
 db 005h,005h,005h
 db 007h,007h,007h
 db 00Ah,00Ah,00Ah
 db 00Dh,00Dh,00Dh
 db 00Fh,00Fh,00Fh
 db 012h,012h,012h
 db 015h,015h,015h
 db 017h,017h,017h
 db 01Ah,01Ah,01Ah
 db 01Ch,01Ch,01Ch
 db 01Fh,01Fh,01Fh
 db 022h,022h,022h
 db 024h,024h,024h
 db 027h,027h,027h
 db 02Ah,02Ah,02Ah
 db 02Ch,02Ch,02Ch
 db 02Fh,02Fh,02Fh
 db 031h,031h,031h
 db 034h,034h,034h
 db 037h,037h,037h
 db 039h,039h,039h
 db 03Ch,03Ch,03Ch
 db 03Fh,03Fh,03Fh

;custom 8x16 font
f8x16 db 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
 db 000h,000h,07Eh,081h,0A5h,081h,081h,0BDh,099h,081h,081h,07Eh,000h,000h,000h,000h
 db 000h,000h,07Eh,0FFh,0DBh,0FFh,0FFh,0C3h,0E7h,0FFh,0FFh,07Eh,000h,000h,000h,000h
 db 000h,000h,000h,000h,06Ch,0FEh,0FEh,0FEh,0FEh,07Ch,038h,010h,000h,000h,000h,000h
 db 000h,000h,000h,000h,010h,038h,07Ch,0FEh,07Ch,038h,010h,000h,000h,000h,000h,000h
 db 000h,000h,000h,018h,03Ch,03Ch,0E7h,0E7h,0E7h,099h,018h,03Ch,000h,000h,000h,000h
 db 000h,000h,000h,018h,03Ch,07Eh,0FFh,0FFh,07Eh,018h,018h,03Ch,000h,000h,000h,000h
 db 000h,000h,000h,000h,000h,000h,018h,03Ch,03Ch,018h,000h,000h,000h,000h,000h,000h
 db 0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0E7h,0C3h,0C3h,0E7h,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh
 db 000h,000h,000h,000h,000h,03Ch,066h,042h,042h,066h,03Ch,000h,000h,000h,000h,000h
 db 0FFh,0FFh,0FFh,0FFh,0FFh,0C3h,099h,0BDh,0BDh,099h,0C3h,0FFh,0FFh,0FFh,0FFh,0FFh
 db 000h,000h,01Eh,00Eh,01Ah,032h,078h,0CCh,0CCh,0CCh,0CCh,078h,000h,000h,000h,000h
 db 000h,000h,03Ch,066h,066h,066h,066h,03Ch,018h,07Eh,018h,018h,000h,000h,000h,000h
 db 000h,000h,03Fh,033h,03Fh,030h,030h,030h,030h,070h,0F0h,0E0h,000h,000h,000h,000h
 db 000h,000h,07Fh,063h,07Fh,063h,063h,063h,063h,067h,0E7h,0E6h,0C0h,000h,000h,000h
 db 000h,000h,000h,018h,018h,0DBh,03Ch,0E7h,03Ch,0DBh,018h,018h,000h,000h,000h,000h
 db 000h,080h,0C0h,0E0h,0F0h,0F8h,0FEh,0F8h,0F0h,0E0h,0C0h,080h,000h,000h,000h,000h
 db 000h,002h,006h,00Eh,01Eh,03Eh,0FEh,03Eh,01Eh,00Eh,006h,002h,000h,000h,000h,000h
 db 000h,000h,018h,03Ch,07Eh,018h,018h,018h,018h,07Eh,03Ch,018h,000h,000h,000h,000h
 db 000h,000h,066h,066h,066h,066h,066h,066h,066h,000h,066h,066h,000h,000h,000h,000h
 db 000h,000h,07Fh,0DBh,0DBh,0DBh,07Bh,01Bh,01Bh,01Bh,01Bh,01Bh,000h,000h,000h,000h
 db 000h,07Ch,0C6h,060h,038h,06Ch,0C6h,0C6h,06Ch,038h,00Ch,0C6h,07Ch,000h,000h,000h
 db 000h,000h,000h,000h,000h,000h,000h,000h,0FEh,0FEh,0FEh,0FEh,000h,000h,000h,000h
 db 000h,000h,018h,03Ch,07Eh,018h,018h,018h,018h,07Eh,03Ch,018h,07Eh,000h,000h,000h
 db 000h,000h,018h,03Ch,07Eh,018h,018h,018h,018h,018h,018h,018h,000h,000h,000h,000h
 db 000h,000h,018h,018h,018h,018h,018h,018h,018h,07Eh,03Ch,018h,000h,000h,000h,000h
 db 000h,000h,000h,000h,000h,018h,00Ch,0FEh,00Ch,018h,000h,000h,000h,000h,000h,000h
 db 000h,000h,000h,000h,000h,030h,060h,0FEh,060h,030h,000h,000h,000h,000h,000h,000h
 db 000h,000h,000h,000h,000h,0C0h,0C0h,0C0h,0C0h,0FEh,000h,000h,000h,000h,000h,000h
 db 000h,000h,000h,000h,000h,028h,06Ch,0FEh,06Ch,028h,000h,000h,000h,000h,000h,000h
 db 000h,000h,000h,000h,010h,038h,038h,07Ch,07Ch,0FEh,0FEh,000h,000h,000h,000h,000h
 db 000h,000h,000h,000h,0FEh,0FEh,07Ch,07Ch,038h,038h,010h,000h,000h,000h,000h,000h
 db 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
 db 000h,000h,018h,03Ch,03Ch,03Ch,018h,018h,018h,000h,018h,018h,000h,000h,000h,000h
 db 000h,066h,066h,066h,024h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
 db 000h,000h,000h,06Ch,06Ch,0FEh,06Ch,06Ch,06Ch,0FEh,06Ch,06Ch,000h,000h,000h,000h
 db 018h,018h,07Ch,0C6h,0C2h,0C0h,07Ch,006h,086h,0C6h,07Ch,018h,018h,000h,000h,000h
 db 000h,000h,000h,000h,0C2h,0C6h,00Ch,018h,030h,060h,0C6h,086h,000h,000h,000h,000h
 db 000h,000h,038h,06Ch,06Ch,038h,076h,0DCh,0CCh,0CCh,0CCh,076h,000h,000h,000h,000h
 db 000h,030h,030h,030h,060h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
 db 000h,000h,00Ch,018h,030h,030h,030h,030h,030h,030h,018h,00Ch,000h,000h,000h,000h
 db 000h,000h,030h,018h,00Ch,00Ch,00Ch,00Ch,00Ch,00Ch,018h,030h,000h,000h,000h,000h
 db 000h,000h,000h,000h,000h,066h,03Ch,0FFh,03Ch,066h,000h,000h,000h,000h,000h,000h
 db 000h,000h,000h,000h,000h,018h,018h,07Eh,018h,018h,000h,000h,000h,000h,000h,000h
 db 000h,000h,000h,000h,000h,000h,000h,000h,000h,018h,018h,018h,030h,000h,000h,000h
 db 000h,000h,000h,000h,000h,000h,000h,0FEh,000h,000h,000h,000h,000h,000h,000h,000h
 db 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,018h,018h,000h,000h,000h,000h
 db 000h,000h,000h,000h,002h,006h,00Ch,018h,030h,060h,0C0h,080h,000h,000h,000h,000h
 db 000h,000h,07Ch,0C6h,0C6h,0CEh,0D6h,0D6h,0E6h,0C6h,0C6h,07Ch,000h,000h,000h,000h
 db 000h,000h,018h,038h,078h,018h,018h,018h,018h,018h,018h,07Eh,000h,000h,000h,000h
 db 000h,000h,07Ch,0C6h,006h,00Ch,018h,030h,060h,0C0h,0C6h,0FEh,000h,000h,000h,000h
 db 000h,000h,07Ch,0C6h,006h,006h,03Ch,006h,006h,006h,0C6h,07Ch,000h,000h,000h,000h
 db 000h,000h,00Ch,01Ch,03Ch,06Ch,0CCh,0FEh,00Ch,00Ch,00Ch,01Eh,000h,000h,000h,000h
 db 000h,000h,0FEh,0C0h,0C0h,0C0h,0FCh,00Eh,006h,006h,0C6h,07Ch,000h,000h,000h,000h
 db 000h,000h,038h,060h,0C0h,0C0h,0FCh,0C6h,0C6h,0C6h,0C6h,07Ch,000h,000h,000h,000h
 db 000h,000h,0FEh,0C6h,006h,006h,00Ch,018h,030h,030h,030h,030h,000h,000h,000h,000h
 db 000h,000h,07Ch,0C6h,0C6h,0C6h,07Ch,0C6h,0C6h,0C6h,0C6h,07Ch,000h,000h,000h,000h
 db 000h,000h,07Ch,0C6h,0C6h,0C6h,07Eh,006h,006h,006h,00Ch,078h,000h,000h,000h,000h
 db 000h,000h,000h,000h,018h,018h,000h,000h,000h,018h,018h,000h,000h,000h,000h,000h
 db 000h,000h,000h,000h,018h,018h,000h,000h,000h,018h,018h,030h,000h,000h,000h,000h
 db 000h,000h,000h,006h,00Ch,018h,030h,060h,030h,018h,00Ch,006h,000h,000h,000h,000h
 db 000h,000h,000h,000h,000h,000h,0FEh,000h,000h,0FEh,000h,000h,000h,000h,000h,000h
 db 000h,000h,000h,060h,030h,018h,00Ch,006h,00Ch,018h,030h,060h,000h,000h,000h,000h
 db 000h,000h,07Ch,0C6h,0C6h,00Ch,018h,018h,018h,000h,018h,018h,000h,000h,000h,000h
 db 000h,000h,000h,07Ch,0C6h,0C6h,0DEh,0DEh,0DEh,0DCh,0C0h,07Ch,000h,000h,000h,000h
 db 000h,000h,010h,038h,06Ch,0C6h,0C6h,0FEh,0C6h,0C6h,0C6h,0C6h,000h,000h,000h,000h
 db 000h,000h,0FCh,066h,066h,066h,07Ch,066h,066h,066h,066h,0FCh,000h,000h,000h,000h
 db 000h,000h,03Ch,066h,0C2h,0C0h,0C0h,0C0h,0C0h,0C2h,066h,03Ch,000h,000h,000h,000h
 db 000h,000h,0F8h,06Ch,066h,066h,066h,066h,066h,066h,06Ch,0F8h,000h,000h,000h,000h
 db 000h,000h,0FEh,066h,062h,068h,078h,068h,060h,062h,066h,0FEh,000h,000h,000h,000h
 db 000h,000h,0FEh,066h,062h,068h,078h,068h,060h,060h,060h,0F0h,000h,000h,000h,000h
 db 000h,000h,03Ch,066h,0C2h,0C0h,0C0h,0DEh,0C6h,0C6h,066h,03Ah,000h,000h,000h,000h
 db 000h,000h,0C6h,0C6h,0C6h,0C6h,0FEh,0C6h,0C6h,0C6h,0C6h,0C6h,000h,000h,000h,000h
 db 000h,000h,03Ch,018h,018h,018h,018h,018h,018h,018h,018h,03Ch,000h,000h,000h,000h
 db 000h,000h,01Eh,00Ch,00Ch,00Ch,00Ch,00Ch,0CCh,0CCh,0CCh,078h,000h,000h,000h,000h
 db 000h,000h,0E6h,066h,06Ch,06Ch,078h,078h,06Ch,066h,066h,0E6h,000h,000h,000h,000h
 db 000h,000h,0F0h,060h,060h,060h,060h,060h,060h,062h,066h,0FEh,000h,000h,000h,000h
 db 000h,000h,0C6h,0EEh,0FEh,0FEh,0D6h,0C6h,0C6h,0C6h,0C6h,0C6h,000h,000h,000h,000h
 db 000h,000h,0C6h,0E6h,0F6h,0FEh,0DEh,0CEh,0C6h,0C6h,0C6h,0C6h,000h,000h,000h,000h
 db 000h,000h,038h,06Ch,0C6h,0C6h,0C6h,0C6h,0C6h,0C6h,06Ch,038h,000h,000h,000h,000h
 db 000h,000h,0FCh,066h,066h,066h,07Ch,060h,060h,060h,060h,0F0h,000h,000h,000h,000h
 db 000h,000h,07Ch,0C6h,0C6h,0C6h,0C6h,0C6h,0C6h,0D6h,0DEh,07Ch,00Ch,00Eh,000h,000h
 db 000h,000h,0FCh,066h,066h,066h,07Ch,06Ch,066h,066h,066h,0E6h,000h,000h,000h,000h
 db 000h,000h,07Ch,0C6h,0C6h,060h,038h,00Ch,006h,0C6h,0C6h,07Ch,000h,000h,000h,000h
 db 000h,000h,07Eh,07Eh,05Ah,018h,018h,018h,018h,018h,018h,03Ch,000h,000h,000h,000h
 db 000h,000h,0C6h,0C6h,0C6h,0C6h,0C6h,0C6h,0C6h,0C6h,0C6h,07Ch,000h,000h,000h,000h
 db 000h,000h,0C6h,0C6h,0C6h,0C6h,0C6h,0C6h,0C6h,06Ch,038h,010h,000h,000h,000h,000h
 db 000h,000h,0C6h,0C6h,0C6h,0C6h,0C6h,0D6h,0D6h,0FEh,06Ch,06Ch,000h,000h,000h,000h
 db 000h,000h,0C6h,0C6h,06Ch,06Ch,038h,038h,06Ch,06Ch,0C6h,0C6h,000h,000h,000h,000h
 db 000h,000h,066h,066h,066h,066h,03Ch,018h,018h,018h,018h,03Ch,000h,000h,000h,000h
 db 000h,000h,0FEh,0C6h,086h,00Ch,018h,030h,060h,0C2h,0C6h,0FEh,000h,000h,000h,000h
 db 000h,000h,03Ch,030h,030h,030h,030h,030h,030h,030h,030h,03Ch,000h,000h,000h,000h
 db 000h,000h,000h,080h,0C0h,0E0h,070h,038h,01Ch,00Eh,006h,002h,000h,000h,000h,000h
 db 000h,000h,03Ch,00Ch,00Ch,00Ch,00Ch,00Ch,00Ch,00Ch,00Ch,03Ch,000h,000h,000h,000h
 db 010h,038h,06Ch,0C6h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
 db 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,0FFh,000h,000h
 db 030h,030h,018h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
 db 000h,000h,000h,000h,000h,078h,00Ch,07Ch,0CCh,0CCh,0CCh,076h,000h,000h,000h,000h
 db 000h,000h,0E0h,060h,060h,078h,06Ch,066h,066h,066h,066h,0DCh,000h,000h,000h,000h
 db 000h,000h,000h,000h,000h,07Ch,0C6h,0C0h,0C0h,0C0h,0C6h,07Ch,000h,000h,000h,000h
 db 000h,000h,01Ch,00Ch,00Ch,03Ch,06Ch,0CCh,0CCh,0CCh,0CCh,076h,000h,000h,000h,000h
 db 000h,000h,000h,000h,000h,07Ch,0C6h,0FEh,0C0h,0C0h,0C6h,07Ch,000h,000h,000h,000h
 db 000h,000h,038h,06Ch,064h,060h,0F0h,060h,060h,060h,060h,0F0h,000h,000h,000h,000h
 db 000h,000h,000h,000h,000h,076h,0CCh,0CCh,0CCh,0CCh,0CCh,07Ch,00Ch,0CCh,078h,000h
 db 000h,000h,0E0h,060h,060h,06Ch,076h,066h,066h,066h,066h,0E6h,000h,000h,000h,000h
 db 000h,000h,018h,018h,000h,038h,018h,018h,018h,018h,018h,03Ch,000h,000h,000h,000h
 db 000h,000h,006h,006h,000h,00Eh,006h,006h,006h,006h,006h,006h,066h,066h,03Ch,000h
 db 000h,000h,0E0h,060h,060h,066h,06Ch,078h,078h,06Ch,066h,0E6h,000h,000h,000h,000h
 db 000h,000h,038h,018h,018h,018h,018h,018h,018h,018h,018h,03Ch,000h,000h,000h,000h
 db 000h,000h,000h,000h,000h,0ECh,0FEh,0D6h,0D6h,0D6h,0D6h,0D6h,000h,000h,000h,000h
 db 000h,000h,000h,000h,000h,0DCh,066h,066h,066h,066h,066h,066h,000h,000h,000h,000h
 db 000h,000h,000h,000h,000h,07Ch,0C6h,0C6h,0C6h,0C6h,0C6h,07Ch,000h,000h,000h,000h
 db 000h,000h,000h,000h,000h,0DCh,066h,066h,066h,066h,066h,07Ch,060h,060h,0F0h,000h
 db 000h,000h,000h,000h,000h,076h,0CCh,0CCh,0CCh,0CCh,0CCh,07Ch,00Ch,00Ch,01Eh,000h
 db 000h,000h,000h,000h,000h,0DCh,076h,062h,060h,060h,060h,0F0h,000h,000h,000h,000h
 db 000h,000h,000h,000h,000h,07Ch,0C6h,060h,038h,00Ch,0C6h,07Ch,000h,000h,000h,000h
 db 000h,000h,010h,030h,030h,0FCh,030h,030h,030h,030h,036h,01Ch,000h,000h,000h,000h
 db 000h,000h,000h,000h,000h,0CCh,0CCh,0CCh,0CCh,0CCh,0CCh,076h,000h,000h,000h,000h
 db 000h,000h,000h,000h,000h,066h,066h,066h,066h,066h,03Ch,018h,000h,000h,000h,000h
 db 000h,000h,000h,000h,000h,0C6h,0C6h,0C6h,0D6h,0D6h,0FEh,06Ch,000h,000h,000h,000h
 db 000h,000h,000h,000h,000h,0C6h,06Ch,038h,038h,038h,06Ch,0C6h,000h,000h,000h,000h
 db 000h,000h,000h,000h,000h,0C6h,0C6h,0C6h,0C6h,0C6h,0C6h,07Eh,006h,00Ch,0F8h,000h
 db 000h,000h,000h,000h,000h,0FEh,0CCh,018h,030h,060h,0C6h,0FEh,000h,000h,000h,000h
 db 000h,000h,00Eh,018h,018h,018h,070h,018h,018h,018h,018h,00Eh,000h,000h,000h,000h
 db 000h,000h,018h,018h,018h,018h,000h,018h,018h,018h,018h,018h,000h,000h,000h,000h
 db 000h,000h,070h,018h,018h,018h,00Eh,018h,018h,018h,018h,070h,000h,000h,000h,000h
 db 000h,000h,076h,0DCh,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
 db 000h,000h,000h,000h,010h,038h,06Ch,0C6h,0C6h,0C6h,0FEh,000h,000h,000h,000h,000h
 db 000h,000h,03Ch,066h,0C2h,0C0h,0C0h,0C0h,0C2h,066h,03Ch,00Ch,006h,07Ch,000h,000h
 db 000h,000h,0CCh,0CCh,000h,0CCh,0CCh,0CCh,0CCh,0CCh,0CCh,076h,000h,000h,000h,000h
 db 000h,00Ch,018h,030h,000h,07Ch,0C6h,0FEh,0C0h,0C0h,0C6h,07Ch,000h,000h,000h,000h
 db 000h,010h,038h,06Ch,000h,078h,00Ch,07Ch,0CCh,0CCh,0CCh,076h,000h,000h,000h,000h
 db 000h,000h,0CCh,0CCh,000h,078h,00Ch,07Ch,0CCh,0CCh,0CCh,076h,000h,000h,000h,000h
 db 000h,060h,030h,018h,000h,078h,00Ch,07Ch,0CCh,0CCh,0CCh,076h,000h,000h,000h,000h
 db 000h,038h,06Ch,038h,000h,078h,00Ch,07Ch,0CCh,0CCh,0CCh,076h,000h,000h,000h,000h
 db 000h,000h,000h,000h,03Ch,066h,060h,060h,066h,03Ch,00Ch,006h,03Ch,000h,000h,000h
 db 000h,010h,038h,06Ch,000h,07Ch,0C6h,0FEh,0C0h,0C0h,0C6h,07Ch,000h,000h,000h,000h
 db 000h,000h,0C6h,0C6h,000h,07Ch,0C6h,0FEh,0C0h,0C0h,0C6h,07Ch,000h,000h,000h,000h
 db 000h,060h,030h,018h,000h,07Ch,0C6h,0FEh,0C0h,0C0h,0C6h,07Ch,000h,000h,000h,000h
 db 000h,000h,066h,066h,000h,038h,018h,018h,018h,018h,018h,03Ch,000h,000h,000h,000h
 db 000h,018h,03Ch,066h,000h,038h,018h,018h,018h,018h,018h,03Ch,000h,000h,000h,000h
 db 000h,060h,030h,018h,000h,038h,018h,018h,018h,018h,018h,03Ch,000h,000h,000h,000h
 db 000h,0C6h,0C6h,010h,038h,06Ch,0C6h,0C6h,0FEh,0C6h,0C6h,0C6h,000h,000h,000h,000h
 db 038h,06Ch,038h,000h,038h,06Ch,0C6h,0C6h,0FEh,0C6h,0C6h,0C6h,000h,000h,000h,000h
 db 018h,030h,060h,000h,0FEh,066h,060h,07Ch,060h,060h,066h,0FEh,000h,000h,000h,000h
 db 000h,000h,000h,000h,000h,0CCh,076h,036h,07Eh,0D8h,0D8h,06Eh,000h,000h,000h,000h
 db 000h,000h,03Eh,06Ch,0CCh,0CCh,0FEh,0CCh,0CCh,0CCh,0CCh,0CEh,000h,000h,000h,000h
 db 000h,010h,038h,06Ch,000h,07Ch,0C6h,0C6h,0C6h,0C6h,0C6h,07Ch,000h,000h,000h,000h
 db 000h,000h,0C6h,0C6h,000h,07Ch,0C6h,0C6h,0C6h,0C6h,0C6h,07Ch,000h,000h,000h,000h
 db 000h,060h,030h,018h,000h,07Ch,0C6h,0C6h,0C6h,0C6h,0C6h,07Ch,000h,000h,000h,000h
 db 000h,030h,078h,0CCh,000h,0CCh,0CCh,0CCh,0CCh,0CCh,0CCh,076h,000h,000h,000h,000h
 db 000h,060h,030h,018h,000h,0CCh,0CCh,0CCh,0CCh,0CCh,0CCh,076h,000h,000h,000h,000h
 db 000h,000h,0C6h,0C6h,000h,0C6h,0C6h,0C6h,0C6h,0C6h,0C6h,07Eh,006h,00Ch,078h,000h
 db 000h,0C6h,0C6h,000h,038h,06Ch,0C6h,0C6h,0C6h,0C6h,06Ch,038h,000h,000h,000h,000h
 db 000h,0C6h,0C6h,000h,0C6h,0C6h,0C6h,0C6h,0C6h,0C6h,0C6h,07Ch,000h,000h,000h,000h
 db 000h,018h,018h,03Ch,066h,060h,060h,060h,066h,03Ch,018h,018h,000h,000h,000h,000h
 db 000h,038h,06Ch,064h,060h,0F0h,060h,060h,060h,060h,0E6h,0FCh,000h,000h,000h,000h
 db 000h,000h,066h,066h,03Ch,018h,07Eh,018h,07Eh,018h,018h,018h,000h,000h,000h,000h
 db 000h,0F8h,0CCh,0CCh,0F8h,0C4h,0CCh,0DEh,0CCh,0CCh,0CCh,0C6h,000h,000h,000h,000h
 db 000h,00Eh,01Bh,018h,018h,018h,07Eh,018h,018h,018h,018h,018h,0D8h,070h,000h,000h
 db 000h,018h,030h,060h,000h,078h,00Ch,07Ch,0CCh,0CCh,0CCh,076h,000h,000h,000h,000h
 db 000h,00Ch,018h,030h,000h,038h,018h,018h,018h,018h,018h,03Ch,000h,000h,000h,000h
 db 000h,018h,030h,060h,000h,07Ch,0C6h,0C6h,0C6h,0C6h,0C6h,07Ch,000h,000h,000h,000h
 db 000h,018h,030h,060h,000h,0CCh,0CCh,0CCh,0CCh,0CCh,0CCh,076h,000h,000h,000h,000h
 db 000h,000h,076h,0DCh,000h,0DCh,066h,066h,066h,066h,066h,066h,000h,000h,000h,000h
 db 076h,0DCh,000h,0C6h,0E6h,0F6h,0FEh,0DEh,0CEh,0C6h,0C6h,0C6h,000h,000h,000h,000h
 db 000h,03Ch,06Ch,06Ch,03Eh,000h,07Eh,000h,000h,000h,000h,000h,000h,000h,000h,000h
 db 000h,038h,06Ch,06Ch,038h,000h,07Ch,000h,000h,000h,000h,000h,000h,000h,000h,000h
 db 000h,000h,030h,030h,000h,030h,030h,060h,0C0h,0C6h,0C6h,07Ch,000h,000h,000h,000h
 db 000h,000h,000h,000h,000h,000h,0FEh,0C0h,0C0h,0C0h,0C0h,000h,000h,000h,000h,000h
 db 000h,000h,000h,000h,000h,000h,0FEh,006h,006h,006h,006h,000h,000h,000h,000h,000h
 db 000h,0C0h,0C0h,0C2h,0C6h,0CCh,018h,030h,060h,0CEh,093h,006h,00Ch,01Fh,000h,000h
 db 000h,0C0h,0C0h,0C2h,0C6h,0CCh,018h,030h,066h,0CEh,09Ah,03Fh,006h,00Fh,000h,000h
 db 000h,000h,018h,018h,000h,018h,018h,018h,03Ch,03Ch,03Ch,018h,000h,000h,000h,000h
 db 000h,000h,000h,000h,000h,033h,066h,0CCh,066h,033h,000h,000h,000h,000h,000h,000h
 db 000h,000h,000h,000h,000h,0CCh,066h,033h,066h,0CCh,000h,000h,000h,000h,000h,000h
 db 011h,044h,011h,044h,011h,044h,011h,044h,011h,044h,011h,044h,011h,044h,011h,044h
 db 055h,0AAh,055h,0AAh,055h,0AAh,055h,0AAh,055h,0AAh,055h,0AAh,055h,0AAh,055h,0AAh
 db 0DDh,077h,0DDh,077h,0DDh,077h,0DDh,077h,0DDh,077h,0DDh,077h,0DDh,077h,0DDh,077h
 db 018h,018h,018h,018h,018h,018h,018h,018h,018h,018h,018h,018h,018h,018h,018h,018h
 db 018h,018h,018h,018h,018h,018h,018h,0F8h,018h,018h,018h,018h,018h,018h,018h,018h
 db 018h,018h,018h,018h,018h,0F8h,018h,0F8h,018h,018h,018h,018h,018h,018h,018h,018h
 db 036h,036h,036h,036h,036h,036h,036h,0F6h,036h,036h,036h,036h,036h,036h,036h,036h
 db 000h,000h,000h,000h,000h,000h,000h,0FEh,036h,036h,036h,036h,036h,036h,036h,036h
 db 000h,000h,000h,000h,000h,0F8h,018h,0F8h,018h,018h,018h,018h,018h,018h,018h,018h
 db 036h,036h,036h,036h,036h,0F6h,006h,0F6h,036h,036h,036h,036h,036h,036h,036h,036h
 db 036h,036h,036h,036h,036h,036h,036h,036h,036h,036h,036h,036h,036h,036h,036h,036h
 db 000h,000h,000h,000h,000h,0FEh,006h,0F6h,036h,036h,036h,036h,036h,036h,036h,036h
 db 036h,036h,036h,036h,036h,0F6h,006h,0FEh,000h,000h,000h,000h,000h,000h,000h,000h
 db 036h,036h,036h,036h,036h,036h,036h,0FEh,000h,000h,000h,000h,000h,000h,000h,000h
 db 018h,018h,018h,018h,018h,0F8h,018h,0F8h,000h,000h,000h,000h,000h,000h,000h,000h
 db 000h,000h,000h,000h,000h,000h,000h,0F8h,018h,018h,018h,018h,018h,018h,018h,018h
 db 018h,018h,018h,018h,018h,018h,018h,01Fh,000h,000h,000h,000h,000h,000h,000h,000h
 db 018h,018h,018h,018h,018h,018h,018h,0FFh,000h,000h,000h,000h,000h,000h,000h,000h
 db 000h,000h,000h,000h,000h,000h,000h,0FFh,018h,018h,018h,018h,018h,018h,018h,018h
 db 018h,018h,018h,018h,018h,018h,018h,01Fh,018h,018h,018h,018h,018h,018h,018h,018h
 db 000h,000h,000h,000h,000h,000h,000h,0FFh,000h,000h,000h,000h,000h,000h,000h,000h
 db 018h,018h,018h,018h,018h,018h,018h,0FFh,018h,018h,018h,018h,018h,018h,018h,018h
 db 018h,018h,018h,018h,018h,01Fh,018h,01Fh,018h,018h,018h,018h,018h,018h,018h,018h
 db 036h,036h,036h,036h,036h,036h,036h,037h,036h,036h,036h,036h,036h,036h,036h,036h
 db 036h,036h,036h,036h,036h,037h,030h,03Fh,000h,000h,000h,000h,000h,000h,000h,000h
 db 000h,000h,000h,000h,000h,03Fh,030h,037h,036h,036h,036h,036h,036h,036h,036h,036h
 db 036h,036h,036h,036h,036h,0F7h,000h,0FFh,000h,000h,000h,000h,000h,000h,000h,000h
 db 000h,000h,000h,000h,000h,0FFh,000h,0F7h,036h,036h,036h,036h,036h,036h,036h,036h
 db 036h,036h,036h,036h,036h,037h,030h,037h,036h,036h,036h,036h,036h,036h,036h,036h
 db 000h,000h,000h,000h,000h,0FFh,000h,0FFh,000h,000h,000h,000h,000h,000h,000h,000h
 db 036h,036h,036h,036h,036h,0F7h,000h,0F7h,036h,036h,036h,036h,036h,036h,036h,036h
 db 018h,018h,018h,018h,018h,0FFh,000h,0FFh,000h,000h,000h,000h,000h,000h,000h,000h
 db 036h,036h,036h,036h,036h,036h,036h,0FFh,000h,000h,000h,000h,000h,000h,000h,000h
 db 000h,000h,000h,000h,000h,0FFh,000h,0FFh,018h,018h,018h,018h,018h,018h,018h,018h
 db 000h,000h,000h,000h,000h,000h,000h,0FFh,036h,036h,036h,036h,036h,036h,036h,036h
 db 036h,036h,036h,036h,036h,036h,036h,03Fh,000h,000h,000h,000h,000h,000h,000h,000h
 db 018h,018h,018h,018h,018h,01Fh,018h,01Fh,000h,000h,000h,000h,000h,000h,000h,000h
 db 000h,000h,000h,000h,000h,01Fh,018h,01Fh,018h,018h,018h,018h,018h,018h,018h,018h
 db 000h,000h,000h,000h,000h,000h,000h,03Fh,036h,036h,036h,036h,036h,036h,036h,036h
 db 036h,036h,036h,036h,036h,036h,036h,0FFh,036h,036h,036h,036h,036h,036h,036h,036h
 db 018h,018h,018h,018h,018h,0FFh,018h,0FFh,018h,018h,018h,018h,018h,018h,018h,018h
 db 018h,018h,018h,018h,018h,018h,018h,0F8h,000h,000h,000h,000h,000h,000h,000h,000h
 db 000h,000h,000h,000h,000h,000h,000h,01Fh,018h,018h,018h,018h,018h,018h,018h,018h
 db 0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh
 db 000h,000h,000h,000h,000h,000h,000h,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh
 db 0F0h,0F0h,0F0h,0F0h,0F0h,0F0h,0F0h,0F0h,0F0h,0F0h,0F0h,0F0h,0F0h,0F0h,0F0h,0F0h
 db 00Fh,00Fh,00Fh,00Fh,00Fh,00Fh,00Fh,00Fh,00Fh,00Fh,00Fh,00Fh,00Fh,00Fh,00Fh,00Fh
 db 0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,000h,000h,000h,000h,000h,000h,000h,000h,000h
 db 000h,000h,000h,000h,000h,076h,0DCh,0D8h,0D8h,0D8h,0DCh,076h,000h,000h,000h,000h
 db 000h,000h,000h,000h,000h,0FCh,0C6h,0FCh,0C6h,0C6h,0FCh,0C0h,0C0h,0C0h,000h,000h
 db 000h,000h,0FEh,0C6h,0C6h,0C0h,0C0h,0C0h,0C0h,0C0h,0C0h,0C0h,000h,000h,000h,000h
 db 000h,000h,000h,000h,080h,0FEh,06Ch,06Ch,06Ch,06Ch,06Ch,06Ch,000h,000h,000h,000h
 db 000h,000h,000h,0FEh,0C6h,060h,030h,018h,030h,060h,0C6h,0FEh,000h,000h,000h,000h
 db 000h,000h,000h,000h,000h,07Eh,0D8h,0D8h,0D8h,0D8h,0D8h,070h,000h,000h,000h,000h
 db 000h,000h,000h,000h,066h,066h,066h,066h,066h,07Ch,060h,060h,0C0h,000h,000h,000h
 db 000h,000h,000h,000h,076h,0DCh,018h,018h,018h,018h,018h,018h,000h,000h,000h,000h
 db 000h,000h,000h,07Eh,018h,03Ch,066h,066h,066h,03Ch,018h,07Eh,000h,000h,000h,000h
 db 000h,000h,000h,038h,06Ch,0C6h,0C6h,0FEh,0C6h,0C6h,06Ch,038h,000h,000h,000h,000h
 db 000h,000h,038h,06Ch,0C6h,0C6h,0C6h,06Ch,06Ch,06Ch,06Ch,0EEh,000h,000h,000h,000h
 db 000h,000h,01Eh,030h,018h,00Ch,03Eh,066h,066h,066h,066h,03Ch,000h,000h,000h,000h
 db 000h,000h,000h,000h,000h,07Eh,0DBh,0DBh,0DBh,07Eh,000h,000h,000h,000h,000h,000h
 db 000h,000h,000h,003h,006h,07Eh,0CFh,0DBh,0F3h,07Eh,060h,0C0h,000h,000h,000h,000h
 db 000h,000h,01Ch,030h,060h,060h,07Ch,060h,060h,060h,030h,01Ch,000h,000h,000h,000h
 db 000h,000h,000h,07Ch,0C6h,0C6h,0C6h,0C6h,0C6h,0C6h,0C6h,0C6h,000h,000h,000h,000h
 db 000h,000h,000h,000h,0FEh,000h,000h,0FEh,000h,000h,0FEh,000h,000h,000h,000h,000h
 db 000h,000h,000h,000h,018h,018h,07Eh,018h,018h,000h,000h,0FFh,000h,000h,000h,000h
 db 000h,000h,000h,030h,018h,00Ch,006h,00Ch,018h,030h,000h,07Eh,000h,000h,000h,000h
 db 000h,000h,000h,00Ch,018h,030h,060h,030h,018h,00Ch,000h,07Eh,000h,000h,000h,000h
 db 000h,000h,00Eh,01Bh,01Bh,018h,018h,018h,018h,018h,018h,018h,018h,018h,018h,018h
 db 018h,018h,018h,018h,018h,018h,018h,018h,0D8h,0D8h,0D8h,070h,000h,000h,000h,000h
 db 000h,000h,000h,000h,018h,018h,000h,07Eh,000h,018h,018h,000h,000h,000h,000h,000h
 db 000h,000h,000h,000h,000h,076h,0DCh,000h,076h,0DCh,000h,000h,000h,000h,000h,000h
 db 000h,038h,06Ch,06Ch,038h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
 db 000h,000h,000h,000h,000h,000h,000h,018h,018h,000h,000h,000h,000h,000h,000h,000h
 db 000h,000h,000h,000h,000h,000h,000h,000h,018h,000h,000h,000h,000h,000h,000h,000h
 db 000h,00Fh,00Ch,00Ch,00Ch,00Ch,00Ch,0ECh,06Ch,06Ch,03Ch,01Ch,000h,000h,000h,000h
 db 000h,0D8h,06Ch,06Ch,06Ch,06Ch,06Ch,000h,000h,000h,000h,000h,000h,000h,000h,000h
 db 000h,070h,098h,030h,060h,0C8h,0F8h,000h,000h,000h,000h,000h,000h,000h,000h,000h
 db 000h,000h,000h,000h,07Ch,07Ch,07Ch,07Ch,07Ch,07Ch,07Ch,000h,000h,000h,000h,000h
 db 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h


end Startup