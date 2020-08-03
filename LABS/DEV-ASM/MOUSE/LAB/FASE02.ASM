name "psmouse"

ORG 0x0100 		;* YEP its a .COM file!

;I will use the NASM syntax!!
;I made this code for a Logitech M-S48a mouse. (normal PS/2 Code)
;For some reason the keyboard wil stall after program is terminated :S

;If you have problems understandig this code take a look at my mouseprog for the COM-mouse

;(Piece of disclaimer)
;(I do NOT give any guarantee or what so ever on this piece of code.)
;(I am not responsible for any damage whatsoever                    )
;(By using this code u accept the two lines above                   )
;(USAGE IS AT YOUR OWN RISK                                         )

;***************************************************
;* This is for the system to know where to jump to *
;***************************************************
; load source into DS:SI,	  		   *
; load target into ES:DI:			   *
        MOV     AX, CS				  ;*
        MOV     DS, AX				  ;*
        MOV     ES, AX                            ;*
;***************************************************

JMP MAINP 

;-----------------------------------------------------------------------

CLSCUR:
    mov     ax, WORD PTR [X]
    mov     di, ax
    mov     ax, 0B800h
    mov     es, ax
    mov     al, 0
    mov     ah, 00000111b
    stosw
ret 

CLS:
    mov     ah, 00h
    mov     al, 03h
    int     10h
ret

EBLINK:
    mov     ch, 6
 	mov     cl, 7
 	mov     ah, 1
 	int     10h 
ret 

DBLINK:
    mov     ch, 32
 	mov     ah, 1
 	int     10h
ret
 
;----------------------------------------------------------------------- 
 
;***********************************************************************
;Activate mouse port (PS/2)
;***********************************************************************
PS2SET:
  mov  al, 0xa8		; enable mouse port
  out  0x64, al		; write to keyboardcontroller
  call CHKPRT		; check if command is progressed (demand!)
ret

;***********************************************************************
;Check if command is accepted. (not got stuck in inputbuffer)
;***********************************************************************
CHKPRT:
  xor  cx, cx		
 .again:
  in   al, 0x64		; read from keyboardcontroller
  test al, 2		; Check if input buffer is empty
  jz  continue
  jmp .again		; (demand!) This may couse hanging, use only when sure.
 continue:
ret

;***********************************************************************
;Write to mouse
;***********************************************************************
WMOUS:
  mov  al, 0xd4		; write to mouse device instead of to keyboard
  out  0x64, al		; write to keyboardcontroller
  call CHKPRT		; check if command is progressed (demand!)
ret



;***********************************************************************
;mouse output buffer full
;***********************************************************************
MBUFFUL:
  xor  cx, cx
 .mn:
  in   al, 0x64		; read from keyboardcontroller
  test al, 0x20		; check if mouse output buffer is full
  jz  continue2
  loop .mn
 continue2:
ret


;***********************************************************************
;Write activate Mouse HardWare
;***********************************************************************
ACTMOUS:
  call WMOUS
  mov  al, 0xf4 	; Command to activate mouse itselve (Stream mode)
  out  0x60, al		; write ps/2 controller output port (activate mouse)
  call CHKPRT		; check if command is progressed (demand!)
  call CHKMOUS		; check if a BYTE PTR is available
ret

;***********************************************************************
;Check if mouse has info for us
;***********************************************************************
CHKMOUS:
  mov  bl, 0
  xor  cx, cx
 .vrd:
  in   al, 0x64		; read from keyboardcontroller
  test al, 1		; check if controller buffer (60h) has data
  jnz .yy
  loop .vrd
  mov  bl, 1
 .yy:
ret

;***********************************************************************
;Disable Keyboard
;***********************************************************************
DKEYB:
  mov  al, 0xad		; Disable Keyboard
  out  0x64, al		; write to keyboardcontroller
  call CHKPRT		; check if command is progressed (demand!)
ret

;***********************************************************************
;Enable Keyboard
;***********************************************************************
EKEYB:
  mov  al, 0xae		; Enable Keyboard
  out  0x64, al		; write to keyboardcontroller
  call CHKPRT		; check if command is progressed (demand!)
ret

;***********************************************************************
;Get Mouse BYTE PTR
;***********************************************************************
GETB:
 cagain:
  call CHKMOUS		; check if a BYTE PTR is available
  or   bl, bl
  jnz cagain
  call DKEYB		; disable keyboard to read mouse BYTE PTR
  xor  ax, ax
  in   al, 0x60		; read ps/2 controller output port (mouseBYTE PTR)
  mov  dl, al
  call EKEYB		; enable keyboard
  mov  al, dl
ret


;***********************************************************************
;Get 1ST Mouse BYTE PTR
;***********************************************************************
GETFIRST:
  call GETB 		;Get BYTE PTR1 of packet
  xor  ah, ah
  mov  bl, al
  and  bl, 1
  mov  BYTE PTR [LBUTTON], bl
  mov  bl, al
  and  bl, 2
  shr  bl, 1
  mov  BYTE PTR [RBUTTON], bl
  mov  bl, al
  and  bl, 4
  shr  bl, 2
  mov  BYTE PTR [MBUTTON], bl 
  mov  bl, al
  and  bl, 16
  shr  bl, 4
  mov  BYTE PTR [XCOORDN], bl
  mov  bl, al
  and  bl, 32
  shr  bl, 5
  mov  BYTE PTR [YCOORDN], bl
  mov  bl, al
  and  bl, 64
  shr  bl, 6
  mov  BYTE PTR [XFLOW], bl
  mov  bl, al
  and  bl, 128
  shr  bl, 7
  mov  BYTE PTR [YFLOW], bl
ret


;***********************************************************************
;Get 2ND Mouse BYTE PTR
;***********************************************************************
GETSECOND:
  call GETB 		;Get BYTE PTR2 of packet
  xor  ah, ah
  mov  BYTE PTR [XCOORD], al
ret


;***********************************************************************
;Get 3RD Mouse BYTE PTR
;***********************************************************************
GETTHIRD:
  call GETB 		;Get BYTE PTR3 of packet
  xor  ah, ah
  mov  BYTE PTR [YCOORD], al
ret



;-----------------------------------------------------------------------
;***********************************************************************
;* MAIN PROGRAM
;***********************************************************************
;-----------------------------------------------------------------------


MAINP:
  call CLS
  call DBLINK 
  call PS2SET
  call ACTMOUS
  call GETB 	;Get the responce BYTE PTR of the mouse (like: Hey i am active)  If the BYTE PTRs are mixed up, remove this line or add another of this line.

main:  
  call GETFIRST
  call GETSECOND
  call GETTHIRD



;*NOW WE HAVE XCOORD & YCOORD* + the button status of L-butten and R-button and M-button allsow overflow + sign bits

;!!!
;! The Sign bit of X tells if the XCOORD is Negative or positive. (if 1 this means -256)
;! The XCOORD is allways positive
;!!!

;???
;? Like if:    X-Signbit = 1		Signbit
;? 					|
;?             XCOORD = 11111110 ---> -256 + 254 = -2  (the mouse cursor goes left)
;?                      \      /
;?                       \    /
;?                        \Positive
;???


;?? FOR MORE INFORMATION ON THE PS/2 PROTOCOL SEE BELOW!!!!



;!!!!!!!!!!!!!
;the rest of the source... (like move cursor) (i leave this up to you m8!)
;!!!!!!!!!!!!!


;*************************************************************
;Allright, Allright i'll give an example!  |EXAMPLE CODE|
;*************************************************************  

;=============================
;**Mark a position on scr**
;=============================
 mov BYTE PTR [row], 0
 mov BYTE PTR [col], 0

;=============================
;**go to start position**
;=============================
 call GOTOXY
  
;=============================
;**Lets display the L button**
;=============================
 mov  si, OFFSET strlbt	; display the text for Lbutton
 call disp
 mov  al, BYTE PTR [LBUTTON]
 xor  ah, ah
 call DISPDEC
 mov  si, OFFSET stretr	; goto nextline on scr
 call disp

;=============================
;**Lets display the R button**
;=============================
 mov  si, OFFSET strrbt	; display the text for Rbutton
 call disp
 mov  al, BYTE PTR [RBUTTON]
 xor  ah, ah
 call DISPDEC
 mov  si, OFFSET stretr	; goto nextline on scr
 call disp
 
;=============================
;**Lets display the M button**
;=============================
 mov  si, OFFSET strmbt	; display the text for Mbutton
 call disp
 mov  al, BYTE PTR [MBUTTON]
 xor  ah, ah
 call DISPDEC
 mov  si, OFFSET stretr	; goto nextline on scr
 call disp 
 
;-------------------------------------------  
  
  cmp BYTE PTR [LBUTTON], 1
  je  soltar
  cmp BYTE PTR [RBUTTON], 1
  je  soltar
  cmp BYTE PTR [MBUTTON], 1
  je  soltar  
  
  cmp BYTE PTR [PRESSED], 1
  je zerar 
  
  jmp continuar
  
zerar:
  mov BYTE PTR [PRESSED], 0
  jmp main
  
  
soltar:
  mov BYTE PTR [PRESSED], 1
  jmp main 
   
;------------------------------------------- 

continuar:

;=============================
;**Lets display the X coord**
;=============================
 
 call   CLSCUR
 mov    al, BYTE PTR [XCOORDN]
 or     al, al
 jz     negative
 sub    WORD PTR [X], 2
 jmp    positive
negative:
 add    WORD PTR [X], 2
positive:
 xor    ah, ah
 mov    al, BYTE PTR [XCOORD]

;=============================
;**Lets display the Y coord**
;=============================
 
 mov    al, BYTE PTR [YCOORDN]
 or     al, al
 jz     negativex
 ;add    WORD PTR [X], 80
 jmp    positivex
negativex:
 ;sub    WORD PTR [X], 80
positivex:
 ;xor    ah, ah
 mov    al, BYTE PTR [YCOORD] 
 
    mov     ax, WORD PTR [X]
    mov     di, ax
    mov     ax, 0B800h
    mov     es, ax
    mov     al, 0
    mov     ah, 78h
    stosw  

;=============================
;**stop program on keypress**	|Note: sometimes it takes a while for the program stops, or keyboard stalls|
;=============================  |due to more time is spend looking at the PS/2 mouse port (keyb disabled)  |
    xor  ax, ax
    mov  ah, 0x11
    int  0x16
    jnz quitprog
;************************************************************* 

jmp main



quitprog:  

 call    CLS
 call    EBLINK
 MOV     AH, 0x4C  	;Return to OS
 INT     0x21		
;-----------------------------------------------------------------------
;***********************************************************************
;* END OF MAIN PROGRAM
;***********************************************************************
;-----------------------------------------------------------------------


;XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
;X Dont Worry about this displaypart, its yust ripped of my os.
;X (I know it could be done nicer but this works :P)
;XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
;XXX
;************************************************
;* Displays AX in a decimal way 
;************************************************
DISPDEC:
    mov  BYTE PTR [zerow], 0x00
    mov  WORD PTR [varbuff], ax
    xor  ax, ax
    xor  cx, cx
    xor  dx, dx
    mov  bx, 10000
    mov  WORD PTR [deel], bx
   mainl:    
    mov  bx, WORD PTR [deel]
    mov  ax, WORD PTR [varbuff]
    xor  dx, dx
    xor  cx, cx
    div  bx
    mov  WORD PTR [varbuff], dx
    jmp ydisp
   
   vdisp:
    cmp  BYTE PTR [zerow], 0x00
    je .nodisp

   ydisp:
    mov  ah, 0x0E                            ; BIOS teletype
    add  al, 48                              ; lets make it a 0123456789 :D
    mov  bx, 1 
    int  0x10                                ; invoke BIOS
    mov  BYTE PTR [zerow], 0x01
   jmp yydis

   nodisp:

   yydis:
    xor  dx, dx
    xor  cx, cx
    xor  bx, bx
    mov  ax, WORD PTR [deel]
    cmp  ax, 1
    je bver
    cmp  ax, 0
    je .bver
    mov  bx, 10
    div  bx
    mov  WORD PTR [deel], ax
   jmp mainl

   bver:
   ret
;***************END of PROCEDURE*********************************
;****************************************************************
;* PROCEDURE disp      
;* display a string at ds:si via BIOS
;****************************************************************
disp:
 HEAD:
    lodsb                                    ; load next character
    or   al, al                              ; test for NUL character
    jz   DONE                               ; if NUL char found then goto done
    mov  ah, 0x0E                            ; BIOS teletype
    mov  bx, 1 				     ; make it a nice fluffy blue (mostly it will be grey but ok..)
    int  0x10                                ; invoke BIOS
    jmp  HEAD
 
 DONE: 
   ret
;*******************End Procedure ***********************
;*****************************
;*GOTOXY  go back to startpos
;*****************************
GOTOXY:
    mov ah, 2
    mov bh, 0                  ;0:graphic mode 0-3: in modes 2&3 0-7: in modes 0&1
    mov dl, BYTE PTR [col]
    mov dh, BYTE PTR [row]
    int 0x10
ret
;*******END********
;
;XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
;XXX
;XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX








;***********************************************************************
;variables
;***********************************************************************
LBUTTON db 0x00	;	Left   button status 1=PRESSED 0=RELEASED
RBUTTON db 0x00	;	Right  button status 1=PRESSED 0=RELEASED
MBUTTON db 0x00	;	Middle button status 1=PRESSED 0=RELEASED
XCOORD  db 0x00	;	the moved distance  (horizontal)
YCOORD  db 0x00	;	the moved distance  (vertical)
XCOORDN db 0x00 ;       Sign bit (positive/negative) of X Coord
YCOORDN db 0x00 ;       Sign bit (positive/negative) of Y Coord
XFLOW   db 0x00 ;       Overflow bit (Movement too fast) of X Coord
YFLOW   db 0x00 ;       Overflow bit (Movement too fast) of Y Coord

X       dw 0x03E8       ; center of screen 

PRESSED  db 0x00




;************************************
;* Some var's of my display function
;************************************
deel    dw 0x0000
varbuff dw 0x0000
zerow   db 0x00
strlbt  db "Left button:   ", 0x00
strrbt  db "Right button:  ", 0x00
strmbt  db "Middle button: ", 0x00
strcdx  db "Mouse moved (X): ", 0x00
strcdy  db "Mouse moved (Y): ", 0x00
stretr  db 0x0D, 0x0A, 0x00
strneg  db "-", 0x00
strsp   db " ", 0x00
row     db 0x00
col     db 0x00



;***********************************************************************
; PS/2 mouse protocol (Standard PS/2 protocol)
;***********************************************************************
; ----------------------------------------------------------------------
;
; Data packet format: 
; Data packet is 3 BYTE PTR packet. 
; It is send to the computer every time mouse state changes 
; (mouse moves or keys are pressed/released). 
; 
;   Bit7 Bit6 Bit5 Bit4 Bit3 Bit2 Bit1 Bit0 
; 
; 1. YO   XO   YS   XS   1    MB   RB   LB 
; 2. X7   X6   X5   X4   X3   X2   X1   X0
; 3. Y7   Y6   Y5   Y4   Y3   Y2   Y1   Y0
;
; This means:
; YO   :  Overflow bit for Y-coord (movement to fast)
; XO   :  Overflow bit for X-coord (movement to fast) 
; X0-X7:  BYTE PTR of the x-coord 
; Y0-Y7:  BYTE PTR of the y-coord
; LB   :  Left button pressed
; RB   :  Right button pressed
; MB   :  Middle button pressed
;
;*********************************************************************** 
;If you want to use the scroll function u might look up the protocol at 
;the company that made the mouse. 
;(the packet format will then mostly be greater then 3)
;***********************************************************************
