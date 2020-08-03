
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
                
                POS_X   		DW 		78
                POS_Y   		DW 		1920
                
                CUR_POS_X       DW      0 
                CUR_POS_Y       DW      0
                
                OLD_X   		DW 		0
                OLD_Y   		DW 		0 
                									
                POS     		DW 		0
                OLD_POS 		DW 		0 
                
                BTLEFT          DB      0
                BTRIGHT         DB      0
                UP              DB      0
                DOWN            DB      0 
                LEFT            DB      0
                RIGHT           DB      0 

;*******************************************************************************************
BEG:    ;The program start
;-------------------------------------------------------------------------------------------
; COM1 port initialization
;-------------------------------------------------------------------------------------------
;First check for being already loaded
            			MOV		AX, CS
        				MOV 	DS, AX
        				
        				CALL    CLS
        				CALL    SHOW
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
Int_0Bh:		        
                        MOV 	DX, L_Status_Reg		;2FD = Line Status Register
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
REC:    		        ;byte receiving
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
        				
        				CMP     AL, 01010000b           ;se clicar com botao direito do mouse 
                        JE      INT_RET                 ;retorno ao kernel  
        				
        				;CMP     EXEC01, 0               ;verifico se foi a inicializacao da COM2
        				JNE     CONTEXEC                ;se nao for, processo os 3 bytes de dados
        				;INC     EXEC01
        				JMP     Int_0Bh
				
CONTEXEC:		        
        				CMP     QTDEBYTE, 0             ;verifico se e o primeiro byte a ser analisado
        				JE      ADDBYTE0                ;analiso o primeiro byte
        				
        				CMP     QTDEBYTE, 1             ;verifico se e o segundo byte a ser analisado
        				JE      ADDBYTE1                ;analiso o segundo byte
        				
        				CMP     QTDEBYTE, 2             ;verifico se e o terceiro byte a ser analisado
        				JE      ADDBYTE2                ;analiso o terceiro byte

ADDBYTE0:               
                        MOV     BYTES[0], AL            ;armazeno no buffer os dados do primeiro byte
                        CALL    CHKBYTE0                
                        CMP     UP, 1                   ;deve movimentar pra cima?
                        JE      SUB_POS_Y               ;sobe o cursor
                        CMP     LEFT, 1                 ;deve movimentar para esquerda?
                        JE      SUB_POS_X               ;movimenta para esquerda       
                        JMP     CONTINUE
                
SUB_POS_Y:      
                        CMP     POS_Y, 0                ;deve movimentar para baixo?
                        JE      NOSUBY                  ;nao deve
                        JNE     YES_SUB_Y               ;mais lento
                        JMP     NOSUBY
YES_SUB_Y:      
                        SUB     POS_Y, 160              ;subo o cursor
NOSUBY:         
                        CALL    SHOW
        				MOV     UP, 0
        				CALL    CONTINUE
                
SUB_POS_X:      
                        CMP     POS_X, 2                ;valido a posicao minima a esquerda
						JE		SUB2
						JL		CSUBX
                        SUB     POS_X, 4
						JMP		CSUBX
SUB2:					SUB		POS_X, 2
						
CSUBX:         
                        CALL    SHOW
        				MOV     LEFT, 0
        				CALL    CONTINUE
                
ADDBYTE1:       
                        MOV     BYTES[1], AL            ;armazeno no buffer os dados do segundo byte
                        CALL    CHKBYTE1 
                        CMP     RIGHT, 1                ;deve movimentar pra direita?
                        JNE     CONTRIGHT 
                        CMP     POS_X, 156              ;valido a posicao maxima a direita
						JE		CADD
                        JG     	NOADDPOSX
                        ADD     POS_X, 4
						JMP		NOADDPOSX
CADD:					ADD		POS_X, 2			
NOADDPOSX:      
                        CALL    SHOW
                        MOV     RIGHT, 0                                        
CONTRIGHT:      
                        JMP     CONTINUE 

ADDBYTE2:       
                        MOV     BYTES[2], AL            ;armazeno no buffer os dados do terceiro byte
                        CALL    CHKBYTE2 
                        CMP     DOWN, 1                 ;deve movimentar para baixo?
                        JNE     CONTDOWN 
                        CMP     POS_Y, 3840             ;valido a posicao maxima a baixo
                        JGE     NOADDPOSY
YES_ADD_Y:      
                        ADD     POS_Y, 160              ;desco o ponteiro do mouse
NOADDPOSY:      
                        CALL    SHOW
                        MOV     DOWN, 0                                        
CONTDOWN:       
                        MOV     QTDEBYTE, 0
                        JMP     Int_0Bh
                
CONTINUE:   	
                        INC     QTDEBYTE
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
 INT_RET:       
                        CALL	CLS
        				MOV 	AL, OldIMR
                        OUT 	21h, AL  				;1-st PIC IMR restoring

        				INT     20h  
				
;******************************************************************************************* 
CHKBYTE0:
;-------------------------------------------------------------------------------------------
       
        				MOV     DL, BYTES[0]            ;primeiro byte
        				CMP     DL, 01100000b 
                        JE      LEFT_BUTTON 
                        AND     DL, 00001100b           ;0101 XXXX clique do botao direito
                        RCL     DL, 4                   ;0100 XXXX clique do botao esquerdo
                        MOV     BL, 00111111b           ;0100 1100 movimento para cima
                        ADD     DL, BL                  ;0100 0011 movimento para esquerda
                        CMP     DL, 11111111b
                        JE      YES_UP                  ;segundo byte
                        MOV     DL, BYTES[0]            ;01000011 00111111 00000000 movimento para esquerda 
                        AND     DL, 00000011b           ;01000000 000XXXX1 00000000 movimento para direita
                        MOV     BL, 11111100b
                        ADD     DL, BL
                        CMP     DL, 11111111b           ;terceiro byte
                        JE      YES_LEFT                ;01000011 00000000 00111111 movimento para cima
                        RET                             ;01000000 00000000 000XXXX1 movimento para baixo
YES_LEFT:       
                        MOV     LEFT, 1
                        RET
YES_UP:         
                        MOV     UP, 1
                        RET   
;-------------------------------------------------------------------------------------------        				
;*******************************************************************************************
                        
                        
;*******************************************************************************************                        
LEFT_BUTTON:
;-------------------------------------------------------------------------------------------

                        XOR     DX, DX
                        MOV     AX, POS_Y 
                        CMP     AX, 0
                        JE      NO_CALC_X
                        MOV     BL, 160
                        DIV     BL
                        MOV     DH, AL 
NO_CALC_X:              MOV     AX, POS_X
                        CMP     AX, 0
                        JE      NO_CALC_Y
                        MOV     BX, 2
                        DIV     BL
                        MOV     DL, AL
NO_CALC_Y:              MOV     AX, 0200h
                        XOR     BX, BX
                        INT     10H
                                                
                        RET                 

;-------------------------------------------------------------------------------------------        				
;*******************************************************************************************
  

;******************************************************************************************* 
CHKBYTE1:
;-------------------------------------------------------------------------------------------
                
                        MOV     DL, BYTES[1]
                        CMP     DL, 0
                        JE      NORIGHT
                        CMP     DL, 00001111b
                        JG      NORIGHT
                        MOV     RIGHT, 1
NORIGHT:        
                        RET
    
;-------------------------------------------------------------------------------------------        				
;*******************************************************************************************


;******************************************************************************************* 
CHKBYTE2:
;-------------------------------------------------------------------------------------------
                
                        MOV     DL, BYTES[2]
                        CMP     DL, 0
                        JE      NODOWN
                        CMP     DL, 00001111b
                        JG      NODOWN
                        MOV     DOWN, 1
NODOWN:         
                        RET
    
;-------------------------------------------------------------------------------------------        				
;*******************************************************************************************


;*******************************************************************************************				
CLS:
;-------------------------------------------------------------------------------------------
    				
            			MOV     AH, 00H
        				MOV     AL, 03H
        				INT     10H
        				RET    
        				                                                                         
;-------------------------------------------------------------------------------------------        				
;*******************************************************************************************				
                                                                                              
                                                                                              
;*******************************************************************************************				
SHOW:			
;-------------------------------------------------------------------------------------------

        				CALL    HIDE_POS
        					
        				MOV     AX, POS_X
        				ADD     AX, POS_Y
        				MOV     POS, AX 
        				MOV     OLD_POS, AX
        					
        				CALL    SET_POS
        				
        				RET
				
SET_POS:        
                        MOV     AX, 0B800H
        				MOV     ES, AX
        				MOV     AL, 20H
        				MOV     AH, 7FH             ; SET COLORS: WHITE BACKGROUND, BLUE TEXT.
        				MOV     DI, POS             ; POINT TO START OF THE SCREEN.
        				MOV     ES:[DI], AX         ; WRITE TO VIDEO MEMORY. 
        				
        				RET 
                
HIDE_POS:       
                        ;CMP     OLD_POS, 0
        				;JE      NOHIDE
        				MOV     AX, 0B800H
        				MOV     ES, AX
        				MOV     AL, 20H
        				MOV     AH, 00H             
        				MOV     DI, OLD_POS         
        				MOV     ES:[DI], AX         
						
NOHIDE:			
                        RET 

;-------------------------------------------------------------------------------------------
;*******************************************************************************************

   
cd ends
end start 