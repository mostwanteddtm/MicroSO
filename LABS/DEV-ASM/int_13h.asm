org  100h

jmp st

;para testar tem que compilar
  
filename    db 'Paula e Marcos Apaixonados!'      
buffer      db 512 dup (0)

msg db 'fim$' 
e2 db "   i/o error...",0Dh,0Ah,'$'


; write bytes to disk
st: mov ah, 03h
    mov al, 1 ; write 1 sector (512 bytes).
    mov cl, 2  ; sector (1..18)
    mov ch, 0  ; cylinder (0..79)
    mov dh, 0  ; head  (0..1)  
    mov dl, 0 ; always 0 (A:)
    mov bx, offset filename
    int 13h
    jc er


    lea dx, msg
    mov ah, 09h
    int 21h 
    
    ret

er: lea dx, e2
    mov ah, 9
    int 21h
    jmp e2e
    
    e2e:

    ret         
    