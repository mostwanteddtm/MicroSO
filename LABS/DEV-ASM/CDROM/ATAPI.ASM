;=========================================================; 
; Ata_Atapi                                      11/12/03 ; 
;---------------------------------------------------------; 
; DOS EXTREME OS V0.01                                    ; 
; by Craig Bamford.                                       ; 
;                                                         ; 
; ATA/ATAPI functions.                                    ;                           
;=========================================================; 
 
 
 
 ;----------------------------------------------------; 
 ; GetAtaPiDrive      ; Gets the Ata/Atapi drive info ; 
 ;----------------------------------------------------; 
 ;                                                    ; 
 ;   Input:                                           ; 
 ;          none.                                     ; 
 ;  Output:                                           ; 
 ;          Puts drive info in vals:                  ; 
 ;                                             (100%) ; 
 ;....................................................; 
 
GetAtaPiDrive: 
        mov   byte [Drive_num],0                        ; 0 the variable called " Drive_num ". 
        mov   byte [command],0xec                       ; Put the hex number for IDENTIFY DRIVE in the var "command". 
drive_id: 
        mov   word [port],0x1f0                         ; Try port 1f0 . 
        mov   byte [drive],0x00                         ; Try master drive 0 (bit 5 should be 0). 
 
        call  AtaPi_Id_Drive                            ; Call proc,if no error we have a ata/atapi address. 
               
        mov   word [port],0x1f0                         ; Try port 1f0 . 
        mov   byte [drive],0x10                         ; Try slave drive 1 (bit 5 should be 1,so we put 0x10 bin 10000b) . 
 
        call  AtaPi_Id_Drive                            ; Call proc,if no error we have a ata/atapi address. 
               
        mov   word [port],0x170                         ; Try port 170 . 
        mov   byte [drive],0x00                         ; Try master drive 0 (bit 5 should be 0). 
                
        call  AtaPi_Id_Drive                            ; Call proc,if no error we have a ata/atapi address. 
             
        mov   word [port],0x170                         ; Try port 170 . 
        mov   byte [drive],0x10                         ; Try slave drive 1 (bit 5 should be 1,so we put 0x10 bin 10000b) . 
                
        call  AtaPi_Id_Drive                            ; Call proc,if no error we have a ata/atapi address. 
                
        cmp  byte[command],0xA1                         ; Have we been here before, yes then lets go! 
        je   Lets_go                        
                                      
        mov  byte[command],0xA1                         ; Put the hex number for ATAPI IDENTIFY DRIVE in the var "command". 
        jmp  drive_id 
              
Lets_go: 
                
        ret 
 
 
 ;----------------------------------------------------; 
 ; AtaPi_Id_Drive                                     ; 
 ;----------------------------------------------------; 
 
AtaPi_Id_Drive: 
          
        mov   dx,0x7 
        add   dx,word [port] 
        mov   cx,0xffff 
 
StatusReg1:                                   
        in    al,dx 
        and   al,0x80     
        jz    WriteCommand1          
        loop  StatusReg1 
                 
        jmp   DeviceBusy              
WriteCommand1:                                
        mov   dx,0x6          
        add   dx,word [port] 
        mov   al,byte [drive]        
        or    al,0xef 
        out   dx,al 
        mov   cx,0xffff 
        mov   dx,0x7 
        add   dx,word [port]  
         
StatusReg2:                                   
        in    al,dx 
        test  al,0x80            
        jz    Drdy_check                  
        loop  StatusReg2  
 
        jmp   DeviceBusy 
Drdy_check:   
        test  al,0x40 
        jnz   WriteCommand2 
        cmp   byte[command],0xA1 
        je    WriteCommand2  
                     
DeviceBusy:      
 
        stc 
        ret 
 ;----------------------------------------------------; 
 ;  WriteCommand2                                     ; 
 ;----------------------------------------------------; 
 
WriteCommand2:                                
        mov   dx,0x7            
        add   dx,word [port] 
        mov   al,byte [command]       
        out   dx,al 
        mov   cx,0xffff 
        mov   dx,0x7 
        add   dx,word [port]  
        
StatusReg3:  
        in    al,dx  
        test  al,0x80 
        jnz   DrqErrorCheck1          
        test  al,0x01 
        jnz   error 
        test  al,0x08  
        jnz   Read_data_reg_0     
 
        stc 
        ret 
 ;----------------------------------------------------; 
 ; DrqErrorCheck                                      ; 
 ;----------------------------------------------------; 
 
DrqErrorCheck1:           
        push  cx 
        mov   cx,0xFFFF 
busy_delay123: 
        nop 
        nop 
        nop 
        nop 
        nop 
        nop 
        nop 
        nop 
        loop  busy_delay123 
 
        pop   cx 
        loop  StatusReg3 
 
error: 
        stc 
        ret 
 ;----------------------------------------------------; 
 ; Read data reg              (& move it into buffer) ; 
 ;----------------------------------------------------; 
 
                   
Read_data_reg_0:                                                   
        mov   dx,0              
        add   dx,word [port] 
        mov   cx,0x100 
        mov   di,Temp_Buffer 
                 
Read_data_reg_1: 
        in    ax,dx                                                         
        stosw 
        loop  Read_data_reg_1              
 ;----------------------------------------------------; 
 ; Label drive C                                      ; 
 ;----------------------------------------------------; 
        cmp   word[HdPort1],0 
        jne   ItsAcd_1 
         
        mov   dx,word [port] 
        mov   word[HdPort1],dx 
 
        mov   al,byte [drive] 
        mov   byte[HdDrive1],al  
        jmp   Byby  
ItsAcd_1: 
        cmp   word[CdPort1],0 
        jne   Byby 
        mov   dx,word [port] 
        mov   word[CdPort1],dx 
 
        mov   al,byte [drive] 
        mov   byte[CdDrive1],al  
             
Byby: 
       ; mov   al,[Drive_num]  
       ; mov   ah,0xe 
	;int   0x10  
               
        clc 
        ret 
 
 
 ;----------------------------------------------------; 
 ; Small Delay                                        ; 
 ;----------------------------------------------------; 
 
Small_Delay: 
        push  cx 
        mov   cx,0x0ffff 
BusyDelay3a:                                   
        nop 
        nop 
        nop 
        nop 
        nop 
        nop 
        nop 
        nop 
        loop  BusyDelay3a 
        pop   cx 
        ret   
      
 ;----------------------------------------------------; 
 ; Send Atapi Packet                                  ; 
 ;----------------------------------------------------; 
 ;                                                    ; 
 ;   Input:                                           ; 
 ;          esi, points to 12 byte packet.            ; 
 ;  Output:                                           ; 
 ;          none                                      ; 
 ;                                             (100%) ; 
 ;....................................................; 
Send_Atapi_Packet: 
              
        mov   dx,0x7                                    ; Read Status = 7 
        add   dx,word [port]                            ; Add the base 
        mov   cx,0xffff                                 ; Mov cx, number of loops 
StatusReg1_1:                                   
        in    al,dx                                     ; Mov data from port to al 
        and   al,0x80                                   ; Check bit 7(busy bit) ,loop if not 0 
        jz    WriteCommand1_1                           ; Jump to WriteCommand1_1 if al bit7 =0 
        loop  StatusReg1_1                              ; If al bit 7 =1,loop StatusReg1_1 
        jmp   DeviceBusy_1                              ; time out:-( 
WriteCommand1_1:                                
        mov   dx,0x6                                    ; Write Drivehead register = 6         
        add   dx,word [port]                            ; Add to base 
        mov   al,byte [drive]                           ; Bit 4 ,0 to select primary drive, 1 to select secondary drive 
        or    al,0xef                                   ; What is bit 4 ? 
        out   dx,al                                     ; Write al to port (register) 
        mov   cx,0xffff                                 ; Mov cx, number of loops 
        mov   dx,0x7                                    ; Read status = 7 
        add   dx,word [port]                            ; Add the base 
StatusReg2_1:                                   
        in    al,dx                                     ; Mov data from port to al 
        and   al,0x80                                   ; Check bit 7(busy bit) ,loop if not 0 
        jz    WriteCommand2_1                           ; Jump to WriteCommand2_1 if al bit7 =0 
        loop  StatusReg2_1                              ; If al bit 7 =1,loop StatusReg2_1 
DeviceBusy_1:                                           ; time out:-( 
        stc                                             ; Set the carry flag to 1 
        ret                                    
 
 ;----------------------------------------------------; 
 ; Write Command                                      ; 
 ;----------------------------------------------------;  
 
WriteCommand2_1:                                
        mov   dx,0x7                                    ; Write Command = 7           
        add   dx,word [port]                            ; Add base 
        mov   al,byte [command]                         ; Add the 8 bit code to al 
        out   dx,al                                     ; Write al to port (register) 
        mov   cx,0xffff                                 ; Mov cx, number of loops 
        mov   dx,0x7                                    ; Read status = 7 
        add   dx,word [port]                            ; Add the base 
StatusReg3_1:                                  
        in    al,dx                                     ; Mov data from port to al 
        test  al,0x80                                   ; Does bit 7 = 0 (busy bit) 
        jnz   DrqErrorCheck1_1                          ; Jump to "DrqErrorCheck1_1" if bit7 is 1 
        test  al,0x01                                   ; Does bit 0 = 0 (error bit) 
        jnz   error_1                                   ; Jump to "error_1" if bit0 is 1       
        test  al,0x08                                   ; Does bit3 = 0 (DRQ bit) 
        jnz   WriteCommandPacket1_1                     ; Jump to label if bit3 is 1,we can transfer data to port:-)  
DrqErrorCheck1_1:                               
        loop  StatusReg3_1                              ; Loop label 
        jmp   DeviceBusy_1                              ; Time out:-( 
 ;----------------------------------------------------; 
 ; Write Command Packet                               ; 
 ;----------------------------------------------------;  
 
WriteCommandPacket1_1:                          
        mov   dx,0x0                                    ; Read date/write = 0               
        add   dx,word [port]                            ; Add the base 
        mov   si,packet                                 ; Point esi to how 12 byte packet 
        xor   cx,cx                                     ; 0 cx   
        mov   cx,6                                      ; Mov number of words to mov into cx 
WritePacket1_1:                                 
        lodsw                                           ; Mov a word from packet to ax, inc esi 2 
        out   dx,ax                                     ; Write ax to port (register) 
        loop  WritePacket1_1                            ; Loop label 
 
        mov   cx,0xffff                                 ; Mov cx, number of loops 
        mov   dx,0x7                                    ; Read status = 7  
        add   dx,word [port]                            ; Add the base 
StatusReg4_1:                                  
        in    al,dx                                     ; Mov data from port to al 
        test  al,0x80                                   ; Does bit 7 = 0 (busy bit) 
        jnz   DrqErrorCheck2_1                          ; Jump to "DrqErrorCheck2_1" if bit7 is 1 
        test  al,0x1                                    ; Does bit 0 = 0 (error bit) 
        jnz   error_1                                   ; Jump to "error_1" if bit0 is 1 
                 
        clc                                             ; Clear the carry flag 
        ret 
 
 ;----------------------------------------------------; 
 ; Drq Error Check                                    ; 
 ;----------------------------------------------------;  
 
DrqErrorCheck2_1:                              
        push  cx                                        ; Save old cx 
        mov   cx,0xffff                                 ; Put 65535 in new cx 
BusyDelay_1:                                            ; Label 
        nop                                             ; Do a null operation(xchg ax,ax) 
        nop                                             ; Do a null operation(xchg ax,ax) 
        nop                                             ; Do a null operation(xchg ax,ax) 
        nop                                             ; Do a null operation(xchg ax,ax) 
        nop                                             ; Do a null operation(xchg ax,ax) 
        nop                                             ; Do a null operation(xchg ax,ax) 
        nop                                             ; Do a null operation(xchg ax,ax) 
        nop                                             ; Do a null operation(xchg ax,ax) 
        loop  BusyDelay_1                               ; Loop label 
        
        pop   cx                                        ; Get old cx 
        loop  StatusReg4_1                              ; Loop label 
        jmp   DeviceBusy_1                              ; Time out 
error_1: 
        stc                                             ; Set the carry flag to 1 
                                             
        ret 
 
 
 
 ;----------------------------------------------------; 
 ; Play cd                                            ; 
 ;----------------------------------------------------; 
 
Play_cd: 
        push  di 
 
        call  Clear_atapi_packet 
        mov   di,packet 
        mov   byte[es:di+8],0xff 
        mov   byte[es:di+7],0xff 
        mov   byte[es:di+5],0xff 
        mov   byte[es:di+4],0xff 
        mov   byte[es:di+3],0xff 
        mov   byte[es:di+2],0xff 
        mov   byte[es:di+0],0x45 
        call  Send_Atapi_Packet 
 
        pop   di 
 
        ret    
 
 ;----------------------------------------------------; 
 ; Clear atapi packet                                 ; 
 ;----------------------------------------------------; 
 
Clear_atapi_packet: 
        push  di 
        push  cx 
        push  ax 
        mov   di,packet 
        mov   cx,12 
        xor   al,al 
                 
        rep   stosb 
                
        pop   ax 
        pop   cx 
        pop   di 
 
        ret 
 
 ;----------------------------------------------------; 
 ; Stop cd                                            ; 
 ;----------------------------------------------------; 
Stop_cd: 
        push  di 
 
        call  Clear_atapi_packet 
        mov   di,packet 
        mov   byte[es:di+4],0x0 
        mov   byte[es:di+1],0x1 
        mov   byte[es:di+0],0x1b 
                 
        call  Send_Atapi_Packet 
 
        pop   di 
 
        ret    
 
 ;----------------------------------------------------; 
 ; Pause cd                                           ; 
 ;----------------------------------------------------; 
 
Pause_cd: 
        push  di 
 
        call  Clear_atapi_packet 
        mov   di,packet 
                 
        mov   byte[es:di+8],0x0                
        mov   byte[es:di+0],0x4b 
                 
        call  Send_Atapi_Packet 
 
        pop   di 
 
        ret    
 
 ;----------------------------------------------------; 
 ; Start cd                                           ; 
 ;----------------------------------------------------; 
 
Start_cd: 
        push  di 
 
        call  Clear_atapi_packet 
        mov   di,packet 
        mov   byte[es:di+4],0x1 
        mov   byte[es:di+1],0x1 
        mov   byte[es:di+0],0x1b 
                 
        call  Send_Atapi_Packet 
 
        pop   di 
 
        ret    
 
 
 ;----------------------------------------------------; 
 ; Eject cd                                           ; 
 ;----------------------------------------------------; 
 
Eject_cd: 
        push  di 
 
        call  Clear_atapi_packet 
        mov   di,packet 
        mov   byte[es:di+4],0x2 
        mov   byte[es:di+1],0x1 
        mov   byte[es:di+0],0x1b 
                 
        call  Send_Atapi_Packet 
 
        pop   di 
 
        ret    
 
 ;----------------------------------------------------; 
 ; Close cd                                           ; 
 ;----------------------------------------------------; 
 
Close_cd: 
        push  di 
 
        call  Clear_atapi_packet 
        mov   di,packet 
        mov   byte[es:di+4],0x3 
        mov   byte[es:di+1],0x1 
        mov   byte[es:di+0],0x1b 
                 
        call  Send_Atapi_Packet 
 
        pop   di 
 
        ret  
   
 
 ;--------------------------------------------------------------------------------------------; 
 ;                                           Data                                             ; 
 ;--------------------------------------------------------------------------------------------; 
 
include 'Atapi_info.inc' 
 
command:         db 0 
port:            dw 0 
drive:           db 0 
AtapiError       db 0 
;ATAPIorNot      db 0   
Drive_num:       db 0 
 
HdDrive1:        db 0 
HdPort1:         dw 0 
 
CdDrive1:        db 0 
CdPort1:         dw 0 
 
 
packet: 
		db 0x0                      
		db 0x0                     
		db 0x0                      
		db 0x0                      
                db 0x0                     
		db 0x0                      
		db 0x0 
		db 0x0                      
		db 0x0                     
		db 0x0 
		db 0x0 
		db 0x0 
 
Temp_Buffer rw  256 