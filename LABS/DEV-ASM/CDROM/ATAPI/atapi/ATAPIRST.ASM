; *****************************************************************************
;
; ATAPIRST.ASM [ ATAPI device I/O code draft - ATAPI SOFT RESET Command ]
; Copyright (C) 2002  Erdogan TAN  [ 20/11/2002 ]
; (Based on ATAID.ASM by Erdogan Tan & ATAPI Specification SFF-8020i Rev. 2.6)
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

; IDE Status Register Bits
IdeCmdReg_R_Status_BSY  equ 80h ; Bit 7
IdeCmdReg_R_Status_DRDY equ 40h ; Bit 6
IdeCmdReg_R_Status_DWF  equ 20h ; Bit 5
IdeCmdReg_R_Status_DSC  equ 10h ; Bit 4
IdeCmdReg_R_Status_DRQ  equ 08h ; Bit 3
IdeCmdReg_R_Status_CORR equ 04h ; Bit 2
IdeCmdReg_R_Status_IDX  equ 02h ; Bit 1
IdeCmdReg_R_Status_ERR  equ 01h ; Bit 0

; [ ATA Commands ]

; ATA PACKET INTERFACE Command
; ATAPI_PKT_COMMAND equ 0A0h ; Mandatory
; ATAPI_IDENTIFY_DRIVE equ 0A1h ; Mandatory
ATAPI_SOFT_RESET equ 08h ; Mandatory
; ATAPI_SERVICE equ A2h    ; Optional

; [ ATAPI Pkt Commands - as a parameter of ATA Command A0h ]
ATAPI_START_STOP_UNIT equ 1Bh ; Operation Code

 Present segment Para 'code'

		assume CS:Present, DS:Present, ES:Present, SS:Present

;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
;±
;±              PROCEDURE proc_start
;±
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±

proc_start      proc    far

                org 100h
start:                                         
                push ds
                pop es

                mov byte ptr [Command], ATAPI_SOFT_RESET

loc_inq_atapi_drive:

                call proc_clear_screen

                mov word ptr [Port], 1F0h
                mov byte ptr [Drive], 0
                mov word ptr [ATAPI_RESET_T_Port], "F1"  ; 1F0h
                mov byte ptr [ATAPI_RESET_T_Drive], "0"
                call proc_atapi_soft_reset

                jc short pass_1F0_0

                mov si, offset ATAPI_RESET_Table_Header
                call proc_printmsg

                xor ah, ah
                int 16h

pass_1F0_0:
                mov byte ptr [Drive], 10h ; Drive 1
                mov byte ptr [ATAPI_RESET_T_Drive], "1"
                call proc_atapi_soft_reset

                jc short pass_1F0_1

                mov si, offset ATAPI_RESET_Table_Header
                call proc_printmsg

                xor ah, ah
                int 16h

pass_1F0_1:
                mov word ptr [Port], 170h
                mov byte ptr [Drive], 0
                mov word ptr [ATAPI_RESET_T_Port], "71"  ; 170h
                mov byte ptr [ATAPI_RESET_T_Drive], "0"
                call proc_atapi_soft_reset

                jc short pass_170_0

                mov si, offset ATAPI_RESET_Table_Header
                call proc_printmsg

                xor ah, ah
                int 16h

pass_170_0:
                mov byte ptr [Drive], 10h ; Drive 1
                mov byte ptr [ATAPI_RESET_T_Drive], "1"
                call proc_atapi_soft_reset

                jc short loc_terminate

                mov si, offset ATAPI_RESET_Table_Header
                call proc_printmsg

loc_terminate:
                int 20h

proc_start      endp

proc_atapi_soft_reset proc near

                mov dx, ideCmdReg_R_Status
                add dx, word ptr [Port]

                mov cx, 0FFFFh
loc_write_command_1:
                mov dx, ideCmdReg_W_DriveHead
                add dx, word ptr [Port]
                mov al, byte ptr [Drive]
                or al, 0EFh ; Select Drive via Bit 4
                out dx, al
loc_write_command_2:
                mov dx, ideCmdReg_W_Command
                add dx, word ptr [Port]
                mov al, byte ptr [Command]
                out dx, al
                mov cx, 0FFFFh
                mov dx, ideCmdReg_R_Status
                add dx, word ptr [Port]
loc_read_status_reg:
                in al, dx
                test al, 80h ; BSY bit
                jnz short loc_busy_loop
                test al, 01h ; ERR bit
                jnz short loc_error
                clc
                retn
loc_busy_loop:
                loop loc_write_command_1
loc_error:
                stc
                retn

proc_atapi_soft_reset endp

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

Command:        db 0
Port:           dw 0
Drive:          db 0

ATAPI_RESET_Table_Header:
                db 7
                db 0Dh, 0Ah
                db "ATAPI SOFT RESET COMMAND OUTPUT  [ ¸ Erdogan Tan 2002 ]"
                db 0Dh, 0Ah
ATAPI_RESET_Data_Table:
                db 0Dh, 0Ah
                db "I/O Port                    : "
ATAPI_RESET_T_Port:
                db "1F0h"
                db 0Dh, 0Ah
                db "Drive                       : "
ATAPI_RESET_T_Drive:
                db "0"
                db 0Dh, 0Ah
                db 0Dh, 0Ah
                db "CD-ROM Drive SOFT RESET operation has been completed..."
                db 0Dh, 0Ah
                db 0Dh, 0Ah
                db "(Press any key to continue...)"
                db 0Dh, 0Ah
end_of_table:
                db 0Dh, 0Ah,0

Present         ends

                end  start
