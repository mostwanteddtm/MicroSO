org 100h 

jmp EntryPoint

    data db 30 dup (0) ; Armazena um espaço na memoria, para leitura dos dados (Endereco 0103h)
     
    msg db 'Dados escritos no FLOPPY_0..aperte uma tecla para ler os dados...', 0dh, 0ah, 0h
    
    buffer db 'Paula e Marcos Apaixonados!', 0h  ; dados que serao scritos no diskete
    db 512 dup (0)  ; como iremos gravar um setor inteiro, limpamos a memoria
                    ; utilizada pelo programa, para gravarmos so a frase

    print:
        lodsb
        or al, al
        jz continue
        mov ah, 0eh
        int 10h 
        jmp print
        
        continue:
        ret  

EntryPoint:

    mov ah, 03h     ; interrupcao para gravacao
    mov al, 01h     ; quantidade de setores a serem gravados
    mov ch, 00h     ; Cylinder ou Track | TRILHA (0....79)
    mov dh, 00h     ; Head              | CABECA (0.....1) 
    mov cl, 01h     ; Sector            | SETOR  (1....18)
    mov dl, 00h
    mov bx, offset buffer
    int 13h
    
    mov si, offset msg 
    call print
    
    xor ax, ax
    int 16h
    
    mov ah, 02h     ; interrupcao para leitura
    mov al, 01h     ; quantidade de setores a serem lidos
    mov ch, 00h     ;C
    mov dh, 00h     ;H
    mov cl, 01h     ;S
    mov dl, 00h
    mov bx, 0180h   ;offset data (Apontaria para o endereco de memoria 0103h)
    int 13h
    
    mov si, 0180h   ;provavelmente so e possivel apontar para o endereco de memoria
    call print      ;que corresponde o endereco final do programa
     
    int 20h 
    
end
    
    