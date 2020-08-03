.286
.model tiny  
.code
_TEXT SEGMENT PUBLIC USE16
    assume CS:_Text, DS:_Text
    org 100h
EntryPoint: 

    push cs
    pop ds
	
main:
    
    mov ah, 00h
    mov al, 03h
    int 10h

    mov ah, 02h
    mov dh, 0Ah
	mov dl, 00h
	mov bh, 00h
	int 10h
	
	mov ah, 0eh
	mov al, 65
	int 10h
	
	mov ah, 00h
    int 16h
    
    push 0800h     ; Aqui e o JUMP para outro segmento
    push 0000h
    retf

_TEXT ENDS
END main  