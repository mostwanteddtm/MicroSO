ORG 100H 		;* YEP its a .COM file!

;-----------------------------
;-----------------------------
;I will use the nasm syntax!!
;I tested this code on a Tulip(R) mouse.
;-----------------------------
;(Piece of disclaimer)
;(I do NOT give any guarantee or what so ever on this piece of code.)
;(I am not responsible for any damage whatsoever                    )
;(By using this code u accept the two lines above                   )
;-----------------------------
;-----------------------------

;*-----------------------------*
;The Ralf Brown interruptlist
;*-----------------------------*
;If you want to know what to do with most ports and interrupts then lookup
;this list. (yust a recommedation)
;
;In this sourcecode I have included some parts of the Ralf Brown list, but
;these parts only cover the needed ports for this source code.
;
;For more correct and more info on any port i strongly recommend you to 
;read the Ralf Brown interruptlist.
;*-----------------------------*

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
;***********************************************************************
; Here are the procedures needed to decode packets & init'ing the mouse
;***********************************************************************
;-----------------------------------------------------------------------

;***********************************************************************
;Set COM port for MS protocol  (for COM-details see the ralf brownlist)
;***********************************************************************
COMSET:
 xor  ax, ax      ;make ax empty
 mov  al, 0x86    ;value for 1200 Baud, 1 stop bit, 7 data bits  	|For more info see below| INT 14h|
 mov  dx, 0       ;port number
 int  14h	  ;Set comport
ret


;***********************************************************************
;Enable mouse  (power on) (DTR + RTS) 
;***********************************************************************
MSENABLE:
 mov  dx, 3fch   ; COMPORT control					|For more info see below| PORT 3FC|
 mov  al, 3	  ; DTR + RTS
 out  dx, al      ; send changes 
ret

;???
;on power on the mouse will first send the character "M"
;!! it might be handy to use this as a test if the mouse is ACTIVE
;???


;***********************************************************************
;Check for data ;mouse move or button click/ unclick
;GET mouse byte
;***********************************************************************
GET:
 mov  dx, 3fdh   ; COMPORT control					|For more info see below| PORT 3FD|
 in   al, dx      ; get status
 and  al, 1       ; check if byte is ready
 cmp  al, 0 
 je  GET
 mov  dx, 3f8h	  ; get the byte
 in   al, dx
ret


;***********************************************************************
;Find first byte of protocol    (bit 6 is "1")
;***********************************************************************
;?? For the MS-protocol see below	
;***********************************************************************
findfirst:                ;find first byte
 call GET
 mov  bl, al
 and  bl, 64		  ;compare bits (test if bit 6 =1)
 cmp  bl, 0
 je  findfirst

 mov  bl, al              ;get left button status
 and  bl, 32
 shr  bl, 5		  ;move bits to end
 mov  BYTE PTR [LBUTTON], bl

 mov  bl, al              ;get right button status
 and  bl, 16
 shr  bl, 4		  ;move bits to end
 mov  BYTE PTR [RBUTTON], bl

 mov  bl, al              ;get high bits of Y coord
 and  bl, 12
 shl  bl, 4		  ;move bits to front
 mov  BYTE PTR [YCOORD], bl

 mov  bl, al              ;get high bits of X coord
 and  bl, 3
 shl  bl, 6		  ;move bits to front 
 mov  BYTE PTR [XCOORD], bl
ret


;***********************************************************************
;HANDLE 2nd BYTE
;***********************************************************************
handle2:
 mov  bl, al              ;get the rest of the xcoord
 and  bl, 63
 add  BYTE PTR [XCOORD], bl
ret


;***********************************************************************
;HANDLE 3rd BYTE
;***********************************************************************
handle3:
 mov  bl, al              ;get the rest of the ycoord
 and  bl, 63
 add  BYTE PTR [YCOORD], bl
ret

;-----------------------------------------------------------------------
;***********************************************************************
; End of the procedure list.
;***********************************************************************
;-----------------------------------------------------------------------



;-----------------------------------------------------------------------
;=======================================================================
;MAIN part of the program
;=======================================================================
;-----------------------------------------------------------------------
MAINP:
 call COMSET
 call MSENABLE
main:
 call findfirst
 call GET
 call handle2
 call GET
 call handle3


;*NOW WE HAVE XCOORD & YCOORD* + the button status of L-butten and R-button

;!!!
;! The first bit of XCOORD or YCOORD means -128  (MINUS)
;! The rest is positive
;!!!

;???
;? Like if XCOORD = 11111110 ---> -128+126 = -2  (the mouse cursor goes left)
;?                  |\     /
;?   Negative    ---/ \   /
;?                     \Positive
;???


;the rest of the source...  (like move cursor) (i leave this up to you m8!)



;*************************************************************
;Allright, Allright i'll give an example! 
;*************************************************************
;=============================
;Save current position on scr
;=============================
 mov BYTE PTR [row], 20
 mov BYTE PTR [col], 0


;=============================
;**Lets display the X coord**
;=============================
 mov  si, OFFSET strcdx
 call disp
 xor  ah, ah
 mov  al, BYTE PTR [XCOORD]
 call DISPDEC
 mov  si, OFFSET stretr
 call disp

;=============================
;**Lets display the Y coord**
;=============================
 mov  si, OFFSET strcdy
 call disp
 xor  ah, ah
 mov  al, BYTE PTR [YCOORD]
 call DISPDEC
 mov  si, OFFSET stretr
 call disp

;=============================
;**Lets display the L button**
;=============================
 mov  si, OFFSET strlbt
 call disp
 mov  al, BYTE PTR [LBUTTON]
 xor  ah, ah
 call DISPDEC
 mov  si, OFFSET stretr
 call disp

;=============================
;**Lets display the R button**
;=============================
 mov  si, OFFSET strrbt
 call disp
 mov  al, BYTE PTR [RBUTTON]
 xor  ah, ah
 call DISPDEC
 mov  si, OFFSET stretr
 call disp
 
;=============================
;**go back to start position**
;=============================
 call GOTOXY


;=============================
;**stop program on keypress**
;=============================
    xor  ax, ax
    mov  ah, 11h
    int  16h
    jnz quitprog
;*************************************************************



jmp .main

quitprog:
     INT 20H		
;-----------------------------------------------------------------------
;=======================================================================
;* END OF MAIN PROGRAM
;=======================================================================
;-----------------------------------------------------------------------


;XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
;X Dont Worry about this DisplayPart, its yust ripped of my os.
;X (I know it could be done nicer but this works :P)
;XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
;XXX
;************************************************
;* Displays AX in a decimal way 
;************************************************
DISPDEC:
    mov  BYTE PTR [zerow], 00h
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
    cmp  BYTE PTR [zerow], 00h
    je nodisp

ydisp:
    mov  ah, 0Eh                                    ; BIOS teletype
    add  al, 48                                     ; lets make it a 0123456789 :D
    mov  bx, 1 
    int  10h                                        ; invoke BIOS
    mov  BYTE PTR [zerow], 01h
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
    je bver
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
    lodsb                                       ; load next character
    or   al, al                                 ; test for NUL character
    jz   DONE                                  ; if NUL char found then goto done
    mov  ah, 0Eh                                ; BIOS teletype
    mov  bx, 1 				                    ; make it a nice blue color (in this program it still displays a grey one)
    int  10h                                    ; invoke BIOS
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
    int 10h
ret
;*******END********

;
;XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
;XXX
;XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX








;***********************************************************************
;variables
;***********************************************************************
LBUTTON db 00h	;	Left  button status 1=PRESSED 0=RELEASED
RBUTTON db 00h	;	Right button status 1=PRESSED 0=RELEASED
XCOORD  db 00h	;	the moved distance  (horizontal)
YCOORD  db 00h	;	the moved distance  (vertical)




;************************************
;* Some var's of my display function
;************************************
deel    dw 0000h
varbuff dw 0000h
zerow   db 00h
strlbt  db "Left button:  ", 00h
strrbt  db "Right button: ", 00h
strcdx  db "Mouse moved (X): ", 00h
strcdy  db "Mouse moved (Y): ", 00h
stretr  db 0Dh, 0Ah, 00h
row     db 00h
col     db 00h



;-----------------------------------------------------------------------
;***********************************************************************
; MSmouse protocol
;***********************************************************************
;-----------------------------------------------------------------------
; Serial data parameters: 
; 1200bps, 7 databits, 1 stop-bit 
;-----------------------------------------------------------------------
;
; Data packet format: 
; Data packet is 3 byte packet. 
; It is send to the computer every time mouse state changes 
; (mouse moves or keys are pressed/released). 
; 
;   Bit7 Bit6 Bit5 Bit4 Bit3 Bit2 Bit1 Bit0 
; 
; 1. X    1    LB   RB   Y7   Y6   X7   X6 
; 2. X    0    X5   X4   X3   X2   X1   X0 
; 3. X    0    Y5   Y4   Y3   Y2   Y1   Y0 
;
; This means:
; X    :  dont care (eiter 1 or 0) depends on mouse
; X0-X7:  byte of the x-coord 
; Y0-Y7:  byte of the y-coord
; LB   :  Left button pressed
; RB   :  Right button pressed
;*********************************************************************** 
;-----------------------------------------------------------------------


;-----------------------------------------------------------------------
;***********************************************************************
;INT 14 - SERIAL - INITIALIZE PORT	|Made of some info of Ralf Brown interrupt list|
;***********************************************************************
;-----------------------------------------------------------------------
;Input:	AH = 00h
;	AL = port parameters 
;	DX = port number (00h-03h) (COM1-COM4)
;
;Return: AH = line status 
;	 AL = modem status 
;
;----------------------------------------------------------------
;Table for Port parameters	|This is of most interest for us|
;----------------------------------------------------------------
;Bit(s)	Description	
; 7-5	baudrate 	(000, 001, 010, 011,  100,  101,  110,  111)
;		 (bps)	(110, 150, 300, 600, 1200, 2400, 4800, 9600) 
;
; 4-3	parity 	 	(00 or 10,  01,   11 )
;		 	(  none  , odd, even )
;
; 2	stop bits 	(    1 ,   0  )
;			( 2bits, 1bit )
;
; 1-0	data bits 	( 00 , 01 , 10 , 11 )
;			(  5 ,  6 ,  7 ,  8 )
;----------------------------------------------------------------
;
;----------------------------
;Table for Line status		
;----------------------------
;Bit(s)	Description
; 7	timeout
; 6	transmit shift register empty
; 5	transmit holding register empty
; 4	break detected
; 3	framing error
; 2	parity error
; 1	overrun error
; 0	receive data ready
;----------------------------
;
;----------------------------
;Table for Modem status
;----------------------------
;Bit(s)	Description
; 7	carrier detect			
; 6	ring indicator
; 5	data set ready
; 4	clear to send
; 3	delta carrier detect
; 2	trailing edge of ring indicator
; 1	delta data set ready
; 0	delta clear to send
;
;***********************************************************************
;-----------------------------------------------------------------------


;-----------------------------------------------------------------------
;***********************************************************************
;Serial port	|These are parts(snippets) of the Ralf Brown interrupt list|
;***********************************************************************
;-----------------------------------------------------------------------
;PORT 02E8h-02EFh (COM2)
;PORT 02F8h-02FFh (typical non-PS/2 COM3)
;PORT 03E8h-03EFh (typical non-PS/2 COM4)
;
;03FC  RW  modem control register (see #P0881)
;03FD  R-  line status register (LSR) (see #P0882)
;
;RW = Read + write
;R- = Read only
;
;
;-----------------------------------------------------------------------
;Bitlayout for port 3FC
;-----------------------------------------------------------------------
;
;Bitfields for serial port Modem Control Register (MCR):
;Bit(s)	Description	(Table P0881)
; 7-6	reserved (0)
; 5	(82510 only) state of OUT0 pin
; 4	loopback mode for diagnostic testing of serial port
;	output of transmitter shift register is looped back to receiver
;	  shift register input. In this mode, transmitted data is received
;	  immediately so that the CPU can verify the transmit data/receive
;	  data serial port paths.
;	If OUT2 is disabled, there is no official way to generate an IRQ
;	  during loopback mode.
; 3	auxiliary user-designated output 2 (OUT2)
;	because of external circuity OUT2 must be 1 to master-intr-enableing.
;	BUG: Some Toshiba Laptops utilize this bit vice versa, newer Toshiba
;	  machines allow assignment of the bit's polarity in system setup.
;	82050: This bit is only effective, if the chip is being used with an
;	  externally-generated clock.
; 2	=1/0  auxiliary user-designated output 1 (OUT1)
;	should generally be cleared!!
;	Some external hardware, e.g. c't MIDI interface (and compatibles) use
;	  this bit to change the 8250 input clock from 1,8432 MHz to 4Mhz
;	  (enabling MIDI-conformant baudrates) and switching to
;	  MIDI-compatible current loop connectors.
; 1	force request-to-send active (RTS)		|Set voltage over the RTS pin in COM-port|
; 0	force data-terminal-ready active (DTR)		|Set voltage over the RTS pin in COM-port|
;
;????????????????????????????????????????????????
; See mouse basics below !
;????????????????????????????????????????????????
;
;-----------------------------------------------------------------------
;Bitlayout for port 3FD
;-----------------------------------------------------------------------
;
;Bitfields for serial port Line Status Register (LSR):
;Bit(s)	Description	(Table P0882)
; 7	=0  reserved
;	=1  on some chips produced by UMC
; 6	transmitter shift and holding registers empty
; 5	transmitter holding register empty (THRE)
;	Controller is ready to accept a new character to send.
; 4	break interrupt. the received data input is held in the zero bit
;	  state longer than the time of start bit + data bits + parity bit +
;	  stop bits.
; 3	framing error (FE). the stop bit that follows the last parity or data
;	  bit is a zero bit
; 2	parity error (PE). Character has wrong parity
; 1	overrun error (OE). a character was sent to the receiver buffer
;	  before the previous character in the buffer could be read. This
;	  destroys the previous character.
; 0	data ready. a complete incoming character has been received and sent
;	  to the receiver buffer register.		|Check if mouse send a byte over COM-port|
;
;????????????????????????????????????????????????
; I only use this port to see if there is a byte 
; in the buffer. 
; (like only read when a byte is ready)
;????????????????????????????????????????????????
;
;***********************************************************************
;-----------------------------------------------------------------------



;-----------------------------------------------------------------------
;***********************************************************************
; Serial Mouse Basics
;***********************************************************************
;-----------------------------------------------------------------------
;
;First of all is that u need power for your mouse to function.
;To power your mouse u need to put the RTS & DTR pins on 1.
;How this functions?
;
;Well lets take a look at the COM-port pinout:
;
;
;You can control the 0 and the 1 status of DTR & RTS by using 
;the Line Status Register (LSR), port 3FD for this program.
;
;------------
;Pinout of The COM-port
;------------
;9 pin    25 pin     Wire Name            Comments
;shell     1         Protective Ground
;3         2         TD                  Serial data from host to mouse (only for power)
;2         3         RD                  Serial data from mouse to host
;7         4         RTS                 Positive voltage to mouse
;8         5         CTS
;6         6         DSR
;5         7         Signal Ground
;4         20        DTR                 Positive voltage to mouse and reset/detection
;------------
;
;RTS = Request to Send   CTS = Clear to Send
;DSR = Data Set Ready    DTR = Data Terminal Ready
;
;
;
;
;
;------------
;Ok lets move on. 
;If you put power on your mouse this way (enableing the DTR & RTS) the mouse will 
;'powerup' and send a byte to the COM-port. (This byte is an 'M')
; 
;If you build your own mouse driver u can check this way if a MSmouse is connected 
;to your COM-port. 
;
;
;
;
;
;------------
;About the info the mouse sends to us:
;------------
;
;(Note: To get the X and Y movements look at the Serial MS-mouse protocol above)
;If you build together the X and the Y movements of the mouse u get a value, this value 
;consists of data build by the mouse movement detectors. 
;
;Mouse movement detectors
;The most mouse movement detectors consists of an light (IR-led) and a 
;wheel (with gaps, slots) and an detector.
;These wheels are connected to the mouse ball by a axel. (1 for y and 1 for x)
;per wheel there are 2 detectors that are placed in a 90 deg phase shift so you can 
;sepperate the forward and backward direction
;
;Each time a wheel turns the gap appears/disappears so the detector sees a ligh or doesnt see a light.
;
;Example:
;sensor 1 ----    ----    ----  sensor 'sees' a light
;             ----    ----      sensor doesn't 'see' a light
;
;sensor 2   ----    ----    --  sensor 'sees' a light
;         --    ----    ----    sensor doesn't 'see' a light
;
;
;This data is sliced in time slots and converted to binary code:
;Example:
;Sensor info:
;sensor 1 ----    ----    ----   sensor 'sees' a light
;             ----    ----       sensor doesn't 'see' a light
;
;sensor 2   ----    ----    --   sensor 'sees' a light
;         --    ----    ----     sensor doesn't 'see' a light
;
;Binary info:
;         11110000111100001111
;         00111100001111000011
;
;Simplyfied this looks like: 
;         Forward direction     Backwards direction
;bit#       0 1 2 3                3 2 1 0
;sensor 1 - 1 1 0 0                0 0 1 1
;sensor 2 - 0 1 1 0                0 1 1 0
;
;To separate the backward direction from the forward directon the mouse-chip changes the data into:
;forward direction	the most significant bit (highest bit) becomes 0
;backward direction	the most significant bit (highest bit) becomes 1
;
;The most significant bit stands for dec: 128.
;When this bit is set it counts for -128 and the rest of the bits are still positive:
;
; Like if XCOORD = 11111110 ---> 1 * -128 + 126 = -2  (the mouse cursor goes left)
;                  |\     /
;   Negative    ---/ \   /
;                     \Positive
;
; Like if XCOORD = 00000001 ---> 0 * -128 + 1 = 1  (the mouse cursor goes left)
;                  |\     /
;   Negative    ---/ \   /
;                     \Positive
;
;Keep in mind that movement of zero can only be arranged the following way
;
; Like if XCOORD = 00000000 ---> 0 * -128 + 0 = 0  (the mouse cursor goes left)
;                  |\     /
;   Negative    ---/ \   /
;                     \Positive
;
;
;------------
;Well armed with this information you sould be able to understand the working of this program.
;------------
;
;
;
;
;------------
;Basic layout of my program:
;------------
;1.Set COM-1 at 1200bps, 7 databits, 1 stop-bit 
;2.Enable mouse (RTS+DTR)
;3.Decode the packet
;--
;3.1 Find the first byte of MS-mouse packet. (bit6 = 1)
;3.2 read second byte
;3.3 read third byte
;--
;4. display the stuff (not interresting for building mouse programs)
;
;
;