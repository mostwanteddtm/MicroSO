;*********************************************
;	Boot1.asm
;		- A Simple Bootloader
;
;	Operating Systems Development Series
;*********************************************

org	0						        ; we will set regisers later

start:	jmp	main					; jump to start of bootloader

;*********************************************
;	BIOS Parameter Block
;*********************************************

; BPB Begins 3 bytes from start. We do a far jump, which is 3 bytes in size.
; If you use a short jump, add a "nop" after it to the 3rd byte.

bpbOEM			        db "My OS   "			; Boot sector name (8bytes)
bpbBytesPerSector     	DW 512                  ; Sector size (must be 512)
bpbSectorsPerCluster 	DB 1                    ; Cluster size (must be 1)
bpbReservedSectors   	DW 1                    ; Where FAT begins (usually 1)
bpbNumberOfFATs 	    DB 2                    ; Number of FATs (must be 2)
bpbRootEntries   	    DW 224                  ; Root directory size (usually 224 entries)
bpbTotalSectors 	    DW 2880                 ; Drive size (must be 2880 sectors)
bpbMedia 		        DB 0xf8                 ; Media type(must be 0xf8)
bpbSectorsPerFAT 	    DW 9                    ; Length of FAT area(must be 9 sectors)
bpbSectorsPerTrack   	DW 18                   ; Sectors per track(must be 18)
bpbHeadsPerCylinder 	DW 2                    ; Number of heads (must be 2)
bpbHiddenSectors 	    DD 0                    ; Must be 0 since there is no partition
bpbTotalSectorsBig      DD 0                    ; Drive size again
bsDriveNumber 	        DB 0
bsUnused 		        DB 0
bsExtBootSignature   	DB 0x29                 ; Not sure
bsSerialNumber	        DD 0xa0a1a2a3           ; Probably volume serial number
bsVolumeLabel 	        DB "MOS FLOPPY "        ; Name of the disc (11 bytes)
bsFileSystem 	        DB "FAT12   "           ; Name of the format (8 bytes)

;************************************************;
;	Prints a string
;	DS=>SI: 0 terminated string
;************************************************;
Print:
			lodsb				; load next byte from string from SI to AL
			or	al, al			; Does AL=0?
			jz	PrintDone		; Yep, null terminator found-bail out
			mov	ah, 0eh			; Nope-Print the character
			int	10h
			jmp	Print			; Repeat until null terminator found
	PrintDone:
			ret				    ; we are done, so return

;************************************************;
; Reads a series of sectors
; CX=>Number of sectors to read
; AX=>Starting sector
; ES:BX=>Buffer to read to
;************************************************;

ReadSectors:
     .MAIN:
          mov     di, 0x0005                            ; five retries for error
     .SECTORLOOP:
          push    ax
          push    bx
          push    cx
          call    LBACHS                                ; convert starting sector to CHS
          mov     ah, 0x02                              ; BIOS read sector
          mov     al, 0x01                              ; read one sector
          mov     ch, [absoluteTrack]                   ; track
          mov     cl, [absoluteSector]                  ; sector
          mov     dh, [absoluteHead]                    ; head
          mov     dl, [bsDriveNumber]                   ; drive
          int     0x13                                  ; invoke BIOS
          jnc .SUCCESS                                  ; test for read error
          xor     ax, ax                                ; BIOS reset disk
          int     0x13                                  ; invoke BIOS
          dec     di                                    ; decrement error counter
          pop     cx
          pop     bx
          pop     ax
          jnz .SECTORLOOP                               ; attempt to read again
          int     0x18
     .SUCCESS:
          ;mov     si, offset msgProgress
          ;call    Print
          pop     cx
          pop     bx
          pop     ax
          add     bx, [bpbBytesPerSector]               ; queue next buffer
          inc     ax                                    ; queue next sector
          loop .MAIN                                    ; read next sector
          ret

;************************************************;
; Convert CHS to LBA
; LBA = (cluster - 2) * sectors per cluster
;************************************************;

ClusterLBA:
          sub     ax, 0x0002                            ; zero base cluster number
          xor     cx, cx
          mov     cl, [bpbSectorsPerCluster]            ; convert byte to word
          mul     cx
          add     ax, [datasector]                      ; base data sector
          ret
     
;************************************************;
; Convert LBA to CHS
; AX=>LBA Address to convert
;
; absolute sector = (logical sector / sectors per track) + 1
; absolute head   = (logical sector / sectors per track) MOD number of heads
; absolute track  = logical sector / (sectors per track * number of heads)
;
;************************************************;

LBACHS:
          xor     dx, dx                                ; prepare dx:ax for operation
          div     [bpbSectorsPerTrack]                  ; calculate
          inc     dl                                    ; adjust for sector 0
          mov     [absoluteSector], dl
          xor     dx, dx                                ; prepare dx:ax for operation
          div     [bpbHeadsPerCylinder]                 ; calculate
          mov     [absoluteHead], dl
          mov     [absoluteTrack], al
          ret

;*********************************************
;	Bootloader Entry Point
;*********************************************

main:

     ;----------------------------------------------------
     ; code located at 0000:7C00, adjust segment registers
     ;----------------------------------------------------
     
          cli						        ; disable interrupts
          mov     ax, 0x07C0				; setup registers to point to our segment
          mov     ds, ax                    ; para rodar no emulador, e so comentar (1)   
          mov     es, ax                    ; essas duas linhas                     (2)

     ;----------------------------------------------------
     ; create stack
     ;----------------------------------------------------
     
          mov     ax, 0x0000				; set the stack
          mov     ss, ax
          mov     sp, 0xFFFF
          sti						        ; restore interrupts

     ;----------------------------------------------------
     ; Display loading message
     ;----------------------------------------------------
     
          mov     si, offset msgLoading
          call    Print
          
     ;----------------------------------------------------
     ; Load root directory table
     ;----------------------------------------------------

     LOAD_ROOT:
     
     ; compute size of root directory and store in "cx"
     
          xor     cx, cx
          xor     dx, dx
          mov     ax, 0x0020                            ; 32 byte directory entry
          mul     [bpbRootEntries]                      ; total size of directory
          div     [bpbBytesPerSector]                   ; sectors used by directory
          xchg    ax, cx
          
     ; compute location of root directory and store in "ax"
     
          mov     al, [bpbNumberOfFATs]            ; number of FATs
          mul     [bpbSectorsPerFAT]               ; sectors used by FATs
          add     ax, [bpbReservedSectors]         ; adjust for bootsector
          mov     [datasector], ax                 ; base of root directory
          add     [datasector], cx
          
     ; read root directory into memory (7C00:0200)
     
          mov     bx, 0x0200                            ; copy root dir above bootcode 
          mov     cx, 0x1
          call    ReadSectors

     ;----------------------------------------------------
     ; Find stage 2
     ;----------------------------------------------------

     ; browse root directory for binary image
          mov     cx, [bpbRootEntries]                  ; load loop counter
          mov     di, 0x0200                            ; locate first root entry
     .LOOP:
          push    cx
          mov     cx, 0x000B                            ; eleven character name
          mov     si, offset ImageName                         ; image name to find
          push    di
     rep  cmpsb                                         ; test for entry match
          pop     di
          je      LOAD_FAT
          pop     cx
          add     di, 0x0020                            ; queue next directory entry
          loop .LOOP
          jmp FAILURE

     ;----------------------------------------------------
     ; Load FAT
     ;----------------------------------------------------

     LOAD_FAT:
     
     ; save starting cluster of boot image
          
          mov     si, offset msgCRLF
          call    Print
          mov     dx, [di + 0x001A]
          mov     [cluster], dx                  ; file's first cluster
          
     ; compute size of FAT and store in "cx"
     
          xor     ax, ax
          mov     al, [bpbNumberOfFATs]          ; number of FATs
          mul     [bpbSectorsPerFAT]             ; sectors used by FATs
          mov     cx, ax

     ; compute location of FAT and store in "ax"

          mov     ax, [bpbReservedSectors]       ; adjust for bootsector
          
     ; read FAT into memory (7C00:0200)

          mov     bx, 0x0200                          ; copy FAT above bootcode 
          mov     cx, 0x1
          call    ReadSectors

     ; read image file into memory (0800:0000)
          
          ;mov     si, offset msgCRLF
          ;call    Print
          mov     ax, 0x0800
          mov     es, ax                              ; destination for image
          mov     bx, 0x0000                          ; destination for image
          push    bx

     ;----------------------------------------------------
     ; Load Stage 2
     ;----------------------------------------------------

     LOAD_IMAGE: 

          mov     ax, [cluster]                         ; cluster to read
          pop     bx                                    ; buffer to read into
          call    ClusterLBA                            ; convert cluster to LBA
          xor     cx, cx
          mov     cl, [bpbSectorsPerCluster]            ; sectors to read
          call    ReadSectors
          push    bx 
          
     ; compute next cluster
     
          mov     ax, [cluster]                         ; identify current cluster
          mov     cx, ax                                ; copy current cluster
          mov     dx, ax                                ; copy current cluster
          shr     dx, 0x0001                            ; divide by two
          add     cx, dx                                ; sum for (3/2)
          mov     bx, 0x0200                            ; location of FAT in memory
          add     bx, cx                                ; index into FAT
          mov     dx, [bx]                              ; read two bytes from FAT
          test    ax, 0x0001
          jnz .ODD_CLUSTER 
          
     .EVEN_CLUSTER:
          
          and     dx, 0000111111111111b                 ; take low twelve bits
          jmp .DONE
         
     .ODD_CLUSTER:

          shr     dx, 0x0004                            ; take high twelve bits
          
     .DONE: 

          mov     [cluster], dx                         ; store new cluster
          cmp     dx, 0x0FF0                            ; test for end of file
          jb LOAD_IMAGE 
          
     DONE:
          
          mov     si, offset msgCRLF
          call    Print
          push    0x0800
          push    0x0000
          retf
          
     FAILURE:
     
          mov     si, offset msgFailure
          call    Print
          mov     ah, 0x00
          int     0x16                                ; await keypress
          int     0x19                                ; warm boot computer
     
     absoluteSector db 0x00
     absoluteHead   db 0x00
     absoluteTrack  db 0x00
     
     datasector  dw 0x0000
     cluster     dw 0x0000
     ImageName   db "KRNLDR  SYS"
     msgLoading  db 0x0D, 0x0A, "Iniciando o Sistema", 0x0D, 0x0A, 0x00 
     msgCRLF     db 0x0D, 0x0A, 0x00
     msgProgress db ".", 0x00
     msgFailure  db 0x0D, 0x0A, "ERROR : Press Any Key to Reboot", 0x0A, 0x00
     
     db (510 - ($ - start)) dup (0) 
     DW 0xAA55
