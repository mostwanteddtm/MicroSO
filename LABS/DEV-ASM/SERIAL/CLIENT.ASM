org 100h

    jmp main
        curY            db 0
        msg             db "Selecione a porta de comunicacao ( COM1 : 1 | COM2: 2 ): ", 0  
        msgSair         db "Deseja Sair: (sim: s | nao: n): ", 0 
        pularLinha      db 0Ah, 0Dh, 0       
        port            db 0
        
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
    
main: 

    mov ah, 00h
    mov al, 03h
    int 10h
    
    mov si, offset msg
    call Print 
    
    xor ax, ax
    int 16h
    
    mov ah, 0eh
    int 10h 
    
    sub al, 31h 
    mov port, al
   
    xor dx, dx
    mov ah, 0 ;Initialize opcode
    mov al, 10100111b ;Parameter data.
    mov dl, [port] ;COM3: port.
    int 14h
    
    continue:
    mov curY, 0
    
    mov ah, 00h
    mov al, 03h
    int 10h

    mov cx, 20
    whileSerial: 

        mov dh, 00h
    	mov dl, [curY]
    	mov bh, 0
    	mov ah, 2
    	int 10h
        
        xor ax, ax  
        xor dx, dx
        mov dl, [port] ;Select COM3:
        mov ah, 2 ;Receive opcode
        int 14h
        
        cmp al, 0
        je whileSerial
        
        mov ah, 0eh
        int 10h
        inc curY
                
    loop whileSerial 
    
    mov si, offset pularLinha
    call Print
    
    mov si, offset msgSair
    call Print 
    
    xor ax, ax
    int 16h 
    
    cmp al, 73h
    jne continue
    
    int 20h     

ret




