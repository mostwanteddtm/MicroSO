
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
start:  		JMP 	BEG
;-------------------------------------------------------------------------------------------
;program data
;-------------------------------------------------------------------------------------------
OldIMR        	DB   	0    				;the same 
OVERR         	DB		0    			    ;data lost
Data_Reg      	DW		2F8h 				;register of data and
											;and of rate low byte
Int_Contr_Reg 	DW		2F9h 				;register of interrupt control
											;and of rate high byte
Int_ID_Reg    	DW		2FAh 				;interrupt ID register
L_Contr_Reg   	DW		2FBh 				;line control register
Mod_CONTR     	DW		2FCh 				;modem control register
L_Status_Reg  	DW		2FDh 				;line status register  

QTDEBYTE        DB      0 

BYTES           DB      0
                DB      0
                DB      0
                
EXEC01          DB      0
;*******************************************************************************************
BEG:    ;The program start
;-------------------------------------------------------------------------------------------
; COM1 port initialization
;-------------------------------------------------------------------------------------------
;First check for being already loaded

    			MOV		AX, CS
				MOV 	DS, AX
;-------------------------------------------------------------------------------------------
		
				IN 		AL, 21h				    ;read 1-st interrupt controller IMR
				AND 	AL, 0EFh 			    ;clear it's 4-th bit
				MOV 	OldIMR, AL			    ;store it value
				OUT 	21h, AL  			    ;now COM2 interrupt permitted
											    ;now is the serial port's turn
                                                
				MOV 	DX, L_Contr_Reg 	    ;2FBh = line control register
				IN 		AL, DX                  
				OR 		AL, 80h   			    ;set DLAB bit for rate divider
											    ;word enabling to send
				OUT 	DX, AL                  
                                                
				MOV 	DX, Data_Reg		    ;2F8h = data control register
				MOV 	AL, 60h                 
				OUT 	DX, AL   			    ;low byte for 1200 baud rate
                                                
				MOV 	DX, Int_Contr_Reg 	    ;now DX=2F9h, interrupt control
											    ;and high rate byte register
				XOR 	AX, AX                  
				OUT 	DX, AL   			    ;the high rate byte for 1200 baude rate
                                                
				MOV 	DX, L_Contr_Reg 	    ;2FBh - line control register
				MOV 	AL, 2    			    ;7 bits, 1 stop-bit, no parity
				OUT 	DX, AL   			    ;done
                                                
				MOV 	DX, Int_Contr_Reg	    ;2F9h=interrupt control register
				MOV 	AL, 1  				    ;receiving enable
				OUT 	DX, AL                  
                                                
				MOV 	DX, Mod_CONTR  		    ;2FCh = modem control register
				MOV 	AL, 0Bh  			    ;set DTR,RTS and OUT2 bits
				OUT 	DX, AL
;-------------------------------------------------------------------------------------------
;Interrupt 0Bh handler
;-------------------------------------------------------------------------------------------
Int_0Bh:		MOV 	DX, L_Status_Reg		;2FD = Line Status Register
                IN 		AL, DX 					;read it
                TEST 	AL, 1					;if 1 = data received
                JNZ 	OBR  					;go to handle the data
				JMP		Int_0Bh
;-------------------------------------------------------------------------------------------
OBR:    		;received byte processing
;-------------------------------------------------------------------------------------------
				
				MOV 	AX,	CS
				MOV 	DS,	AX
				MOV 	ES,	AX

				MOV 	DX,	Int_ID_Reg 			;2FAh - interrupt ID register
				IN  	AL,	DX 					;read its status
				AND 	AL,	6
				CMP 	AL,	04 					;is there somesthing for us?
				JZ 		REC    					;yes
				JMP 	Int_0Bh
;-------------------------------------------------------------------------------------------
REC:    		;byte receiving
				MOV 	AL,	64h 				;mask IRQ4 for not interrupting
				OUT 	20h, AL
				MOV 	DX,	Int_ID_Reg 			;2FAh - interrupt ID register
				IN 		AL,	DX
				TEST 	AL,	4 					;receive?
				JNZ 	READ  					;yes,receive byte
				;JMP 	INT_RET 				;no,return  
				JMP     Int_0Bh
;-------------------------------------------------------------------------------------------
READ: 			;read byte from serial port receiving register
;-------------------------------------------------------------------------------------------
				MOV 	DX,	L_Status_Reg 		;2FDh = line status register
				IN 		AL,	DX   				;read it
				AND 	AL,	2   				;error?
				MOV 	OVERR,	AL 				;set OVERRUN BIT <>0, if symbol lost
				MOV 	DX,	Data_Reg 			;2F8h = data register
				IN 		AL,	DX 					;clear the receiving register
				
				CMP     EXEC01, 0
				JNE     CONTEXEC
				INC     EXEC01
				JMP     Int_0Bh
				
CONTEXEC:		CMP     AL, 01010000B
                JE      INT_RET 

				CMP     QTDEBYTE, 0
				JE      ADDBYTE0
				
				CMP     QTDEBYTE, 1
				JE      ADDBYTE1
				
				CMP     QTDEBYTE, 2
				JE      ADDBYTE2

ADDBYTE0:       MOV     DL, AL                  
                CALL    PRINT 
                JMP     CONTINUE
                
ADDBYTE1:       MOV     DL, AL                  
                CALL    PRINT                   
                JMP     CONTINUE 

ADDBYTE2:       MOV     DL, AL                  
                CALL    PRINT          
                MOV     QTDEBYTE, 0
                CALL    CRLF 
                JMP     Int_0Bh
                
CONTINUE:   	INC     QTDEBYTE
                JMP     Int_0Bh  
                                
    ;-----------------------------------------------------------------------
    ;***********************************************************************
    ; MSmouse protocol
    ;***********************************************************************
    ;-----------------------------------------------------------------------
    ; Serial data parameters: 
    ; 1200bps, 7 databits, 1 stop-bit 
    ;-----------------------------------------------------------------------
    ;
    ; Data packet format: 
    ; Data packet is 3 byte packet. 
    ; It is send to the computer every time mouse state changes 
    ; (mouse moves or keys are pressed/released). 
    ; 
    ;   Bit7 Bit6 Bit5 Bit4 Bit3 Bit2 Bit1 Bit0 
    ; 
    ; 1. X    1    LB   RB   Y7   Y6   X7   X6 
    ; 2. X    0    X5   X4   X3   X2   X1   X0 
    ; 3. X    0    Y5   Y4   Y3   Y2   Y1   Y0 
    ;
    ; This means:
    ; X    :  dont care (eiter 1 or 0) depends on mouse
    ; X0-X7:  byte of the x-coord 
    ; Y0-Y7:  byte of the y-coord
    ; LB   :  Left button pressed
    ; RB   :  Right button pressed
    ;*********************************************************************** 
    ;-----------------------------------------------------------------------    
    
;-------------------------------------------------------------------------------------------
;  Reset and exit
;-------------------------------------------------------------------------------------------
 INT_RET:       MOV 	AL, OldIMR
                OUT 	21h, AL  				;1-st PIC IMR restoring

				INT     20h
				
PRINT:          MOV     CX, 8
	                                                           
CONT:           XOR     AX, AX
                RCL     DL, 1 
                ADC     AL, 30H
                MOV     AH, 0EH
                INT     10H 
                
                LOOP    CONT 
                
                MOV     AL, ' '
                MOV     AH, 0EH
                INT     10H
         
                RET 
                
CRLF:           MOV     AH, 0EH
                MOV     AL, 0DH
                INT     10H
                
                MOV     AL, 0AH
                INT     10H 
                
                RET
   
cd ends
end start 

    