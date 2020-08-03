.model tiny  
.data
    value db FFh
.code
main: 
    push dx
    push bx
    mov dl, byte ptr [value] ;ate o momento, nao vi sentido em usar byte ptr   
    mov bl, value
    mov [0105h], dl ;move para o deslocamento o valor do registrador dl
    mov bx, [0100h]
    mov ax, [bx] ;move para ax o conteudo do endereco de memoria de bx   
    pop dx
    pop bx
end main       
