;****************************************
;*                                      *
;*         Simple Tutorial              *
;*      Mouse Driver Program            *
;*      Author: Yu.I.Petrenko           *
;*                                      *
;****************************************
.286
cd segment
assume cs:cd,ds:cd,es:cd,ss:nothing
   ORG 100h
start:  JMP BEG
;=========================================================
;program data
;---------------------------------------------------------
Message1      DB        0Ah,0Dh
              DB        'The driver is already loaded',0Ah,0Dh
              DB        0Ah,0Dh,'$'
Message2      DB        0Ah,0Dh
              DB        'The tutorial driver is now installed',0Ah,0Dh
              DB        0Ah,0Dh,'$'
Old_0C_Off    DW   0    ;old interrupt 0Ch vector
Old_0C_Seg    DW   0    ;
Old_33_Off    DW   0    ;old interrupt 33h vector
Old_33_Seg    DW   0    ;
VeryOldIMR    DB   0    ;PIC mask register value
OldIMR        DB   0    ;the same
OVERR         DB   0    ;data lost
Data_Reg      DW   3F8h ;register of data and
                        ;and of rate low byte
Int_Contr_Reg DW   3F9h ;register of interrupt control
                        ;and of rate high byte
Int_ID_Reg    DW   3FAh ;interrupt ID register
L_Contr_Reg   DW   3FBh ;line control register
Mod_CONTR     DW   3FCh ;modem control register
L_Status_Reg  DW   3FDh ;line status register
Buf_Counter   DW   0    ;mouse buffer counter
RESID         DB   0    ;resident flag
NB            DB   0    ;byte number
Buff1         DB  'Buffer1'; Mouse work buffer
Buttons       DB   1    ;button condition
DELTA_X       DB   0    ;X increment
DELTA_Y       DB   0    ;Y increment
;*********************************************************
BEG:    ;The program start
;=========================================================
; COM1 port initialization
;---------------------------------------------------------
;First check for being already loaded
        MOV AX,CS
        MOV DS,AX
PUSH BP         ;register storing
 PUSH AX
  PUSH BX
   PUSH CX
    PUSH DX
     PUSH ES

     IN AL,21h          ;storing of IMR initial value
     MOV VeryOldIMR,AL
     OR AL,10h  ;masking of COM1 interrupt - IRQ4
                ;for IRQ4 to be prohibited surely
     OUT 21h,AL
;now the program checks, if it is loaded before
     MOV AL,0Ch
     MOV AH,35h ;get Int 0Ch vector in ES:BX
     INT 21h
     MOV AX,CS:L_Status_Reg
     MOV CX,ES:L_Status_Reg
     CMP CX,AX  ;if couincide,then the same program
                ;already loaded
     JNZ T ; no, first load

qq:  STI   ;yes, the same program already loaded,
           ;go away
        MOV     AH,9
        LEA     DX,Message1     ;Type $-string
        INT     21h
     MOV AL,OldIMR ;set old interrupt flags
     OUT 21h,AL    ;IRQ4 permitted
     POP ES     ;register restoring
    POP DX
   POP CX
  POP BX
 POP AX
POP BP
    JMP EXIT ; without reloading twice
;---------------------------------------------------------
T:      ;the very first driver loading
        MOV     AH,9
        LEA     DX,Message2     ;Type $-string
        INT     21h
     MOV RESID,1  ;set resident flag
     MOV Old_0C_off,BX  ;Store ES:BX as old Int 0Ch vector
     MOV Old_0C_seg,ES
     MOV DX, offset Int_0Ch
     MOV AL,0Ch
     MOV AH,25h
     INT 21h ;Set as new Int 0Ch vector the own one
     MOV AL,33h
     MOV AH,35h ;Get old Int 33h vector in ES:BX
     INT 21h
     MOV Old_33_off,BX  ;store it
     MOV Old_33_seg,ES
     MOV DX, offset Int_33h
     MOV AL,33h
     MOV AH,25h  ;set  the own vector
     INT 21h     ;as Int 33h pointer
     PUSH CS
     POP DS
     CLI         ;interrupts forbidden
     IN AL,21h   ;read 1-st interrupt controller IMR
     AND AL,0EFh ;clear it's 4-th bit
     MOV OldIMR,AL;store it value
     OUT 21h,AL  ;now COM1 interrupt permitted
;now is the serial port's turn

     MOV DX,L_Contr_Reg ;3FBh = line control register
     IN AL,DX
     OR AL,80h   ;set DLAB bit for rate divider
                 ;word enabling to send
     OUT DX,AL

     MOV DX,Data_Reg;3F8h = data control register
     MOV AL,60h
     OUT DX,AL   ;low byte for 1200 baud rate

     MOV DX,Int_Contr_Reg ;now DX=3F9h, interrupt control
        ;and high rate byte register
     XOR AX,AX
     OUT DX,AL   ;the high rate byte for 1200 baude rate

     MOV DX,L_Contr_Reg ;3FBh - line control register
     MOV AL,2    ; 7 bits, 1 stop-bit, no parity
     OUT DX,AL   ;done

     MOV DX,Int_Contr_Reg;3F9h=interrupt control register
     MOV AL,1  ;receiving enable
     OUT DX,AL
     JMP $+2
     jMP $+2    ;delay

     MOV DX,Mod_CONTR  ;3FCh = modem control register
     MOV AL,0Bh  ;set DTR,RTS and OUT2 bits
     OUT DX,AL
     STI         ;interrupts permitted

     MOV DX,Data_Reg ;Data register address
     IN AL,DX    ;read it for to clear the input buffer

     MOV AL,OldIMR ; 1-st interrupt controller IMR
     OUT 21h,AL    ; restored

     POP ES         ;register restoring
    POP DX
   POP CX
  POP BX
 POP AX
POP BP
     jmp EXIT ;initialisation end, driver already works
;=========================================================
;Interrupt 33h handler
;---------------------------------------------------------
Int_33h:
 CMP SI,7373h  ;checking the parole
 JZ M0         ;well, can go
 IRET          ; with strangers nothing to do
M0:
   PUSH BP    ;register storing
    PUSH DS
     PUSH ES
      PUSH DI
       PUSH SI
        PUSH CS
        POP DS
;---------------------------------------------------------
; Interrupt 33h function switch
;---------------------------------------------------------
    CMP AL,0
    JNZ M1
    JMP M_Status
M1:
       CMP AL,3
       JNZ M2
       JMP M_Position
M2:
       CMP AL,0Bh
       JNZ M3
       JMP M_Motion
M3:
       CMP AL,15h
       JNZ M4
       JMP M_Memory
M4:
       CMP AL,16h
       JNZ M5
       JMP Status_Save
M5:
       JMP OLD_33
;---------------------------------------------------------
; Int 33h function implemention
;---------------------------------------------------------
 M_Status:
;Expects: AX=0;
;Returns: AX=0 - not installed; AX=0FFFFh - installed;
;         BX= 0FFFFh - two buttons;
;             00     - other, then two;
;             02     - two buttons;
;             03     - "Mouse System" 3 buttons
   MOV AX,0FFFFh
   MOV BX,0FFFFh
   JMP NEW_33
;---------------------------------------------------------
 M_Position:
;Expects: AX=03h;
;Returns: Bit 0=1 - left   button pressed;  CX = column;
        ; Bit 1=1 - right  button pressed;  DX = row;
        ; Bit 2=1 - middle button pressed;
    XOR BH,BH
    MOV BL,Buttons
    XOR CX,CX
    XOR DX,DX
    JMP NEW_33
;---------------------------------------------------------
 M_Motion:
;Expects: AX=0Bh;
;Returns: CX = gorisontal steps count;
        ; DX = vertical   steps count;
MOV al, DELTA_X
CBW
MOV CX,AX
MOV al, DELTA_Y
MOV DELTA_X,0
CBW
MOV DX,AX
MOV DELTA_Y,0
    JMP NEW_33
;---------------------------------------------------------
 M_Memory:
;Expects: AX=15h;
;Returns: BX= buffer size, bytes;
   MOV BX,10h ;asks only 16 bytes
   JMP NEW_33
;---------------------------------------------------------
 Status_Save:
;Expects: AX=16h; ES:DX - buffer pointer;
;Returns: buffer status stored;
    MOV BX,DX
    MOV AX,Old_33_Off
    MOV ES:[BX],AX
    MOV AX,Old_33_Seg
    MOV ES:[BX+2],AX
    JMP NEW_33
;---------------------------------------------------------
OLD_33:    ; call old 33h driver (if any) for other
           ;functions
       POP SI  ;register restoring
      POP DI   ;for old interrupt call
     POP ES
    POP DS
   POP BP
    PUSH Old_33_seg
    PUSH Old_33_off
   RETF ;old interrupt call
;---------------------------------------------------------
NEW_33:    ; out for own-done functions
       POP SI  ;register restoring
      POP DI
     POP ES
    POP DS
   POP BP
    IRET       ;all done
;=========================================================
;Interrupt 0Ch handler
;---------------------------------------------------------
Int_0Ch:
   PUSH BP              ;register storing
    PUSH AX
     PUSH BX
      PUSH CX
       PUSH DX
        PUSH DS
         PUSH ES
          PUSH DI
           PUSH SI
            PUSH CS
            POP DS
                MOV DX,L_Status_Reg;3FD = Line Status Register
                IN AL,DX ;read it
                TEST AL,1; if 1 = data received
                JNZ OBR  ; go to handle the data
OLD_0C:            ; no, something else
           POP SI  ;register restoring
          POP DI
         POP ES
        POP DS
       POP DX
      POP CX
     POP BX
    POP AX
   POP BP
    PUSH Old_0C_seg
     PUSH Old_0C_off
   RETF ; old interrupt call for other cases
;---------------------------------------------------------
OBR:    ;received byte processing
         MOV AX,CS
         MOV DS,AX
         MOV ES,AX

         MOV DX,Int_ID_Reg ;3FAh - interrupt ID register
         IN  AL,DX ;read its status
         AND AL,6
		 CMP AL,04 ;is there somesthing for us?
         JZ REC    ;yes
         JMP OLD_0C;no, call old interrupt handler
 REC:    ;byte receiving
         MOV AL,64h ; mask IRQ4 for not interrupting
         OUT 20h,AL
         MOV DX,Int_ID_Reg ;3FAh - interrupt ID register
         IN AL,DX
         TEST AL,4 ;receive?
         JNZ READ  ;yes,receive byte
         JMP INT_RET ;no,return
;---------------------------------------------------------
 READ: ;read byte from serial port receiving register
         MOV DX,L_Status_Reg ;3FDh = line status register
         IN AL,DX   ;read it
         AND AL,2   ;error?
         MOV OVERR,AL ;set OVERRUN BIT <>0, if symbol lost
         MOV DX,Data_Reg ;3F8h = data register
         IN AL,DX ;clear the receiving register
;---------------------------------------------------------
 WRITE_CH:  ;write the byte into the Mouse buffer
;---------------------------------------------------------
         AND AL,7Fh ; clear the 7-th bit
         TEST AL,40h; is it the first byte?
         JZ B1      ;no
;yes,it is = first byte processing
         XOR BX,BX  ;byte bias in the buffer
         MOV Buff1[BX],AL ;to 0 position
         MOV Buff1[BX+3],0
         MOV NB,1 ;now it equal to 1
 jmp INT_RET ;all done, return
;---------------------------------------------------------
B1:    ; 6-th bit = 0, so not the firsf byte
       ; if NB<>0 then write into buffer, else it is error,
       ; do nothing before the first byte arrives
       XOR BX,BX
       MOV BL,NB  ;byte bias in the buffer
       MOV Buff1[BX],AL;save the byte
       INC BL
       MOV NB,BL
       CMP BL,3 ;if the data packed full?
       JZ BBB   ;yes,go to process it
       MOV BUFF1[3],0 ;no, wait for next byte
jmp INT_RET     ;all done, return
;---------------------------------------------------------
; Mouse information pack handling
;---------------------------------------------------------
BBB:
;---------------------------------------------------------
;                  Buttons status restore
        MOV NB,0    ;read 1-st byte in AL
        MOV AL,BUFF1[0]
        TEST AL,20h ;is left button pressed?
        JZ LB0      ;no
        OR Buttons,1;yes, set "Left button pressed" state
        JMP RB
LB0:
        AND Buttons,0FEh ;set "Left button released" state
RB:                 ; now the right button turn
        TEST AL,10h ;is right button pressed?
        JZ RB0      ; no
        OR Buttons,2;yes, set "Right button pressed" state
        JMP CRD
RB0:
        AND Buttons,0FDh  ;"Right button released"
;---------------------------------------------------------
CRD:              ;Increments handling
;---------------------------------------------------------
; X-coordinate increments
   MOV AL,BUFF1[1]
   AND AL,3Fh  ;clear senior 2 bits
   MOV DELTA_X,AL
   MOV AL,BUFF1[0]
   AND AL,3    ;two senior bits from 0-byte
   SHL AL,6
   OR DELTA_X,AL
;---------------------------------------------------------
; Y-coordinate increments
   MOV AL,BUFF1[2]
   AND AL,3Fh  ;clear senior 2 bits
   MOV DELTA_Y,AL
   MOV AL,BUFF1[0]
   AND AL,0Ch  ;two senior bits from 0-byte
   SHL AL,4
   OR DELTA_Y,AL
;---------------------------------------------------------
;  Reset and exit
;---------------------------------------------------------
 INT_RET:       STI ;interrupts permitted
                MOV AL,OldIMR
                OUT 21h,AL  ;1-st PIC IMR restoring

           POP SI           ;register restoring
          POP DI
         POP ES
        POP DS
       POP DX
      POP CX
     POP BX
    POP AX
   POP BP
   IRET
;---------------------------------------------------------
EXIT:
     CMP RESID,0
     JNZ Q    ;not resident yet?
     JMP ENDD ;yes nothing to do
    Q:      MOV DX,OFFSET zzz ;stay resident
            SHR DX,4
            ADD DX,1;
            MOV AL,0   ;return code
            MOV AH,31h
            int 21h
ENDD:                  ;all done, exit
            MOV AX,4C00h
            int 21h
zzz:        ; program end marker for int 31h
cd ends
end start
;*********************************************************