
; ______________________________________________________________________________________
;|																						|
;|						Template para compilacao com o MASM 6.15						|
;|______________________________________________________________________________________|

.286
.MODEL TINY 
_Text SEGMENT PUBLIC USE16
	ASSUME DS:_TEXT,ES:_TEXT 

.DATA     

                        MOUSE_POS_X         DW      78
                        MOUSE_POS_Y         DW      1920 
                        MOUSE_OLD_X         DW      0
                        MOUSE_OLD_Y         DW      0 
                        									
                        MOUSE_POS     		DW      0
                        MOUSE_OLD_POS 		DW      0
                        
                        CUR_POS_X           DW      78 
                        CUR_POS_Y           DW      160

.CODE

ORG 100h

;-----------------------------------------------------------------------------------------------
;									 EntryPoint
;-----------------------------------------------------------------------------------------------

main:                           
                                
                                
            INIT:
                                CALL        CLEAR_SCREEN
                                CALL        SET_CUR_POS 
                                CALL        SHOW_MOUSE 
                                CALL        CHKEYPRESS 
                                 
                                JMP         INIT
                                
            QUIT:
                                INT         20h
                                

;***********************************************************************************************
            CHKEYPRESS:
;-----------------------------------------------------------------------------------------------

            STARTCHK:          
                                MOV	        AH, 01h	            ; check keyboard buffer
                            	INT	        16h		            ; any key pressed?
                                
                                CMP         AH, 01h             ; AH is no modified?
                                JNE         ENDCHK              ; yes, modified
                                
                                JMP         STARTCHK
            ENDCHK:                
                                CMP         AH, 48h
                                JE          UP
                                CMP         AH, 50h
                                JE          DOWN
                                CMP         AH, 4Bh
                                JE          LEFT
                                CMP         AH, 4Dh
                                JE          RIGHT
                                CMP         AH, 1Ch 
                                JE          NEW_CUR_POS
                                JMP         RETURN 
                                
            NEW_CUR_POS:
                                MOV         DX, MOUSE_POS_X
                                MOV         CUR_POS_X, DX
                                MOV         DX, MOUSE_POS_Y
                                MOV         CUR_POS_Y, DX
                                XOR         DX, DX
                                JMP         RETURN
            UP:         
                                SUB         MOUSE_POS_Y, 160 
                                JMP         RETURN
                                
            DOWN:               
                                ADD         MOUSE_POS_Y, 160
                                JMP         RETURN
                                
            LEFT:
                                SUB         MOUSE_POS_X, 2
                                JMP         RETURN
                                
            RIGHT:              ADD         MOUSE_POS_X, 2       
                                
            RETURN:             
                                MOV	        AH, 10H	                    ; yes: remove from buffer
                            	INT	        16H 
                            	OR	        AL, 1			            ; clear zero flag
                            	      
                                RET 
                                
            ;#################################################
            ; 
            ;       SCANCODES
            ;
            ;       UP      :   48h
            ;       DOWN    :   50h
            ;       LEFT    :   4Bh
            ;       RIGHT   :   4Dh 
            ;
            ;       ENTER   :   1Ch
            ;       ESC     :   01h
            ;
            ;#################################################                   

;***********************************************************************************************

;-----------------------------------------------------------------------------------------------
                                
       
;***********************************************************************************************
            SET_CUR_POS:
;-----------------------------------------------------------------------------------------------
                                
                                XOR         DX, DX
                                MOV         AX, CUR_POS_Y 
                                CMP         AX, 0
                                JE          NO_CALC_X
                                MOV         BL, 160
                                DIV         BL
                                MOV         DH, AL 
             NO_CALC_X:         MOV         AX, CUR_POS_X
                                CMP         AX, 0
                                JE          NO_CALC_Y
                                MOV         BX, 2
                                DIV         BL
                                MOV         DL, AL
             NO_CALC_Y:         MOV         AX, 0200h
                                XOR         BX, BX
                                INT         10H
                                
                                
                                RET   
                                
;-----------------------------------------------------------------------------------------------                                     
               
;***********************************************************************************************


;***********************************************************************************************				
            SHOW_MOUSE:		
;-----------------------------------------------------------------------------------------------

                				CALL        HIDE_MOUSE_POS
                					
                				MOV         AX, MOUSE_POS_X
                				ADD         AX, MOUSE_POS_Y
                				MOV         MOUSE_POS, AX 
                				MOV         MOUSE_OLD_POS, AX
                					
                				CALL        SET_MOUSE_POS
                				
                				RET
            				
            SET_MOUSE_POS:            
                                MOV         AX, 0B800h
                				MOV         ES, AX
                				MOV         AL, 20h
                				MOV         AH, 7Fh             ; SET COLORS: WHITE BACKGROUND, BLUE TEXT.
                				MOV         DI, MOUSE_POS             ; POINT TO START OF THE SCREEN.
                				MOV         ES:[DI], AX         ; WRITE TO VIDEO MEMORY. 
                				
                				RET 
                            
            HIDE_MOUSE_POS:           
                                CMP         MOUSE_OLD_POS, 0
                				JE          NOHIDE
                				MOV         AX, 0B800h
                				MOV         ES, AX
                				MOV         AL, 20h
                				MOV         AH, 00h             
                				MOV         DI, MOUSE_OLD_POS         
                				MOV         ES:[DI], AX         
            						
            NOHIDE:			    RET 

;-----------------------------------------------------------------------------------------------

;*********************************************************************************************** 

;-----------------------------------------------------------------------------------------------
            CLEAR_SCREEN:
;***********************************************************************************************

                                XOR         AX, AX
                                MOV         AL, 03h
                                INT         10h
                                
                                RET 
                                
;-----------------------------------------------------------------------------------------------

;*********************************************************************************************** \

END main

_TEXT ENDS
