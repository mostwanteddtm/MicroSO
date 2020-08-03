org 100h 

    mov ah, 0 ;Initialize opcode
    mov al, 11100011b ;Parameter data.
    mov dx, 2 ;COM4: port.
    int 14h  
    
    mov dx, 2 ;Select COM4:
    mov al, 41h
    mov ah, 1 ;Transmit opcode
    int 14h
    
    int 20h

ret




