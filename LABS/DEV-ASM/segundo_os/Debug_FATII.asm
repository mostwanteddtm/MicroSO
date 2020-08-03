org 100h

EntryPoint:

    mov ah, 02h
    mov al, 01h
    mov ch, 00h  ;C
    mov dh, 00h  ;H
    mov cl, 02h  ;S
    mov dl, 00h
    mov bx, offset FAT
    int 13h 
    
start:
    
    mov bx, offset FAT
    mov ax, [cluster] 
    mov cx, ax
    mov dx, ax
    shr dx, 1     ;calculo para leitura de endereco de memoria
    add cx, dx    ;onde estara a informacao do proximo cluster
    add bx, cx    ;cluster atual / 2 + cluster
    mov dx, [bx]

    test    ax, 0x0001
    jnz .ODD_CLUSTER 
          
    .EVEN_CLUSTER:
          
          and     dx, 0000111111111111b                 ; take low twelve bits
          jmp .DONE
         
    .ODD_CLUSTER:

          shr     dx, 0x0004                            ; take high twelve bits
          
     .DONE:
           
          mov [cluster], dx
          cmp dx, 0x0FF0 
          jb start
                  
int 20h
                  
   cluster dw 2 
   FAT db 0Fh dup (0)       
     
end    
    
   