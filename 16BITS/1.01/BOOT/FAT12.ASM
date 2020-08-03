;----------------------------------------------------------------------------------------------|
;                                                                                              |
;                   Copyright Marcos Roberto da Costa - 18 de Novembro de 2015                 |
;                           BootLoader 1.01 - Compilado Com MASM 6.15                          |
;                                                                                              |
;----------------------------------------------------------------------------------------------|

.286
.MODEL TINY

_TEXT SEGMENT PUBLIC USE16  
    
    ASSUME DS:_TEXT,ES:_TEXT,SS:_TEXT

.CODE

ORG 0h  

EntryPoint:                 jmp     start
     
bpbOEM                      db      "MICROSO "                      ;OEM Nome do Produto  

bpbBytesPorSetor            dw      512                             ;bytes por setor 
bpbSetoresPorCluster        db      1                               ;setor por cluster 
bpbSetoresReservados        dw      1                               ;setor reservado (setor de boot) 
bpbTotalFATs                db      2                               ;numero de tabelas FAT 
bpbTotalDiretoriosArquivos  dw      224                             ;numero maximo de arquivos/diretorios do diretorio raiz 
bpbTotalSetoresNoDisco      dw      2880                            ;numero maximo de setores do disco 
bpbTabelaDescricaoDisco     db      0f8h                            ;tipo de disco - 0f8h = disquete 
bpbTotalSetoresPorFAT       dw      9                               ;setores por FAT 
bpbTotalSetoresPorTrilha    dw      18                              ;18 setores por trilha (36/trilhas) 
bpbTotalCabecasNoDisco      dw      2                               ;2 cabecas 
bpbSetoresOcultos           dd      0                               ;setores ocultos 
bpbOutros                   dd      0                                

bsDriveDisquete             db      0                               ;numero do drive - disquete A:\> 
bsCabecaDisco               db      0                               ;cabeca inicial de leitura 
bsAssinaturaDisquete        db      29h                             ;assinatura de disquete 
bsNumeroSerie               dd      101h                            ;numero de serie 
bsVolume                    db      "MICROS01.01"                   ;etiqueta de volume 
bsSistemaArquivos           db      "FAT12   "                      ;sistema de arquivos 

Cluster                     dw      0                    

Cabeca                      db      0
Trilha                      db      0
Setor                       db      0

KernelBuffer                dw      0h                              ;Para Testar com o Arquivo "LOADFILECOM" alinhar a memoria com 0100h
KernelArquivo               db      "KERNEL  SYS"                   ;nome do arquivo (11 bytes) - "LOADFILECOM" - Arquivo de Teste
                                                                    ;aqui sera o "KERNEL  SYS"
DiretorioRaiz               dw      19                              ;endereco LBA do diretorio Raiz 
ArquivosDiretoriosPorSetor  dw      16                              ;16 Arquivos/DIRs de 32 Bytes = 512 Bytes = 1 Setor
TotalSetoresDiretorioRaiz   dw      14                              ;14 Stores com 16 Arquivos/DIRs = 224 Arquivos 

copyright 					db      0Dh, 0Ah
                            db      "Copyright MicroSO 1.01 by Marcos Roberto da Costa, 18 de Novembro de 2015"
                            db      0Dh, 0Ah
                            db      "*****     Para entender como utilizar o sistema, digite: AJUDA      *****" 
                            db      0Dh, 0Ah, 0
                                                            
;------------------------------------------------------------------------------------------------|
;                                                                                                |
; Converter LBA para CHS                                                                         |
; AX=>LBA Endereco de convercao                                  19                              |        
;                                                                              AL  DL            |
; setor     = (setor MOD setores por trilha) + 1                 (19 mod 18) = 1      + 1   = 2  |
; cabeca    = (setor / setores por trila) MOD numero de cabecas  (19/18) = 1(sobra 1) mod 2 = 1  |  
; trilha    = setor / (setores por trilha * numero de cabecas)   19 / (18*2) = 36 19 / 36   = 0  | 
;                                                                                                |
;------------------------------------------------------------------------------------------------|

LeiaDisco:                  call    ConvertLBACHS
                            mov     ah, 02h
                            mov     al, 01h
                            mov     ch, [Trilha]                    ;C - Clylinder / Track
                            mov     dh, [Cabeca]                    ;H - Head
                            mov     cl, [Setor]                     ;S - Sector
                            mov     dl, [bsDriveDisquete]
                            int     13h 
                            jc      sair 
                            ret                                     
	          
ConvertLBACHS:              xor     dx, dx                
                            div     [bpbTotalSetoresPorTrilha]  
                            inc     dl                    
                            mov     [Setor], dl
                            xor     dx, dx                
                            div     [bpbTotalCabecasNoDisco] 
                            mov     [Cabeca], dl
                            mov     [Trilha], al 
	                        ret

;-----------------------------------------------------------------------------------------------------|
;                                                                                                     |
; O endereco do boot = 7C:0 => 07C0:0000 => 0000:7C00 - Se utilizar org, ignora-se o zero a esquerda  |
;                                                                                                     |
; No Registrador AX => AH=07 - AL=C0                                org 7C00h                         |
;                                                                                                     |
;-----------------------------------------------------------------------------------------------------|

start:                      mov     ax, 07C0h                      ;Endereco do boot 0000:7C00
                            mov     ds, ax                         ;No Emulador 8086, nao alinhar o Data Segment e o  (1)
                            mov     es, ax                         ;Extra Segment. Entao comentar as linhas 1 e 2     (2)
                            
                            mov     ax, 0
                            mov     ss, ax
                            mov     sp, 0FFFFh 
                            
                            mov     si, OFFSET copyright            
                            mov     ah, 0Eh
                    print:
                            lodsb      
                            cmp     al, 0
                            je      stop
                            int     10h
                            jmp     print
                    stop:
                            
                            mov     ax, DiretorioRaiz               ;Diretorio Raiz em Floppy A:\>
                            mov     bx, 0200h                       ;OFFSET onde os nomes dos Arquivos/DIRs sao carregados
                            mov     di, 0200h                       ;OFFSET onde sera comparado com o nome da imagem do KERNEL.SYS
                            mov     cx, ArquivosDiretoriosPorSetor  ;16 Arquivos/DIR
                            
ProximoSetor:

                            call    LeiaDisco                  
                            
                    cont:       
                            mov     si, OFFSET KernelArquivo        ;"KERNEL  SYS" - Arquivo de Teste "LOADFILECOM"
                            push    di
                            mov     cx, 0Bh
                            repe    cmpsb
                            je      LeiaFAT
                            pop     di
                            add     di, 20h 
                    loop    cont
                    
                            dec     [TotalSetoresDiretorioRaiz]     ;14 - representa o Total de Setores do diretorio Raiz
                            cmp     [TotalSetoresDiretorioRaiz], 0  ;Verifica se percorreu os 14 setores
                            je      sair                            ;Percorreu todos e nao encontrou o arquivo
                            inc     [DiretorioRaiz]                 ;Ainda nao percorreu os 14 setores e vai para o proximo
                            mov     ax, DiretorioRaiz
                            jmp     ProximoSetor
                            
                            jmp     sair                            ;Nao encontrou o arquivo
                                                       
LeiaFAT:                    pop     di
                            xor     dx, dx
                            mov     ax, [di + 001Ah]                ;Leio o 26 Byte, para Encontrar o cluster inicial do arquivo  
                            mov     bx, 0200h
                            push    bx
                            
ProximoCluster:             pop     bx
                            mov     [cluster], ax                   ;Armazeno o cluster inicial 
                            xor     dx, dx
                            div     [bpbBytesPorSetor]              ;Divido o cluster inicial pelo numero de bytes por setor
                            inc     al                              ;Pego o resultado e adiciono 1
                                                                    ;Ex: cluster 2 / 512 = 0 + 1 = 1 - LBA 2
                            call    LeiaDisco                       ;Outro Ex: 1081 / 512 = 2 + 1 = 3 - LBA 3 
                            
                            push    bx
                            push    es
                            mov     bx, [KernelBuffer]
                            
                            mov     ax, 0060h                       ;O Kernel sera carregado em 0060:0000
                            mov     es, ax                                         
                            mov     ax, 31d                         ;A regra abaixo consiste em:
                            mov     dx, [Cluster]                   ;Endereco LBA da area de dados dos arquivos
                            add     ax, dx                          ;que se inicia no Setor 33 - 2 primeiros Clusters reservados = 31
                            call    LeiaDisco                       ;Mais Cluster indicado na tabela FAT. Entao 31 + 2 = 33 para o primeiro arquivo no disco
                                                                    ;Lembrando que cada Cluster e um Setor no Disquete
                                                                    
                            pop     es
                            pop     bx 
                            push    bx
                            
                            mov     ax, [cluster] 
                            mov     cx, ax
                            mov     dx, ax
                            shr     dx, 1                           ;calculo para leitura de endereco de memoria
                            add     cx, dx                          ;onde estara a informacao do proximo cluster
                            add     bx, cx                          ;cluster atual / 2 + cluster
                            mov     dx, [bx]
                        
                            test    ax, 0001h
                            jnz     ClusterPar 
                                  
ClusterImpar:               and     dx, 0000111111111111b           ;Considera apenas os 12 bits da direita
                            jmp     DONE
                                 
ClusterPar:                 shr     dx, 0004h                       ;Considera apenas os 12 bits da esquerda
                                  
DONE:                       add     [KernelBuffer], 200h
                            mov     [cluster], dx
                            mov     ax, [cluster]
                            cmp     dx, 0FF0h 
                            jb      ProximoCluster
                            
                            xor     bx, bx
                            mov     ax, 0060h
                            mov     es, ax
                            mov     ds, ax
                            xor     ax, ax
                            mov     si, ax
                            mov     di, ax
                            
                            push    0060h							;O Kernel sera carregado em 0060:0000
                            push    0000h
                            retf
                            
                            sair:                               
                            int     19h                             ;Sai com erro, pois nao carregou o KERNEL

                            ORG     510                             ;db      510 - ($ - EntryPoint) dup(0)
                            dw      0AA55h 
_TEXT ENDS
END