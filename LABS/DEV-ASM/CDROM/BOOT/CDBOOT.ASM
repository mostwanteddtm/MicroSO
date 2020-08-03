;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
;;                                                                                  ;; 
;; Project          :   smiddyOS (CD-ROM Booter)                                    ;; 
;; Author           :   smiddy                                                      ;; 
;; Website          :                                                               ;; 
;; Date             :   December 27, 2011                                           ;; 
;; Quick Information:   Compact Disc bootloader beta to load bootable software.     ;; 
;; Filename         :   cdboot2.asm                                                 ;; 
;; Assembler Command:   Using FASMW IDE                                             ;; 
;;                                                                                  ;; 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
;;                                                                                  ;; 
;; Useage: Using CDBOOT2.BIN as the boot loader from the created ISO from the       ;; 
;;         CD-ROM creating CDROM.ASM from within FASMW IDE.                         ;; 
;;                                                                                  ;; 
;;         See CDROM.ASM for further details.                                       ;; 
;;                                                                                  ;; 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
;;                                                                                  ;; 
;; v1.00  - Beta release; CD-ROM compatible booter, capable of booting bootable     ;; 
;;          software, in this case SMIDDYOS.EXE. Change the file name to one you    ;; 
;;          wish to load instead. The loader expects to be booted at 0060:0000      ;; 
;;          (600h linear) and the bootable software gets loaded at 0202:0000        ;; 
;;          (2020h linear).                                                         ;; 
;;                                                                                  ;; 
;;          Limitations include that the boot file needs to be in the root          ;; 
;;          directory and the root directory can not be longer than one CD sector   ;; 
;;          (2048 bytes).                                                           ;; 
;;                                                                                  ;; 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 

   ;format binary as "bin"               ; Tell FASM to make an BIN image 

   ORG 0 

DEBUG_MESSAGES:                         ; Comment out to remove debugging messages 

BootSector:                             ; Label in order to determine size of code for 
                                        ; padding at the end. 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
;; Start Boot Procedure                                                             ;; 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 

Begin:                                  ; Begining of instructions 

    CLI                                 ; Turn off intterrupts 
    mov ax,0060h                        ; Boot Segment (no need to copy there) 
    mov ds,ax 
    mov es,ax 
    MOV [CDDriveNumber],DL              ; Save boot drive, right away 
    MOV AX,7000h 
    MOV DS,AX                           ; Segment of saved variables for SmiddyOS 
    MOV BX,530h                         ; Offset of boot drive saved variable 
    MOV [DS:BX],DL                      ; Save the boot drive for SmiddyOS use later 
    MOV AX,60h 
    MOV DS,AX                           ; Reset segment 
    XOR AX,AX                           ; Zero out the stack segment 
    MOV SS,AX 
    MOV SP,5FEh                         ; 0000:05FE 
    MOV SP,AX 
    STI                                 ; Turn interrupts back on 

    MOV SI,WelcomeMessage               ; Tell everyone hello 
    CALL PrintString                    ; Print the welcome message 
    MOV SI,TheEndOfTheLine              ; Go to the next line 
    CALL PrintString 

    MOV AL,[CDDriveNumber]              ; Load drive number in for comparison 
    CMP AL,0                            ; Compare to known BAD drive number for CD/DVD/BD 
    JE Failure                          ; If it is, it failed. 

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
    ;; Get Status (Bootable CD-ROM) 
    ;; 
    ;; Call with: AX = 4B01H 
    ;; DL = Drive number 
    ;; DS:SI = Empty specification packet (needs to be 13h in size) 
    ;; 
    ;; Return: If Function Successful, 
    ;; Carry Flag = Clear 
    ;; 
    ;; If Function Unsuccessful, 
    ;; Carry Flag = Set 
    ;; AX = Status code 
    ;; 
    ;; DS:SI = Specification packet filled 
    ;;       Offset Size Description 
    ;;       00h    db   size of packet in bytes (13h) 
    ;;       01h    db   boot media type 
    ;;                   Bit(s) Description 
    ;;                   3-0    media type. 
    ;;                   0000   no emulation. 
    ;;                   0001   1.2M diskette. 
    ;;                   0010   1.44M diskette. 
    ;;                   0011   2.88M diskette. 
    ;;                   0100   hard disk 
    ;;                   Other reserved 
    ;;                   5-4    reserved (0) 
    ;;                   6      image contains ATAPI driver 
    ;;                   7      image contains SCSI driver(s) 
    ;;       02h    db   drive number 
    ;;                   00h floppy image 
    ;;                   80h bootable hard disk 
    ;;                   81h-FFh nonbootable or no emulation drive 
    ;;       03h    db   CD-ROM controller number 
    ;;       04h    dd   Logical Block Address (LBA) of disk image to emulate 
    ;;       08h    dw   device specification (same as boot media type plus) 
    ;;                   (IDE) bit 0: Drive is slave instead of master 
    ;;                   (SCSI)  bits 7-0: LUN and PUN 
    ;;                   bits 15-8: Bus number 
    ;;       0Ah    dw   segment of 3K buffer for caching CD-ROM reads 
    ;;       0Ch    dw   load segment for initial boot image (if 0000h, load at segment 07C0h; only valid for INT 13h/AH=4Ch) 
    ;;       0Eh    dw   number of 512-byte virtual sectors to load (only valid for INT 13h/AH=4Ch) 
    ;;       10h    db   low byte of cylinder count (for INT 13/AH=08h) 
    ;;       11h    db   sector count, high bits of cylinder count (for INT 13h/AH=08h) 
    ;;       12h    db   head count (for INT 13h/AH=08h) 
    ;; 
    ;; Comments: 
    ;; 
    ;; The Function is used to get the status of the CD/DVD/BD. This function is called 
    ;; first for "no emulation" booting of optical media. If the Function is successful, 
    ;; the carry flag is clear, else carry flag is set and AX register returns status 
    ;; code. 
    ;; 
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 

GetBootedCDStatus: 

    MOV DL,[CDDriveNumber]              ; Prepare to read CD-ROM, load boot drive 
    MOV AH,4Bh                          ; Use function 4Bh 
    MOV AL,1 
    MOV SI,DiskResultsBuffer            ; Results buffer to load 
    INT 13h                             ; Call Check Extensions Present? 

    JC Failure                          ; Need to engage the Failure Procedure 

    MOV AH,255                          ; Load proposed error code (255 is our failure code for drive number miss detected) 
    MOV DL,[DiskResultsBuffer+2]        ; Load resultant drive information 
    CMP [CDDriveNumber],DL              ; Compare to see if they are the same (they should be) 
    JNE Failure                         ; If they are not, Failure 

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
    ;; More information can be gathered here if needed later, not needed at this time. 
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
    ;; Check INT 13h Extensions Present 
    ;; 
    ;; Call with: AH = 41H 
    ;; DL = Drive number (80h - FFh; but we're interested in CDs for this exercise) 
    ;; BX = 55AAh (Signature?) 
    ;; 
    ;; Return: If Function Successful, 
    ;; Carry Flag = Clear 
    ;; BX = AA55h if installed 
    ;; AH = major version of extensions 
    ;;    01h = 1.x 
    ;;    20h = 2.0 / EDD-1.0 
    ;;    21h = 2.1 / EDD-1.1 
    ;;    30h = EDD-3.0 
    ;; AL = internal use 
    ;; CX = API subset support bitmap 
    ;;      1 - Device Access using packet structure (INT 13h AH=42h-44h,47h,48h) 
    ;;      2 - Drive Locking and Ejecting (INT 13h AH=45h,46h,48h,49h,INT 15h AH=52h) 
    ;;      4 - Enhanced Disk Drive Support (INT 13h AH=48h,AH=4Eh) 
    ;; DH = extension version (v2.0+ ??? -- not present in 1.x) 
    ;; 
    ;; If Function Unsuccessful, 
    ;; Carry Flag = Set 
    ;; AH = 01h (invalid function) 
    ;; 
    ;; Comments: 
    ;; 
    ;; The Function is used to see if INT 13h extensions are present (not really 
    ;; needed if you can do the previous function, right?) 
    ;; 
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 

GetINT13hExtenstions: 

    MOV DL,[CDDriveNumber]              ; Prepare to read CD-ROM, load boot drive 
    MOV AH,41h                          ; Use function 41h: Check Extensions Present 
    MOV BX,55AAh                        ; Signature? 
    INT 13h                             ; Call Check Extensions Present? (This makes no sense if you try INT 13h Function 4B01h, but details are 
                                        ; provided upon return if CF isn't set) 

    JC Failure                          ; Nope, get out of here... 

if defined DEBUG_MESSAGES 

    MOV [VersionEnhancedDiskDriveExtensions],AH 
    MOV [InternalUseEnhancedDiskDriveExtensions],AL 
    MOV [InterfaceSupportBitMask],CX 

    MOV AL,[VersionEnhancedDiskDriveExtensions] 
    MOV CL,8 
    CALL ToHex 

    MOV SI,HexBuffer 
    Call PrintString 

    MOV SI,AddTheHAtTheEnd 
    CALL PrintString 

    MOV SI,EnhancedDiskDriveVersionMessage 
    CALL PrintString 

    MOV AX,[InterfaceSupportBitMask] 
    MOV CL,16 
    CALL ToHex 

    MOV SI,HexBuffer 
    CALL PrintString 

    MOV SI,AddTheHAtTheEnd 
    CALL PrintString 

    MOV SI,IsEqualToTheCX 
    CALL PrintString 

    MOV SI,TheEndOfTheLine 
    call PrintString 

end if 

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
    ;; Extended Read Function 
    ;; 
    ;; Call with AH=42h 
    ;; DL = drive number 
    ;; DS:SI = Disk Address Packet (DAP) 
    ;;       Offset Size Description 
    ;;       00h    db   Size of packet (10h or 18h; we're using 10h here, see below) 
    ;;       01h    db   Reserved (0) 
    ;;       02h    dw   Number of sectors to read (max 007Fh for Phoenix EDD) 
    ;;       04h    dd   Initial segment:offset where to load the read in sector(S) 
    ;;       08h    dq   starting absolute sector number (for non-LBA devices, compute as (Cylinder*NumHeads + SelectedHead) * SectorPerTrack + SelectedSector - 1 
    ;;       10h    dq   (EDD-3.0, optional) 64-bit flat address of transfer buffer; used if dd at 04h is FFFFh:FFFFh 
    ;; 
    ;; Return: If Function Successful, 
    ;; Carry Flag = Clear 
    ;; AH = 00h 
    ;; 
    ;; If Function Unsuccessful, 
    ;; Carry Flag = Set 
    ;; AH = Error code 
    ;; 
    ;; Error code: 
    ;;   00h    successful completion 
    ;;   01h    invalid function in AH or invalid parameter 
    ;;   02h    address mark not found 
    ;;   03h    disk write-protected 
    ;;   04h    sector not found/read error 
    ;;   05h    reset failed (hard disk) 
    ;;   05h    data did not verify correctly (TI Professional PC) 
    ;;   06h    disk changed (floppy) 
    ;;   07h    drive parameter activity failed (hard disk) 
    ;;   08h    DMA overrun 
    ;;   09h    data boundary error (attempted DMA across 64K boundary or >80h sectors) 
    ;;   0Ah    bad sector detected (hard disk) 
    ;;   0Bh    bad track detected (hard disk) 
    ;;   0Ch    unsupported track or invalid media 
    ;;   0Dh    invalid number of sectors on format (PS/2 hard disk) 
    ;;   0Eh    control data address mark detected (hard disk) 
    ;;   0Fh    DMA arbitration level out of range (hard disk) 
    ;;   10h    uncorrectable CRC or ECC error on read 
    ;;   11h    data ECC corrected (hard disk) 
    ;;   20h    controller failure 
    ;;   31h    no media in drive (IBM/MS INT 13 extensions) 
    ;;   32h    incorrect drive type stored in CMOS (Compaq) 
    ;;   40h    seek failed 
    ;;   80h    timeout (not ready) 
    ;;   AAh    drive not ready (hard disk) 
    ;;   B0h    volume not locked in drive (INT 13 extensions) 
    ;;   B1h    volume locked in drive (INT 13 extensions) 
    ;;   B2h    volume not removable (INT 13 extensions) 
    ;;   B3h    volume in use (INT 13 extensions) 
    ;;   B4h    lock count exceeded (INT 13 extensions) 
    ;;   B5h    valid eject request failed (INT 13 extensions) 
    ;;   B6h    volume present but read protected (INT 13 extensions) 
    ;;   BBh    undefined error (hard disk) 
    ;;   CCh    write fault (hard disk) 
    ;;   E0h    status register error (hard disk) 
    ;;   FFh    sense operation failed (hard disk) 
    ;; 
    ;; Initial DAP: 
    ;; 
    ;;   db 10h       - Initial Volume Descriptor, which has the important data we need 
    ;;                  to get to the root directory where our OS is stored. 
    ;;   db  0        - Unused, should be zero 
    ;;   dw  1        - Number of sectors to read (initial one should be one for Volume Descriptor) 
    ;;   dd 0202:0000 - Initial segment:offset where to load the read in sector(S) 
    ;;   dq 16        - Starting sector to read in, then we need to get to the root directory 
    ;; 
    ;; Comments: 
    ;; 
    ;; This functions is called three times: Initially to get the Initial 
    ;; Volume Descriptor so we can find the root directory; then it gets used 
    ;; again to read in the root directory, so we can scan for SmiddyOS; finally 
    ;; once we recognize SmiddyOS we load it and jump to it, if all goes as it 
    ;; should "on a good day" as expected. 
    ;; 
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 

    MOV DL,[CDDriveNumber]              ; Set it up again 
    MOV AH,42h                          ; Read from drive function 
    MOV SI,DiskAddressPacket            ; Load SI with address of the Disk Address Packet 
    INT 13h                             ; Call read sector from drive 
    JC Failure                          ; Nope, hosed, get out 

    MOV ES,[DiskAddressPacket.Segment] 
    MOV DI,[DiskAddressPacket.Offset] 

    MOV BX,40                           ; Load BX with Volume Label offset (Check CDROM.ASM or ISO 9660) 

VolumeLabelLoop: 

    MOV CL,[ES:DI+BX]                   ; Grab a letter 
    CMP CL,' '                          ; Is it a space? (Assumes end of string is space, may run out) 
    JE .VolumeLabelDone                 ; Yes, we are done 

    MOV [VolumeLabel+BX-40],CL 
    INC BX 
    JMP VolumeLabelLoop                ; Need to compare BX to length of Volume Label on CD (32?) 

.VolumeLabelDone: 

    MOV byte [VolumeLabel+BX-40],0      ; End the string 

    MOV EAX,[ES:DI+158]                 ; LBA of root directory, where all things start. 
    MOV [DiskAddressPacket.End],EAX     ; Load packet with new address on CD of the root directory 
    MOV DL,[CDDriveNumber]              ; Set it up again 
    MOV AH,42h                          ; Read from drive function 
    MOV SI,DiskAddressPacket            ; Load SI with address of the Disk Address 
                                        ;    Packet 
    INT 13h                             ; Call read sector from drive 

    JC Failure                          ; Nope, hosed, get out 

    CALL PrintDirectory 

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
;; Failure: Looks up error code and displays the error then waits for a key to     ;; 
;;          reboot.                                                                ;; 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 

Failure: 

    mov AL,AH                           ; Put the error into lowest bits 
    mov cl,8                            ; only 8 bits 
    call ToHex                          ; Get what is in the XX to display 

    MOV SI,FailureMessage               ; reboot message 
    CALL PrintString 
    mov si,HexBuffer 
    CALL PrintString 
    MOV SI,AddTheHAtTheEnd 
    CALL PrintString 
    MOV SI,TheEndOfTheLine 
    CALL PrintString 
    mov SI,PressAnyKeyMessage 
    CALL PrintString 
    MOV AH,0                            ; Reboot on error 
    INT 16h                             ; BIOS GetKey 
    INT 19h                             ; BIOS Reboot 

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
;; PrintDirectory: Prints the root directory to the display. 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 

PrintDirectory: 

    MOV ES,[DiskAddressPacket.Segment] 
    MOV DI,[DiskAddressPacket.Offset] 

    MOV SI,DriveDisplayMessage 
    CALL PrintString 

    CMP byte [VolumeLabel],0 
    JE .NoLabel 

    MOV SI,VolumeLabel 
    CALL PrintString 
    JMP .LabelDone 

.NoLabel: 

    MOV SI,HasNoLabel 
    CALL PrintString 

.LabelDone: 

    MOV SI,TheEndOfTheLine 
    CALL PrintString 
    MOV SI,TheEndOfTheLine 
    CALL PrintString 

.GrabDirectoryEntry: 

    MOV AL,[ES:DI]                           ; Length of the current directory entry 
    MOV [DirectoryEntrySize],AL 

    MOV EAX,[ES:DI+2]                        ; Starting sector of directory entry 
    MOV [FileSector],EAX 

    MOV EAX,[ES:DI+10]                       ; Size of directory entry on CD/DVD/BD 
    MOV [FileSize],EAX 

    MOV AL,[ES:DI+32]                        ; File's name length (see El Torito of ISO:9660 or CDROM.ASM) 
    MOV [FileNameLength],AL 

    XOR BX,BX                           ; Initialize BX 
    XOR CX,CX 
    MOV SI,DI 
    ADD SI,33 
    MOV BX,FileNameEntry 
    MOV AL,[FileNameLength] 
    CMP AL,1 
    JE .DotAndDotDotEntries 

.LoopFileNameEntry: 

    MOV AL,[ES:SI] 
    MOV [DS:BX],AL 
    INC BX 
    INC CX 
    INC SI 
    XOR AX,AX 
    MOV AL,[FileNameLength] 
    CMP CX,AX 
    JB .LoopFileNameEntry 

    MOV byte [DS:BX],0 
    JMP .FileNameEntryDisplay 

.DotAndDotDotEntries: 

    MOV AL,[FileEntryNumber] 
    CMP AL,0 
    JA .DoDotDotEntry 
    MOV word [FileNameEntry],'.'                   ; First directory entry 
    MOV byte [FileNameEntry+1],0                   ; End the string with a termination 
    JMP .FileNameEntryDisplay 

.DoDotDotEntry: 

    MOV word [FileNameEntry],'..'                  ; Second directory entry 
    MOV byte [FileNameEntry+2],0                   ; End the string with a termination 

.FileNameEntryDisplay: 

    MOV SI,FileNameEntry 
    CALL PrintString 

    MOV SI,FileNameEntry 
    PUSH DI 
    MOV DI,FileName 
    CALL StringCompare 
    POP DI 
    JC .EndOfTheLine 

    MOV SI,TheEndOfTheLine 
    CALL PrintString 

    MOV EAX,[FileSector] 
    MOV [DiskAddressPacket.End],EAX             ; Save the starting sector into DAP 
    MOV EAX,[FileSize] 
    XOR EDX,EDX 
    MOV EBX,2048 
    DIV EBX 
    INC EAX 
    MOV [DiskAddressPacket.SectorsToRead],AX    ; Save number of sectors to read 

if defined DEBUG_MESSAGES 

    MOV CL,16 
    CALL ToHex 

    MOV SI,HexBuffer 
    Call PrintString 

    MOV SI,AddTheHAtTheEnd 
    CALL PrintString 

    MOV SI,TheEndOfTheLine 
    CALL PrintString 

    MOV EAX,[FileSector] 
    MOV CL,32 
    CALL ToHex 

    MOV SI,HexBuffer 
    CALL PrintString 

    MOV SI,AddTheHAtTheEnd 
    CALL PrintString 

    MOV SI,TheEndOfTheLine 
    call PrintString 

end if 

    MOV DL,[CDDriveNumber]                      ; Set it up again 
    MOV AH,42h                                  ; Read from drive function 
    MOV SI,DiskAddressPacket                    ; Load SI with address of the Disk Address Packet 
    INT 13h                                     ; Call read sector from drive 
    JC Failure                                  ; Nope, hosed, get out 

    MOV DL,[CDDriveNumber]                      ; Drive into DL for booting 

    PUSH WORD 0202h                             ; New Location 
    PUSH WORD 0000h                             ; CS:IP = 0202:0000 

    RETF                                        ; Will pop our new CS:IP 

.EndOfTheLine: 

    MOV SI,TheEndOfTheLine 
    CALL PrintString 


    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
    XOR CX,CX                                   ; Prepare CX to do math for DI 
    MOV CL,[DirectoryEntrySize]                 ; Get the size of the directory entry 
    ADD DI,CX                                   ; Add that size to the DI to get to the next record 
    CMP byte [ES:DI],0                          ; Is the next entry = 0? 
    JE .End                                     ; If so, we're at the end of the directory, move on 

    XOR CX,CX 
    MOV BX,FileNameEntry 

.ClearFileNameEntry: 

    MOV byte [DS:BX],0                           ; Erase the begining of the 
    INC BX 
    INC CX 
    CMP CX,254 
    JB .ClearFileNameEntry 
    MOV byte [DS:BX],0 
    INC byte [FileEntryNumber] 
    JMP .GrabDirectoryEntry                     ; If not, we have more processing to do 

.End: 

    RET 

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
;; PrintString                                                                      ;; 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 

PrintString: 

    PUSHA                               ; Save Registers 

.Loop: 

    LODSB                               ; Load SI into AL, increment SI one byte 
    OR AL,AL                            ; AL = 0? 
    JZ .Done                            ; If yes, get out 
    MOV AH,0Eh 
    MOV BH,0 
    MOV BL,7                            ; character attribute 
    INT 10h                             ; Display character in AL 
    JMP .Loop                           ; Do it again 

.Done: 

    POPA                                ; Replace registers 

    RET 

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
;; ToHex 
;; Loads HexBuffer with ASCII corresponding to 8, 16, or 32 bit interger in 
;;    hex. 
;; Requires interger in AL, AX, or EAX depending on bit size 
;; Requires the number of bits in the CL 
;; Returns a full buffer or an empty buffer on error 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 

ToHex: 

        pusha 

    MOV BX,0x0000               ; Load BX with pointer offset 
    MOV [TheEAX],EAX            ; Save the EAX 
    MOV [TheCL],CL              ; Save the CL  
    CMP CL,0x08                 ; Check for 8 bits 
    JNE .Check16 
    JMP .Loop1                  ; Start loading the buffer 

.Check16: 

    CMP CL,0x10                 ; Check for 16 bits 
    JNE .Check32 
    JMP .Loop1                  ; Start loading the buffer 

.Check32: 

    CMP CL,0x20                 ; Check for 32 bits 
    JNE .ErrorBits 

.Loop1: 

    MOV EAX,[TheEAX]            ; Reload EAX with the converter 
    SUB CL,0x04                 ; Lower bit count by 4 bits 
    SHR EAX,CL 

    AND AL,0x0F 
    ADD AL,'0' 
    CMP AL,'9' 
    JBE .LoadBuff1 
    ADD AL,'A'-'0'-10           ; Convert to "A" to "F" 

    JMP .LoadBuff1 

.Loop2: 
    MOV EAX,[TheEAX]            ; Reload EAX again 
    SUB CL,4                    ; Lower bit count by 8 bits 
    SHR EAX,CL 
    AND AL,0x0F 
    ADD AL,'0' 
    CMP AL,'9' 
    JBE .LoadBuff2 
    ADD AL,'A'-'0'-10           ; Convert A,B,C,D,E,F 

    JMP .LoadBuff2 

.LoadBuff1: 

    MOV [HexBuffer+BX],AL       ; Load buffer with AL 
    INC BX                      ; Increment buffer pointer 
    JMP .Loop2                  ; Do next byte 

.LoadBuff2: 

    MOV [HexBuffer+BX],AL       ; Load buffer with AL 
    INC BX                      ; Increment buffer pointer 
    CMP CL,0                    ; Check if we're done 
    JNE .Loop1                  ; Do next Byte  

.ErrorBits: 

    MOV AL,0 
    MOV [HexBuffer+BX],AL       ; End the string with a zero 
     
    popa 

    RET 

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
;; StringCompare                                                                   ;; 
;;                                                                                 ;; 
;;    Compares the equality of two strings, loaded in ESI and EDI.                 ;; 
;;                                                                                 ;; 
;;    Sets the CF if not the same.                                                 ;; 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 

StringCompare: 

    PUSH SI            ; Save ESI to be restored at the end 
    PUSH DI            ; Save EDI to be restored at the end 

.Loop: 

    MOV AL,[SI]        ; Grab byte from ESI 
    MOV BL,[DI]        ; Grab byte from EDI 
    CMP AL,BL           ; Compare if they are equal 
    JNE .NotEqual       ; They aren't equal 

    CMP AL,0            ; Both bytes are null 
    JE .Done 

    INC DI             ; Increment EDI 
    INC SI             ; Increment ESI 
    JMP .Loop           ; Start looping 

.NotEqual: 

    STC                 ; Set the carry flag to indicate failure 
    JMP .End 

.Done: 

    CLC                 ; Clear the carry flag to indicate success 

.End: 

    POP DI             ; Restore EDI before returning to caller 
    POP SI             ; Restore ESI before returning to caller 

    RET 

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
;; StringLength                                                                    ;; 
;;                                                                                 ;; 
;;    Checks the length of the string in the ESI and returns it in the EAX.        ;; 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 

StringLength: 

    XOR EAX,EAX 

.Loop: 

    CMP byte [ESI+EAX],0 
    JE .End 

    INC EAX 
    JMP .Loop 

.End: 

    RET 

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
;; Program Data                                                                     ;; 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 

DirectoryEntrySize:  db 0 
FileSector:          dd 0 
FileSize:            dd 0 
FileNameLength:      db 0 
FileNameEntry:       TIMES 255 db ' ' 
FileEntryNumber:     db 0 
DriveDisplayMessage: db 'Volume in drive: ',0  ; Get label from Primary Volume Descriptor (loaded first) 
HasNoLabel:          db 'no label',0 
FileNamePointer:     dw 0 

DataSector:               DW 0 
CDDriveNumber:            db 0 
RootDirectorySector       dd 0 

absoluteSector:           DB 0 
absoluteHead:             DB 0 
absoluteTrack:            DB 0 

BootDotNumber:            DB '1' 

Cluster:                  DW 0 
FileName:                 DB 'SMIDDYOS.EXE',0                ; FAT Filename, 8.3, or 11 characters 

VersionEnhancedDiskDriveExtensions:     db 0 
InternalUseEnhancedDiskDriveExtensions: db 0 
InterfaceSupportBitMask:                dw 0 

EnhancedDiskDriveVersionMessage: db ' - Enhanced Disk Drive Extensions Version Number.',13,10,0 
DirectoryEntrySizeMessage:       db ' - Directory entry size.',13,10,0 
DiskResultsBufferMessage: db 'Disk Buffer on in here...',13,10,0 
IsEqualToTheCX            db ' = CX contents from INT 13h Function 41h.',13,10,0 
IsEqualToTheEAX           db ' = EAX contents is the sector of the root directory contents.',13,10,0 
WelcomeMessage:           DB 'smiddy OS CD boot v1.00',225,13,10,0   ; Version of CD-Boot 
FailureMessage:           db 'Failure: ',0 
DriveNumberReported:      db 'Drive number reported: ',0 
PressAnyKeyMessage:       db 'Press any key to reboot...',13,10,0 
AddTheHAtTheEnd:          db 'h',0 
TheEndOfTheLine:          db 13,10,0                        ; Used to print the end of the line string 
SizeOfPacketInBytes:      db 'The size of packet in bytes: ',0 
BootMediaType:            db 'The boot media type: ',0 
DriveNumberFromPacket:    db 'Drive number from packet: ',0 
VolumeLabel:              TIMES 33 db 0 ; Where the volume label is stored 

DiskAddressPacket:        db 16,0 
.SectorsToRead:           dw 1                                ; Number of sectors to read (read size of OS) 
.Offset:                  dw 0                                ; Offset :0000 
.Segment:                 dw 0202h                            ; Segment 0202: currerntly, will change to 0202:0000 for loading SmiddyOS 
.End:                     dq 16                               ; Sector 16 or 10h on CD-ROM 

DiskResultsBuffer: times 30 db 0                              ; Return buffer from int 13h ah=48h 
HexBuffer:                  DB 0,0,0,0,0,0,0,0,0              ; Buffer for hex text string 
TheEAX:                     dd 0                              ; Saves EAX 
TheCL:                      db 0 


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
;; 512 Byte Code Boot Signature                                                     ;; 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 

TIMES 2046-($-BootSector)   DB 0 
                            DW 0AA55h           ; Bootloading sector signature (for CD/DVD/BD) I am not sure this is needed for optical media booting.