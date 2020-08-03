STACK   SEGMENT PARA STACK 'STACK'
        DB 256 DUP(?)
STACK   ENDS
DATA    SEGMENT PARA PUBLIC 'DATA'
BUFFER  DB 10 DUP(0)
BUFPTR1 DW 0
BUFPTR2 DW 0
SCANTABLE DB 0,0,'1234567890-=',8,0
          DB 'QWERTYUIOP[]',0DH,0
          DB 'ASDFGHJKL;',0,0,'\',0
          DB 'ZXCVBNM,./',0,0,0
          DB ' ',0,0,0,0,0,0,0,0,0,0,0,0,0
          DB '789-456+1230.'
DATA    ENDS
CODE    SEGMENT PARA PUBLIC 'CODE'
START   PROC FAR
        ASSUME CS:CODE,DS:DATA,SS:STACK
        PUSH DS
        XOR AX,AX
        PUSH AX
        MOV AX,DATA
        MOV DS,AX
        CLI
        XOR AX,AX
        MOV ES,AX
        MOV DI,24H
        MOV AX,OFFSET KBINT
        CLD
        STOSW
        MOV AX,CS
        STOSW
        MOV AL,0FCH
        OUT 21H,AL
        STI
FOREVER:CALL KBGET
        PUSH AX
        CALL DISPCHAR
        POP AX
        CMP AL,0DH
        JNZ FOREVER
        MOV AL,0AH
        CALL DISPCHAR
        JMP FOREVER
KBGET PROC NEAR
        PUSH BX
        CLI
        MOV BX,BUFPTR1
        CMP BX,BUFPTR2
        JNZ KBGET2
        STI
        POP BX
        JMP KBGET
KBGET2: MOV AL,[BUFFER+BX]
        INC BX
        CMP BX,10
        JC KBGET3
        MOV BX,0
KBGET3: MOV BUFPTR1,BX
        STI
        POP BX
        RET
KBGET   ENDP
KBINT PROC FAR
        PUSH BX
        PUSH AX
        IN AL,60H
        PUSH AX
        IN AL,61H
        OR AL,80H
        OUT 61H,AL
        AND AL,7FH
        OUT 61H,AL
        POP AX
        TEST AL,80H
        JNZ KBINT2
        LEA BX,SCANTABLE
        XLAT
        CMP AL,0
        JZ KBINT2
        MOV BX,BUFPTR2
        MOV [BUFFER+BX],AL
        INC BX
        CMP BX,10
        JC KBINT3
        MOV BX,0
KBINT3: CMP BX,BUFPTR1
        JZ KBINT2
        MOV BUFPTR2,BX
KBINT2: MOV AL,20H
        OUT 20H,AL
        POP AX
        POP BX
        IRET
KBINT ENDP
DISPCHAR PROC NEAR
        PUSH BX
        MOV BX,0
        MOV AH,14
        INT 10H
        POP BX
        RET
DISPCHAR ENDP
START ENDP
CODE ENDS
        END START