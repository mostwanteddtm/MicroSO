org 100h 

    ;push      ds
    ;pop       es
    mov ah, 0Ah               ; function 0Ah - input string
    mov dx, buffer            ; DS:DX - buffer address
    int 21h                   ; DOS service call 
    
    mov cx, LStr1 
    lea di, Str1              ; ES:DI point to string 2 (memory)
    lea si, Str2              ; DS:SI point to string 1 (entered)
    mov ch, 0                 ; clear high byte of CX
    mov cl, ActLen            ; CX contains actual length of string
   ;cld                       ; process strings from left to right
    repe cmpsb                ; compare strings
    jne  diferente:
    
    mov ah, 09h
    lea dx, Texto1
    int 21h
    ret
    
    diferente: 
    mov ah, 09h
    lea dx, Texto2
    int 21h
    ret
    
    Str1     db      'ab', 24h  
    LStr1	 equ	 Str1 - 24h
    
    Texto1   db      ' - string igual', 24h 
    Texto2   db      ' - string diferente', 24h 
    
    buffer: 
    StrBuf  db        3
    ActLen  db        0
    Str2    db        3 dup (?)