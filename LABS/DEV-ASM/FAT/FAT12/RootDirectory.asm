#masm#
;*******************************************************************************************************************************************|
;                                                        								                                                    |
;       				                          Template para compilacao com MASM 6.15           				                            |
;     				                           Facimente testado no EMU8086 com a diretiva        				                            |
;                       			                            #masm#                           			                                |
;                                                        								                                                    |
;*******************************************************************************************************************************************|  

.286
.MODEL TINY					   
_TEXT SEGMENT PUBLIC USE16
.DATA 

        ;secao de dados
                        bpbOEM			        db "My OS   "			; Boot sector name (8bytes)
                        bpbBytesPerSector     	DW 512                  ; Sector size (must be 512)
                        bpbSectorsPerCluster 	DB 1                    ; Cluster size (must be 1)
                        bpbReservedSectors   	DW 1                    ; Where FAT begins (usually 1)
                        bpbNumberOfFATs 	    DB 2                    ; Number of FATs (must be 2)
                        bpbRootEntries   	    DW 224                  ; Root directory size (usually 224 entries)
                        bpbTotalSectors 	    DW 2880                 ; Drive size (must be 2880 sectors)
                        bpbMedia 		        DB 0f8h                 ; Media type(must be 0xf8)
                        bpbSectorsPerFAT 	    DW 9                    ; Length of FAT area(must be 9 sectors)
                        bpbSectorsPerTrack   	DW 18                   ; Sectors per track(must be 18)
                        bpbHeadsPerCylinder 	DW 2                    ; Number of heads (must be 2)
                        bpbHiddenSectors 	    DD 0                    ; Must be 0 since there is no partition
                        bpbTotalSectorsBig      DD 0                    ; Drive size again
                        bsDriveNumber 	        DB 0
                        bsUnused 		        DB 0
                        bsExtBootSignature   	DB 29h                  ; Not sure
                        bsSerialNumber	        DD 0a0a1a2a3h           ; Probably volume serial number
                        bsVolumeLabel 	        DB "MOS FLOPPY "        ; Name of the disc (11 bytes)
                        bsFileSystem 	        DB "FAT12   "           ; Name of the format (8 bytes)
                        
                        absoluteSector          db 0
                        absoluteHead            db 0
                        absoluteTrack           db 0
                        
                        datasector              dw 0
		        
.CODE 

ORG 100h 

;============================================================================================================================================

start:	                                ;secao de codigo                              Aqui pode-se colocar todos os comentarios
                                        xor     cx, cx
                                        xor     dx, dx
                                        mov     ax, 0020h                             ; 32 byte directory entry
                                        mul     [bpbRootEntries]                      ; total size of directory
                                        div     [bpbBytesPerSector]                   ; sectors used by directory
                                        xchg    ax, cx
                                      
                                    ; compute location of root directory and store in "ax"
                                 
                                        mov     al, [bpbNumberOfFATs]                   ; number of FATs
                                        mul     [bpbSectorsPerFAT]                      ; sectors used by FATs
                                        add     ax, [bpbReservedSectors]                ; adjust for bootsector
                                        mov     [datasector], ax                        ; base of root directory
                                        add     [datasector], cx
                                      
                                    ; read root directory into memory (7C00:0200)
                                 
                                        mov     bx, 0200h                               ; copy root dir above bootcode 
                                        mov     cx, 1
		                                int         20h

;============================================================================================================================================
    
_TEXT ENDS
END start
