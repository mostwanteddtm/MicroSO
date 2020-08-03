
; *****************************************************************************
;
; ATAID.ASM  [ ATA & ATAPI device I/O code draft ]
; Copyright (C) 2002  Erdogan TAN  [ 27/01/2002 ]  Last Update: 20/11/2002
;
; Microsoft Macro Assembler: (Command Line)
; "masm.exe ataid" & "link /t ataid" --> ataid.com
;  or
; "ml /AT /Zm ataid.asm"
;
; *****************************************************************************

; ATA/IDE Command Register Block [ AT Task File ]
IdeCmdReg_R_Data      equ 0  ; Data Register
IdeCmdReg_W_Data      equ 0  ; Data Register
IdeCmdReg_R_Error     equ 1  ; Error Register
IdeCmdReg_W_Feature   equ 1  ; Feature Register
IdeCmdReg_R_SectCount equ 2  ; Sector Count Register
IdeCmdReg_W_SectCount equ 2  ; Sector Count Register
IdeCmdReg_R_Sector    equ 3  ; Sector Number or LBA Bits 0-7
IdeCmdReg_W_Sector    equ 3  ; Sector Number or LBA Bits 0-7
IdeCmdReg_R_Cylinder0 equ 4  ; Cylinder Bits 0-7 or LBA Bits 8-15
IdeCmdReg_W_Cylinder0 equ 4  ; Cylinder Bits 0-7 or LBA Bits 8-15
IdeCmdReg_R_Cylinder1 equ 5  ; Cylinder Bits 8-15 or LBA Bits 16-23
IdeCmdReg_W_Cylinder1 equ 5  ; Cylinder Bits 8-15 or LBA Bits 16-23
IdeCmdReg_R_DriveHead equ 6  ; Drive & Head Bits or LBA Bits 24-27
IdeCmdReg_W_DriveHead equ 6  ; Drive & Head Bits or LBA Bits 24-27
IdeCmdReg_R_Status    equ 7  ; Status Register
IdeCmdReg_W_Command   equ 7  ; Command Register

; ATA "IDENTIFY DRIVE" (ECh) Command Parameters Lists
; 512 bytes (256 words)
ataidConfig        equ 0
ataidNumOfCyls     equ 2
ataidReserved1     equ 4
ataidNumOfHeads    equ 6
ataidBytePerTrU    equ 8
ataidBytePerSecU   equ 10
ataidSecPerTrack   equ 12
ataidVendorSpec1   equ 14
ataidSerialNo      equ 20     ; ASCII
ataidBuffType      equ 40
ataidBuffSize      equ 42
ataidNumOfECCByte  equ 44
ataidFirmwareRev   equ 46     ; ASCII
ataidModelName     equ 54     ; ASCII
ataidMulSecPerInt  equ 94
ataidDWIO          equ 96
ataidLBADMA        equ 98
ataidReserved2     equ 100
ataidPIOTiMode     equ 102
ataidDMATiMode     equ 104
ataidReserved3     equ 106
ataidApNumOfCyls   equ 108
ataidApNumOfHeads  equ 110
ataidApSecPerTrack equ 112
ataidCapacity      equ 114
ataidNumSecPerInt  equ 118
ataidLBASectors    equ 120
ataidSinDMAModes   equ 124
ataidMulDMAModes   equ 126
ataidReserved4     equ 128
ataidVendorSpec2   equ 256
ataidReserved5     equ 320
   
; IDE Status Register Bits
IdeCmdReg_R_Status_BSY  equ 80h ; Bit 7
IdeCmdReg_R_Status_DRDY equ 40h ; Bit 6
IdeCmdReg_R_Status_DWF  equ 20h ; Bit 5
IdeCmdReg_R_Status_DSC  equ 10h ; Bit 4
IdeCmdReg_R_Status_DRQ  equ 08h ; Bit 3
IdeCmdReg_R_Status_CORR equ 04h ; Bit 2
IdeCmdReg_R_Status_IDX  equ 02h ; Bit 1
IdeCmdReg_R_Status_ERR  equ 01h ; Bit 0

; ATAPI General Configuration Word
ATAPI_Protocol_Type_Mask equ 0C000h ; Bits 15-14
ATAPI_Protocol_Type_is_ATAPI equ 8000h ; Bit 15 is 1 and Bit 14 is 0
ATAPI_Device_Type_Mask equ 1F00h ; Bits 12-8
ATAPI_Device_is_CDROM equ 0500h ; Bit 10 and Bit 8 is 1
ATAPI_Removable_Mask equ 0080h ; Bit 7
ATAPI_CMD_DRQ_Type_Mask equ 0060h ; Bits 6-5
ATAPI_Command_Packet_Size_Mask equ 0003h ; Bits 1-0
ATAPI_Command_Packet_Size_is_12 equ 0
ATAPI_Command_Packet_Size_is_16 equ 1

; ATA/IDE/ATAPI Commands
IDENTIFY_DRIVE equ 0ECh
ATAPI_IDENTIFY_DRIVE  equ 0A1h

 Present segment Para 'code'

		assume CS:Present, DS:Present, ES:Present, SS:Present

;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
;±
;±              PROCEDURE proc_start
;±
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±

proc_start      proc    far

                org 100h
start::                                         
                push ds
                pop es

                mov byte ptr [Command], IDENTIFY_DRIVE

loc_get_ata_drive_IDs:

                call proc_clear_screen

                mov si, offset ID_Table_Header
                call proc_printmsg

                mov word ptr [Port], 1F0h
                mov byte ptr [Drive], 0
                mov word ptr [ID_T_Port], "F1"  ; 1F0h
                mov byte ptr [ID_T_Drive], "0"
                call proc_ata_identify_drive
                mov byte ptr [Drive], 10h ; Drive 1
                mov byte ptr [ID_T_Drive], "1"
                call proc_ata_identify_drive
                mov word ptr [Port], 170h
                mov byte ptr [Drive], 0
                mov word ptr [ID_T_Port], "71"  ; 170h
                mov byte ptr [ID_T_Drive], "0"
                call proc_ata_identify_drive
                mov byte ptr [Drive], 10h ; Drive 1
                mov byte ptr [ID_T_Drive], "1"
                call proc_ata_identify_drive
                cmp byte ptr [Command], ATAPI_IDENTIFY_DRIVE
                je short loc_terminate

                mov byte ptr [Command], ATAPI_IDENTIFY_DRIVE

                mov si, offset Msg_PressAnyKey
                call proc_printmsg

                xor ah, ah
                int 16h

                jmp short loc_get_ata_drive_IDs

loc_terminate:
                int 20h

proc_start      endp

proc_ata_identify_drive proc near

                mov word ptr [ID_T_ATAPI], "IP"

                mov dx, ideCmdReg_R_Status
                add dx, word ptr [Port]

                mov cx, 0FFFFh
loc_read_status_reg_1:
                in al, dx
                and al, ideCmdReg_R_Status_BSY
                jz short loc_write_ide_command_1
                loop loc_read_status_reg_1

loc_device_is_busy:

              ; stc

                retn

loc_write_ide_command_1:
                mov dx, ideCmdReg_W_DriveHead
                add dx, word ptr [Port]
                mov al, byte ptr [Drive]
                or al, 0EFh ; Select Drive via Bit 4
                out dx, al
                mov cx, 0FFFFh
                mov dx, ideCmdReg_R_Status
                add dx, word ptr [Port]
loc_read_status_reg_2:
                in al, dx
                test al, 80h  ; BSY
                jz short loc_drdy_check
                loop loc_read_status_reg_2
                jmp loc_device_is_busy
loc_drdy_check:
                test al, 40h  ; DRDY
                jnz short loc_write_ide_command_2
                cmp byte ptr [Command], 0A1h ; ATAPI IDENTIFY DRIVE Command
                je short loc_write_ide_command_2
                                             ; DRDY is not forced for ATAPI
; loc_drive_is_not_ready:

              ; stc
                retn

loc_write_ide_command_2:
                mov dx, ideCmdReg_W_Command
                add dx, word ptr [Port]
                mov al, byte ptr [Command]
                out dx, al
                mov cx, 0FFFFh
                mov dx, ideCmdReg_R_Status
                add dx, word ptr [Port]
loc_read_status_reg_3:
                in al, dx
                test al, 80h ; BSY bit
                jnz short pass_drq_err_check
                test al, 01h ; ERR bit
                jnz short loc_ata_ide_io_error
                test al, 08h  ; DRQ bit
                jnz short loc_read_data_reg_0
pass_drq_err_check:
                loop loc_read_status_reg_3

              ; and al, 80h
              ; jnz short loc_device_is_busy

              ; Some ATA Disks return BSY without ERR for ATAPI commands.

; loc_ATAPI_COMMAND_failed:
              ; stc
                retn

loc_read_data_reg_0:
                mov dx, ideCmdReg_R_Data
                add dx, word ptr [Port]
                mov cx, 100h
                mov di, offset ParametersBuffer
                push di
loc_read_data_reg_1:
                in ax, dx
                stosw
                loop loc_read_data_reg_1
                pop si

                mov ax, word ptr [SI]  ; General Configuration Word
                push ax
                call proc_hex_double   ; Input -> AX= Binary
                                       ; Output -> DX:AX= 4 bytes ASCII
                mov word ptr [ID_T_ConfigWh], dx
                mov word ptr [ID_T_CONFIGWh]+2, ax
                pop ax
                mov cx, 10h
                mov di, offset ID_T_ConfigWb
                call proc_binary_string ; Input -> AX= Binary
                                        ;          CX= Character Count
                                        ;          ES:DI= Destination
                                        ; Output -> Binary String at ES:DI
                mov cx, 10
                push si
                add si, ataidSerialNo
                mov di, offset ID_T_Serial
loc_get_serialno:
                lodsw
                xchg al,ah  ; Ata/Atapi devices SWAP bytes of an ASCII field.
                stosw
                loop loc_get_serialno
                pop si

                push si
                mov cx, 4
                add si, ataidFirmwareRev
                mov di, offset ID_T_Firmware
loc_get_firmwarerev:
                lodsw
                xchg al,ah  ; Ata/Atapi devices SWAP bytes of an ASCII field.
                stosw
                loop loc_get_firmwarerev
                pop si

                mov cx, 20
                add si, ataidModelName
                mov di, offset ID_T_Model
loc_get_modelname:
                lodsw
                xchg al,ah  ; Ata/Atapi devices SWAP bytes of an ASCII field.
                stosw
                loop loc_get_modelname

                mov si, offset ID_Table
                cmp byte ptr [ParametersBuffer]+1, 80h ; Is it ATAPI device ?
                jnb short loc_print_ID_Table
                mov word ptr [ID_T_ATAPI], 2020h

                call proc_printmsg
              ; clc
                retn

loc_ata_ide_io_error:
              ; stc
                retn

loc_print_ID_Table:
                mov cx, offset end_of_table
                sub cx, si
loc_print_table_cx:
                lodsb                        ; Load byte at DS:SI to AL
                mov     AH,0Eh
		mov     BX,07h             
                int     10h                  ; BIOS Service func ( ah ) = 0Eh
                                             ; Write char as TTY
                                             ;AL-char BH-page BL-color
                loop    short loc_print_table_cx           

             ;  Some ATA/ATAPI devices return ZERO in SERIAL NUMBER field.
             ;  Above instructions are used for preventing STOP due to al=0.
             ;  Otherwise, 'call proc_printmsg' would be used.

                retn

proc_ata_identify_drive endp

proc_clear_screen proc near

                mov ah, 0Fh 
                int 10h
                mov ah, 0
                int 10h

                retn

proc_clear_screen endp

proc_printmsg   proc near
loc_print:          
                lodsb                        ; Load byte at DS:SI to AL
		and     AL,AL            
                je      short loc_return     ; If AL = 00h then return
		mov     AH,0Eh                  
		mov     BX,07h             
                int     10h                  ; BIOS Service func ( ah ) = 0Eh
                                             ; Write char as TTY
                                             ;AL-char BH-page BL-color
		jmp     short loc_print           
loc_return:
		retn

proc_printmsg   endp

;'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''';
; From binary (word) to hexadecimal (character) converter    ;
;                                                            ;
; input -> AX = word (binary number) to be converted         ;
; output -> DX = First 2 characters of hexadecimal number    ;
; output -> AX = Last 2 characters of hexadecimal number     ;
;                                                            ;
; (c) Erdogan Tan  [ 28/1/2002 ]                             ;
;............................................................;

proc_hex_double  proc    near

                 push cx
                 xor dx, dx
                 mov cx, 10h
                 div cx      ; Q in AX, R in DX (DL)
                 xchg dh, dl ; DH= 0, R in DL <- CX= 10h 
                 push dx     ; R in DH, DL= 0
                 xor dh, dh
                 div cx
                 push dx     ; R in DL, DH= 0, AX <= FFh
                 div cl      ; AX <= 0Fh
                             ; R in AH, Q in AL, AL (Q) is 0
                 push ax
                 pop dx      ; High Word Characters is in DX

                 pop cx      ; R in CL
                 pop ax      ; R in AH, AL = 0
                 or al, cl
                 
                 or DX,'00'

                 cmp DL,'9'
                 jna short pass_cc_dl
                 add DL,7
pass_cc_dl:
                 cmp DH,'9'
                 jna short pass_cc_dh
                 add DH,7
pass_cc_dh:
                 or AX, '00'

                 cmp AL,'9'
                 jna short pass_cc_al
                 add AL,7
pass_cc_al:
                 cmp AH,'9'
                 jna short pass_cc_ah
                 add AH,7
pass_cc_ah:
                 pop cx

                 retn

proc_hex_double  endp

;'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''';
; From binary (word) to binary string (character) converter  ;
;                                                            ;
; input -> AX = word (binary number) to be converted         ;
;          ES:DI = Destination Address                       ;
;                                                            ;
; (c) Erdogan Tan  [ 28/1/2002 ]                             ;
;............................................................;

proc_binary_string  proc    near

                 ; push ax
                 push bx
                 mov bx,ax
loc_write_bin_char:
                 shl bx,1
                 jc short loc_bin_str_write_1
                 mov al, 30h
loc_bin_str_stosb:
                 stosb
                 loop loc_write_bin_char

                 pop bx
                 ; pop ax
                 ; clc
                 retn

loc_bin_str_write_1:
                 mov al, 31h
                 jmp short loc_bin_str_stosb

proc_binary_string endp


Command         db 0
Port            dw 0
Drive           db 0

ParametersBuffer:
                dw 256 dup(0)

Msg_PressAnyKey:
                db 0Dh, 0Ah
                db "Press any key to continue ..."
                db 0Dh, 0Ah, 0

ID_Table_Header:
                db 7
                db 0Dh, 0Ah
                db "ATA/ATAPI IDENTIFY DRIVE COMMAND OUTPUT  [ (c) Erdogan TAN 2002 ]"
                db 0Dh, 0Ah, 0
ID_Table:
                db 0Dh, 0Ah
                db "Port               : "
ID_T_Port:      
                db "1F0h"
                db 0Dh, 0Ah
                db "Drive              : "
ID_T_Drive:     
                db "0"
                db 0Dh, 0Ah
                db "Type               : ATA"
ID_T_ATAPI:     
                dw 2020h
                db 0Dh, 0Ah
                db "Serial Number      : "
ID_T_Serial:
                db 20 dup(20h)
                db 0Dh, 0Ah
                db "Firmware Revision  : "
ID_T_Firmware:
                db 8 dup(20h)
                db 0Dh,0Ah
                db "Model Name         : "
ID_T_Model:
                db 40 dup(20h)
                db 0Dh, 0Ah
                db 0Dh, 0Ah
                db "Configuration Word : "
ID_T_ConfigWh:  
                dd 20202020h
                db "h  [ "
ID_T_ConfigWb:  
                db 16 dup(20h)
                db "b ]"
                db 0Dh, 0Ah
end_of_table:
                db 0Dh, 0Ah,0

Present         ends

                end  start
