org 0000h

    EntryPoint:
    
        push cs
        pop ds 
        
        ; wait for a command:
        mov dx, cmd_size ; buffer size.
        lea di, command_buffer
        call get_string
    
        push ds
        pop es
        
        cld ; forward compare.
        
        lea si, command_buffer
        mov cx, LenCmdMatrix - offset CmdMatrix  
        lea di, CmdMatrix
        repe cmpsb
        je  ExecuteMatrix
        
        lea si, command_buffer
        mov cx, LenCmdMEUBEM - offset CmdMEUBEM 
        lea di, CmdMEUBEM
        repe cmpsb
        je ExecuteMEUBEM
        
        jmp Error 
        
        get_string proc near
            push ax
            push cx
            push di
            push dx
            
            cmp dx, 1           ; buffer too small?
            jbe empty_buffer      
            
            dec dx              ; reserve space for last zero.
            
            start:
            
            lea si, Drive
            call print 
            
            mov cx, 0           ; char counter.
            
            wait_for_key:
            
                mov ah, 0                   ; get pressed key.
                int 16h
                
                cmp al, 0Dh                 ; 'return' pressed?
                jz exit
                  
                cmp al, 8                   ; 'backspace' pressed?
                jne add_to_buffer
                jcxz wait_for_key            ; nothing to remove!
                dec cx
                dec di
                
                mov ah, 0eh
                mov al, 08h
                int 10h		
                
                mov al, 20h
                int 10h		
                
                mov al, 08h
                int 10h   
                
                jmp wait_for_key
            
                add_to_buffer:
                
                        cmp cx, dx          ; buffer is full?
                        ;jae wait_for_key    ; if so wait for 'backspace' or 'return'...
                
                        mov [di], al
                        inc di
                        inc cx
                        
                        ; print the key:
                        mov ah, 0eh
                        int 10h
            
                        jmp wait_for_key
            
            exit:
            
            mov [di], 0
            
            empty_buffer:
            
            pop dx
            pop di
            pop cx
            pop ax
            ret
        get_string endp
        
        ExecuteMatrix:
            mov Sector, 03h
            jmp Execute 

        ExecuteMEUBEM:
            mov Sector, 04h
            jmp Execute

        continue:
            
        mov ah, 00h
        int 16h
        
        jmp EntryPoint
        
    Execute:
    
        lea si, CrLf
        call print
        
        mov ah, 02h
        mov al, 01h
        mov ch, 00h
        mov cl, Sector
        mov dh, 00h
        mov dl, 00h
        mov bx, 0900h
        mov es, bx
        mov bx, 00h
        int 13h
        
        jmp 0900h:0000h  
    
    print proc near 
        
        push ax
        push si
        
        c:
            mov al, [si]
            cmp al, 00h
            jz sair:
            mov ah, 0eh
            int 10h
           
            inc si
        
        jmp c 
        
        sair:
        pop ax
        pop si
        ret
    
    print endp
    
    Error:
        lea si, CrLf
        call print
        lea si, CmdError
        call print
        lea si, CrLf
        call print
        call EntryPoint 
    
    Drive db 41h, 3ah, 3eh, 0
    CrLf db 0ah, 0dh, 0
    
    cmd_size equ 10    ; size of command_buffer
    command_buffer  db cmd_size dup("b") 
    
    CmdMatrix db "matrix", 0
    LenCmdMatrix:
    CmdMEUBEM db "meubem", 0
    LenCmdMEUBEM: 
    
    Sector db 0
    CmdError db "Programa nao encontrado", 0

end    