
;-------------------------------------------------------------------------------|
;                                                                               |
;         Copyright Marcos Roberto da Costa - 18 de Novembro de 2015            |
;                                                                               |
;                  Kernel 1.01 - Compilado Com MASM 6.15                        |
;                                                                               |
;      Area de memoria do Kernel 0060:0000 ~ 0090:0100 -> 1.536k ~ 2.560k       |               
;                                                                               |
;-------------------------------------------------------------------------------|

.286 
.MODEL TINY

_TEXT SEGMENT PUBLIC USE16                  ;code segment starts here.    
        ASSUME DS:_TEXT,ES:_TEXT,SS:_TEXT 
.DATA


OldIMR        	            DB   	0    				            ;the same 
OVERR         	            DB		0    			                ;data lost
Data_Reg      	            DW		2F8h 				            ;register of data and
				            							            ;and of rate low byte
Int_Contr_Reg 	            DW		2F9h 				            ;register of interrupt control
				            							            ;and of rate high byte
Int_ID_Reg    	            DW		2FAh 				            ;interrupt ID register
L_Contr_Reg   	            DW		2FBh 				            ;line control register
Mod_CONTR     	            DW		2FCh 				            ;modem control register
L_Status_Reg  	            DW		2FDh 				            ;line status register  
                            
INIT_COM_PORT               DB      0
    
.CODE
        
ORG 0h 

;*************************************************************************************************************************************

EntryPoint: 
                            push    cs
                            pop     ds

                            push    es
                            
                            ;call    INIT_COM_2						; Verificar a necessidade dessa inicialização
																	; utilizava a COM2 no 486
                            mov     ax, 0                           ;set es to "0000":      
                            mov     es, ax                          ;calculate vector address for interrupt 20h:
                            
                            mov     al, 20h                         ;multiply 20h by 4, store result in ax:    
                            
                            mov     bl, 4h       		            ;result is 0000:0080 
                            mul     bl          
                            mov     bx, ax
                            
                            mov     si, OFFSET INT20                ;copy offset into interrupt vector:
                            mov     es:[bx], si
                            add     bx, 2   
                                
                            mov     ax, cs                          ;copy segment into interrupt vector:     
                            mov     es:[bx], ax
                            
                            pop     es        
                          
                            int     20h                             ;test newly created interrupt. 
                            
;*************************************************************************************************************************************

INIT_COM_2:		
				            IN 		AL, 21h				            ;read 1-st interrupt controller IMR
				            AND 	AL, 0EFh 			            ;clear it's 4-th bit
				            MOV 	OldIMR, AL			            ;store it value
				            OUT 	21h, AL  			            ;now COM2 interrupt permitted
				            							            ;now is the serial port's turn
                                                                    
				            MOV 	DX, L_Contr_Reg 	            ;2FBh = line control register
				            IN 		AL, DX                          
				            OR 		AL, 80h   			            ;set DLAB bit for rate divider
				            							            ;word enabling to send
				            OUT 	DX, AL                          
                                                                    
				            MOV 	DX, Data_Reg		            ;2F8h = data control register
				            MOV 	AL, 60h                         
				            OUT 	DX, AL   			            ;low byte for 1200 baud rate
                                                                    
				            MOV 	DX, Int_Contr_Reg 	            ;now DX=2F9h, interrupt control
				            							            ;and high rate byte register
				            XOR 	AX, AX                          
				            OUT 	DX, AL   			            ;the high rate byte for 1200 baude rate
                                                                    
				            MOV 	DX, L_Contr_Reg 	            ;2FBh - line control register
				            MOV 	AL, 2    			            ;7 bits, 1 stop-bit, no parity
				            OUT 	DX, AL   			            ;done
                                                                    
				            MOV 	DX, Int_Contr_Reg	            ;2F9h=interrupt control register
				            MOV 	AL, 1  				            ;receiving enable
				            OUT 	DX, AL                          
                                                                    
				            MOV 	DX, Mod_CONTR  		            ;2FCh = modem control register
				            MOV 	AL, 0Bh  			            ;set DTR,RTS and OUT2 bits
				            OUT 	DX, AL 
;-------------------------------------------------------------------------------------------
;Interrupt 0Bh handler
;-------------------------------------------------------------------------------------------
Int_0Bh:		
                            MOV 	DX, L_Status_Reg		        ;2FD = Line Status Register
                            IN 		AL, DX 					        ;read it
                            TEST 	AL, 1					        ;if 1 = data received
                            JNZ 	OBR  					        ;go to handle the data  
				            JMP		Int_0Bh
;-------------------------------------------------------------------------------------------
OBR:    		;received byte processing
;-------------------------------------------------------------------------------------------
				
            				MOV 	AX,	CS
            				MOV 	DS,	AX
            				MOV 	ES,	AX
            
            				MOV 	DX,	Int_ID_Reg 			        ;2FAh - interrupt ID register
            				IN  	AL,	DX 					        ;read its status
            				AND 	AL,	6                           
            				CMP 	AL,	04 					        ;is there somesthing for us?
            				JZ 		REC    					        ;yes  
            				JMP 	INT_RET
;-------------------------------------------------------------------------------------------
REC:    		            ;byte receiving
            				MOV 	AL,	64h 				        ;mask IRQ4 for not interrupting
            				OUT 	20h, AL                         
            				MOV 	DX,	Int_ID_Reg 			        ;2FAh - interrupt ID register
            				IN 		AL,	DX                          
            				TEST 	AL,	4 					        ;receive?
            				JNZ 	READ  					        ;yes,receive byte 
            				JMP     INT_RET
;-------------------------------------------------------------------------------------------
READ: 			;read byte from serial port receiving register
;-------------------------------------------------------------------------------------------
            				MOV 	DX,	L_Status_Reg 		        ;2FDh = line status register
            				IN 		AL,	DX   				        ;read it
            				AND 	AL,	2   				        ;error?
            				MOV 	OVERR,	AL 				        ;set OVERRUN BIT <>0, if symbol lost
            				MOV 	DX,	Data_Reg 			        ;2F8h = data register
            				IN 		AL,	DX 					        ;clear the receiving register
            				                                        
            				CMP     AL, 01010000b                   ;se clicar com botao direito do mouse 
                            JE      INT_RET

            				INC     INIT_COM_PORT				
            				CMP     INIT_COM_PORT, 3
            				JE      INT_RET
            
                            JMP     Int_0Bh  


INT_RET:        
                            MOV 	AL, OldIMR
                            OUT 	21h, AL  				        ;1-st PIC IMR restoring  
                            
                            RET

;*************************************************************************************************************************************            

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
        
INT20                       PROC                                     ;interrupt 20h starts here: 
                            
                            push    cs                               ;make sure data segment is code segment:
                            pop     ds 
                            push    cs
                            pop     es
                            
                            cmp     ax, 4E00h                        ;4E00h infomra ao KERNEL.SYS
                            jne     videoOK                          ;que devera resetar o video
                            
                            mov     ah, 00h
                            mov     al, 03h
                            int     10h
    
                            mov     al, 00h
                        	mov     ch, 00h
                        	mov     cl, 00h
                        	mov     bh, 00000111b                     ;defino cor de fundo preta e letras cinzas
                        	mov     dh, 18h                           ;18h = 24d, numero de linhas do video
                        	mov     dl, 4fh                           ;4fh = 84d, numero de colunas
                        	mov     ah, 06h
                        	int     10h 
                            
videoOK:                    mov     CMD, ah
                            cmp     CMD, 4Fh                         ;AH <> 4Fh Carrega o COMMAND.COM
                            jne     LoadCommand 
                            
loadEXE:                    mov     bx, OFFSET Program               ;o registrador bx recebe o endereco do buffer Program
                            mov     si, 0                            ;onde o nome do mesmo sera armazenado
                            mov     cx, 11 
            
cLoad:                      push    ds
                            
                            mov     ax, 0800h                        ;o COMMAND.COM escreveu em ds:si 0800:0000
                            mov     ds, ax                           ;o nome do programa a ser carregado
                                                                     
                            mov     dl, byte ptr ds:[si] 

                            pop     ds
                            
                            mov     byte ptr [bx], dl                ;movo o array de caracteres para o buffer Program
                            
                            inc     si
                            inc     bx
                            
                            loop    cLoad

LoadCommand:                jmp     start 
          
                            
LeiaDisco:                  call    ConvertLBACHS
                            mov     ah, 02h
                            mov     al, 01h
                            mov     ch, [Trilha]                    ;C - Clylinder / Track
                            mov     dh, [Cabeca]                    ;H - Head
                            mov     cl, [Setor]                     ;S - Sector
                            mov     dl, [bsDriveDisquete]
                            int     13h 
                            jc      reiniciar 
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
							
reiniciar:				    mov     ax, 40h
                            mov     ds, ax
                            mov     bx, 72h
                            xor     ax, ax
                            mov     [bx], ax
                            dec     ax
                            push    ax
                            inc     ax
                            push    ax
                            retf

;*************************************************************************************************************************************	                        

start:						mov     ax, DiretorioRaiz               ;Diretorio Raiz em Floppy A:\>
                            mov     bx, 0400h                       ;OFFSET onde os nomes dos Arquivos/DIRs sao carregados
                            mov     di, 0400h                       ;OFFSET onde sera comparado com o nome da imagem do KERNEL.SYS
                            mov     cx, ArquivosDiretoriosPorSetor  ;16 Arquivos/DIR
                            
ProximoSetor:               call    LeiaDisco
                            
                            cmp     CMD, 4Fh
                            jne     carregarCommand 
							mov     si, OFFSET Program 
							mov     cx, 11			
							jmp     localizarPrograma
							              						
carregarCommand:            mov     si, OFFSET Command
localizarPrograma:          mov     dx, 16
																	
                    cont:   push    si                              
                            push	di                           
                            mov     cx, 0Bh
                            repe    cmpsb
                            je      LeiaFAT
                            pop     di
                            add     di, 20h 
                            dec     dx
                            cmp     dx, 0
                            je      exeProgram
							pop 	si
                    jmp    cont
                    
                            dec     [TotalSetoresDiretorioRaiz]     ;14 - representa o Total de Setores do diretorio Raiz
                            cmp     [TotalSetoresDiretorioRaiz], 0  ;Verifica se percorreu os 14 setores
                            je      exeProgram                      ;Percorreu todos e nao encontrou o programa .COM
                            inc     [DiretorioRaiz]                 ;Ainda nao percorreu os 14 setores e vai para o proximo
                            mov     ax, DiretorioRaiz
                            jmp     ProximoSetor
							
                            jmp     sair                            ;Nao encontrou o arquivo
                            
exeProgram:                 cmp     EXE, 1
                            je      sair 
                            
                            mov     buffer, 0
                            
                            push    ds
                            push    si
                            
                            mov     ax, 0800h                       ;Ate aqui nao foi encontrado um programa com a extensao .COM
                            mov     ds, ax                          ;entao substituo no endereco 0800:0008 ~ 0800:0010
                            xor     ax, ax                          ;a extensao .EXE
                            mov     si, 8
                            
                            mov     ds:[si], byte ptr 45h           ;E
                            inc     si
                            mov     ds:[si], byte ptr 58h           ;X
                            inc     si
                            mov     ds:[si], byte ptr 45h           ;E
                            inc     si 
                            
                            pop     si
                            pop     ds
                            
                            mov     EXE, 1
                            jmp     loadEXE                         ;tento localizar o programa com a extensao .EXE
                            
                                                       
LeiaFAT:                    pop     di
                            xor     dx, dx
                            mov     ax, [di + 001Ah]                ;Leio o 26 Byte, para Encontrar o cluster inicial do arquivo  
                            mov     bx, 0600h
                            push    bx
                            
ProximoCluster:             pop     bx
                            mov     [cluster], ax                   ;Armazeno o cluster inicial 
                            xor     dx, dx
                            div     [bpbBytesPorSetor]              ;Divido o cluster inicial pelo numero de bytes por setor
                            inc     al                              ;Pego o resultado e adiciono 1
                                                                    ;Ex: cluster 2 / 512 = 0 + 1 = 1 - LBA 2
                            call    LeiaDisco                       ;Outro Ex: 1081 / 512 = 2 + 1 = 3 - LBA 3
                            push    es
                            push    bx
                            
                            cmp     CMD, 4Fh                        ;AH = 4Fh carrega user program
                            jne     loadCMD01                       ;AH <> 4Fh carrega o COMMAND COM
                            mov     ax, 0B00h                       ;os demais programas serao carregados em 0B00:0100 
                            jmp     loadCMD02     
                            
loadCMD01:                  mov     ax, 0800h                       ;o COMMAND COM sera carregado em 0800:0100
loadCMD02:                  mov     es, ax

                            mov     bx, buffer                      ;zero o buffer, pois o OFFSET do programa .EXE deve ser 0
                                         
                            mov     ax, 31d                         ;A regra abaixo consiste em:
                            mov     dx, [Cluster]                   ;Endereco LBA da area de dados dos arquivos
                            add     ax, dx                          ;que se inicia no Setor 33 - 2 primeiros Clusters reservados = 31
                            call    LeiaDisco                       ;Mais Cluster indicado na tabela FAT. Entao 31 + 2 = 33 
                                                                    ;para o primeiro arquivo no disco
                                       
                            pop     bx
                            pop     es 
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
                            
                            mov     Buffer, 0100h                   ;Reseta o Buffer para futura reutilizacao
							
                            cmp     CMD, 4Fh
                            jne     loadCMD03
							
                            cmp     EXE, 1
                            je      peFormat
							
                            push    0B00h                           ;os programas com extensao .COM
                            push    0100h                           ;serao carregados em 0B00:0100 
                            retf 
                            
peFormat:					mov     EXE, 0                          ;resseto o valor, para futuras buscas
                            mov     ax, 0B00h                       
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
                            push    ds:[14h]  						; ip
                                                                    
                            mov     dl, 0                           ; let program know boot drive
                            sti
                            retf
                            
loadCMD03:                  push    0800h                           ;o COMMAND COM sera carregado em 0800:0100
                            push    0100h
                            retf
                                              
                            sair:
                            mov     cx, 35 
                            mov     si, OFFSET Erro
                loopErro:   mov     al, [si]
                            mov     ah, 0Eh
                            int     10h
                            inc     si
                            loop    loopErro
                            
                     fim:   mov     buffer, 0100h                   ;reseta o buffer, pois pode ter sido alterado
																	;ao tentar carregar um programa .EXE
																	
							mov		EXE, 0							;reseto o valor para as proximas buscas						
							
                            xor     ax, ax							;Lembrando: AH = 00h - carrega COMMAND.COM                         
                            int     20h								;Lembrando: AH = 4Fh - carrega programa
 
                            
;*************************************************************************************************************************************                            

bpbBytesPorSetor            dw      512                             
bpbTotalSetoresPorTrilha    dw      18                              
bpbTotalCabecasNoDisco      dw      2                               
bsDriveDisquete             db      0                                

Cluster                     dw      0                    

Cabeca                      db      0
Trilha                      db      0
Setor                       db      0
                                                                    
DiretorioRaiz               dw      19                              ;endereco LBA do diretorio Raiz 
ArquivosDiretoriosPorSetor  dw      16                              ;16 Arquivos/DIRs de 32 Bytes = 512 Bytes = 1 Setor
TotalSetoresDiretorioRaiz   dw      14                              ;14 Stores com 16 Arquivos/DIRs = 224 Arquivos

Program                     db      11 dup(0)                       ;reserva 11 bytes, para o nome do programa a ser carregado
Command                     db      "COMMAND COM"                    
Buffer                      dw      0100h                           ;Offset onde e carregado cada setor lido = BX 0100h
CMD                         db      0                               ;[Int 20h AH <> 4Fh - USER PROGRAM] [Int 20h AH XXh COMMAND.COM]

EXE                         db      0                               ;Caso o KERNEL.SYS nao encontre o programa com a extensao
                                                                    ;.COM ele ira procurar com a extensao .EXE

Erro                        db      "Programa ou comando nao encontrado!"                             
               
INT20                       ENDP

;*************************************************************************************************************************************

_TEXT ENDS
END EntryPoint
