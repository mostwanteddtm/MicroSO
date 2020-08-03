;==============================================================================
;
; FlyingDragon OS Boot Sector FOR FAT32
;
; Author: Jack
; V0.01 2005-07-23 17:39
; V0.02 2005-08-07 09:29
;
; Build : nasm -f bin FAT32.ASM -oFAT32.BIN
;
;==============================================================================
;
; The role of the BIOS in startup:
; (1) The BIOS loads the 0 sector (CHS = 0:0:1) content on the boot drive to the memory linear address 7C00H
; (2) The BIOS checks whether the loaded sector has a boot flag (510, 511 bytes are 55H and AAH respectively)
; (3) CPU register DL is set to the drive number assigned to the boot drive, 00H is floppy drive A, 80H is hard drive C
; (4) The BIOS jumps to the code in its loaded sector (ie, at 7C00H) and passes control to the boot code.
;
; The boot code should initialize the following registers:
; (1) DS: Some BIOS settings have a value of 0, some settings are 40H, it should be set to (7C00H-BOOT_ORG)/16 
; Where BOOT_ORG is the ORG value of the boot code, which is typically 7C00H (which means DS should be set to 0)
; (2) SS and SP (stack): The initial values ​​of these two registers depend on the BIOS
; (3) CS IP (via JMP instruction): Most BIOS enters the startup code at 0000:7C00H, but some
; The BIOS jumps to 07C0:0000H. Since short jumps and conditional jumps are IP related, if not used
; Far jump or absolute jump, you do not need to reset CS and IP; however, DS still must be the correct value.
;
;===============================================================================
;
; General memory (0000 0000H - 000F FFFFH, ie 0-1MB) usage at system startup
;
;===============================================================================
;
; ---------------------------------
; | 0000 0000 - 0000 03FF | 1024B 		IDT read only
; |-------------------------------|	
; | 0000 0400 - 0000 04FF | 256B 		BIOS Data Area , read only
; |-------------------------------|	
; | 0000 0500 - 0000 7BFF |* 30464B 	Free Memory , read/write (29.75KB)
; |------------------------------ |	
; | 0000 7C00 - 0000 7DFF | 512B 		Boot Sector , read/write
; |------------------------------ |	
; | 0000 7E00 - 0000 7FFF | 512B 		Free Memory , read /write
; |------------------------------ |	
; | 0000 8000 - 0009 FBFF | 607KB 		Free Memory , read / write( 32K - 639KB )
; |------------------------------ |	
; | 0009 FC00 - 0009 FFFF |** 1KB 		EBDA extended BIOS data area
; |------------------------------ |	
; | 000A 0000 - 000A FFFF | 64KB 		Video Memory
; |------------------------------ |	
; | 000B 0000 - 000B 7FFF | 32KB 		Mono Video Text Memory
; |------------------------------ |	
; | 000B 8000 - 000B FFFF | 32KB 		Color Video Text Memory
; |------------------------------ |	
; | 000C 0000 - 000C 7FFF | 32KB 		Video BIOS , read only
; |------------------------------ |	
; | 000C 8000 - 000E FFFF | 160KB 		Adapter ROM, read only
; |------------------------------ |
; | 000F 0000 - 000F FFFF | 64KB 		System BIOS, read only
; |------------------------------ |
; | 0010 0000 - 0010 FFEF |***64KB-16 	High Memory Area, read/write (at the beginning of 1MB)
; |------------------------------ |
; | 0010 FFF0 - | 						Free Extended Memory, read/write
; |------------------------------ |
;
; * Free memory does not actually start from 0000 0500, the BIOS data area will actually use a small number of bytes starting from 0000 0500, for example
; 00000500 saves the status of the print screen, when the print screen (PrintScreen) button is pressed, the low-level keyboard BIOS initializes the print screen
; Curtain function, keyboard BIOS trigger interrupt 5 print screen handler. Because the BIOS data area has crossed the boundaries of 256B, so DOS actually
; The top is loaded from 0000 0522. For the sake of safety, free memory can be used starting from 0000 0600. (1.5K - 31K 29.5KB)
;
; ** Some of these machines do not have this BIOS extension data area.
;
; *** If you are not using an extended high-end memory area program (such as Emm386.exe), memory starting from 0010 0000 (1MB) is available.
;
;
;============================================================================
; 
 
BITS   16    					; generate 16-bit code instead of 32-bit code
SECTION  .TEXT      			; code segment
ORG   7C00H         			; specifies the starting position of the program to be loaded into memory
 
;============================================================================
;
; macro and constant definitions
;
;============================================================================
?     EQU  0   					; NASM does not support DW? Such a syntax, you can use such a definition
                                ; Simulation to make the code more readable
DATA_BUF_SEG EQU  0200H         ; buffer (8K) segment address for reading root or file contents
DATA_BUF_OFF EQU  2000H         
STACK_ADDR  EQU  7BD0H          ; Stack top (note: stack size is approximately 20K)
OSLOADER_ADDR EQU  8000H        ; FDOSLDR.BIN is placed in the starting position in memory, which means
                                ; The size of the loader and related resources cannot exceed 608K
                                ; 8000H - A000H (32K - 640K)
OSLOADER_SEG EQU  0800H         ; starting segment address
SECOND_SECTOR EQU  03H          ; sector number of the second boot sector (fourth sector)
SECOND_ADDR  EQU  7E00H         ; loading position of the second boot sector
 
;==============================================================================
; Save several intermediate variables with the stack ( SS = 0 BP = 7C00H )
;==============================================================================
FAT_START_SECTOR EQU  4  		; The starting sector number of the FAT table DWORD
ROOT_START_SECTOR EQU  8        ; the starting sector number of the root directory DWORD
DATA_START_SECTOR EQU  12       ; data area start sector number DWORD
FAT_ENTRY_SECTORS EQU  14       ; Number of sectors occupied by FAT table WORD
ROOT_ENTRY_SECTORS EQU  16      ; Number of sectors in the root directory WORD
DIR_PER_SECTOR  EQU  17         ; Directory for each sector BYTE
DISK_EXT_SUPPORT EQU  18        ; Does the disk support extended BIOS BYTE?
CURRENT_CLUSTER  EQU  40        ; The cluster number currently being processed DWORD
 
 
;==============================================================================
; the address pack used by the extended disk service
;==============================================================================
DAP_SECTOR_HIGH  EQU  24   		; The upper 32 bits of the starting sector number (reset required for each call) DWORD
DAP_SECTOR_LOW  EQU  28         ; The lower 32 bits of the starting sector number (reset required for each call) DWORD
DAP_BUFFER_SEG  EQU  30         ; Buffer segment address (reset required for each call) WORD
DAP_BUFFER_OFF  EQU  32         ; Buffer offset (reset required for each call) WORD
DAP_RESERVED2  EQU  33          ; Reserved bytes
DAP_READ_SECTORS EQU  34        ; Number of sectors to process (1 - 127)
DAP_RESERVED1  EQU  35          ; Reserved bytes
DAP_PACKET_SIZE  EQU  36        ; The size of the packet is 16 bytes
 
;==============================================================================
;
; directory item structure (each structure is 32 bytes)
;
;==============================================================================
OFF_DIR_NAME    EQU  0  					; offset of directory entry BYTE[11]		
OFF_DIR_ATTRIBUTE   EQU  11                 ; Directory attribute BYTE
OFF_NT_RESERVED    EQU  12                  ; Reserved attribute BYTE
OFF_CREATE_TIME_HUNDREDTH EQU  13           ; creation time BYTE
OFF_CREATE_TIME    EQU  14                  ; creation time WORD
OFF_CREATE_DATE    EQU  16                  ; Create time WORD
OFF_LAST_ACCESS_DATE  EQU  18               ; Last accessed WORD
OFF_START_CLUSTER_HIGH  EQU  20             ; starting cluster number high WORD
OFF_LAST_UPDATE_TIME  EQU  22               ; Last updated WORD
OFF_LAST_UPDATE_DATE  EQU  24               ; Last updated WORD
OFF_START_CLUSTER_LOW  EQU  26              ; starting cluster number low WORD
OFF_FILE_SIZE    EQU  28                    ; file size DWORD
                                            
; ????                                      
DIR_NAME_DELETED   EQU  0E5H                ; the item has been deleted
DIR_NAME_FREE    EQU  00H                   ; The item is free (it is also idle)
DIR_NAME_DOT    EQU  2EH                    ; special directory . or ..
DIR_NAME_SPACE    EQU  20H                  ; characters not allowed
DIR_ENTRY_SIZE    EQU  32                   ; the size of each directory item, its structure is as shown above
                                            
;????                                       
DIR_ATTR_READONLY   EQU  01H                ; Read-only file
DIR_ATTR_HIDDEN    EQU  02H                 ; hidden file
DIR_ATTR_SYSTEM    EQU  04H                 ; system file
DIR_ATTR_VOLUME    EQU  08H                 ; volume label (can only appear in the root directory)
DIR_ATTR_SUBDIR    EQU  10H                 ; Subdirectory
DIR_ATTR_ARCHIVE   EQU  20H                 ; Archive properties
DIR_ATTR_LONGNAME   EQU  0FH                ; long filename
DIR_ATTR_LONGNAME_MASK  EQU  3FH            ; long filename mask
                                            
; ???                                       
CLUSTER_MASK    EQU  0FFFFFFFH              ; Cluster number mask (FAT32=>FAT28)
CLUSTER_FREE    EQU  00000000H              ; The cluster is idle
CLUSTER_RESERVED   EQU  00000001H           ; Cluster is reserved
CLUSTER_MIN_VALID   EQU  00000002H          ; minimum valid cluster number
CLUSTER_MAX_VALID   EQU  0FFFFFF6H          ; maximum valid cluster number
CLUSTER_BAD     EQU  0FFFFFF7H              ; bad cluster
CLUSTER_LAST    EQU  0FFFFFF8H              ; 0xFFFFFFF8-0xFFFFFFFF indicates the last cluster of the file
 
;==============================================================================
;
; boot sector (512 bytes)
;
;==============================================================================
_ENTRY_POINT:  
 
											; 3-byte jump instruction
 JMP SHORT _BOOT_CODE 	                    ; Jump to the real boot code
 NOP      		                            ; null instruction to guarantee the number of bytes is 3
 
			
OEMName     DB "FDOS1.00" 
 
;==================================================================== 
;  
; BPB( BIOS Parameter Block )  
;  
;==================================================================== 
BytesPerSector   DW ? 						; Bytes per sector (512 1024 2048 4096)				
SectorsPerCluster  DB ?                     ; Number of sectors per cluster ( 1 2 4 8 16 32 64 128 )
        		                            ; Multiplying the two cannot exceed 32K (the maximum size of the cluster)
ReservedSectors   DW ?                      ; The number of reserved sectors starting from the first sector of the volume;
        		                            ; the value cannot be 0, for FAT12/FAT16, the value is usually 1;
        		                            ;For FAT32, the typical value is 32;
NumberOfFATs   DB ?                         ; The number of FAT data structures on the volume, which should normally be 2
RootEntries    DW ?                         ; For FAT12/FAT16, this value represents the number of 32-byte directory entries;
        		                            ; for FAT32, this value must be 0;
NumberOfSectors16  DW ?                     ; The total number of sectors on the volume, this field can be 0 if the field
        		                            ; 0, then NumberOfSectors32 cannot be 0; for FAT32,
        		                            ; this field must be 0
MediaDescriptor   DB ?                      ; Media Type
SectorsPerFAT16   DW ?                      ; This field identifies the number of sectors (FAT12/FAT16) occupied by a FAT structure.
        		                            ; for FAT32 volumes, this field must be 0;
SectorsPerTrack   DW ?                      ; Number of sectors per track for INT 0x13 interrupts
HeadsPerCylinder  DW ?                      ; Number of heads per cylinder for INT 0x13 interrupts
HiddenSectors   DD ?                        ; Number of hidden sectors before the partition containing the FAT volume
NumberOfSectors32  DD ?                     ; This field contains the number of all sectors on the volume. For FAT32, this field
        		                            ; Not 0; FAT12/FAT16 can exceed 65,536 fans according to the actual size
        		                            ;The number of zones determines whether this field is used
 
;==================================================================== 
;  
; EBPB ( Extended BIOS Parameter Block ) 
;  
;==================================================================== 
SectorsPerFAT32   DD ?  	 				; For FAT32, this field contains the size of a FAT, and SectorsPerFAT16
			                                ; field must be 0;
ExtFlags    DW ?   	                        ; logo
FSVersion    DW ?   	                    ; This is the version of the file system, with the high byte as the main version and the low byte as the minor version;
RootDirectoryStart  DD ?                    ; The starting cluster number of the root directory, usually 2;
FSInfoSector   DW ?   	                    ; FSINFO structure in the FAT32 volume reserved area sector number
BackupBootSector  DW ?                      ; If this field is not 0, it indicates the sector number of the boot record saved in the reserved area.
          		                            ; usually 6, no other values ​​are recommended;
Reserved1 TIMES 12 DB ?                     ; Reserved field, the formatter should clear this field to 0
DriveNumber    DB ?   	                    ; drive letter for INT 0x13, 0x00 for floppy disk, 0x80 for hard disk
NTReserved    DB ?   	                    ; Reserved bytes (for Windows NT, ie NTFS), for FAT files
         		                            ; system should always be 0
BootSignature   DB  29H                     ; Extended boot flag (value 0x29)
VolumeId    DD ?   	                        ; serial number of the volume
VolumeLabel  times 11   DB ?                ; volume label, which is the same as the 11-byte volume label in the root directory
         		                            ;NASM does not currently support DUP syntax
FileSystemType   DB 'FAT32'                 ;FileSystemType DB 'FAT32 ' ; file system type
 
;==============================================================================
;
; The real startup code starts from here (offset: 0x3E)
; Its function is to search the root directory of the disk, find the FDOSLDR.BIN file, read it into memory and run it.
;
;==============================================================================
_BOOT_CODE: 
 
											; Initialize related registers and flags
 CLI                                        ; first turn off the interrupt
 CLD                                        ; direction is forward increment
 XOR  AX,AX                                 ; AX = 0
 MOV  DS,AX                                 ; Set data segment register DS: SI
 MOV  ES,AX                                 ; Set additional segment register ES:DI
 MOV  SS,AX                                 ; Set the stack segment register
 MOV  BP,7C00H                              ; Set the base register
 MOV  SP,STACK_ADDR                         ; Set the stack top
 STI                                        ; allow interrupt
 
 ;==================================================================== 
 ; save the boot disk number
 ;==================================================================== 
 MOV  [DriveNumber],DL 						; This value is set by the BIOS. If it is booted from USB, the value is 0x80.
                                            ; that is the number of the first hard disk, this value will be used for subsequent disks
                                            ; read call
 
 
 ;====================================================================   
 ; Prepare constants commonly used in the FAT32 file system for subsequent operations 
 ;==================================================================== 
 ; 
 ; [hidden sector] [reserved sector] [FAT][DATA] 
 ; 
 ;==================================================================== 
  
 ;====================================================================   
 ; Check if disk interrupt INT 13H extension is supported
 ;==================================================================== 
 MOV  BYTE [BP - DISK_EXT_SUPPORT],00H 					; 00H indicates that disk expansion is not supported  
 MOV  DL,[DriveNumber]                      
 MOV  AH,41H                                
 MOV  BX,055AAH                             
 INT  13H                                   
 JC  _NO_DISK_EXTENSION                     			; If it fails, the carry flag is 1 or the BX value is incorrect ( AA55 or 55AA )
  

 MOV  BYTE [BP - DISK_EXT_SUPPORT],01H  				; set disk support extended interrupt flag
                                                        ; 01H indicates support for disk expansion
                                                        
_NO_DISK_EXTENSION:                                     ; does not support disk expansion
                                                        
                                                        
                                                        ; check if it is a FAT32 partition
 CMP  WORD [RootEntries],0                              ; for FAT32 partitions, the root entry is 0
 JNZ  NEAR _DISK_ERROR                                  
                                                        
                                                        
                                                        ; check the number of reserved sectors (reserved sectors must be greater than or 
 CMP  WORD [ReservedSectors],4                          ; the second sector of code exists in the fourth sector)
 JB  NEAR _DISK_ERROR                                   
                                                        
                                                        
                                                        ; Check the number of sectors per FAT
                                                        ; SectorsPerFAT16 == 0
 CMP  WORD [SectorsPerFAT16],0                          ; SectorsPerFAT32 != 0
 JNZ  NEAR _DISK_ERROR                                  
 CMP  DWORD[SectorsPerFAT32],0                          
 JZ  NEAR _DISK_ERROR                                   
                                                        
                                                        
 MOV  AX,WORD [BytesPerSector]                          ; Calculate the directory entry contained in each sector (512/32 = 16 = 10H )
 MOV  CL,DIR_ENTRY_SIZE                                 
 DIV  CL                                                
 MOV  BYTE [BP - DIR_PER_SECTOR],AL                     ; AH:AL = BytesPerSector / 32 ( AH = Remainder = 0 )
                                                        ; AL = DirEntriesPerSector
                                                        
                                                        ; FAT starting sector
 MOV  AX ,WORD [ReservedSectors]                        ; FAT starting sector = Hidden+Reserved
 CWD                                                    
 ADD  AX, WORD [HiddenSectors]                          ; AX => DX : AX
 ADC   DX, WORD [HiddenSectors+2]                       
 MOV  WORD[ BP - FAT_START_SECTOR  ],AX                 
 MOV   WORD[ BP - FAT_START_SECTOR+2],DX                
                                                        
                                                        
                                                        ; the number of sectors occupied by the FAT table
                                                        ; FAT_SECTORS = NumberOfFAT * SectorsPerFAT
 XOR  EAX,EAX                                           
 MOV  AL, BYTE [NumberOfFATs]                           ; Number of FATs
 MOV  EBX,DWORD [SectorsPerFAT32]                       
 MUL  EBX                                               ; Product in EDX:EAX
 MOV  DWORD [ BP - FAT_ENTRY_SECTORS  ] , EAX 
  
														; Calculate the starting sector of the data area
 ADD  EAX ,DWORD[ BP - FAT_START_SECTOR  ] 
 MOV  DWORD [ BP - DATA_START_SECTOR ],EAX  
  
  
 ;==================================================================== 
 ; 
 ; Initialize DiskAddressPacket 
 ; Only need to modify the field when using: DATA_BUFFER_OFF DATA_BUFFER_SEG 
 ; DAP_SECTOR_LOW DAP_SECTOR_HIGH 
 ; 
 ;==================================================================== 
 MOV  DWORD [BP - DAP_SECTOR_HIGH ],00H 
 MOV  BYTE  [BP - DAP_RESERVED1   ],00H 
 MOV  BYTE  [BP - DAP_RESERVED2   ],00H 
 MOV  BYTE  [BP - DAP_PACKET_SIZE ],10H 
 MOV  BYTE  [BP - DAP_READ_SECTORS],01H 
 MOV  WORD  [BP - DAP_BUFFER_SEG  ],00H 
 MOV  BYTE  [BP - DAP_READ_SECTORS],01H  ; read only one sector at a time
  
 ; load the second boot sector  
 MOV  WORD  [BP - DAP_BUFFER_OFF  ],SECOND_ADDR  
 MOV  EAX , DWORD[HiddenSectors] 
 ADD  EAX , SECOND_SECTOR 
 MOV  DWORD [BP - DAP_SECTOR_LOW  ],EAX 
 CALL ReadSector 
  
  
 ; Start looking for the root directory and load FDOSLDR.BIN
 JMP  _SEARCH_LOADER 
  
;==================================================================== 
; Error handling
;==================================================================== 
_MISSING_LOADER:      					; shows no loader
 MOV  SI,MessageMissLoader              
 CALL ShowMessage                       
 JMP  _REBOOT                           
                                        
_DISK_ERROR:                            ; Display disk error message
 MOV  SI,MessageDiskError               
 CALL ShowMessage                       
                                        
_REBOOT:                                ; restart
 MOV  SI,MessageRestart 
 CALL ShowMessage 
  
 ; call keyboard interrupt, wait for user button
 MOV  AH,00H 
 INT  16H 
  
 ; restart the computer
 INT  19H  
 

 JMP  $ 
 
 
;==================================================================== 
;  
; subprocess
;  
;==================================================================== 
 
;==================================================================== 
;  
; read a disk sector
; Input: The corresponding field in DAP has been set
; Restriction: Cannot read more than one cluster of content
;  
;==================================================================== 
ReadSector: 
 
 PUSHA 									; save register
  
 ; check if extension mode is used 
 CMP  BYTE [BP - DISK_EXT_SUPPORT],00H 
 JZ  .NoDiskExtension 
  
;==================================================================== 
; INT 13H AH = 42H extended disk call
;==================================================================== 
 ; read one sector at a time 
 MOV  AH,42H         					; function number 
 LEA  SI ,[BP - DAP_PACKET_SIZE]        ; address pack address
                                        
 ; drive letter                         
 MOV  DL ,[DriveNumber]                 ; drive letter
 INT  13H                               
 JC   _DISK_ERROR                       ; read failed
 JMP  _READ_SECTOR_OK                   ; read successfully
 
;==================================================================== 
;  
; INT 13H
; AH = 2 cylinder number: 0 - 1023
; AL = number of sectors to read head number: 0 - 255
; CH = cylinder number lower 8 bits Sector number: 1 - 63
; CL = cylinder number 2 digits: 6-digit sector number
; DH = head number
; DL = drive letter
;
; LBA = ( (cylinder * HeadsPerCylinder + heads ) * SectorsPerTrack ) + sector - 1 
;
; Sector = LBA % SectorsPerTrack +1
; Head = ( LBA / SectorsPerTrack ) % HeadsPerCylinder
; Cylinder= ( LBA / SectorsPerTrack ) / HeadsPerCylinder
; 
;====================================================================  
.NoDiskExtension: 
   
 ;===================================================================  
 ; First need to convert the sector number to CHS address 
 ;=================================================================== 
  
											; first calculate the sector number
 MOV  AX,WORD [ BP - DAP_SECTOR_LOW   ]     
 MOV  DX,WORD [ BP - DAP_SECTOR_LOW+2 ]     
 DIV  WORD [SectorsPerTrack ]               ; AX = LBA / SectorsPerTrack DX = LDA % SectorsPerTrack
 MOV  CX,DX                                 
 INC  CX                                    ; CL = Sector
 AND  CL,3FH                                ; 1-63
                                            
                                            ; Recalculate the head number and cylinder number
 XOR  DX,DX                                 ; DX: AX = LBA / SectorsPerTrack
 DIV  WORD [HeadsPerCylinder]               ; DX = ( LBA/SectorsPerTrack ) % HeadsPerCylinder = Head
                                            ; AX = ( LBA/SectorsPerTrack ) / HeadsPerCylinder = Cylinder
 MOV  CH,AL                                 ; lower cylinder number 8
 SHL  AH,6                                  
 OR  CL,AH                                  ; CL = cylinder number 2 bits: 6-bit sector number
 MOV  DH,DL                                 ; DL = head number
                                            
                                            ; ready to read the disk
 MOV  AX,WORD[ BP - DAP_BUFFER_SEG ]        
 MOV  ES,AX                                 
 MOV  BX,WORD[ BP - DAP_BUFFER_OFF ]        
 MOV  AX ,0201H                             ; read only one sector at a time
                                            
                                            ; drive letter
 MOV  DL ,[DriveNumber]                     ; drive letter
 INT  13H                                   
 JC   _DISK_ERROR                           ; read failed
                                            
_READ_SECTOR_OK:                            
 POPA                                       ; recovery register
 RET  
     
;==================================================================== 
;  
; display a string
; Enter:
; DS:SI = start address of the string (ends with NULL)
;    
;==================================================================== 
ShowMessage: 
 LODSB    									; AL = DS: [SI] SI = SI+1
 OR  AL,AL                                  ; detect if a NULL string is encountered
 JZ  _SHOW_END 
 MOV  AH,0EH 
 MOV  BX,07H 
 INT  10H 
 JMP  ShowMessage 
 
_SHOW_END: 
 RET  
 
;==================================================================== 
; Data area
;==================================================================== 
LoaderName     db "FDOSLDR BIN"       							; second stage starter FDOSLDR.BIN
MessageMissLoader   db "NO FDOSLDR.BIN.",0DH,0AH,00H            ; No loader found
MessageDiskError   db  "Disk Error.",0DH,0AH,00                 ; disk error message
MessageRestart    db "Press any key to restart." ,0DH,0AH,00    ; Prompt to restart message
;==================================================================== 
; the last marked byte of the sector (NASM does not support repeated ORG) 
;==================================================================== 
Padding TIMES 510-($-$$) db  00H 
SectorSignature    dw 0AA55H 
 
 
 
;==================================================================== 
; the code of the second sector (the code is located in the fourth sector of the partition)
;==================================================================== 
 
;==================================================================== 
; Find the root directory and check if there is a FDOSLDR.BIN file
;==================================================================== 
_SEARCH_LOADER:  
 
 
													; set buffer
 MOV  WORD [ BP - DAP_BUFFER_OFF  ], DATA_BUF_OFF   ; 0000:1000H
                                                    
                                                    ; root directory starting cluster number
 MOV  EAX,DWORD[RootDirectoryStart]                 
 MOV  DWORD[ BP - CURRENT_CLUSTER ],EAX             
                                                    
                                                    ; check the next cluster
_NEXT_ROOT_CLUSTER:                                 
                                                    
                                                    ; Calculate the sector number (EAX-2)*SectorsPerCluster+DATA_START_SECTOR based on the cluster number
 DEC  EAX                                           
 DEC  EAX                                           ; EAX = EAX - 2
 XOR  EBX,EBX                                       
 MOV  BL, BYTE[ SectorsPerCluster]                  
 MUL  EBX                                           
 ADD  EAX,DWORD[ BP- DATA_START_SECTOR]             
 MOV  DWORD[ BP - DAP_SECTOR_LOW  ], EAX            
 MOV  DL,[SectorsPerCluster]                        
                                                    
                                                    ; check the next sector
_NEXT_ROOT_SECTOR:                                  
                                                    
                                                    ; Read each root sector sector in turn to check for the existence of the FDOSLDR.BIN file
 CALL ReadSector                                    
                                                    
                                                    ; check the contents of the sector
 MOV  DI,DATA_BUF_OFF                               
 MOV  BL,BYTE [ BP - DIR_PER_SECTOR]                
                                                    
                                                    ; check each directory entry
_NEXT_ROOT_ENTRY:                                   
 CMP  BYTE [DI],DIR_NAME_FREE                       
 JZ  _MISSING_LOADER                                ; NO MORE DIR ENTRY
                                                    
                                                    ; check if the loader
 PUSH  DI                                           ; Save DI
 MOV  SI,LoaderName                                 
 MOV  CX,11                                         
 REPE  CMPSB                                        
 JCXZ  _FOUND_LOADER                                ; Load Loader and run
                                                    
                                                    ; Is there still a next directory entry (inner loop)
 POP  DI                                            
 ADD   DI,DIR_ENTRY_SIZE                            
 DEC  BL                                            
 JNZ   _NEXT_ROOT_ENTRY                             
                                                    
                                                    ; Check if there is still the next sector readable (outer loop)
 DEC  DL                                            
 JZ  _CHECK_NEXT_ROOT_CLUSTER                       
 INC  DWORD [ BP - DAP_SECTOR_LOW ]                 ; Increase the sector number
 JMP  _NEXT_ROOT_SECTOR                             
                                                    
                                                    ; check the next cluster
_CHECK_NEXT_ROOT_CLUSTER:                           
                                                    
                                                    ; Calculate the cluster number and offset where the FAT is located
                                                    ; FatOffset = ClusterNum*4
 XOR  EDX,EDX                                       
 MOV  EAX,DWORD[BP - CURRENT_CLUSTER]               
 SHL  EAX,2                                         
 XOR  ECX,ECX                                       
 MOV  CX,WORD [ BytesPerSector ]                    
 DIV  ECX                                           ; EAX = Sector EDX = OFFSET
 ADD  EAX,DWORD [BP - FAT_START_SECTOR  ]           
 MOV  DWORD [ BP - DAP_SECTOR_LOW ], EAX            
                                                    
                                                    ; read sector	
 CALL  ReadSector                                   
                                                    
                                                    ; check the next cluster	
 MOV  DI,DX                                         
 ADD  DI,DATA_BUF_OFF                               
 MOV  EAX,DWORD[DI]                                 ; EAX = next cluster number to read
 AND  EAX,CLUSTER_MASK                              
 MOV  DWORD[ BP - CURRENT_CLUSTER ],EAX             
 CMP  EAX,CLUSTER_LAST                              ; CX >= 0FFFFFF8H means no more clusters
 JB  _NEXT_ROOT_CLUSTER 
 JMP  _MISSING_LOADER 
 
;==================================================================== 
; Load the FDOSLDR.BIN file
;==================================================================== 
_FOUND_LOADER: 
													; directory structure address in DI
 POP  DI                                            
 XOR  EAX,EAX                                       
 MOV  AX,[DI+OFF_START_CLUSTER_HIGH]                ; starting cluster number is 32 bits high
 SHL  AX,16                                         
 MOV  AX,[DI+OFF_START_CLUSTER_LOW]                 ; starting cluster number lower 32 bits
 MOV  DWORD[ BP - CURRENT_CLUSTER ],EAX             
 MOV  CX, OSLOADER_SEG                              ; CX = buffer segment address
                                                    
                                                    
_NEXT_DATA_CLUSTER:                                 
                                                    
                                                    ; Calculate the sector number based on the cluster number
 DEC  EAX                                           
 DEC  EAX                                           ; EAX = EAX - 2
 XOR  EBX,EBX                                       
 MOV  BL, BYTE[ SectorsPerCluster]                  
 MUL  EBX                                           
 ADD  EAX,DWORD[ BP- DATA_START_SECTOR]             
 MOV  DWORD[ BP - DAP_SECTOR_LOW  ], EAX            
 MOV  DL,[SectorsPerCluster]                        
                                                    
                                                    ; set buffer
 MOV  WORD [ BP - DAP_BUFFER_SEG   ],CX             
 MOV  WORD [ BP - DAP_BUFFER_OFF   ],00H            
                                                    
                                                    ; number of sectors that each cluster needs to read
 MOV  BL , BYTE [SectorsPerCluster]                 
                                                    
_NEXT_DATA_SECTOR:                                  
                                                    ; read each sector in the cluster (inner loop)
                                                    ; Note: By checking the file size, you can avoid reading all the sizes of the last dissatisfied cluster
                                                    ; read data sector
 CALL  ReadSector                                   
                                                    
                                                    ; update the address and continue reading
 MOV  AX, WORD [BytesPerSector]                     
 ADD  WORD  [BP - DAP_BUFFER_OFF],AX                
 INC  DWORD [BP - DAP_SECTOR_LOW]                   ; Incremental sector number
 DEC  BL                                            ; inner loop count
 JNZ  _NEXT_DATA_SECTOR                             
                                                    
                                                    ; check the next cluster
                                                    
                                                    ; update to read the buffer address of the next cluster
                                                    
 MOV  CL,BYTE [ SectorsPerCluster ]                 
 MOV  AX ,WORD [BytesPerSector]                     
 SHR  AX ,4                                         
 MUL  CL                                            
 ADD  AX ,WORD [ BP - DAP_BUFFER_SEG ]              ; Save the buffer segment address of the next cluster
 MOV  CX,AX 
  
 ;==================================================================== 
 ; 
 ; Check if there is another cluster (read the information about the FAT table) 
 ; LET N = data cluster number
 ; THUS FAT_BYTES  = N*4  (FAT32) 
 ; FAT_SECTOR = FAT_BYTES / BytesPerSector 
 ; FAT_OFFSET = FAT_BYTES % BytesPerSector 
 ; 
 ;==================================================================== 
  
													; Calculate the cluster number and offset where the FAT is located
 MOV  EAX,DWORD [BP - CURRENT_CLUSTER]              
 XOR  EDX,EDX                                       
 SHL  EAX,2                                         
 XOR  EBX,EBX                                       
 MOV  BX,WORD [ BytesPerSector ]                    
 DIV  EBX                                           ; EAX = Sector EDX = Offset
                                                    
                                                    ; set the buffer address
 ADD  EAX,DWORD [BP - FAT_START_SECTOR  ]           
 MOV  DWORD [ BP - DAP_SECTOR_LOW ], EAX            
 MOV   WORD [BP - DAP_BUFFER_SEG  ], 00H            
 MOV  WORD [BP - DAP_BUFFER_OFF  ], DATA_BUF_OFF    ; 0000:1000H
                                                    
                                                    ; read sector
 CALL  ReadSector                                   
                                                    
                                                    ; check the next cluster
 MOV  DI,DX                                         
 ADD  DI,DATA_BUF_OFF                               
 MOV  EAX,DWORD[DI]                                 ; EAX = next cluster number to read
 AND  EAX,CLUSTER_MASK                              
 MOV  DWORD[ BP - CURRENT_CLUSTER ],EAX             
 CMP  EAX,CLUSTER_LAST                              ; CX >= 0FFFFFF8H means no more clusters
 JB  _NEXT_DATA_CLUSTER                             
                                                    
                                                    
_RUN_LOADER:                                        
                                                    
                                                    ; Run FDOSLDR.BIN
 MOV  DL,[DriveNumber]                              
 jmp 800h:0100h                                     ; JMP 00: OSLOADER_ADDR
 
;==================================================================== 
; debug routine
;==================================================================== 
%IFDEF DEBUG 
;==================================================================== 
 
;==================================================================== 
;  
; display one character
; Input: AL = character to be displayed
; 
;==================================================================== 
PrintChar: 
 PUSH BX 
 MOV  AH,0EH 
 MOV  BX,7 
 INT  10H 
 POP  BX 
 RET 
  
;==================================================================== 
%ENDIF ; DEBUG 
;==================================================================== 
 
 
;==================================================================== 
; the last marked byte of the sector (NASM does not support repeated ORG) 
;==================================================================== 
SecondPadding  TIMES 1022-($-$$) db  00H 
SecondSignature  DW 0AA55H 
 
;==================================================================== 
; end of code
;==================================================================== 
 

 
