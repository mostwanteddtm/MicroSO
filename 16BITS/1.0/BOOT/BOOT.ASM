org 0h
 
EntryPoint: 

	jmp main

	bpbOEM                      db 'MICROSO '        ;OEM disk label (8 bytes) 

	bpbBytesPorSetor            dw 512              ;bytes per sector 
	bpbSetoresPorCluster        db 1                ;sectors per cluster 
	bpbSetoresReservados        dw 1                ;reserved sectors (1 for boot code) 
	bpbTotalFATs                db 2                ;number of file allocation tables 
	bpbTotalDiretoriosArquivos  dw 224              ;number of root directory entries 
	bpbTotalSetoresNoDisco      dw 2880             ;number of logical sectors 
	bpbTabelaDescricaoDisco     db 0f8h             ;media descriptor byte 
	bpbTotalSetoresPorFAT       dw 9                ;9 sectors per FAT 
	bpbTotalSetoresPorTrilha    dw 18               ;18 sectors per track (36/cylinder) 
	bpbTotalCabecasNoDisco      dw 2                ;2 heads per cylinder 
	bpbSetoresOcultos           dd 0                ;no hidden sectors 
	bpbOutros                   dd 0                ;no large sectors 

	bsDriveDisquete             db 0                ;drive number (for drive A) 
	bsCabecaDisco               db 0                ;reserved (current head) 
	bsAssinaturaDisquete        db 29h              ;drive signature (29h for floppy) 
	bsNumeroSerie               dd 0                ;volume ID (serial number) 
	bsVolume                    db 'MICROS0v0.1'    ;volume label (11 bytes) 
	bsSistemaArquivos           db 'FAT12   '       ;file system type (8 bytes) 
	   
    Cluster                     dw 0                    
    
    Cabeca                      db 0
    Trilha                      db 0
    Setor                       db 0
    
    KernelArquivo               db 'KERNEL  SYS'    ;file name (11 bytes) 
 	
	LeiaDisco: 
	    call ConvertLBACHS
        mov ah, 02h
        mov al, 01h
        mov ch, [Trilha] ; C - Clylinder / Track
        mov dh, [Cabeca] ; H - Head
        mov cl, [Setor]  ; S - Sector
        mov dl, [bsDriveDisquete]
        int 13h 
        jc sair 
        ret
	          
	ConvertLBACHS: 
        xor dx, dx                
        div [bpbTotalSetoresPorTrilha]  
        inc dl                    
        mov [Setor], dl
        xor dx, dx                
        div [bpbTotalCabecasNoDisco] 
        mov [Cabeca], dl
        mov [Trilha], al 
	    ret
main: 
						        
    mov ax, 07C0h				
    mov ds, ax      ; para rodar no emulador, e so comentar (1)   
    mov es, ax      ; essas duas linhas                     (2)
    
    mov ax, 0000h
    mov ss, ax
    mov sp, 0FFFFh				        	

    ;Leitura do Diretorio Raiz a procura do Kernel 
    mov al, 19d ; Endereco LBA do Diretorio Raiz
    mov bx, 200h  
    call LeiaDisco 	 
    
    mov cx, bpbTotalDiretoriosArquivos   
    mov di, 200h 
    
    while:
        mov si, OFFSET KernelArquivo
        push cx 
        push di
        mov cx, 0Bh
        rep cmpsb
        je LeiaFAT
        pop di
        add di, 20h
        pop cx
        sub cx, 20h
    loop while
    
    jmp sair
    
    LeiaFAT: 
            
        pop di
        mov dx, [di + 1Ah]
        mov [Cluster], dx 
        mov bx, 200h 
        mov ax, 1d ; Endereco LBA da Tabela FAT 
        call LeiaDisco
        
        mov ax, 0800h
        mov es, ax
        mov bx, 0000h
        push bx   
        
        LeiaArquivo:
            
            ; A regra abaixo consiste em: 
            ; Endereco LBA da area de dados dos arquivos
            ; que se inicia no Setor 33 - 2 primeiros Clusters reservados = 31 
            ; Mais Cluster indicado na tabela FAT. Entao 31 + 2 = 33 para o primeiro arquivo no disco
            ; Lembrando que cada Cluster e um Setor no Disquete  
            mov ax, 31d
            mov dx, [Cluster]
            add ax, dx 
            call LeiaDisco 
            
            mov bx, 200h
            mov ax, [Cluster] 
            mov cx, ax
            mov dx, ax
            shr dx, 1     ;calculo para leitura de endereco de memoria
            add cx, dx    ;onde estara a informacao do proximo cluster
            add bx, cx    ;cluster atual / 2 + cluster
            mov dx, [bx] 
            
            ; Apos a leitura de cada cluster, avancamos
            ; mais um setor na memoria, para armazenar 
            ; os dados do proximo cluster 
            pop bx
            add bx, 200h
            push bx
        
            test    ax, 0001h
            jnz ClusterPar 
                  
            ClusterImpar:
                  
                and     dx, 0000111111111111b  
                jmp ValidaFimClusters
                 
            ClusterPar:
        
                shr     dx, 0004h  
                  
            ValidaFimClusters:
            
                mov [Cluster], dx 
                cmp dx, 0FF0h 
                jb LeiaArquivo
        
    CarregarKernel:
    
    push    0800h
    push    0000h
    retf  
    
    sair:
        int 18h
 
    db (510-($-EntryPoint)) dup (0)
    dw 0AA55h 

END