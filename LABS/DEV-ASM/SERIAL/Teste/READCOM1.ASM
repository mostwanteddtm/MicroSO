;Program READCOM1.ASM: Read and display COM1 data.
;
        .MODEL SMALL
        .DATA
XMSG    DB    'Press any key to exit...',0DH,0AH,'$'
DSTR    DB    ' is '
CDATA   DB    20H      ;reserved for COM1 data
        DB    0DH,0AH,'$'

        .CODE
        .STARTUP
        LEA   DX,XMSG     ;set up pointer to exit message
        MOV   AH,9        ;display string function
        INT   21H         ;DOS call
COM1:   MOV   DX,3FDH     ;set up status port address
MORE:   IN    AL,DX       ;read UART status
        TEST  AL,1        ;has a character been received?
        JNZ   READ        ;yes, go get it
AKEY:   MOV   AH,0BH      ;check keyboard status
        INT   21H
        CMP   AL,0FFH     ;has any key been pressed?
        JNZ   MORE
        JMP   BYE
READ:   MOV   DX,3F8H     ;set up data port address
        IN    AL,DX       ;read UART receiver
        MOV   CDATA,AL    ;save character
        CMP   AL,20H      ;test for printable ASCII
        JC    NONPRT
        CMP   AL,80H
        JC    OKVAL
NONPRT: MOV   CDATA,20H   ;use a blank when non-printable
OKVAL:  CALL  DISPBIN     ;display data in binary
        LEA   DX,DSTR     ;set up pointer to data string
        MOV   AH,9        ;display string function
        INT   21H         ;DOS call
        JMP   AKEY        ;and repeat
BYE:    .EXIT

DISPBIN PROC NEAR
        MOV   CX,8        ;set up loop counter
NEXT:   SHL   AL,1        ;move bit into Carry flag
        PUSH  AX          ;save number
        JC    ITIS1       ;was the LSB a 1?
        MOV   DL,30H      ;load '0' character
        JMP   SAY01       ;go display it
ITIS1:  MOV   DL,31H      ;load '1' character
SAY01:  MOV   AH,2        ;display character function
        INT   21H         ;DOS call
        POP   AX          ;get number back
        LOOP  NEXT        ;and repeat
        RET
DISPBIN ENDP

        END

