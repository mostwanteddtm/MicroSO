org  100h

jmp st

;para testar tem que compilar 

;cria uma pasta em a:\TESTE  
dirname    db 'TESTE', 20h, 20h, 20h, 20h, 20h, 20h, 10h, 00h, 00b4h, 00cbh, 93h 
            db 00e4h, 003eh, 00e4h, 003eh, 00h, 00h, 00cch, 93h, 00e4h, 3eh

;cria um arquivo: a:\teste.txt            
filename    db 'TESTE', 20h, 20h, 20h, 54h, 58h, 54h, 20h, 18h, 58h, 03h, 00a3h, 00e4h, 003eh 
            db 00e4h, 003eh, 00h, 00h, 08h, 00a3h, 00e4h, 003eh                      
                 
buffer      db 512 dup (0)

msg db 'fim$' 
e2 db "   i/o error...",0Dh,0Ah,'$' 

;sequencia de utilizacao do disquete: setor (1..18) -> head (0) = 0 ate 2600
;depois: setor (1..18) -> head (1) = 2610 ate 5200


; write bytes to disk
st:  
    mov ah, 03h
    mov al, 1 ; write 1 sector (512 bytes).
    mov cl, 2  ; sector (1..18)
    mov ch, 0  ; cylinder (0..79)
    mov dh, 1  ; head  (0..1)  
    mov dl, 0 ; always 0 (A:)
    ;mov bx, offset dirname 
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
    