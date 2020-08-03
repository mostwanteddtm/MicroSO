org 100h

EntryPoint:
    
    jmp main 
    cmd db "dire", 0 
    lenCmd dw $-cmd

main:  

     mov [0150h], 'd'
     mov [0151h], 'i'  
     mov [0152h], 'r' 
     
     mov cx, lenCmd
     mov si, offset cmd
     mov di, 0150h
     repe cmpsb 
     je ok
     int 20h
     
     ok:
     int 20h

end