org 100h

; no boot, quando lemos os dados no diskete, carregamos os dados no endereco
; mov bx, 0800h
; quando executamos o codigo jmp 0800h:0000h
; o codigo ja esta carregado na memoria 

jmp 0700h:010Ah ; de 0100h a 0104h

db 5h dup (0)  ; de 0105h a 0109h

    cli ; 01Ah 
    hlt