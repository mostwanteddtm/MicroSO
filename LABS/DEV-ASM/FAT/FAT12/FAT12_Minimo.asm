org	7C00H						        ; we will set regisers later

start:	jmp	main					; jump to start of bootloader

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
    
    
    ; Precisa identificar por que tem que ocupar a memoria
    ; com o volume abaixo 
    ; pode ser com instrucoes ou variaveis
    Teste dw 35 dup (0)                                                              

main: 

    cli
    hlt
     
    db (510 - ($ - start)) dup (0) 
    DW 0xAA55  

END
