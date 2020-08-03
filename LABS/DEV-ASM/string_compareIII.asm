.model tiny 
.stack 200h
.data 
    CmdCD db 'CD'
    LenCD:
    CmdCL db 'CL'
    LenCL:
    userCommand db 8 dup(0) 
.code
    
    EntryPoint:
        
        push cs
        pop ds
  
        xor cx, cx ;This will be incremented.
        mov di, offset userCommand
        push di
        
        While:
            xor ah, ah
            int 16h
            cmp al, 0dh ;Check for ENTER.
            jz CheckCommand
            cmp al, 08h
            jz BackSpace  
            mov ah, 0eh
            int 10h
            and al, 0dfh ;This makes the key uppercase, no case sensitivity.
            inc dx
            stosb ;This won't modify Flags.
        jmp While 
        
        CheckCommand proc near 
            
            pop di 
            mov si, offset CmdCD  
            mov cx, LenCD - offset CmdCD
            cmp cx, dx
            je CheckCD 
            
            Command02:
            
            pop di
            mov si, offset CmdCL
            mov cx, LenCL - offset CmdCL
            cmp cx, dx
            je CheckCL 
            jne Error
            
        CheckCommand endp 
        
        ;Comando 01   
        CheckCD proc near 
            push di
            rep cmpsb
            je ExecuteCD
            jne Command02
        CheckCD endp         
                
        ExecuteCD proc near
            mov al, 31h
            jmp Fim
        ExecuteCD endp
        
        ;Comando 02
        CheckCL proc near
            rep cmpsb
            je ExecuteCL
            jne Error
        CheckCL endp
        
        ExecuteCL proc near
            mov al, 32h
            jmp Fim
        ExecuteCL endp
        
        Error proc near
            mov al, 30h
            jmp Fim
        Error endp 
                
        BackSpace proc near 
            dec di
            dec dx
            mov ah, 0eh
            mov al, 08h
            int 10h		;backspace on the screen
            
            mov al, 20h
            int 10h		;blank character out
            
            mov al, 08h
            int 10h      ;backspace 
            jmp While 
        BackSpace endp
        
        Fim:
        mov ah, 0eh
        int 10h
        
        mov ah, 00h
        int 16h
        
        mov al, 03h
        mov ah, 0
        int 10h
        
        mov     bh, 00h
        mov     dl, 00h
        mov     dh, 0h
        mov     ah, 02h
        int     10h
        
        jmp EntryPoint
            
        ret            
;---------------------------------------------------------------
;COMENTANDO A LINHA  AND al, 0DFh
;a:  0110 0001
;df: 1101 1111

;=:  0100 0001

;a:  0110 0001 (61h)
;A:  0100 0001 (41h)
;---------------------------------------------------------------
    
end