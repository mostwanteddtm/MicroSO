;BootLoader que deve ser compilado no Emu8086
org 7c00h 
;ini dw $

xor ax,ax ;zero ax
mov ds,ax ;pois nao da pra zerar direto ds (data segment)

mov al,03h
mov ah,0
int 10h 

lea si,msg
mov cx,msglen 

c:
    mov al,[si]
    mov bh,00h
    mov ah,0eh
    int 10h
    
    inc si 
    
loop c

continuar:

mov ah,00h
int 16h

mov ah,02h ;leitura do disco
mov al,01h ;numero de setores
mov ch,00h ;trilha
mov cl,02h ;setor
mov dh,00h ;cabeca
mov dl,00h ;drive (0 = disquete)
mov bx,0800h
mov es,bx
mov bx,00h
int 13h

jmp 0800h:0000h
        
msg db "Boot Loader v0.01",10,13,"Boot Completo. Pressione qualquer tecla para continuar...",10,13,10,13 
msglen dw $-msg
    
;db (510 - ($ - ini)) dup (0) 
;dw 0AA55h 
