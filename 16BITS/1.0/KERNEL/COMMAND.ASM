org 100h   

EntryPoint:

    jmp main
        
        Message                     db "Lista de arquivos encontrados no disquete A:", 0Ah, 0Dh, 0Ah, 0Dh
                                    db "Arquivo      Data        Hora", 0Ah, 0Dh, 0Ah, 0Dh, 0
                
        EndMessageIni               db 0Ah, 0Dh, "Total de ", 0
        EndMessageFim               db " arqvuivos encontrados.", 0 
                
        imageIni                    dw 500h
        
        bpbTotalDiretoriosArquivos  dw 224
        bpbTotalSetoresPorTrilha    dw 18
        bpbTotalCabecasNoDisco      dw 2
        bsDriveDisquete             db 0
        
        Cabeca                      db 0
        Trilha                      db 0
        Setor                       db 0 
        
        dataHora                    db 10 dup (0)  
        Decimal                     dw 10
        countImages                 db 0
         
    LeiaDisco:   
    
	    call ConvertLBACHS
        mov ah, 02h
        mov al, 01h
        mov ch, [Trilha] ; C - Clylinder / Track
        mov dh, [Cabeca] ; H - Head
        mov cl, [Setor]  ; S - Sector
        mov dl, [bsDriveDisquete]
        int 13h 
        jc sair 
        ret
	          
	ConvertLBACHS:  
	
        xor dx, dx                
        div [bpbTotalSetoresPorTrilha]  
        inc dl                    
        mov [Setor], dl
        xor dx, dx                
        div [bpbTotalCabecasNoDisco] 
        mov [Cabeca], dl
        mov [Trilha], al 
	    ret 
	    
    PularLinha: 
    
        mov ah, 0eh
        mov al, 0Ah
        int 10h
        
        mov al, 0Dh
        int 10h
        
        ret 
        
    ConvertDecimal:       
        
        mov Decimal, 10
        
        c:
            xor dx, dx
            div [Decimal]
            add dl, 30h 
            mov [dataHora+bx], dl
            inc bx
            cmp al, 9
            ja c
        
        continue: 
            xor dx, dx
            xchg dl, al
            add dl, 30h 
            mov [dataHora+bx], dl 
       
        mov si, offset dataHora
        add si, bx
        print: 
            mov ah, 0eh
            mov al, [si]
            int 10h
            dec si
        loop print 
        
        xor dx, dx
        
        ret
    
    PrintData: 
     
        xor dx, dx
        xor bx, bx
        xchg ah, al
        push ax
    
        and al, 00011111b
        mov dl, al
        mov ax, dx
        mov cx, 2
        call ConvertDecimal
        
        mov ah, 0eh
        mov al, 2Fh
        int 10h
        
        pop ax
        push ax
        
        rcr ax, 5
        and al, 00001111b
        mov dl, al
        mov ax, dx
        mov cx, 2
        call ConvertDecimal 
    
        mov ah, 0eh
        mov al, 2Fh
        int 10h
        
        pop ax
        
        rcr ah, 1
        xor dx, dx
        mov dl, ah 
        add dx, 7BCh
        mov ax, dx 
        mov cx, 4
        call ConvertDecimal 
        
        ret 
        
    PrintHora:
        
        push ax
        xor ah, ah
        rcr al, 3
        and al, 00011111b 
        mov cx, 2
        call ConvertDecimal 
        
        mov ah, 0eh
        mov al, 3Ah
        int 10h
        
        pop ax
        push ax
        
        xchg ah, al  
        and ah, 00000111b
        rcr ax, 5
        and al, 00111111b
        xor ah, ah 
        mov cx, 2
        call ConvertDecimal
        
        mov ah, 0eh
        mov al, 3Ah
        int 10h
        
        pop ax
        xchg ah, al
        xor ah, ah
        and al, 00011111b
        rcl al, 1
        mov cx, 2
        call ConvertDecimal
        
        ret
        
    ExibirMensagem: 
    
        whileMessage:
            lodsb
            cmp al, 0
            je sairMessage
            mov ah, 0eh
            int 10h
        jmp whileMessage 
        
        sairMessage:
        
        ret
        
    Espaco:
        
        mov ah, 0eh
        mov al, 20h
        int 10h
        
        mov al, 20h
        int 10h
        
        ret
        
main: 

    push cs
    pop ds
    
    ;Leitura do Diretorio Raiz a procura do Kernel 
    mov al, 19d ; Endereco LBA do Diretorio Raiz
    mov bx, imageIni  
    call LeiaDisco 
    
    mov si, offset Message
    call ExibirMensagem
    
    mov cx, [bpbTotalDiretoriosArquivos]
    whileImages:  
        
        xor bx, bx 
        mov si, imageIni 
        
        whileImageName:
            mov ah, 0eh 
            mov al, [si+bx]
            cmp al, 20h
            jl sair
            cmp al, 7Ah
            jg sair
            int 10h
            inc bx
            cmp bx, 0Bh
            je continueImages
        jmp whileImageName  
        
        continueImages:
            
            call Espaco

            mov si, imageIni
            add si, 10h
            mov ah, [si]
            inc si
            mov al, [si]
            call PrintData 
            
            call Espaco 
            
            mov si, imageIni
            add si, 0Eh
            mov ah, [si]
            inc si
            mov al, [si]
            call PrintHora
    
            add imageIni, 20h 
            call PularLinha
            inc countImages 
        
     loop whileImages    
          
    sair:
    
    mov si, offset EndMessageIni
    call ExibirMensagem
    
    mov ah, 0eh
    mov al, CountImages
    add al, 30h
    int 10h
    
    mov si, offset EndMessageFim
    call ExibirMensagem
    
    int 20h	
    
    mov dx, 1
    push dx
    
    push 0800h
    push 0000h
    retf
    
end




