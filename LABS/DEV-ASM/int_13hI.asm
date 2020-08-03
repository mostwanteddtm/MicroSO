org  100h

jmp st

;para testar tem que compilar 
;usar primeiro o programa int_13h para escrever os dados no disco

e2 db "   i/o error...",0Dh,0Ah,'$' 

buffer      db 512 dup (0), 24H


;leitura dos dados
st: mov ah, 02h
    mov al, 1 ; write 1 sector (512 bytes).
    mov cl, 2  ; sector (1..18)
    mov ch, 0  ; cylinder (0..79)
    mov dh, 0  ; head  (0..1)  
    mov dl, 0 ; always 0 (A:)
    mov bx, offset buffer
    int 13h
    jc er  
 
    mov si, offset buffer   
    
print_string:
    mov al, [si]
    cmp al, 0h
    jz fim
    inc si    
    mov ah, 0eh
    int 10h
    jmp print_string 
    
fim:    
    ret

er: lea dx, e2
    mov ah, 9
    int 21h
    jmp e2e
    
    e2e:

    ret         
    