include "COLOR.INC" 
    
SelecionarCores macro near
    
    mov ah, 02h
    mov dh, 00h
	mov dl, 00h
	mov bh, 00h
	int 10h
 
    mov si, offset msgFundo
    whileFundo:
        lodsb
        cmp al, 0
        je endMsgFundo
        mov ah, 0eh
        int 10h
    jmp whileFundo 
    
    endMsgFundo:
    xor ax, ax
    int 16h
    
    mov CorFundo, al 
    
    cmp al, 30h
    jb endMsgFundo
    cmp al, 39h
    ja ContinueNumeroFundo
    sub [CorFundo], 30h 
    jmp ContinueCorFundo
    
    ContinueNumeroFundo: 
    cmp al, 41h
    jb endMsgFundo
    cmp al, 46h
    ja ContinueLetraFundo
    sub [CorFundo], 37h 
    jmp ContinueCorFundo
    
    ContinueLetraFundo:
    cmp al, 61h
    jb endMsgFundo
    cmp al, 66h
    ja endMsgFundo
    sub [CorFundo], 57h 
    and al, 11011111b
    
    ContinueCorFundo:
    
    mov ah, 0eh
    int 10h
    
    mov bh, [CorFundo]
    shl bh, 04h 
    
    mov al, 0Ah
    int 10h
    
    mov al, 0Dh
    int 10h
    
    mov si, offset msgFonte
    whileFonte:
        lodsb
        cmp al, 0
        je endMsgFonte
        mov ah, 0eh
        int 10h
    jmp whileFonte 
    
    endMsgFonte:
    xor ax, ax
    int 16h
    
    mov CorFonte, al 
    
    cmp al, 30h
    jb endMsgFonte
    cmp al, 39h
    ja ContinueNumeroFonte
    sub [CorFonte], 30h 
    jmp ContinueCorFonte
    
    ContinueNumeroFonte: 
    cmp al, 41h
    jb endMsgFonte
    cmp al, 46h
    ja ContinueLetraFonte
    sub [CorFonte], 37h 
    jmp ContinueCorFonte
    
    ContinueLetraFonte:
    cmp al, 61h
    jb endMsgFonte
    cmp al, 66h
    ja endMsgFonte
    sub [CorFonte], 57h 
    and al, 11011111b
    
    ContinueCorFonte:
    mov ah, 0eh
    int 10h
    
    add bh, [CorFonte]
    
    setColor  

endm
       
