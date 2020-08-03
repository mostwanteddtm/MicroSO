org 100h 

mov ah, 02h
mov al, 1 ; write 1 sector (512 bytes).
mov cl, 1  ; sector (1..18)
mov ch, 0  ; cylinder (0..79)
mov dh, 0  ; head  (0..1)  
mov dl, 0 ; always 0 (A:)
mov bx, 0200h
int 13h 

xor cx, cx 
mov cx, 27d 
mov si, 0200h
while:
    mov al, [si]
    mov ah, 0eh
    int 10h
    
    inc si
    
loop while

    cli 
    hlt  
    