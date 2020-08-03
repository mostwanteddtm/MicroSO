; This file is the source for a boot loader (boot sector) that
; moves itself up to the top of conventional memory, locates
; and reads a file from the boot diskette, loads the contents
; of the file into memory starting at absolute address 500h,
; and then does a far jump to that address. The code includes
; the components necessary for the system (DOS/Windows) to
; recognize it as a valid boot sector for a 3.5 inch 1.44MB
; diskette, and this in turn allows the system to access the
; diskette file system normally.
;
; Normal structure of a 3.5 inch 1.44MB diskette:
;
;   Boot sector (512 bytes:c=0,h=0,s=1)
;   FATs (2*9*512 bytes:c=0,h=0,s=2 to c=0,h=1,s=1) 
;   Root directory (224*32 bytes:c=0,h=1,s=2 to c=0,h=1,s=15)
;   File and directory space (starts at c=0,h=1,s=16) 
; 
; Diskettes use a 12-bit FAT. Because the first two FAT entries
; (000 and 001) are reserved, the entry that corresponds to
; cluster 0 starts at the fourth byte. The remaining FAT
; entries should be interpreted is as follows:
;
;   000h            = free cluster
;   001h            = unused code
;   FF0-FF6h        = reserved
;   FF7h            = bad cluster
;   FF8-FFFh        = last cluster of file
;   any other value = link to next cluster in file
;
; For example, assuming the file occupies three clusters and
; starts at the third entry (002):
;
; reserved [003]    [FFF]
; |      | ||  |    ||  |
; F0 FF FF 03 40 00 FF 6F
;             |  ||
;             [004]
;
; Although somewhat difficult to follow because each entry
; is 1.5 bytes, the third entry (002) points to the fourth
; (003), the fourth (003) to the fifth (004), and the fifth
; (004) contains FFFh indicating that the associated cluster
; is the last cluster of the file.
;---------------------------------------------------------------

; Declare a structure for a boot sector header that includes
; all but the 3-byte bsJump field of the BOOTSECTOR structure
; from the Microsoft MS-DOS Programmers Reference (versions
; 5 and 6). The initializers for the essential fields were
; taken from a 3.5 inch 1.44MB diskette formatted under
; Windows 98 SE, but they should be valid for any of the
; later versions of MS-DOS and AFAIK Windows 9x/NT/2000/XP.
;
; Per the MS-DOS Programmers Reference, the structure must
; appear at the beginning of the first sector on the disk.
; The 3-byte bsJump field was left out of the header
; structure so it could be coded separately.
;
BSHEADER struct  
  bsOemName            db "XXXXXXXX"      ; must be 8 bytes
  bsBytesPerSector     dw 512             ; start of BPB
  bsSectorsPerCluster  db 1
  bsReservedSectors    dw 1               ; boot sector only
  bsFats               db 2
  bsRootDirEntries     dw 224
  bsSectors            dw 2880
  bsMedia              db 0f0h
  bsFatSectors         dw 9
  bsSectorsPerTrack    dw 18
  bsHeads              dw 2
  bsHiddenSectors      dd 0
  bsHugeSectors        dd 0               ; end of BPB
  bsDriveNumber        db 0
  bsReserved           db 0
  bsBootSignature      db 29h
  bsVolumeId           dd 12345678h  
  bsVolumeLabel        db 'JUST A TEST'   ; must be 11 bytes
  bsFileSystemType     db 'FAT12   '      ; must be 8 bytes
BSHEADER ENDS

; This structure, included here to serve only as a template,
; is from the MS-DOS Programmers Reference.
;
; Directory entries are 32 bytes each.
;
DIRENTRY STRUCT
  deName          db 8 dup(?)
  deExtension     db 3 dup(?)
  deAttribute     db ?
  deReserved      db 10 dup(?)
  deTime          dw ?
  deDate          dw ?
  deStartCluster  dw ?
  deFileSize      dd ?
DIRENTRY ENDS

.386

; Specify USE16 to force address and operand size to 16 bits.
;
_TEXT SEGMENT USE16

    ; For MASM 6+ ASSUME CS in not necessary.
    ;
    ASSUME ds:_TEXT,es:_TEXT,ss:_TEXT

    ; The BIOS will load the boot sector at address 0000:7C00.
    ;
    ORG   7C00h

  entry:

    ; Use 'NEAR PTR' to force MASM to encode a 3-byte jump.
    ;
    jmp   NEAR PTR init

    ; Define the header.
    ;
    bsh BSHEADER <>

    ; Define the data.
    ;
    dest        dw OFFSET entry2, 97dfh
    filename    db 'STARTUP BIN'
                db ' not found, system halted', 13, 10, 0
    readerror   db 'Error reading diskette', 13, 10, 0
    ok          db 'ok', 13, 10, 0  

  init:

    ; Copy the entire boot sector to address 97DFh:7C00h
    ; (absolute address 9F9F0h) near the top of conventional
    ; memory, avoiding the top 1024KB just in case the BIOS
    ; is using it.
    ;
    xor   ax, ax
    mov   ds, ax
    mov   si, 7c00h
    mov   di, si
    mov   es, dest+2
    mov   cx, 512
    cld
    rep   movsb

    ; Do a far jump to the copy of the boot sector, bypassing
    ; the instructions that precede entry2.
    ;
    jmp   DWORD PTR dest

  entry2:

    ; Set DS, ES, and SS to the new segment address.
    ;
    push  cs
    pop   ds
    push  cs
    pop   es
    push  cs
    pop   ss

    ; This initial SP value will cause the stack to use
    ; memory immediately below the boot sector code.
    ;
    mov   sp, 7C00h
    
    ; We need 224*32 = 7,168 bytes of memory to store the
    ; root directory. Allowing a generous 512 bytes for
    ; the stack, we can use offset address 5E00h for the
    ; base of the storage buffer.
    ;
    BUFFER_BASE EQU 5E00h
    
    ; Load the root directory into the storage buffer.
    ;
    mov   al, 14          ; number of sectors
    mov   ch, 0           ; cylinder number
    mov   cl, 2           ; starting sector number
    mov   dh, 1           ; head number
    call  readdisk
    jnc   @F
    mov   si, OFFSET readerror
    call  print
    jmp   $               ; dynamic halt    
  @@:    

    ; Scan the directory for the target file.
    ;
    mov   bx, BUFFER_BASE
    mov   cx, 224

  dirloop:

    push  cx
    mov   cx, 11
    mov   di, bx
    mov   si, OFFSET filename
    repz  cmpsb
    pop   cx
    jz    match
    add   bx, 32
    loop  dirloop

    ; Not found, display and halt.
    ;
    mov   si, OFFSET filename
    call  print
    jmp   $

  match:
    mov   si, OFFSET ok
    call  print
    jmp   $  

    ;mov   ax,[bx].deStartCluster
    ;ASSUME bx:NOTHING

;---------------------------------------------------------------
; This code uses the BIOS Write Teletype function to display
; an ASCIIZ string.
;
; Parameters:
;   ds:si = address of string
; Uses:
;   ax bx si
; Returns:
;   nothing  
;---------------------------------------------------------------
;
  print:
    mov   ah, 0Eh
    xor   bx, bx
  @@:
    lodsb
    or    al, al
    jz    @F
    int   10h
    jmp   @B
  @@:
    ret
    
;---------------------------------------------------------------
; This code uses the BIOS Read Disk Sectors function to read
; sectors from the first diskette drive into memory. The drive
; number and destination address (ES:BUFFER_BASE) are hard
; coded, and the read cannot span tracks.
;
; Parameters:
;   al    = number of sectors to read (cannot span tracks)
;   ch    = cylinder number (0-79)
;   cl    = starting sector number (1-18)
;   dh    = head number (0-1)
; Uses:
;   ax bx cx dx si
; Returns:
;   CF set on error
;---------------------------------------------------------------
;
  readdisk:
    mov   si, 4           ; maximum of 4 tries
    xor   dl, dl          ; drive = 0
    mov   bx, BUFFER_BASE
  @@:
    mov   ah, 2           ; read disk sectors
    int   13h
    jnc   @F              ; finished if no error
    xor   ah, ah          ; reset diskette drive and controller
    int   13h
    jc    @F              ; finished if error
    dec   si              ; dec does not affect carry flag
    jnz   @B
  @@:
    ret

comment ^
	AH = 02h
	AL = number of sectors to read (must be nonzero)
	CH = low eight bits of cylinder number
	CL = sector number 1-63 (bits 0-5)
	     high two bits of cylinder (bits 6-7, hard disk only)
	DH = head number
	DL = drive number (bit 7 set for hard disk)
	ES:BX -> data buffer
  
 	AH = 00h
	DL = drive (if bit 7 is set both hard disks and floppy disks reset)
  Return: AH = status (see #00234)
	CF clear if successful (returned AH=00h)
	CF set on error
^
;---------------------------------------------------------------
; This code is from the MS-DOS Encyclopedia, Ray Duncan (ed.),
; Microsoft Press, 1988.
;
; Obtains the next link number from a 12-bit FAT.
;
; Parameters:
;   ax    = current entry (cluster) number
;   ds:bx = address of FAT (must be contiguous)
; Uses:
;   bx cx
; Returns:
;   ax    = next link number
;---------------------------------------------------------------
;
  next12:
    add   bx,ax    ; ds:bx = partial index
    shr   ax,1     ; ax = offset/2
                   ; carry = shift needed
    pushf          ; save carry
    add   bx,ax    ; ds:bx = next cluster number index
    mov   ax,[bx]  ; ax = next cluster number
    popf           ; carry = shift needed
    jc    shift    ; skip if using top 12 bits
    and   ax,0fffh ; ax = lower 12 bits
    ret
  shift:
    mov   cx,4     ; cx = shift count
    shr   ax,cl    ; ax = top 12 bits in lower 12 bits
    ret
;---------------------------------------------------------------

    ; MAKEIT.BAT generates a listing file that can be used to
    ; determine exactly what MASM assembled, and how much of
    ; the 512 bytes allocated for a boot sector has been filled
    ; with code and data. For this source, there are 365 free
    ; bytes between the above RET instruction and the signature.
    ;
    org   7C00h + 510
    db    55h,0AAh

_TEXT ENDS

end entry