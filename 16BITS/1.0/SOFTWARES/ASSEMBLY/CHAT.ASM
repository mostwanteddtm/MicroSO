org 100h

EntryPoint:

    jmp main 
        msg             db "Selecione a porta de comunicacao ( COM1 : 1 | COM2: 2 ): ", 0 
        error           db "Erro de conexao na Porta COM. Pressione qualquer tecla para sair.", 0
        pularLinha      db 0Ah, 0Dh, 0       
        port            db 0
        
        row             db 0
        curY01          db 0
        curY02          db 0 
    
    Print:
        whilePrint:
            lodsb
            cmp al, 0
            je sairPrint:
            mov ah, 0eh
            int 10h
        jmp whilePrint
        
        sairPrint:
        ret
        
    LimparLinha:
        mov cx, 79
        whileLimpar:
            mov dh, [row]
            mov dl, cl
        	mov bh, 00h
        	mov ah, 02h
        	int 10h
        	mov ah, 0eh
        	mov al, 00h
        	int 10h 
        loop whileLimpar
        mov curY01, 0
        mov curY02, 0
        jmp continue
   
main: 

    push cs
    pop ds

    mov si, offset msg
    call Print 
    
    xor ax, ax
    int 16h
    
    mov ah, 0eh
    int 10h 
    
    sub al, 31h 
    mov port, al
    
    mov si, offset pularLinha
    call Print 
    
    xor dx, dx
    mov ah, 0 ;Initialize opcode
    mov al, 10100111b ;Parameter data.
    mov dl, [port] ;COM1: port.
    int 14h 
    
    mov ah, 00h
    mov al, 03h
    int 10h
    
    Chat: 
        
        mov dh, 00h
        mov dl, [curY01]
    	mov bh, 00h
    	mov ah, 02h
    	int 10h
    	
        xor ax, ax
        int 16h 
        
        cmp al, 1Bh
        je sair 
        
        mov row, 0
        cmp al, 0Dh
        je call LimparLinha 
        continue:

        mov ah, 0eh
        int 10h
        
        inc curY01
        
        xor dx, dx
        mov dl, [Port] ;Select COM1:
        mov ah, 1 ;Transmit opcode
        int 14h
        ;test ah, 80h ;Check for error
        ;jnz SerialError
        
        xor dx, dx 
        xor ax, ax
        mov dl, [port] ;Select COM1:
        mov ah, 2 ;Receive opcode
        int 14h
        ;test ah, 80h ;Check for error
        ;jnz SerialError 
        push ax
        
        
        cmp al, 0
        je Chat 
        
        mov row, 05h
        cmp al, 0Dh
        je call LimparLinha 
        
        mov dh, 05h
        mov dl, [curY02]
    	mov bh, 00h
    	mov ah, 02h
    	int 10h
        
        pop ax
        mov ah, 0eh
        int 10h  
        
        inc curY02
     
    jmp Chat 
            
    SerialError: 
    
    mov si, offset error
    call Print 
    
    sair:
    
    int 20h
    
    mov dx, 1
    push 0800h
    push 0000h

end