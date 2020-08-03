.model tiny
.stack 512d
.data
    val1 db 02h ;0000 0010b
.code
    mov bl, val1 
    mov cx, 04h ;loop de um nible
    ;SHL move para esquerda um nible o valor do registrador bl 0010 0000b | 20h
    ;equivale tambem a potencia de 2^2| 2^3| 2^4| 2^5 = 32d ou 20h
    shl bl, cl  
    
    ret