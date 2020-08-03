;Program HEXDUMP.ASM: Display contents of any range of memory locations.
;
        .MODEL SMALL
        .DATA
SEGMSG  DB    'Segment address:  $'
BMSG    DB    0DH,0AH,'Starting address: $'
EMSG    DB    0DH,0AH,'Ending address:   $'
        
        .CODE
        .STARTUP
        LEA   DX,SEGMSG   ;set up pointer to first message
        MOV   AH,9        ;display string
        INT   21H         ;DOS call
        CALL  GETHEX      ;get segment address
        MOV   ES,AX       ;use extra segment for viewing memory
        LEA   DX,BMSG     ;set up pointer to second message
        MOV   AH,9        ;display string
        INT   21H         ;DOS call
        CALL  GETHEX      ;get starting address
        MOV   SI,AX       ;use source index to access memory
        LEA   DX,EMSG     ;set up pointer to third message
        MOV   AH,9        ;display string
        INT   21H         ;DOS call
        CALL  GETHEX      ;get ending address
        MOV   DI,AX       ;use destination index to stop display
NEWLYN: MOV   DL,0DH      ;load a carriage return
        MOV   AH,2        ;output character to screen
        INT   21H         ;DOS call
        MOV   DL,0AH      ;load a line feed
        MOV   AH,2        ;output character to screen
        INT   21H         ;DOS call
        MOV   AX,ES       ;get segment address
        CALL  HEXOUTW     ;display word in hexadecimal
        MOV   DL,':'      ;load a colon
        MOV   AH,2        ;output character to screen
        INT   21H         ;DOS call
        MOV   AX,SI       ;get current address
        CALL  HEXOUTW     ;display word in hexadecimal
        MOV   DL,20H      ;load a blank
        MOV   AH,2        ;output character to screen
        INT   21H         ;DOS call
        MOV   AH,2        ;output a second blank
        INT   21H         ;DOS call
        MOV   CX,16       ;prepare for 16 passes
NEWBYT: MOV   AL,ES:[SI]  ;read memory
        INC   SI          ;advance to next location
        CALL  HEXOUTB     ;display byte in hexadecimal
        MOV   DL,20H      ;load a blank
        MOV   AH,2        ;output character to screen
        INT   21H         ;DOS call
        LOOP  NEWBYT      ;repeat loop if necessary
        CMP   SI,DI       ;time to quit?
        JL    NEWLYN
        .EXIT

HEXOUTW PROC NEAR
        PUSH AX           ;save copy of 4-digit hex number
        MOV  AL,AH        ;output upper two digits
        CALL HEXOUTB
        POP  AX           ;get copy of original number back
        CALL HEXOUTB      ;output lower two digits
        RET
HEXOUTW ENDP

HEXOUTB PROC NEAR
        PUSH AX           ;save copy of 2-digit hex number
        ROL  AL,1         ;move upper 4 bits into lower 4 bit positions
        ROL  AL,1
        ROL  AL,1
        ROL  AL,1
        CALL DODIG        ;output hexadecimal equivalent character
        POP  AX           ;get original number back
        CALL DODIG        ;output hex character for lower 4 bits
        RET
HEXOUTB ENDP

DODIG   PROC NEAR
        AND  AL,0FH       ;clear upper 4 bits
        ADD  AL,30H       ;add ASCII bias
        CMP  AL,'9'+1     ;is digit greater than 9?
        JC   NOADD        ;jump if it is not
        ADD  AL,7         ;otherwise, add 7 to correct alpha character
NOADD:  MOV  DL,AL        ;load character for output
        MOV  AH,2         ;output character to screen
        INT  21H          ;DOS call
        RET
DODIG   ENDP

GETHEX  PROC NEAR
        SUB  DX,DX        ;clear result
GH:     MOV  AH,1         ;read keyboard
        INT  21H          ;DOS call
        CMP  AL,0DH       ;did we get a carriage return?
        JZ   GHQ          ;jump if we did
        SUB  AL,30H       ;otherwise, subtract ASCII bias
        CMP  AL,0AH       ;is number still greater than 9?
        JC   RAA          ;jump if it is not
        SUB  AL,7         ;correct bits for A-F value
RAA:    SHL  DX,1         ;shift result 4 bits to left
        SHL  DX,1
        SHL  DX,1
        SHL  DX,1
        ADD  DL,AL        ;add new digit to result
        JMP  GH           ;and repeat
GHQ:    MOV  AX,DX        ;return result
        RET
GETHEX  ENDP

        END