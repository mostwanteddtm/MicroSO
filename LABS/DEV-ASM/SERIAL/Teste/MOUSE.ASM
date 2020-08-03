
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
Message1      	DB      0Ah,0Dh
				DB      'The driver is already loaded',0Ah,0Dh
				DB      0Ah,0Dh,'$'
Message2      	DB      0Ah,0Dh
				DB      'The tutorial driver is now installed',0Ah,0Dh
				DB      0Ah,0Dh,'$'
Old_0C_Off    	DW		0    				;old interrupt 0Ch vector
Old_0C_Seg    	DW   	0    				;
Old_33_Off    	DW   	0    				;old interrupt 33h vector
Old_33_Seg    	DW   	0    				;
VeryOldIMR    	DB   	0    				;PIC mask register value
OldIMR        	DB   	0    				;the same
OVERR         	DB		0    				;data lost
Data_Reg      	DW		3F8h 				;register of data and
											;and of rate low byte
Int_Contr_Reg 	DW		3F9h 				;register of interrupt control
											;and of rate high byte
Int_ID_Reg    	DW		3FAh 				;interrupt ID register
L_Contr_Reg   	DW		3FBh 				;line control register
Mod_CONTR     	DW		3FCh 				;modem control register
L_Status_Reg  	DW		3FDh 				;line status register
Buf_Counter   	DW		0    				;mouse buffer counter
RESID         	DB		0    				;resident flag
NB            	DB		0    				;byte number
Buff1         	DB		'Buffer1'			; Mouse work buffer
Buttons       	DB		1    				;button condition
DELTA_X       	DB		0    				;X increment
DELTA_Y       	DB		0    				;Y increment    
Dado            DB      0
;*******************************************************************************************
BEG:    ;The program start
;-------------------------------------------------------------------------------------------
; COM1 port initialization
;-------------------------------------------------------------------------------------------
;First check for being already loaded

    			MOV		AX, CS
				MOV 	DS, AX
;-------------------------------------------------------------------------------------------
		
				IN 		AL, 21h				;read 1-st interrupt controller IMR
				AND 	AL, 0EFh 			;clear it's 4-th bit
				MOV 	OldIMR, AL			;store it value
				OUT 	21h, AL  			;now COM1 interrupt permitted
											;now is the serial port's turn

				MOV 	DX, L_Contr_Reg 	;3FBh = line control register
				IN 		AL, DX
				OR 		AL, 80h   			;set DLAB bit for rate divider
											;word enabling to send
				OUT 	DX, AL

				MOV 	DX, Data_Reg		;3F8h = data control register
				MOV 	AL, 60h
				OUT 	DX, AL   			;low byte for 1200 baud rate

				MOV 	DX, Int_Contr_Reg 	;now DX=3F9h, interrupt control
											;and high rate byte register
				XOR 	AX, AX
				OUT 	DX, AL   			;the high rate byte for 1200 baude rate

				MOV 	DX, L_Contr_Reg 	;3FBh - line control register
				MOV 	AL, 2    			;7 bits, 1 stop-bit, no parity
				OUT 	DX, AL   			;done

				MOV 	DX, Int_Contr_Reg	;3F9h=interrupt control register
				MOV 	AL, 1  				;receiving enable
				OUT 	DX, AL
				JMP 	$+2
				JMP 	$+2    				;delay

				MOV 	DX, Mod_CONTR  		;3FCh = modem control register
				MOV 	AL, 0Bh  			;set DTR,RTS and OUT2 bits
				OUT 	DX, AL
				STI         				;interrupts permitted

				MOV 	DX, Data_Reg 		;Data register address
				IN 		AL, DX    			;read it for to clear the input buffer

				MOV 	AL, OldIMR 			;1-st interrupt controller IMR
				OUT 	21h, AL    			;restored
;-------------------------------------------------------------------------------------------
;Interrupt 0Ch handler
;-------------------------------------------------------------------------------------------
Int_0Ch:		MOV 	DX, L_Status_Reg		;3FD = Line Status Register
                IN 		AL, DX 					;read it
                TEST 	AL, 1					;if 1 = data received
                JNZ 	OBR  					;go to handle the data
				JMP		Int_0Ch
;-------------------------------------------------------------------------------------------
OBR:    		;received byte processing
;-------------------------------------------------------------------------------------------
				
				MOV 	AX,	CS
				MOV 	DS,	AX
				MOV 	ES,	AX

				MOV 	DX,	Int_ID_Reg 			;3FAh - interrupt ID register
				IN  	AL,	DX 					;read its status
				AND 	AL,	6
				CMP 	AL,	04 					;is there somesthing for us?
				JZ 		REC    					;yes
				JMP 	Int_0Ch
;-------------------------------------------------------------------------------------------
REC:    		;byte receiving
				MOV 	AL,	64h 				;mask IRQ4 for not interrupting
				OUT 	20h,	AL
				MOV 	DX,	Int_ID_Reg 			;3FAh - interrupt ID register
				IN 		AL,	DX
				TEST 	AL,	4 					;receive?
				JNZ 	READ  					;yes,receive byte
				;JMP 	INT_RET 				;no,return  
				JMP     Int_0Ch
;-------------------------------------------------------------------------------------------
READ: 			;read byte from serial port receiving register
;-------------------------------------------------------------------------------------------
				MOV 	DX,	L_Status_Reg 		;3FDh = line status register
				IN 		AL,	DX   				;read it
				AND 	AL,	2   				;error?
				MOV 	OVERR,	AL 				;set OVERRUN BIT <>0, if symbol lost
				MOV 	DX,	Data_Reg 			;3F8h = data register
				IN 		AL,	DX 					;clear the receiving register 
				MOV     Dado, AL
				CALL    print
;-------------------------------------------------------------------------------------------
WRITE_CH:  		;write the byte into the Mouse buffer
;-------------------------------------------------------------------------------------------
				AND 	AL,	7Fh 				;clear the 7-th bit
				TEST 	AL,	40h					;is it the first byte?
				JZ 		B1      				;no
				;yes,it is = first byte processing
				XOR 	BX,	BX  				;byte bias in the buffer
				MOV 	Buff1[BX],	AL 			;to 0 position
				MOV 	Buff1[BX+3], 0
				MOV 	NB,	1 					;now it equal to 1
				;JMP 	INT_RET 				;all done, return 
				JMP     Int_0Ch
;-------------------------------------------------------------------------------------------
B1:    			;6-th bit = 0, so not the firsf byte
				;if NB<>0 then write into buffer, else it is error,
				;do nothing before the first byte arrives
;-------------------------------------------------------------------------------------------
				XOR 	BX,	BX
				MOV 	BL,	NB  				;byte bias in the buffer
				MOV 	Buff1[BX], AL			;save the byte
				INC 	BL
				MOV 	NB, BL
				CMP 	BL, 3 					;if the data packed full?
				JZ 		BBB   					;yes,go to process it
				MOV 	BUFF1[3], 0 			;no, wait for next byte
				;JMP 	INT_RET     			;all done, return   
				JMP     Int_0Ch
;-------------------------------------------------------------------------------------------
; Mouse information pack handling
;-------------------------------------------------------------------------------------------
BBB:
;-------------------------------------------------------------------------------------------
;               Buttons status restore
				MOV 	NB,	0    				;read 1-st byte in AL
				MOV 	AL, BUFF1[0]
				TEST 	AL,	20h 				;is left button pressed?
				JZ 		LB0      				;no
				OR 		Buttons, 1				;yes, set "Left button pressed" state
				JMP 	RB
				
LB0:			AND 	Buttons, 0FEh 			;set "Left button released" state

RB:				TEST 	AL, 10h 				;is right button pressed?
				JZ 		RB0      				;no
				OR 		Buttons, 2				;yes, set "Right button pressed" state
				JMP 	CRD
RB0:			AND 	Buttons, 0FDh  			;"Right button released"
;-------------------------------------------------------------------------------------------
CRD:            ;Increments handling
;-------------------------------------------------------------------------------------------
				;X-coordinate increments
;-------------------------------------------------------------------------------------------
				MOV 	AL, BUFF1[1]
				AND 	AL, 3Fh  				;clear senior 2 bits
				MOV 	DELTA_X, AL
				MOV 	AL, BUFF1[0]
				AND 	AL, 3    				;two senior bits from 0-byte
				SHL 	AL, 6
				OR 		DELTA_X, AL
;-------------------------------------------------------------------------------------------
; Y-coordinate increments
;-------------------------------------------------------------------------------------------
				MOV 	AL, BUFF1[2]
				AND 	AL, 3Fh  				;clear senior 2 bits
				MOV 	DELTA_Y, AL
				MOV 	AL, BUFF1[0]
				AND 	AL, 0Ch  				;two senior bits from 0-byte
				SHL 	AL, 4
				OR 		DELTA_Y, AL   
				JMP     Int_0Ch
;-------------------------------------------------------------------------------------------
;  Reset and exit
;-------------------------------------------------------------------------------------------
 INT_RET:       STI 							;interrupts permitted
                MOV 	AL, OldIMR
                OUT 	21h, AL  				;1-st PIC IMR restoring

				INT     20h
				
print:          mov         dl, Dado 
                mov         cx, 8
	                                                           
cont:           xor         ax, ax
                rcl         dl, 1 
                adc         al, 30h
                mov         ah, 0Eh
                int         10h 
                
                loop        cont 
                
                mov         al, ' '
                mov         ah, 0Eh
                int         10h
                
                cmp         Dado, 01010000b
                je          INT_RET
                ret
   
cd ends
end start