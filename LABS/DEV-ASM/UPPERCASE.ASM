org 100h  

EntryPoint:

    c:
        xor ax, ax
        int 16h
        
        cmp al, 61h
        jb Continue
        cmp al, 7Ah
        ja Continue
        and al, 11011111b
        
        Continue: 
        cmp al, 1bh
        je sair
        mov ah, 0eh
        int 10h 
        
    jmp c 
    
    sair:
    int 20h
    
end