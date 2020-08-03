;PARA TESTAR TEM QUE COMPILAR

org 100h

    ;-------------------------------------------------------------------------
    ; 
    ; O HxD Hex Editor, utiliza o modo de enderecamento LBA 0 - 2880 Setores
    ; CHS comeca com: Cylinder 0, Head 0, Sector 1 
    ;
    ; MODO DE LEITURA CHS
    ;
    ; Setor  1...18 |19...36 |37...54
    ; Cabeca 0......|1...... |0............
    ; Trilha 0.............. |1............
    ;                                      
    ; CHS tem a base / inicio com 1
    ; LBA tem a base / inicio com 0
    ; Exemplo: (CHS) Setor 18 = (LBA) Setor 17
    ;
    ;-------------------------------------------------------------------------  

    mov ah, 03h     ; interrupcao para gravacao
    mov al, 01h     ; quantidade de setores a serem gravados
    mov ch, 00d     ; Cylinder ou Track - TRILHA (0....79)
    mov dh, 01d     ; Head              - CABECA (0.....1)
    mov cl, 02d     ; Sector            - SETOR  (1....18)  1
    mov dl, 00h
    mov bx, offset data
    int 13h
    
    jnc sair 
        mov al, 30h
        call print
    
    sair:
        mov al, 31h
        call print
        
    print:
        mov ah, 0eh
        int 10h 
        
    int 20h  
        
    data db 'WY'
    db 512 dup (0)





