;---------------------------------------------------------------------------------------------------------------

;create time ( =3 bytes ) 

;minimum time: 00:00:00 = 00 00 00 if zero, no time in properties
;maximum time: 23:59:59 = 64 7D BF
;how it calculates it:
;the values on the disk are: 64,90,a6 and properties: 8:52:33pm
;first flip the bytes: 64,90,a6 -> a6,90,64
;convert to binary: a6,90,64 -> 10100110,10010000,01100100
;divide up the sections and convert back to decimal: (from left to right)
;(5bits;hour) 10100 -> = 20hrs (24hr) or - 12 = 8pm
;(6bits;mins) 110100 -> = 52 minutes
;(5bits;secs) 10000 -> 16; * 2 = 32 seconds
;(8bits;mili) 01100100 -> = 100 milliseconds
;if millisecs >=000 and <=099; seconds is correct + no. of milliseconds
;if millisecs >=100 and <=199; seconds + 1 = seconds + no. of milliseconds
;if millisecs >=200; seconds + 2 = seconds (etc) but its considered invalid
;which gives 33 seconds exactly: 8:52:33pm
;invalid times such as 2600hours simply roll fowards to become 0200hours in properties, scandisk does not error.

;-----------------------------------------------------------------------------------------------------------------

org 100h

EntryPoint:
   
   jmp main
        horarioHexa dw 90A6h 
                    
        horario db 10 dup (0)
        decimal dw 10
                
   Convert:       
    
        c:
            xor dx, dx
            div [decimal]
            add dl, 30h 
            mov [horario+bx], dl
            inc bx
            cmp al, 9
            ja c
        
        continue: 
            xor dx, dx
            xchg dl, al
            add dl, 30h 
            mov [horario+bx], dl 
       
        mov si, offset horario
        add si, bx
        print: 
            mov ah, 0eh
            mov al, [si]
            int 10h
            dec si
        loop print 
        
        xor dx, dx
        
        ret  
        
main:
    mov ax, horarioHexa
    xor ah, ah
    rcr al, 3
    and al, 00011111b 
    mov cx, 2
    call Convert 
    
    mov ah, 0eh
    mov al, 3Ah
    int 10h
    
    mov ax, horarioHexa
    xchg ah, al  
    and ah, 00000111b
    rcr ax, 5
    and al, 00111111b
    xor ah, ah 
    mov cx, 2
    call Convert
    
    mov ah, 0eh
    mov al, 3Ah
    int 10h
    
    mov ax, horarioHexa
    xchg ah, al
    xor ah, ah
    and al, 00011111b
    rcl al, 1
    mov cx, 2
    call Convert

    int 20h

end




