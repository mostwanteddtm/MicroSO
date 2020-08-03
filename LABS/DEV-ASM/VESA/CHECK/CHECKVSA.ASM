            .MODEL  small
            .STACK                     ;Default 1Kb stack is OK
            .DATA
             
    
EMsg1       DB      'Your system is not VESA compatible.',13,10
VesaInfo    DB      256 dup (?)        ;VESA Video information block  
            .CODE
            .STARTUP
; Check to see if a VESA extended video BIOS is out there. If it is,
; we have a Super VGA card.
     
      mov             ax,seg VesaInfo
      mov             es,ax
      mov             di,offset VesaInfo
      mov             ax,04F00h
      int             10h                             ; Call the VESA video BIOS
      cmp             ax,004Fh
      jne             Error1
      mov             ax,4c00h
      int             21h
            
            
Error1:     MOV     SI,OFFSET EMsg1
            extrn   PrtString:proc
            CALL    PrtString
AllDone:    mov     ax,4c00h
            int     21h


            END
