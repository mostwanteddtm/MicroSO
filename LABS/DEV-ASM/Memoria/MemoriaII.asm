;-------------------------------------------------|
;                                                 |
;   Manipulacao de dados na memoria               |
;                                                 |
;-------------------------------------------------|
.model tiny 

.code

org 100h

            jmp         start
            cmd         db      8 dup(0)
            x           db      0
    
start:

            mov         si, offset msg[0]
   
cont:
            xor         ax, ax
            int         16h
            cmp         al, 0Dh
            je          print
            mov         ds:si, al
            inc         si
            jmp         cont 
    
print:      mov         ah, 0eh 
            mov         si, OFFSET msg[0]
contp:      lodsb
            cmp         al, 0
            je          fim
            int         10h
            jmp         contp
       
fim:        int 20h

END




