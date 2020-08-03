#masm#
.286
.model tiny  
.code
_TEXT SEGMENT PUBLIC USE16
    assume CS:_Text, DS:_Text
    org 100h
 
main:
    
    mov ah, 02h
    mov al, 01h
    mov ch, 00h
    mov dh, 00h
    mov cl, 01h
    mov dl, 00h
    ;mov bx, 0150h   ; Aqui eu faco um JUMP no mesmo segmento
    mov bx, 0800h  ; As tres linhas abaixo, faco o JUMP para outro segmento
    mov es, bx
    mov bx, 0100h    
    int 13h
    
    push 0800h     ; Aqui e o JUMP para outro segmento
    push 0100h
    retf
    
    ;mov ax, 0150h   ; Aqui e o JUMP para o mesmo segmento
    ;jmp ax
    

_TEXT ENDS
END main  