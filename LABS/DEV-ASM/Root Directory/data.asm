;-----------------------------------------------------------------------------------------------------------------------------

;create date ( =2 bytes ) 

;minimum date: 1/1/1980 = 21 00
;maximum date: 2/7/2106 = 46 FC
;how it calculates it:
;the values on the disk are: 14,2b and properties: 20th august 2001
;first flip the bytes: 14,2b -> 2b,14
;convert to binary: 2b,14 -> 00101011,00010100
;divide up the sections and convert back to decimal: (from left to right)
;(7bits;yr) 0010101 -> 15h -> 21; + 1980 (7BCh) = 2001 (7D1h)
;(4bits;mt) 1000    -> 08h -> = 8 or august
;(5bits;dy) 10100   -> 14h -> = 20 - 20th
;20th august 2001
;invalid dates such as the 31st of september simply roll forwards to the 1st of october in properties, scandisk does not error.

;the last possible create date and time is:
;sunday, february 07, 2106 7:28:15am anything beyond = (unknown)
;the create date and time seem to be handled together though they are separate entries.  

;-------------------------------------------------------------------------------------------------------------------------------

org 100h
    
    jmp start
        dataHexa dw 142Bh
        data db 10 dup (0)  
        decimal dw 10 
        
    Convert:       
    
        c:
            xor dx, dx
            div [decimal]
            add dl, 30h 
            mov [data+bx], dl
            inc bx
            cmp al, 9
            ja c
        
        continue: 
            xor dx, dx
            xchg dl, al
            add dl, 30h 
            mov [data+bx], dl 
       
        mov si, offset data
        add si, bx
        print: 
            mov ah, 0eh
            mov al, [si]
            int 10h
            dec si
        loop print 
        
        xor dx, dx
        
        ret        
        
start:
    
    mov ax, dataHexa 
    xor bx, bx
    xchg ah, al
    push ax

    and al, 00011111b
    mov dl, al
    mov ax, dx
    mov cx, 2
    call Convert
    
    mov ah, 0eh
    mov al, 2Fh
    int 10h
    
    pop ax
    mov sp, 0FFFCh
    
    rcr ax, 5
    and al, 00001111b
    mov dl, al
    mov ax, dx
    mov cx, 2
    call Convert 

    mov ah, 0eh
    mov al, 2Fh
    int 10h
    
    pop ax
    mov sp, 0FFFCh
    
    rcr ah, 1
    xor dx, dx
    mov dl, ah 
    add dx, 7BCh
    mov ax, dx 
    mov cx, 4
    call Convert  
    
    int 20h

end


