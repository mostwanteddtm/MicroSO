org 100h

EntryPoint:
    
    mov si, offset data 
    
    start:
    
    call setData
    mov cx, 16
    
    call print
    
    add value, 1
    cmp value, 2 ; Quantidade de valores [0] 034EFh - [1] 06789h - [2] 0FF00h
    jle start
    
    ret
    
    setData proc near
        mov bx, [si]
        add si, 02h 
        ret
    setData endp 
    
    print proc near
        
        while:  
        
            rcl bx, 1
            adc al, 30h
            mov ah, 0eh
            int 10h
            
            xor ax, ax
        
        loop while 
        
        ret
        
    print endp
    
    value db 0
    
    data dw 034EFh
         dw 06789h 
         dw 0FF00h

end
                                          

