
.386P
.model large
.stack 1024

INCLUDE DATA.INC

MISC = 03c2h
SEQUENCER = 03c4h
CRTC = 03d4h
GRAPHICS = 03ceh
FEATURE = 03dah
ATTRIB = 03c0h

STATUS = 03dah
GRREGWRMODE = 5
GRREGMISC = 6
SQREGMAPMASK = 2
SQREGMEMORY = 4

BYTESPERFONT = 16
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

dataseg segment use16

Seg0040 dw 040h
VidSeg dw ?

oldmode db ?
oldmisc db ?
oldmask db ?
oldmem db ?

dataseg ends

codeseg segment use16
	assume cs:codeseg, ds:dataseg, es:nothing

OutRegs proc                            ;Output CL registers to port DX
 xor al,al                              ;start at reg 0
@@:                                 
 mov ah,[si]                            ;load data
 inc si                                 ;update source
 out dx,ax                              ;output data
 
 inc al                                 ;increase register number
 dec cl                                 ;decrease count
 jnz @b                             	;loop whilst still OK
 ret                                    ;and exit
OutRegs endp                                    ;

SetModeRegs proc                        ;set VGA registers for mode data
                                        ;pointed to by SI
 mov dx,STATUS                          ;get retrace reg
@@1:                                    ;
 in al,dx                               ;get value
                                 
 test al,8                              ;check for vertical retrace bit
 jnz @@1                                ;loop until clear
@@2:                                    ;
 in al,dx                               ;get value
                                 
 test al,8                              ;check for retrace again
 jz @@2                                 ;loop until it's set this time
                                        ;so we get start of ret. to set mode
 mov es,[Seg0040]                       ;load BIOS segment
 xor ah,ah                              ;zero AH
 mov al,[si]                            ;load BIOS mode number
 mov es:[BIOSMODE],al                	;store mode number
 inc si                                 ;update SI
 mov al,[si]                            ;load number of columns
 mov es:[COLUMNS],al                 	;store number of columns
 inc si                                 ;update SI
 mov di,[si]                            ;load Screen Seg
 mov [VidSeg],di                        ;store video segment
 add si,2                               ;update SI
 mov al,[si+CURSORTOPDATA]              ;get cursor top data
 mov es:[CURSORTOP],al               	;store it
 mov al,[si+CURSORBOTTOMDATA]           ;get cursor bottom data
 mov es:[CURSORBOTTOM],al            	;store it
 mov dx,MISC                            ;get VGA MISC reg num
 mov al,[si]                            ;load AL
 inc si                                 ;update source
 out dx,al                              ;output to port
 
 mov dx,FEATURE                         ;get Feature controller number
 mov al,[si]                            ;load data
 inc si                                 ;update source
 out dx,al                              ;output register data
 
 mov dx,SEQUENCER                       ;get sequencer port number
 mov cl,NUMSEQUENCER                    ;get number of regs to set
 call OutRegs                           ;do them
 mov ah,[si+VREND]                      ;load CRTC VREND byte
 mov al,VREND                           ;load reg number
 and ah,NOPROT                          ;clear protection bit
 mov dx,CRTC                            ;CRTC port number
 out dx,ax                              ;no protection
 
 mov cl,NUMCRTC                         ;number of CRTC regs
 call OutRegs                           ;output to port
 mov dx,GRAPHICS                        ;get graphics port number
 mov cl,NUMGRAPHICS                     ;get number of regs
 call OutRegs                           ;do it
 mov dx,FEATURE                         ;load feature controller port
 in al,dx                               ;reset attrib flip flop by reading
 
 mov dx,ATTRIB                          ;attribute controller port
 mov cl,NUMATTRIB                       ;number of regs
 xor al,al                              ;clear AL
@@loop:                                 ;
 mov ah,[si]                            ;load AH
 out dx,al                              ;output to port
                                 
 xchg al,ah                             ;swap data/reg num
 out dx,al                              ;output to port
 xchg ah,al                             ;swap back
 inc al                                 ;next reg
 inc si                                 ;increase source
 cmp al,cl                              ;done yet?
 jb @@loop                              ;loop until done
 mov al,ENABLEATTRIB                    ;enable attribute register reads
 out dx,al                              ;do it
 
 ret                                    ;and exit
SetModeRegs endp                                    

SetFont proc                            
 mov dx,GRAPHICS                        ;get graphics port
 mov al,GRREGWRMODE                     ;get write mode reg
 out dx,al                              ;select the reg
                                 
 inc dx                                 ;change DX
 in al,dx                               ;get value
                                 
 mov [oldmode],al                       ;store it
 dec dx                                 ;restore DX
 mov al,GRREGMISC                       ;get misc reg
 out dx,al                              ;select the reg
                                 
 inc dx                                 ;change DX
 in al,dx                               ;get value
                                 
 mov [oldmisc],al                       ;store it
 dec dx                                 ;restore DX
 mov dx,SEQUENCER                       ;get sequencer port
 mov al,SQREGMAPMASK                    ;get map mask reg
 out dx,al                              ;select the reg
                                 
 inc dx                                 ;change DX
 in al,dx                               ;get value
                                 
 mov [oldmask],al                       ;store it
 dec dx                                 ;restore DX
 mov al,SQREGMEMORY                     ;get memory selector reg
 out dx,al                              ;select the reg
                                 
 inc dx                                 ;change DX
 in al,dx                               ;get value
                                 
 mov [oldmem],al                        ;store it
 mov dx,GRAPHICS                        ;select graphics port
 mov al,GRREGWRMODE                     ;get write mode reg
 mov ah,[oldmode]                       ;get old value
 and ah,0fch                            ;mask it
 out dx,ax                              ;set new value
                                 
 mov al,GRREGMISC                       ;get misc reg
 mov ah,[oldmisc]                       ;get old value
 and ah,0f1h                            ;mask it
 or ah,4                                ;set a flag
 out dx,ax                              ;set it
                                 
 mov dx,SEQUENCER                       ;select sequencer port
 mov al,SQREGMAPMASK                    ;get mask reg
 mov ah,4                               ;get new value
 out dx,ax                              ;set it
                                 
 mov al,SQREGMEMORY                     ;get memory reg
 mov ah,[oldmem]                        ;get old value
 or ah,4                                ;set flag
 out dx,ax                              ;set value
                                 
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
                                 
 mov al,GRREGMISC                       ;get 2nd reg
 mov ah,[oldmisc]                       ;get old value
 out dx,ax                              ;set it
                                 
 mov dx,SEQUENCER                       ;get seq port
 mov al,SQREGMAPMASK                    ;get 3rd reg
 mov ah,[oldmask]                       ;get old value
 out dx,ax                              ;set it
                                 
 mov al,SQREGMEMORY                     ;get 4th reg
 mov ah,[oldmem]                        ;get old value
 out dx,ax                              ;set it
                                 
 ret                                    ;exit
SetFont endp

ClearScreen proc                        ;clears the vid mem
 mov es,[VidSeg]                        ;load segment of video memory
 xor eax,eax                            ;zero screen memory
 mov ecx,16384                          ;32K words
 xor edi,edi                            ;zero destination
 cld                                    ;going up
 rep stosd                              ;clear memory
 ret                                    ;and exit
ClearScreen endp                                    ;


startup:                                ;
 mov ax, seg TextMode                    ;get data segment
 mov ds,ax                              ;in DS

 mov ax, 13h
 int 10h
 
 xor ax, ax
 int 16h

 mov si,offset TextMode                 ;get offset of mode reg data
 call SetModeRegs                       ;set mode
 call SetFont                           ;set the font
 call ClearScreen                       ;clear the screen
 mov es,[VidSeg]                        ;load ES  

 prn:
	xor ax, ax
	int 16h
	
	cmp aL, 1bh
	je fim
	
	mov ah, 07h
	mov es:[di],al                      ;store char
	mov es:[di+1],ah             		;and attribute
	
	add di, 2
	
	jmp prn
				
fim:
 mov ax, 4c00h
 int 21h
 
codeseg ends

end Startup