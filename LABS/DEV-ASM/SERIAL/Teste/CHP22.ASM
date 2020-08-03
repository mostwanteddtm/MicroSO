#masm#
; ______________________________________________________________________________________
;|																						|
;|						Template para compilacao com o MASM 6.15						|
;|______________________________________________________________________________________|

.286
.MODEL TINY 
_Text SEGMENT PUBLIC USE16
	ASSUME CS:_TEXT,DS:_TEXT,ES:_TEXT 

.DATA
             
.CODE

ORG 100h

;---------------------------------------------------------------------------------------
;									EntryPoint
;---------------------------------------------------------------------------------------

main:
            call ComBaud
            
ComBaud         proc 
                
                            push        ax
                            push        dx
                            cmp         ax, 9600
                            ja          Set19200
                            je          Set9600
                            cmp         ax, 2400
                            ja          Set4800
                            je          Set2400
                            cmp         ax, 600
                            ja          Set1200
                            je          Set600
                            cmp         ax, 150
                            ja          Set300
                            je          Set150
                            mov         ax, 1047                ;Default to 110 bps.
                            jmp         SetPort
                            
Set150:                     mov         ax, 768                 ;Divisor value for 150 bps.
                            jmp         SetPort
Set300:                     mov         ax, 384                 ;Divisor value for 300 bps.
                            jmp         SetPort
Set600:                     mov         ax, 192                 ;Divisor value for 600 bps.
                            jmp         SetPort
Set1200:                    mov         ax, 96                  ;Divisor value for 1200 bps.
                            jmp         SetPort
Set2400:                    mov         ax, 48                  ;Divisor value for 2400 bps.
                            jmp         SetPort
Set4800:                    mov         ax, 24                  ;Divisor value for 4800 bps.
                            jmp         SetPort
Set9600:                    mov         ax, 12                  ;Divisor value for 9600 bps.
                            jmp         short SetPort
            
Set19200:                   mov         ax, 6                   ;Divisor value for 19.2 kbps.
SetPort:                    mov         dx, ax                  ;Save baud value.
                            call        ComGetLCR               ;Fetch LCR value.
                            push        ax                      ;Save old divisor bit value.
                            or          al, 80h                 ;Set divisor select bit.
                            call        ComSetLCR               ;Write LCR value back.
                            mov         ax, dx                  ;Get baud rate divisor value.
                            mov         dx, ComPort             ;Point at L.O. byte of divisor reg.
                            out         dx, al                  ;Output L.O. byte of divisor.
                            inc         dx                      ;Point at the H.O. byte.
                            mov         al, ah                  ;Put H.O. byte in AL.
                            out         dx, al                  ;Output H.O. byte of divisor.
                            pop         ax                      ;Retrieve old LCR value.
                            call        ComSetLCR               ;Restore divisor bit value.
                            pop         dx
                            pop         ax  
                            
                            ret
ComBaud         endp
            
comStop         proc
                            push        ax
                            push        dx
                            dec         ax                      ;Convert 1 or 2 to 0 or 1.
                            and         al, 1                   ;Strip other bits.
                            shl         ax, 2                   ;position into bit #2.
                            mov         ah, al                  ;Save our output value.
                            call        ComGetLCR               ;Read LCR value.
                            and         al, 11111011b           ;Mask out Stop Bits bit.
                            or          al, ah                  ;Merge in new # of stop bits.
                            call        ComSetLCR               ;Write result back to LCR.
                            pop         dx
                            pop         ax  
                            
                            ret
comStop         endp
            
ComSize         proc
                            push        ax
                            push        dx
                            sub         al, 5                   ;Map 5..8 -> 00b, 01b, 10b, 11b
                            cmp         al, 3
                            jbe         Okay
                            mov         al, 3                   ;Default to eight bits.
Okay:                       mov         ah, al                  ;Save new bit size.
                            call        ComGetLCR               ;Read current LCR value.
                            and         al, 11111100b           ;Mask out old word size.
                            or          al, ah                  ;Merge in new word size.
                            call        ComSetLCR               ;Write new LCR value back.
                            pop         dx
                            pop         ax 
                            
                            ret
comsize         endp
            
comparity       proc
                            push        ax
                            push        dx
                            shl         al, 3                   ;Move to final position in LCR.
                            and         al, 00111000b           ;Mask out other data.
                            mov         ah, al                  ;Save for later.
                            call        ComGetLCR               ;Get current LCR value.
                            and         al, 11000111b           ;Mask out existing parity bits.
                            or          al, ah                  ;Merge in new bits.
                            call        ComSetLCR               ;Write results back to the LCR.
                            pop         dx
                            pop         ax    
                            
                            ret
comparity       endp
            
ComRead         proc
                            push        dx
                            call        ComGetLCR
                            push        ax                      ;Save divisor latch access bit.
                            and         al, 7fh                 ;Select normal ports.
                            call        ComSetLCR               ;Write LCR to turn off divisor reg.
WaitForChar:                call        ComGetLSR               ;Get data available bit from LSR.
                            test        al, 1                   ;Data Available?
                            jz          WaitForChar             ;Loop until data available.
                            mov         dx, comPort             ;Read the data from the input port.
                            in          al, dx
                            mov         dl, al                  ;Save character
                            pop         ax                      ;Restore divisor access bit.
                            call        ComSetLCR               ;Write it back to LCR.
                            mov         al, dl                  ;Restore output character.
                            pop         dx  
                            
                            ret
ComRead         endp
            
ComWrite        proc
                            push        dx
                            push        ax
                            mov         dl, al                  ;Save character to output
                            call        ComGetLCR               ;Switch to output register.
                            push        ax                      ;Save divisor latch access bit.
                            and         al, 7fh                 ;Select normal input/output ports
                            call        ComSetLCR               ;rather than divisor register.
WaitForXmtr:                call        ComGetLSR               ;Read LSR for xmit empty bit.
                            test        al, 00100000b           ;Xmtr buffer empty?
                            jz          WaitForXmtr             ;Loop until empty.
                            mov         al, dl                  ;Get output character.
                            mov         dx, ComPort             ;Store it in the ouput port to
                            out         dx, al                  ;get it on its way.
                            pop         ax                      ;Restore divisor access bit.
                            call        ComSetLCR
                            pop         ax
                            pop         dx    
                            
                            ret
ComWrite        endp
            
ComTstIn        proc
                            call        ComGetLSR
                            and         ax, 1                   ;Keep only data available bit.    
                            
                            ret
ComTstIn        endp
            
ComTstOut       proc
                            push        dx
                            call        ComGetLSR               ;Get the line status.
                            test        al, 00100000b           ;Mask Xmitr empty bit.
                            mov         al, 0                   ;Assume not empty.
                            jz          toc1                    ;Branch if not empty.
                            inc         ax                      ;Set to one if it is empty.    
                            
toc1:                       ret

ComTstOut       endp
            
ComGetLSR       proc                                            ;Returns the LSR value in the AL reg.
                            push        dx
                            mov         dx, comLSR              ;Select LSR register.
                            in          al, dx                  ;Read and return the LSR value.
                            pop         dx    
                            
                            ret
ComGetLSR       endp
            
ComGetMSR       proc                                            ;Returns the MSR value in the AL reg.
                            push        dx
                            mov         dx, comMSR              ;Select MSR register.
                            in          al, dx                  ;Read and return MSR value.
                            pop         dx     
                            
                            ret
ComGetMSR       endp
            
ComSetMCR       proc                                            ;Stores AL’s value to the MCR reg.
                            push        dx
                            mov         dx, comMCR              ;Point at MCR register.
                            out         dx, al                  ;Output value in AL to MCR.
                            pop         dx  
                            
                            ret
ComSetMCR       endp
            
ComGetMCR       proc                                            ;Stores value in AL into MCR reg.
                            push        dx                             
                            mov         dx, comMCR              ;Select MCR register.
                            in          al, dx                  ;Read value from MCR register into AL.
                            pop         dx
                            ret  
                            
ComGetMCR       endp
            
ComGetLCR       proc                                            ;Return the LCR value in the AL reg.
                            push        dx
                            mov         dx, comLCR              ;Point at LCR register.
                            in          al, dx                  ;Read and return LCR value.
                            pop         dx        
                            
                            ret
ComGetLCR       endp  
            
ComSetLCR       proc                                            ;Write a new value to the LCR.
                            push        dx
                            mov         dx, comLCR              ;Point at LCR register.
                            out         dx, al                  ;Write value in AL to the LCR.
                            pop         dx   
                            
                            ret
ComSetLCR       endp 
            
ComGetIIR       proc                                            ;Return the value in the IIR.
                            push        dx
                            mov         dx, comIIR              ;Select IIR register.
                            in          al, dx                  ;Read IIR value into AL and return.
                            pop         dx   
                            
                            ret
ComGetIIR       endp
            
ComGetIER       proc                                            ;Return IER value in AL.
                            push        dx
                            call        ComGetLCR               ;Need to select IER register by saving
                            push        ax                      ;the LCR value and then clearing the
                            and         al, 7fh                 ;baud rate divisor latch bit.
                            call        ComSetLCR
                            mov         dx, comIER              ;Address the IER.
                            in          al, dx                  ;Read current IER value.
                            mov         dl, al                  ;Save for now
                            pop         ax                      ;Retrieve old LCR value (divisor latch).
                            call        ComSetLCR               ;Restore divisor latch
                            mov         al, dl                  ;Restore IER value
                            pop         dx     
                            
                            ret
ComGetIER       endp
            
ComSetIER       proc                                            ;Writes value in AL to the IER.
                            push         dx
                            push         ax                     ;Save AX’s value.
                            mov         ah, al                  ;Save IER value to output.
                            call        ComGetLCR               ;Get and save divsor access
                            push        ax                      ;bit.
                            and         al, 7fh                 ;Clear divisor access bit.
                            call        ComSetLCR
                            mov         al, ah                  ;Retrieve new IER value.
                            mov         dx, comIER              ;Select IER register
                            out         dx, al                  ;Output IER value.
                            pop         ax                      ;Restore divisor latch bit.
                            call        ComSetLCR
                            pop         ax
                            pop         dx
                            ret
ComSetIER       endp
            
ComInitIntr     proc
                            pushf                               ;Save interrupt disable flag.
                            push        es
                            push        ax
                            push        dx
                            
                                                                ;Turn off the interrupts while we’re doing this.
                            cli
                            
                            ;Save old interrupt vector. Obviously, you must change the following code
                            ;to save and set up the int 0Bh vector if you want to access COM2: rather
                            ;than the COM1: port. 
                            
                            xor         ax, ax                  ;Point at interrupt vectors
                            mov         es, ax
                            mov         ax, Int0Cofs
                            mov         word ptr OldInt0C, ax
                            mov         ax, Int0Cseg
                            mov         word ptr OldInt0C+2, ax   
                            
                            ; Point int 0ch vector at our interrupt service routine (see note above
                            ; concerning switching to COM2:). 
                            
                            mov         ax, cs
                            mov         Int0Cseg, ax
                            mov         ax, offset ComIntISR
                            mov         Int0Cofs, ax 
                            
                            ; Clear any pending interrupts:   
                            
                            call        ComGetLSR               ;Clear Receiver line status
                            call        ComGetMSR               ;Clear CTS/DSR/RI Interrupts
                            call        ComGetIIR               ;Clear xmtr empty interrupt
                            mov         dx, ComPort
                            in          al, dx                  ;Clear data available intr.
                            
                            ; Clear divisor latch access bit. WHILE OPERATING IN INTERRUPT MODE, THE
                            ; DIVISOR ACCESS LATCH BIT MUST ALWAYS BE ZERO. If for some horrible reason
                            ; you need to change the baud rate in the middle of a transmission (or while
                            ; the interrupts are enabled) clear the interrupt flag, do your dirty work,
                            ; clear the divisor latch bit, and finally restore interrupts. 
                            
                            call        ComGetLCR               ;Get LCR.
                            and         al, 7fh                 ;Clear divisor latch bit.
                            call        ComSetLCR               ;Write new LCR value back. 
                            
                            ; Enable the receiver and transmitter interrupts. Note that this code
                            ; ignores error and modem status change interrupts.
                            
                            mov         al, 3                   ;Enable rcv/xmit interrupts
                            call        ComSetIER       
                            
                            ; Must set the OUT2 line for interrupts to work.
                            ; Also sets DTR and RTS active.   
                            
                            mov         al, 00001011b
                            call        ComSetMCR 
                            
                            ; Activate the COM1 (int 0ch) bit in the 8259A interrupt controller chip.
                            ; Note: you must change the following code to clear bit three (rather than
                            ; four) to use this code with the COM2: port. 
                            
                            in          al, 21h                 ;Get 8259A interrupt enable value.
                            mov         i8259a, al              ;Save interrupt enable bits.
                            and         al, 0efh                ;Bit 4=IRQ 4 = INT 0Ch
                            out         21h, al                 ;Enable interrupts.
                            pop         dx
                            pop         ax
                            pop         es
                            popf                                ;Restore interrupt disable flag.   
                            
                            ret
ComInitIntr     endp
            
ComDisIntr      proc
                            pushf
                            push        es
                            push        dx
                            push        ax
                            cli                                 ;Don’t allow interrupts while messing
                            xor         ax, ax                  ;with the interrupt vectors.
                            mov         es, ax                  ;Point ES at interrupt vector table. 
                            
                            ; First, turn off the interrupt source at the 8250 chip: 
                            
                            call        ComGetMCR               ;Get the OUT 2 (interrupt enable) bit.
                            and         al, 3                   ;Mask out OUT 2 bit (masks ints)
                            call        ComSetMCR               ;Write result to MCR. 
                            
                            ; Now restore the IRQ 4 bit in the 8259A PIC. Note that you must modify this
                            ; code to restore the IRQ 3 bit if you want to support COM2: instead of COM1: 
                            
                            in          al, 21h                 ;Get current 8259a IER value
                            and         al, 0efh                ;Clear IRQ 4 bit (change for COM2:!)
                            mov         ah, i8259a              ;Get our saved value
                            and         ah, 1000b               ;Mask out com1: bit (IRQ 4).
                            or          al, ah                  ;Put bit back in.
                            out         21h, al                 
                            
                            ; Restore the interrupt vector:    
                            
                            mov         ax, word ptr OldInt0C
                            mov         Int0Cofs, ax
                            mov         ax, word ptr OldInt0C+2
                            mov         Int0Cseg, ax
                            pop         ax
                            pop         dx
                            pop         es
                            popf   
                            
                            ret
ComDisIntr      endp
            
ComIntISR       proc far
                            push        ax
                            push        bx
                            push        dx
TryAnother:                 mov         dx, ComIIR
                            in          al, dx                  ;Get interrupt id value.
                            test        al, 1                   ;Any interrupts left?
                            jnz         IntRtn                  ;Quit if no interrupt pending.
                            cmp         al, 100b                ;Since only xmit/rcv ints are
                            jnz         ReadCom1                ;active, this checks for rcv int.
                            cmp         al, 10b                 ;This checks for xmit empty intr.
                            jnz         WriteCom1      
                            
                            ; Bogus interrupt? We shouldn’t ever fall into this code because we have
                            ; not enabled the error or status change interrupts. However, it is possible
                            ; that the application code has gone in and tweakd the IER on the 8250.
                            ; Therefore, we need to supply a default interrupt handler for these conditions.
                            ; The following code just reads all the appropriate registers to clear any
                            ; pending interrupts.
                            
                            call        ComGetLSR               ;Clear receiver line status
                            call        ComGetMSR               ;Clear modem status.
                            jmp         TryAnother              ;Check for lower priority intr.  
                            
                            ; When there are no more pending interrupts on the 8250, drop down and
                            ; and return from this ISR.      
                            
IntRtn:                     mov         al, 20h                 ;Acknowledge interrupt to the
                            out         20h, al                 ;8259A interrupt controller.
                            pop         dx
                            pop         bx
                            pop         ax
                            iret 
                            
                            ; Handle incoming data here:
                            ; (Warning: This is a critical region. Interrupts MUST BE OFF while executing
                            ; this code. By default, interrupts are off in an ISR. DO NOT TURN THEM ON
                            ; if you modify this code).  
                            
ReadCom1:                   mov         dx, ComPort             ;Point at data input register.
                            in          al, dx                  ;Get the input char
                            mov         bx, InHead              ;Insert the character into the
                            mov         [bx], al                ;serial input buffer.
                            inc         bx                      ;Increment buffer ptr.
                            cmp         bx, offset InpBufEnd
                            jb          NoInpWrap
                            mov         bx, offset InpBuf
NoInpWrap:                  cmp         bx, InTail              ;If the buffer is full, ignore this
                            je          TryAnother              ;input character.
                            mov         InHead, bx
                            jmp         TryAnother              ;Go handle other 8250 interrupts. 
                            ; Handle outgoing data here (This is also a critical region): 
                            
WriteCom1:                  mov         bx, OutTail             ;See if the buffer is empty.
                            cmp         bx, OutHead
                            jne         OutputChar              ;If not, output the next char. 
                            ; If head and tail are equal, simply set the TestBuffer variable to zero
                            ; and quit. If they are not equal, then there is data in the buffer and
                            ; we should output the next character. 
                            
                            mov         TestBuffer, 0
                            jmp         TryAnother              ;Handle other pending interrupts.
                            ; The buffer pointers are not equal, output the next character down here. 
                            
OutputChar:                 mov         al, [bx]                ;Get the next char from the buffer.
                            mov         dx, ComPort             ;Select output port.
                            out         dx, al                  ;Output the character
                            ; Okay, bump the output pointer. 
                            
                            inc         bx
                            cmp         bx, offset OutBufEnd
                            jb          NoOutWrap
                            mov         bx, offset OutBuf
NoOutWrap:                  mov         OutTail, bx
                            jmp         TryAnother
ComIntISR       endp
                            
ComIn           proc
                            pushf                               ;Save interrupt flag
                            push        bx
                            sti                                 ;Make sure interrupts are on.
TstInLoop:                  mov         bx, InTail              ;Wait until there is at least one
                            cmp         bx, InHead              ;character in the input buffer.
                            je          TstInLoop
                            mov         al, [bx]                ;Get next char.
                            cli                                 ;Turn off ints while adjusting
                            inc         bx                      ;buffer pointers.
                            cmp         bx, offset InpBufEnd
                            jne         NoWrap2
                            mov         bx, offset InpBuf
NoWrap2:                    mov         InTail, bx
                            pop         bx
                            popf                                ;Restore interrupt flag.   
                            
                            ret
ComIn       endp
            
ComOut      proc far
                            pushf
                            cli                                 ;No interrupts now!
                            cmp         TestBuffer, 0           ;Write directly to serial chip?
                            jnz         BufferItUp              ;If not, go put it in the buffer.
                            ; The following code writes the current character directly to the serial port
                            ; because the 8250 is not transmitting anything now and we will never again
                            ; get a transmit holding register empty interrupt (at least, not until we
                            ; write data directly to the port).  
                            
                            push        dx
                            mov         dx, ComPort             ;Select output register.
                            out         dx, al                  ;Write character to port.
                            mov         TestBuffer, 1           ;Must buffer up next char.
                            pop         dx
                            popf        ;Restore interrupt flag.
                            ret
                            ; If the 8250 is busy, buffer up the character here: 
                            
BufferItUp:                 push        bx
                            mov         bx, OutHead             ;Pointer to next buffer position.
                            mov         [bx], al                ;Add the char to the buffer.
                            ; Bump the output pointer.
                            
                            inc         bx
                            cmp         bx, offset OutBufEnd
                            jne         NoWrap3
                            mov         bx, offset OutBuf
NoWrap3:                    cmp         bx, OutTail             ;See if the buffer is full.
                            je          NoSetTail               ;Don’t add char if buffer is full.
                            mov         OutHead, bx             ;Else, update buffer ptr.
NoSetTail:                  pop         bx
                            popf                                ;Restore interrupt flag 
                            
                            ret
ComOut      endp                            
            
            ; Useful equates:
            BIOSvars = 40h ;BIOS segment address.
            Com1Adrs = 0 ;Offset in BIOS vars to COM1: address.
            Com2Adrs = 2 ;Offset in BIOS vars to COM2: address.
            BufSize = 256 ;# of bytes in buffers.
            ; Serial port equates. If you want to support COM2: rather than COM1:, simply
            ; change the following equates to 2F8h, 2F9h, ...
            ComPort = 3F8h
            ComIER = 3F9h
            ComIIR = 3FAh
            ComLCR = 3FBh
            ComMCR = 3FCh
            ComLSR = 3FDh
            ComMSR = 3FEh
            ; Variables, etc. This code assumes that DS=CS. That is, all the variables
            ; are in the code segment.
            ;
            ; Pointer to interrupt vector for int 0Ch in the interrupt vector table.
            ; Note: change these values to 0Bh*4 and 0Bh*4 + 2 if you want to support
            ; the COM2: pot.
            int0Cofs equ es:[0Ch*4]
            int0Cseg equ es:[0Ch*4 + 2]
            OldInt0c dword ?   
            ; Input buffer for incoming character (interrupt operation only). See the
            ; chapter on data structures and the description of circular queus for
            ; details on how this buffer works. It operates in a fashion not unlike
            ; the keyboard’s type ahead buffer.
            InHead word InpBuf
            InTail word InpBuf
            InpBuf byte Bufsize dup (?)
            InpBufEnd equ this byte
            ; Output buffer for characters waiting to transmit.
            OutHead word OutBuf
            OutTail word OutBuf
            OutBuf byte BufSize dup (?)
            OutBufEnd equ this byte
            ; The i8259a variable holds a copy of the PIC’s IER so we can restore it
            ; upon removing our interrupt service routines from memory.
            
            i8259a byte 0 ;8259a interrupt enable register.
            ; The TestBuffer variable tells us whether we have to buffer up characters
            ; or if we can store the next character directly into the 8250’s output
            ; register (See the ComOut routine for details).
            TestBuffer db 0
            
END main

_TEXT ENDS
