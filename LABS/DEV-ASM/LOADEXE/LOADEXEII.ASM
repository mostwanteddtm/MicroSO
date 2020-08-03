
;----------------------------------------------------------------------------------------------|
;                                                                                              |
;                   Copyright Marcos Roberto da Costa - 15 de Outubro de 2015                  |
;                   Loader Program 1.01 - Compilado Com MASM                                   |
;                                                                                              |
;----------------------------------------------------------------------------------------------|

.model tiny    
.code
     
org 100h
                            jmp     short start 
                            
bpbBytesPorSetor            dw      512                             
bpbTotalSetoresPorTrilha    dw      18                              
bpbTotalCabecasNoDisco      dw      2                               
bsDriveDisquete             db      1                               ;no EMU 8086, usar a imagem FLOPPY_1                                

Cluster                     dw      0                    

Cabeca                      db      0
Trilha                      db      0
Setor                       db      0
                                                                    
DiretorioRaiz               dw      19                              ;endereco LBA do diretorio Raiz 
ArquivosDiretoriosPorSetor  dw      16                              ;16 Arquivos/DIRs de 32 Bytes = 512 Bytes = 1 Setor
TotalSetoresDiretorioRaiz   dw      14                              ;14 Stores com 16 Arquivos/DIRs = 224 Arquivos
                                                            
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
	                        

start:
loadProgram                 proc
    
                            mov     ax, DiretorioRaiz               ;Diretorio Raiz em Floppy A:\>
                            mov     bx, 0300h                       ;OFFSET onde os nomes dos Arquivos/DIRs sao carregados
                            mov     di, 0300h                       ;OFFSET onde sera comparado com o nome da imagem do KERNEL.SYS
                            mov     cx, ArquivosDiretoriosPorSetor  ;16 Arquivos/DIR
                            
ProximoSetor:               call    LeiaDisco
                            
                            push    bp
			                mov     bp, sp 
							mov     si, OFFSET Arquivo              ;mov     si, [bp+4]							
																	;Arquivo db "COMMAND COM", 0Fh ----- "HELLO   COM"
                    cont:   push    si                              
                            push	di
                            push    bx
                            mov     bx, [si + 0Bh]
                            mov     CMD, bh
                            pop     bx                            
                            
                            mov     cx, 0Bh
                            repe    cmpsb
                            je      LeiaFAT
                            pop     di
                            add     di, 20h
							pop 	si
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
                            mov     bx, 0700h
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
                            mov     bx, Buffer
                            
                            mov     ax, 0800h                       ;o COMMAND COM sera carregado em 0400:0100
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
                                  
DONE:                       add     Buffer, 0200h
                            mov     [cluster], dx
                            mov     ax, [cluster]
                            cmp     dx, 0FF0h 
                            jb      ProximoCluster
                            
loadCMD03:                  mov		ax, 0FFFFh
							mov     ax, 0800h
                            mov     ds, ax

                            add     ax, ds:[08h]                    ; ax = image base
                            mov     cx, ds:[06h]                    ; cx = reloc items
                            mov     bx, ds:[18h]                    ; bx = reloc table pointer
                    
                            jcxz    RelocationDone

ReloCycle:                  mov     di, ds:[bx]                     ; di = item ofs
                            mov     dx, ds:[bx+2]                   ; dx = item seg (rel)
                            add     dx, ax                          ; dx = item seg (abs)
                    
                            push    ds
                            mov     ds, dx                          ; ds = dx
                            add     ds:[di], ax                     ; fixup
                            pop     ds
                    
                            add     bx, 4                           ; point to next entry
                            loop    ReloCycle

RelocationDone:             mov     bx, ax
                            add     bx, ds:[0Eh]
                            mov     ss, bx                          ; ss for EXE
                            mov     sp, ds:[10h]                    ; sp for EXE
                    
                            add     ax, ds:[16h]                    ; cs
                            push    ax
                            push    ds:[14h]  
                                                                    ; ip
                            mov     dl, 0                           ; let program know boot drive
                            sti
                            retf
                                              
                            sair:                               
                            int     19h                             ;nao localizou o arquivo 
                            
Arquivo                     db      "TESTE   EXE", 0Fh              ;reserva 12 bytes, para o nome do programa a ser carregado
                                                                    ;11 bytes (nome do arquivo) - o byte 12 verifica se 
                                                                    ;o programa a ser carregado = COMMAND COM
 
Buffer                      dw      00h                           	;Offset onde e carregado cada setor lido = BH 01 - BL 00 = 0100h
CMD                         db      0

loadProgram                 endp

END