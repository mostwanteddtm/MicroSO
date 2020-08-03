ORG 0H
START:

CLI                  ; Disable maskable Interrupts
XOR	AX,AX           ; Zero out both the Accumulator and
MOV	SS,AX           ;    the Stack Segment register.
MOV	SP, 7C00H	        ; Set Stack Pointer to 0000:7C00
MOV	SI,SP           ; Source Index: Copy from here...
PUSH	AX
POP	ES              ; Zero-out Extra Segment
PUSH	AX
POP	DS              ; Zero-out  Data Segment
STI                  ; Enable Interrupts again

CLD                  ; Clear Direction Flag (df=0).
MOV	DI, 0600H         ; Destination Index: New copy of
                     ;  code will begin at 0000:0600
MOV	CX ,0100H         ; Copy 256 Words (512 bytes)
                     ;    (100 hex = 256 decimal)
REP                   ; REPeat the following MOVSW
                     ; instruction for 'CX' times(*).
MOVSW                ;  Copy two bytes at a time.

JMP	0000H:061DH       ; Jump to new copy of code...


; Since the preceding routine copies itself and all of the following
; code to 0000:0600 and then jumps to 0000:061D before continuing to
; run, the following addresses have been changed to reflect the
; code's actual location in memory at the time of execution.


; This next bit of code tries to find an entry in the partition table
; that indicates at least one of them is ACTIVE (i.e., bootable). The
; first byte of a partition entry is used as the indicator: If it's
; an 80h, yes; if 00 then no it's not bootable. If none of the four
; possible partitions is active, then an error message is displayed.

MOV	SI, 07BEH           ; Location of first entry
                       ; in the partition table
                       ; (see Sample Table below).
MOV	BL, 04             ; Maximum of 4 Table Entries.
LOOP1: CMP	BYTE PTR [SI],80H  ; Is this one bootable (80h)?
JE	LABEL1              ; Yes, so jump to next test!
CMP	BYTE PTR [SI],00  ;  No; is it a 00? If not, it's
JNE	LABEL2              ;   an Invalid partition table.
ADD	SI,+10H            ; Check next entry for 80h ...
                       ; (10h = 16 bytes per entry)
DEC	BL                ; Subtract 1 from Entry Counter.
JNZ	LOOP1              ; Have all entries been tested?
INT  18H                ; Yes, and NONE of them were
                                          ;    bootable, so start...
                                          ; ROM-BASIC (only available on
                                          ; some IBM machines!) Many BIOS
                                          ; simply display "PRESS A
                                          ; KEY TO REBOOT" when an
                                          ; Interrupt 18h is executed.


; We found an Active partition, so all the other entries are checked
; for being non-bootable (first byte = 0x00), or there's an error!
; (Only one entry in the Partition Table can be marked as 'Active.')

; Before doing so, we load the Head, Drive, Cylinder and Sector data
; into DX and CX for use by the DOS Interrupt 13 commands later.

LABEL1:         MOV	DX,[SI]           ; Drive  -> DL /   Head -> DH
                                ; For the standard MBR code,
; DL will always be 80h; which means ONLY the first drive can
; be bootable! [ This part of the code is often changed by MBR
; replacements to boot from another (second, etc.) drive! ]

MOV	CX,[SI+02]        ; Sector -> CL / Cylinder -> CH

MOV	BP,SI             ; Save offset of Active Entry
                       ;  pass to Volume Boot Sector.
LABEL7: ADD	SI,+10H            ; Do next Table Entry
DEC	BL                ; Is this the last entry?
JZ	LABEL3              ; All Entries look OK, so...
                       ; -> Jump to Boot-routine!
CMP	BYTE PTR [SI],00  ; Non-bootable entry (00h)?
JE	LABEL7              ; Yes, so check next entry.


; If there was an error, then this next routine displays the message that
; SI points to.  After printing the ASCII-Z string (null terminated), the
; program 'locks up' by going into an infinite loop (at 065B):

LABEL2: MOV	SI, 068BH       ; -> "Invalid partition table"

LABEL6: LODSB              ; Load byte at [SI] into AL ...
                   ;   and increment the SI value.
CMP	AL,00         ; Is it a zero-byte yet ?
JE	LABEL8          ; If yes, were done.  If not ...
PUSH	SI            ;  Store string pointer on stack.
MOV	BX,0007       ; Use Function 0E (Write Text) of
MOV	AH,0EH         ;  DOS Interrupt 10 to send the
INT	10H            ;  character in AL to the screen.
POP	SI
JMP	064BH

LABEL8: JMP  065BH          ; Infinite Loop.  You must
                                      ;    power-down or Reboot!


; Now we can load the first sector of the Active Partition (on most drives,
; this would be Absolute Sector 63 for the first or only partition of your
; Hard Drive. Absolute Sectors 2 thru 62 are normally empty, unless you've
; installed a large MBR replacement, disk translation software for a very
; large HD or some kind of multi-OS or security/encryption boot code).
;
; The first two words of the partition entry are the drive/head
; and the sector/cylinder numbers of the first partition sector.
; This data is in the format required by the INT 13 call below.

LABEL3: MOV	DI,0005       ; Retry 5 times (if necessary)...
LABEL4: MOV	BX,7C00H       ; Load OS Boot Sector to 0000:7C00
MOV	AX,0201H       ; Function 02h. Read 1 sector.
PUSH	DI
INT  13            ;   Note: This old INT 13 Read
                   ; is limited to 1024 cylinders.
POP	DI
JNC	LABEL5          ; Carry Flag set? If no, jump!
XOR	AX,AX         ; Yes, so we had an error! Must
INT  13H            ; ...reset drive (Function 00h)
DEC	DI            ; Decrement counter (if > 0)
JNZ	LABEL4          ;   and try again...

MOV	SI,06A3H       ; Or, declare: "Error loading
JMP	064BH          ; operating system" and hang!

; The section of code above is often changed by MBR replacements that will
; tell you if it ever takes more than ONCE to try loading the OS Boot code!
; Surely you'd want to know this wouldn't you?!
;    This old code was obviously made in the days when hard drives, memory
; chips and the boot process itself may have been quite unreliable.


; Once a boot sector for the Active Partition has been loaded into memory,
; it must be checked to see if it is valid. This is accomplished by simply
; checking the last word of the sector; it must be the hex number 0xAA55.

LABEL5: MOV	SI,06C2H         ; -> "Missing operating system"
                     ; Set up SI, in case we have an
                     ; error in the Boot Sector read.
MOV	DI,7DFEH         ; Point to the last Word of Boot
                     ; Sector. It should be AA55 Hex.

CMP	WORD PTR [DI], 0AA55H ; Is it? ('Signature' Check.)
JNE	LABEL6               ; If not, display Error Message
                        ;         and 'lock-up' system.

MOV	SI,BP	        ;   SI=BP ->  Both are equal to...
                     ; offset of Active Partition Entry
                     ; which is used by OS Boot code.
JMP	0000H:7C00H       ;   Jump to OS Boot Sector code
                                        ;       and continue booting-up! 
                                        
DB 'Invalid partition table', 0
DB 'Error loading operating system', 0
DB 'Missing operating system', 0  

DB 1EDH - $ DUP(0)
DB 00, 80H, 00, 02, 00, 01, 0FH, 3FH, 13H, 01, 00, 00, 00, 0BFH, 4EH, 00, 00, 55H, 0AAH