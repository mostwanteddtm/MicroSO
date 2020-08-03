programa       SEGMENT
               ASSUME CS:programa, DS:programa


               ORG   100h
inicio:

               CALL  inic_retardo
               MOV   CX,20         ; 20 retardos
               MOV   AX,59659      ; de 50 milisegundos
retard:        CALL  retardo
               LOOP  retard
               INT   20h


inic_retardo   PROC
               PUSH  AX
               IN    AL,61h
               AND   AL,11111101b
               OR    AL,1
               JMP   SHORT $+2
               OUT   61h,AL
               MOV   AL,10110100b  ; contador 2, modo 2, binario
               JMP   SHORT $+2
               OUT   43h,AL
               POP   AX
               RET
inic_retardo   ENDP
retardo        PROC
               PUSH  AX
               PUSH  BX
               CLI
               OUT   42h,AL        ; parte baja de la cuenta
               MOV   AL,AH
               JMP   SHORT $+2
               OUT   42h,AL        ; parte alta
               JMP   SHORT $+2
               IN    AL,61h
               XOR   AL,1          ; bajar GATE
               JMP   SHORT $+2
               OUT   61h,AL
               XOR   AL,1          ; subir GATE
               JMP   SHORT $+2
               OUT   61h,AL
               STI
               JMP   SHORT $+2
               MOV   BX,0FFFFh
retardando:    MOV   AL,10000000b
               OUT   43h,AL        ; enclavamiento
               JMP   SHORT $+2
               IN    AL,42h        ; leer contador
               MOV   AH,AL
               JMP   SHORT $+2
               IN    AL,42h
               XCHG  AH,AL         ; AX = valor del contador
               CMP   AX,BX
               MOV   BX,AX
               JBE   retardando
               POP   BX
               POP   AX
               RET
retardo        ENDP


programa       ENDS
               END   inicio