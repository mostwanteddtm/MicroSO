;---------------- HWREAD.ASM --------------
; Demonstration for accessing the floppy controller directly
; Reads the bootsector and displays the ID string (at ofs 3)
; Original Read_Sector from a Dutch book, converted to English
; and (re?)commented by Arne de Bruijn, 1994, PD

; Locks up if no disk is inserted in drive 0 (usually A:), until you insert
; a disk
; With HD drives, you need first to switch to the proper density
; with port 3f7h, 0 = 3"5 HD, 1 = 5"25 HD, 2 = DD (not implented, just
; start with a value, if error try another, just like the BIOS does
; (that's why floppies are so slow after you insert a new disk))
; or just do a dir or something and the BIOS does it all for you
; I've tried to detect a diskchange with a read from port 3f7h, bit 7,
; but after I detected a change, I can't reset the bit (but the BIOS does).
; Anybody?

_DATA   segment word public 'DATA'
buffer  db 512 dup(?)           ; Buffer for the sector
status_buf db 7 dup(?)          ; Buffer for the returned status registers
_DATA   ends

_TEXT   segment word public 'CODE'
        assume ds:_DATA,es:nothing,cs:_TEXT,ss:_STACK
TestHWR proc far
        mov ax,_Data
        mov ds,ax
        call Read_Sector
        mov dx,3+offset buffer ; Address of ID string in bootsector
        mov cx,8               ; 8 Chars
        mov bx,1               ; To STDOUT
        mov ah,40h             ; Write
        int 21h
        mov ax,4c00h           ; Terminate w/exitcode 0
        int 21h
TestHWR endp

Read_Sector proc near
        sti                    ; Enable interrupts
        mov dx,3f2h            ; Address of Digital Output Register
        mov al,28 ;00011100    ; bit 1,0: 00 - Drive 0
                               ; bit 2: FDC enable, bit 3: DMA/IO enable
                               ; bit 4: Motor drive 0 enable
        out dx,al              ; To Digital Output Register
        call Wait_Motor        ; Let moter spin up for 1/2 sec.
        mov ah,15              ; Command 15: Seek
        call Send_FDC_Cmd      ; Send to FDC
        mov ah,0               ; Parameter 1: Drive no
        call Send_FDC_Cmd      ; Send to FDC
        mov ah,0               ; Parameter 2: Track no
        call Send_FDC_Cmd      ; Send to FDC
        call Wait_Int          ; Wait for IRQ 6 from FDC (cmd completed)
        mov cx,1750            ; Wait to settle head
Wait_Head: loop Wait_Head      ; A bit CPU dependant, but it works :-)
        mov al,46h             ; Init DMA
        out 12,al              ; ??
        out 11,al              ; ??
        mov ax,offset buffer   ; Offset of buffer to AX
        mov bx,ds              ; Segment of buffer to BX
        mov cl,4               ; Divide by 16
        rol bx,cl              ; To isolate 64K block (page) of buffer
        mov dl,bl
        and dl,0fh             ; Page no in DL
        and bl,0f0h            ; Add remainder of segment (*16)
        add ax,bx              ; To offset
        adc dl,0               ; And adjust DL if neccesary
        out 4,al               ; Store lo byte of offset
        mov al,ah              ; Hi byte to AL
        out 4,al               ; Store hi byte of offset
        mov al,dl              ; Page no to DL
        out 81h,al             ; Store page no of buffer
        mov ax,511             ; Number of bytes to receive, less 1
        out 5,al               ; Store lo byte of count
        mov al,ah              ; Hi byte to AL
        out 5,al               ; Store hi byte of count
        mov al,2               ; ??
        out 10,al              ; ??

        mov ax,351eh           ; Get address of INT 1Eh, a pointer to
        int 21h                ; a table with some information for the FDC

        mov ah,66h             ; Command 6: Read data
                               ; bit 5: Skip deleted data adress mark
                               ; bit 6: MFM mode
        call Send_FDC_Cmd      ; Send to FDC
        mov ah,0               ; Parameter 1: bit 1,0: drive no. (00=drive 0)
                               ;              bit 2: Head (1=Head 1)
        call Send_FDC_Cmd      ; Send to FDC
        mov ah,0               ; Parameter 2: Track no.
        call Send_FDC_Cmd      ; Send to FDC
        mov ah,0               ; Parameter 3: Head no. (again????)
        call Send_FDC_Cmd      ; Send to FDC
        mov ah,1               ; Parameter 4: Starting sector no.
        call Send_FDC_Cmd      ; Send to FDC
        mov ah,es:[bx+3]       ; Parameter 5: Sector size (get from table)
                               ;  (0 - User spec., 1 - 256, 2 - 512, 3 - 1024)
        call Send_FDC_Cmd      ; Send to FDC
        mov ah,es:[bx+4]       ; Parameter 6: Last sector in track (from table)
                               ;  (Actuelly I think this is the last sector to
                               ;   read, so for 1 sector starting at sec. 1
                               ;   it's 1, but I don't know for sure)
        call Send_FDC_Cmd      ; Send to FDC
        mov ah,es:[bx+5]       ; Parameter 7: Gap length (from table)
        call Send_FDC_Cmd      ; Send to FDC
        mov ah,es:[bx+6]       ; Parameter 8: Data length (if par5 is 0)
        call Send_FDC_Cmd      ; Send to FDC
        call Wait_Int          ; Wait until completed

        mov cx,7               ; Command 6 has 7 status registers
        lea bx,status_buf      ; Read them into Status_Buf
Next:   call Get_FDC_Stat      ; Get one status register
        mov [bx],al            ; Store in buffer
        inc bx                 ; To next position in buffer
        loop Next              ; Do all the 7
        mov dx,3f2h            ; Address of Digital Ouput Register
        mov al,12              ; bit 2: FDC enable, bit 3: DMA/IO enable
                               ; (to turn motor off)
        out dx,al              ; Store to Digital Ouput Register
        ret                    ; Return to caller
Read_Sector endp

Wait_Int proc near             ; Wait for command completed interrupt
        mov ax,40h             ; (IRQ 6), by polling a bit in the BIOS data
        mov es,ax              ; area, at 40h:3eh (bit 7)
                               ; This bit is set by the BIOS IRQ 6 (INT 14)
                               ; handler
Again:  test byte ptr es:[3eh],80h ; Test for the bit
        jz Again               ; Not set? Try again (no timeout check!)
        and byte ptr es:[3eh],7fh  ; And switch off for later use
        ret                    ; Return to caller
Wait_Int endp

Send_FDC_Cmd proc near         ; Send a byte (in AH) to 3F5h
                               ; and check for ready
        mov dx,3f4h            ; Address of main status register
TryAgain:
        in al,dx               ; Get a byte from main status register
        test al,80h            ; Test bit 7: Data reg ready for IO from/to CPU
        jz TryAgain            ; Not set? Try again (no timeout check!)
        inc dx                 ; Set to cmd output address
        mov al,ah              ; Get byte to send
        out dx,al              ; And send to FDC
        ret                    ; Return to caller
Send_FDC_Cmd endp

Get_FDC_Stat proc near
        mov dx,3f4h            ; Address of main status register
TryAg2: in al,dx               ; Get a byte from main status register
        test al,80h            ; Test bit 7: Data reg ready for IO from/to CPU
        jz TryAg2              ; Not set? Try again (no timeout check!)
        inc dx                 ; Set to cmd status address
        in al,dx               ; And get the status byte
        ret                    ; Return to caller
Get_FDC_Stat endp

Wait_Motor proc near           ; Wait a 1/2 sec to let the motor spin up
        mov ax,40h             ; Wait for 9 changes from day-time counter
        mov es,ax              ; In BIOS data area at 40h:6eh
        mov cx,9               ; 18.2 times per sec incremented, 9 -> 1/2 sec
NewTick:mov dx,es:[6ch]        ; Get actual tick count (only lo word)
ChkTick:cmp es:[6ch],dx        ; Compare
        je ChkTick             ; Not changed? Try again
        loop NewTick           ; Wait for next tick
        ret                    ; Return to caller
Wait_Motor endp

_TEXT   ends

_STACK  segment word stack 'STACK'
        db 256 dup(?)
_STACK  ends

        end TestHWR