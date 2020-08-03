org 100h

cli
xor ax, ax
mov es, ax
mov di, 200h
mov ax, offset teste  
cld
stosw
mov ax, cs
stosw
mov al, 0fch    ; instala a interrupcao [0x020-0x02F	Interrupt Controller 1]
out 21h, al
sti

int 80h
mov ax, 4c00h
int 21h


teste: 
mov al, 42h
mov ah, 0eh
int 10h

mov al,20h      ; informa o fim da instrucao de interrupcao
out 20h,al
iret