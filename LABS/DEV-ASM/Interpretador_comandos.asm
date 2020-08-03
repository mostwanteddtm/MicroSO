;org 100h ;para funcionar no emu8086, tem que utilizar offset DOS
org 7c00h

    EntryPoint:
    
        push cs
        pop ds
        
        ; set default video mode 80x25:
        mov ah, 00h
        mov al, 03h
        int 10h 
        
        ; wait for a command:
        mov dx, cmd_size ; buffer size.
        lea di, command_buffer
        call get_string
    
        push ds
        pop es
        
        cld ; forward compare.
        
        ; compare command buffer with 'help'
        lea si, command_buffer
        mov cx, chelp_tail - offset chelp   ; size of ['help',0] string.
        lea di, chelp
        repe cmpsb
        je  help_command
        
        ; compare command buffer with 'cls'
        lea si, command_buffer
        mov cx, ccls_tail - offset ccls  ; size of ['cls',0] string.
        lea di, ccls
        repe cmpsb
        jmp cls_command 
        
        get_string proc near
            push ax
            push cx
            push di
            push dx
            
            mov cx, 0           ; char counter.
            
            cmp dx, 1           ; buffer too small?
            jbe empty_buffer      
            
            dec dx              ; reserve space for last zero.
            
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
                        jae wait_for_key    ; if so wait for 'backspace' or 'return'...
                
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
        
        cls_command:
            mov al, 30h
            mov ah, 0eh
            int 10h
            jmp continue 

        help_command:
            mov al, 31h
            mov ah, 0eh
            int 10h
            jmp continue

        continue:
            
        mov ah, 00h
        int 16h
        
        jmp EntryPoint
        
        cmd_size equ 10    ; size of command_buffer
        command_buffer  db cmd_size dup("b") 
        
        chelp db "help", 0
        chelp_tail:
        ccls db "cls", 0
        ccls_tail: 
        
        db (510-($-EntryPoint)) dup (0)
        dw 0AA55h
end




