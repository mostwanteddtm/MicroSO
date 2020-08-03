[BITS 16]	     ; 16 bit code generation
[ORG 0x7C00]	 ; ORGin location is 7C00

JMP short main   ; Jump past disk description section
NOP              ; Pad out before disk description

; ------------------------------------------------------------------
; Disk description table, to make it a valid floppy
; Note: some of these values are hard-coded in the source!
; Values are those used by IBM for 1.44 MB, 3.5" diskette

OEMLabel            db "BERL OS"    ; Disk label - 8 chars
BytesPerSector      dw 512          ; Bytes per sector
SectorsPerCluster   db 1            ; Sectors per cluster
ReservedForBoot     dw 1            ; Reserved sectors for boot record
NumberOfFats        db 2            ; Number of copies of the FAT
RootDirEntries      dw 224          ; Number of entries in root dir
LogicalSectors      dw 2880         ; Number of logical sectors
MediumByte          db 0F0h         ; Medium descriptor byte
SectorsPerFat       dw 9            ; Sectors per FAT
SectorsPerTrack     dw 18           ; Sectors per track (36/cylinder)
Sides               dw 2            ; Number of sides/heads
HiddenSectors       dd 0            ; Number of hidden sectors
LargeSectors        dd 0            ; Number of LBA sectors
DriveNo             dw 0            ; Drive No: 0
Signature           db 41           ; Drive signature: 41 for floppy
VolumeID            dd 00000000h    ; Volume ID: any number
VolumeLabel         db "BERL OS"    ; Volume Label: any 11 chars
FileSystem          db "FAT12"      ; File system type: don't change!

; End of the disk description table
; ------------------------------------------------------------------

main:
MOV BX, 0                           ; Disable blinking.
MOV BH, 00h
MOV BL, 07h                         ; Color settings
MOV AL, 1
MOV BH, 0
MOV BL, 02h
MOV CX, osmsgend - os_msg           ; Calculate message size. 
MOV DL, 30
MOV DH, 0
PUSH CS
POP ES
MOV BP, os_msg
MOV AH, 13h
INT 10h
JMP wel

wel:
MOV BH, 00h
MOV BL, 07h
MOV AL, 1
MOV BH, 0
MOV BL, 059 
MOV CX, welcome_end - welcome       ; Calculate message size. 
MOV DL, 32
MOV DH, 2
PUSH CS
POP ES
MOV BP, welcome
MOV AH, 13h
INT 10h
JMP osmsgend
                         
welcome DB "Welcome !"
welcome_end:
                         
os_msg DB "BerlOS v0.0.1"
osmsgend:
JMP $

; Boot things
TIMES 510-($-$$) DB 0	            ; Fill the rest of the sector with zeros
DW 0xAA55		                    ; Boot signature