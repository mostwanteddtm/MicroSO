;-------------------------------------------------------------------------------|
;                                                                               |
;     Copyright Marcos Roberto da Costa - 18 de Novembro de 2015                |
;                                                                               |
;             COMMAND 1.01 - Compilado Com MASM 6.15                            |
;                                                                               |
;   Area de memoria do COMMAND 0800:0100 ~ 0B00:0100 -> 33.0240k ~ 45.312K      |               
;                                                                               |
;-------------------------------------------------------------------------------|

.286
.MODEL TINY
.STACK

_TEXT SEGMENT PUBLIC USE16
    
    ASSUME DS:_TEXT,ES:_TEXT,SS:_TEXT 
    
;*************************************************************************************************************************************
    
.DATA
 
        maxLenCmd   				EQU 75                     ;constante de maximo de caracteres digitaveis por linha 
        
        HexTab                      BYTE    "0123456789ABCDEF"
        Regs	                    BYTE	"CS DS ES SS BP SP SI DI",0
        
        CrLf        				BYTE    0Dh, 0Ah, 0
        
        prompt      				BYTE    "A:\>", 0 

        AJUDA                       BYTE    "AJUDA", 0
        CLS                         BYTE    "CLS", 0
        DIR         				BYTE    "DIR", 0   
        RELOAD      				BYTE    "RELOAD", 0 
        RESTART                     BYTE    "RESTART", 0
        SHOWREGS                    BYTE    "SHOWREGS",0 
        
        copyright 					BYTE    "Copyright MicroSO 1.01 by Marcos Roberto da Costa, 18 de Novembro de 2015"
                                    BYTE    0Dh, 0Ah
                                    BYTE    "*****     Para entender como utilizar o sistema, digite: AJUDA      *****" 
                                    BYTE    0Dh, 0Ah, 0
        
        minCurPos					BYTE	4		
        atualPos					BYTE	0
        lenCommand					BYTE	0
        
        Message     				BYTE    "Lista de arquivos encontrados no disquete A:", 0Ah, 0Dh, 0Ah, 0Dh
									BYTE    "Arquivo      Data        Hora", 0Ah, 0Dh, 0Ah, 0Dh, 0
                
		EndMessageIni  				BYTE    0Ah, 0Dh, "Total de ", 0
		EndMessageFim  				BYTE    " arquivos encontrados.", 0Dh, 0Ah, 0

		imageIni  					WORD    900h 
        
		bpbTotalDiretoriosArquivos  WORD    224
		bpbTotalSetoresPorTrilha    WORD    18
		bpbTotalCabecasNoDisco      WORD    2
		bsDriveDisquete             BYTE    0

		Cabeca                      BYTE    0
		Trilha                      BYTE    0
		Setor                       BYTE    0 

		dataHora                    BYTE    10 dup (0)  
		Decimal                     WORD    10
		countImages                 BYTE    0
		
		messageAjuda                BYTE    "Comandos reconhecidos pelo sistema MicroSO 1.01:", 0Dh, 0Ah, 0Dh, 0Ah 
		                            BYTE    "AJUDA    - Exibe comandos suportados pelo sistema MicroSO 1.01.", 0Dh, 0Ah
		                            BYTE    "CLS      - Limpa a tela e exibe o prompt de comando.", 0Dh, 0Ah
		                            BYTE    "DIR      - Lista arquivos e programas armazenados no disquete.", 0Dh, 0Ah 
		                            BYTE    "RELOAD   - Limpa a tela, exibe a mensagem de Copyright e o prompt de comando.", 0Dh, 0Ah
		                            BYTE    "RESTART  - Reinicia o computador.", 0Dh, 0Ah
		                            BYTE    "SHOWREGS - Exibe os valores dos Registradores: CS DS ES SS BP SP SI DI.", 0   
		                            
        command     				BYTE    8       dup(0) 
        COM         				BYTE    "COM"       
                   
.CODE

ORG 100h  

;*************************************************************************************************************************************

EntryPoint:     		push        cs                          ;As 5 Linhas abaixo, devem ser usadas no c0t.asm
						pop         ds                          ;preservam o estados dos registradores
                
start:          		push        es                          ;durante a execucao do codigo
						push        cs
						pop         es
						xor         ax, ax
						mov         ss, ax 
						
						call        SETVIDEOMODE
						
						call        GETCURSORPOSITION
 
						mov         si, OFFSET prompt           ;exibe o prompt de comando
						call        PRINT
                
sprint:         		call        GETCHAR 
                
					   ;VALIDA O COMANDO DIR
					   
						mov         cx, 3
						cmp         lenCommand, 3
						jne         continue01
						mov         di, OFFSET DIR              ;valida se o comando a ser executado sera o DIR
						mov         si, OFFSET command 
						
						repe        cmpsb
						jne         continue01
						call        INITPASSCONTROL             ;quebra de linha para exibicao do texto
						call        DIRCMD
						
						call        CLEARCOMMAND                ;zera da nemoria o comando digitado
						
						pop         es                         
						jmp         start                       ;reinicia o COMMAND.COM sem leitura do drive A:\
             
continue01:    			;VALIDA O COMANDO RELOAD  
                        
                        mov         cx, 6 
                        cmp         lenCommand, 6
						jne         continue02
						mov         di, OFFSET RELOAD              
						mov         si, OFFSET command 
				 
						repe        cmpsb
						jne         continue02
						call        INITPASSCONTROL             
						call        RELOADCMD
						
						call        CLEARCOMMAND                
						
						pop         es                         
						jmp         start

continue02:             ;VALIDA O COMANDO AJUDA  
                
					    mov         cx, 5 
					    cmp         lenCommand, 5
						jne         continue03
						mov         di, OFFSET AJUDA              
						mov         si, OFFSET command 
				 
						repe        cmpsb
						jne         continue03
						call        INITPASSCONTROL             
						call        AJUDACMD
						
						call        CLEARCOMMAND                
						
						pop         es                         
						jmp         start

continue03:				;VALIDA O COMANDO CLS  
                
                        mov         cx, 3 
                        cmp         lenCommand, 3
						jne         continue04
						mov         di, OFFSET CLS              
						mov         si, OFFSET command 
				 
						repe        cmpsb
						jne         continue04
						call        INITPASSCONTROL             
						call        CLSCMD
						
						call        CLEARCOMMAND                
						
						pop         es                         
						jmp         start

continue04:		        ;VALIDA O COMANDO RESTART  
                
                        mov         cx, 7  
                        cmp         lenCommand, 7
						jne         continue05
						mov         di, OFFSET RESTART              
						mov         si, OFFSET command 
				 
						repe        cmpsb
						jne         continue05
						call        INITPASSCONTROL             
						call        RESTARTCMD
						
						call        CLEARCOMMAND                
						
						pop         es                         
						jmp         start

continue05:             ;VALIDA O COMANDO SHOWREGS  
                
                        mov         cx, 8   
                        cmp         lenCommand, 8
						jne         continue06
						mov         di, OFFSET SHOWREGS              
						mov         si, OFFSET command 
				 
						repe        cmpsb
						jne         continue06
						call        INITPASSCONTROL             
						call        SHOWREGSCMD
						
						call        CLEARCOMMAND                
						
						pop         es                         
						jmp         start 
						
continue06:
						pop         es                          ;sempre que for transferir o controle da execucao. 
						                                        ;Preservar o estado do registrador ES
						
						call        INITPASSCONTROL             ;quebra de linha para exibicao do tezto
						
						mov         cx, 11
						call        LOADPROGRAM 
						
						mov         ah, 4Fh
                  		int         20h  

;-------------------------------------------------
;                                                 *
;           Inicio das SubRotinas                 *
;                                                 *
;-------------------------------------------------*

;************************************************************************************************************************************* 

GETCURSORPOSITION       PROC 
    
                        mov         ah, 03h
                        xor         bx, bx
                        int         10h
                        
                        cmp         dh, 0
                        je          naoPularLinha
                        
                        mov         si, OFFSET CrLf
                        call        PRINT
                        
naoPularLinha:          ret 
    
    
GETCURSORPOSITION       ENDP

;*************************************************************************************************************************************

SETVIDEOMODE            PROC
                        
                        mov         ah, 0Fh
                        int         10h
                        cmp         al, 03h
                        je          videoOK 
                        
                        mov         ah, 00h
                        mov         al, 03h
                        int         10h

videoOK:                mov         ah, 0Bh                     ;Definir cor de fundo padrao DOS
                        xor         bx, bx
                        ;int         10h

                        ret
    
SETVIDEOMODE            ENDP 

;*************************************************************************************************************************************

RESTARTCMD              PROC
                        
                        mov         ax, 40h
                        mov         ds, ax
                        mov         bx, 72h
                        xor         ax, ax
                        mov         [bx], ax
                        dec         ax
                        push        ax
                        inc         ax
                        push        ax
                        retf
    
RESTARTCMD              ENDP

;*************************************************************************************************************************************

CLSCMD                  PROC
                        
                        mov         ah, 00h
						mov         al, 03h
						int         10h

						ret
    
CLSCMD                  ENDP

;************************************************************************************************************************************* 

AJUDACMD                PROC
                        
                        mov         si, OFFSET messageAjuda
                        call        PRINT
                        ret

AJUDACMD                ENDP


;*************************************************************************************************************************************

CLEARCOMMAND    		PROC                                    ;limpa da memoria o ultimo comando digitado
                                                        
						mov         cx, 8
						mov         si, OFFSET command
clearCMD:       		mov         [si], byte ptr 0
						inc         si
						loop        clearCMD
						 
						mov         lenCommand, 0
						ret
                
CLEARCOMMAND    		ENDP

;************************************************************************************************************************************* 

INITPASSCONTROL 		PROC                                    ;quebra de linha para exibicao de texto
    
						mov         si, OFFSET CrLf
          
initPass:       		lodsb
						cmp         al, 0
						je          fimPass
						mov         ah, 0Eh
						int         10h
						jmp         initPass
                
fimPass:        		ret
    
    
INITPASSCONTROL 		ENDP

;*************************************************************************************************************************************

GETCHAR		    		PROC 

get:		    		xor		    ax, ax
						int		    16h
						
						jmp		    getPos                      ;verifico a posicao atual do cursor na tela
			
cGetPos:	    		cmp		    al, 08
						je		    calcPos                     ;rotina para impedir que possa apagar o prompt
			
						cmp		    al, 0Dh
						je		    sGetChar
						
						mov		    bh, maxLenCmd
						mov		    bl, lenCommand
						cmp		    bh, bl
						jle		    get
						
						cmp         lenCommand, 8               ;se o comando digitado for maior que 8
						jge         cLenCommand                 ;nao armazenar na memoria o caractere digitado
						
						mov         bx, OFFSET command 
						add         bl, lenCommand
						mov         dl, al                      ;passo o caractere digitado para o registrador DL
						cmp			dl, 30h
						jl			noUpper
						cmp			dl, 39h
						jl			noUpper
						and         dl, 0DFh                    ;Convert.ToUpper(DL)
noUpper:				mov         byte ptr [bx], dl           ;monto na memoria o comando a ser executado
    			
cLenCommand:			inc		    lenCommand 

cGetChar:       		mov		    ah, 0Eh
						int		    10h
			
						jmp		    get
			
sGetChar:	    		cmp         lenCommand, 0
						je          get
						ret
			
calcPos:	    		mov		    bh, minCurPos               ;se a posicao atual do cursor for = 4
						mov		    bl, atualPos                ;nao exibe nada e volta a solicitar que digite uma tecla
						cmp		    bh, bl
						je		    get  
						
						dec		    lenCommand
						
						cmp         lenCommand, 8               ;se apertou o backspace e o comando digitado for maior que 8
						jge         bLenCommand                 ;so exibe o caractere
						
						mov         bx, OFFSET command          ;se apertou o backspace e o ccomando digitado for menor que 8
						add         bl, lenCommand              ;limpa da memoria o ultimo caractere digitado
						mov         byte ptr [bx], 0		
    			
bLenCommand:			mov		    ah, 0Eh
						mov		    al, 08h
						int		    10h
						
						mov		    ah, 0Eh
						mov		    al, 20h
						int		    10h
						
						mov		    al, 08h
						jmp		    cGetChar
			
getPos:		    		mov		    ah, 03h
						mov		    bh, 0
						int		    10h
						
						mov		    atualPos, dl
						jmp		    cGetPos

GETCHAR         		ENDP

;*************************************************************************************************************************************

LOADPROGRAM     		PROC                                    ;para passar o controle para um programa
                                                                ;informo ao KERNEL.SYS
						mov         bx, OFFSET command          ;o local de memoria que estara o nome
						mov         si, 0                       ;do programa a ser carregado
																;local de memoria: 0800:0000
cLoad:          		push        ds

						mov         dl, byte ptr [bx]
						cmp         dl, 0
						jne         naoCriarEspaco              ;se o nome do arquivo/programa tiver menos de 8
						mov         dl, 20h                     ;caracteres, substituo os 0 por espaco 20h
						
naoCriarEspaco:			mov         ax, 0800h
						mov         ds, ax
						
						mov         byte ptr ds:[si], dl
						
						inc         si
						inc         bx
						
						pop         ds
						
						loop        cLoad
						
						ret
                
LOADPROGRAM     		ENDP

;*************************************************************************************************************************************

RELOADCMD       		PROC                                 ;rotina para limpeza de tela e reexibicao do CopyRight
                
						mov         ah, 00h
						mov         al, 03h
						int         10h
						
						mov         si, OFFSET copyright
						call        PRINT
						
						ret
    
RELOADCMD       		ENDP

;************************************************************************************************************************************* 

PRINT           		PROC
                
iPrint:         		lodsb
						cmp         al, 0
						je          fPrint
						mov         ah, 0Eh
						int         10h
						jmp         iPrint
                
fPrint:         		ret
    
PRINT           		ENDP 

;*************************************************************************************************************************************

DIRCMD          		PROC
    
						jmp         initDir
    
LeiaDisco:   			call 		ConvertLBACHS
						mov 		ah, 02h
						mov 		al, 01h
						mov 		ch, [Trilha] 			;C - Clylinder / Track
						mov 		dh, [Cabeca] 			;H - Head
						mov 		cl, [Setor]  			;S - Sector
						mov 		dl, [bsDriveDisquete]
						int 		13h 
						jc 			sair 
						ret
	          
ConvertLBACHS:  		xor 		dx, dx                
						div 		[bpbTotalSetoresPorTrilha]  
						inc 		dl                    
						mov 		[Setor], dl
						xor 		dx, dx                
						div 		[bpbTotalCabecasNoDisco] 
						mov 		[Cabeca], dl
						mov 		[Trilha], al 
						ret 
	    
PularLinha: 			mov 		ah, 0eh
						mov 		al, 0Ah
						int 		10h
						
						mov 		al, 0Dh
						int 		10h
						
						ret
        
ConvertDecimal:  		mov 		Decimal, 10
        
			cConvert: 	xor 		dx, dx
						div 		[Decimal]
						add 		dl, 30h 
						mov 		[dataHora+bx], dl
						inc 		bx
						cmp 		al, 9
						ja 			cConvert
        
continue: 				xor 		dx, dx
						xchg 		dl, al
						add 		dl, 30h 
						mov 		[dataHora+bx], dl

						mov 		si, offset dataHora
						add 		si, bx
        
        printConvert: 	mov 		ah, 0eh
						mov 		al, [si]
						cmp         di, 2
						je          printTotalFiles
						cmp 		al, 0
						je  		sairConvert
printTotalFiles:		int 		10h
						dec 		si
						loop 		printConvert 
        
sairConvert: 			xor 		dx, dx
        
						ret 
        
PrintData:  			xor 		dx, dx
						xor 		bx, bx
						xchg 		ah, al
						push 		ax
					
						and 		al, 00011111b
						mov 		dl, al
						mov 		ax, dx
						mov 		cx, 2
						call 		ConvertDecimal
        
						mov 		ah, 0eh
						mov 		al, 2Fh
						int 		10h
						
						pop 		ax
						push 		ax
						
						rcr 		ax, 5
						and 		al, 00001111b
						mov 		dl, al
						mov 		ax, dx
						mov 		cx, 2
						call 		ConvertDecimal 
					
						mov 		ah, 0eh
						mov 		al, 2Fh
						int 		10h
						
						pop 		ax
						
						rcr 		ah, 1
						xor 		dx, dx
						mov 		dl, ah 
						add 		dx, 7BCh
						mov 		ax, dx 
						mov 		cx, 4
						call 		ConvertDecimal 
        
						ret 
        
PrintHora: 				push 		ax
						xor 		ah, ah
						rcr 		al, 3
						and 		al, 00011111b 
						mov 		cx, 2
						call 		ConvertDecimal 
						
						mov 		ah, 0eh
						mov 		al, 3Ah
						int 		10h
        
						pop 		ax
						push 		ax
						
						xchg 		ah, al  
						and 		ah, 00000111b
						rcr 		ax, 5
						and 		al, 00111111b
						xor 		ah, ah 
						mov 		cx, 2
						call 		ConvertDecimal
						
						mov 		ah, 0eh
						mov 		al, 3Ah
						int 		10h
						
						pop 		ax
						xchg 		ah, al
						xor 		ah, ah
						and 		al, 00011111b
						rcl 		al, 1
						mov 		cx, 2
						call 		ConvertDecimal
        
						ret 
        
ExibirMensagem: 
    
	whileMessage:		lodsb
						cmp 		al, 0
						je 			sairMessage
						mov 		ah, 0eh
						int 		10h
						jmp 		whileMessage 
					
sairMessage:			ret
        
Espaco:					mov 		ah, 0eh
						mov 		al, 20h
						int 		10h
        
						mov 		al, 20h
						int 		10h
        
						ret 
        
         
initDir:   				mov         countImages, 0
                        mov 		ax, 19 				;Endereco LBA do Diretorio Raiz
						mov 		bx, imageIni  
						call 		LeiaDisco 
						
						mov 		si, offset Message
						call 		ExibirMensagem
						
						mov 		cx, [bpbTotalDiretoriosArquivos]
    
whileImages:  			xor 		bx, bx 
						mov 		si, imageIni 
						cmp         byte ptr [si+0Bh], 20h      ; O Build no Windows 10, gera o valor 20h no Offset 0Bh de cada arquivo no diretorio raiz
						je          whileImageName
                        cmp         byte ptr [si+0Bh], 0h       ; O Build no Windows 7/XP/ME/98/95, gera o valor 20h no Offset 0Bh de cada arquivo no diretorio raiz
						je          whileImageName
                        jmp         isdir						; Se nao for 20h ou 0h, entao se trata de diretorio e essa versao do SO ainda nao trata diretorio
                        
	whileImageName: 	mov 		ah, 0eh 				
						mov 		al, [si+bx]
						cmp 		al, 20h
						jl 			sair
						cmp 		al, 7Ah
						jg 			sair
						int 		10h
						inc 		bx
						cmp 		bx, 0Bh
						je 			continueImages
						jmp 		whileImageName  
        
continueImages:			call 		Espaco

						mov 		si, imageIni
						add 		si, 10h
						mov 		ah, [si]
						inc 		si
						mov 		al, [si]
						call 		PrintData 
            
						call 		Espaco 
            
						mov 		si, imageIni
						add 		si, 0Eh
						mov 		ah, [si]
						inc 		si
						mov 		al, [si]
						call 		PrintHora
                         
                        call 		PularLinha 
					    inc 		countImages
isdir:					add 		imageIni, 20h 
        
					    loop 		whileImages    
          
sair:					mov 		si, offset EndMessageIni
						call 		ExibirMensagem
    
                        xor         ax, ax 
                        mov         cx, 2
                        mov         di, 2
						mov 		al, CountImages
						call        ConvertDecimal
						
						mov 		si, offset EndMessageFim
						call 		ExibirMensagem 
						
						ret
                
DIRCMD          		ENDP  

;*************************************************************************************************************************************
 
SHOWREGSCMD             PROC  
    
                        mov         ax, cs
                        call        wax
                        mov         ax, ds
                        call        wax
                        mov         ax, es
                        call        wax
                        mov         ax, ss
                        call        wax
                        mov         ax, bp
                        call        wax
                        mov         ax, sp
                        call        wax
                        mov         ax, si
                        call        wax
                        mov         ax, di
                        call        wax
                
                        lea         si, Regs
                        cld
                        mov         ah, 0eh
                        mov         bx, 7

ErrorCycle:             lodsb
                        or          al, al
                        jz          ErrorDone
                        int         10h
                        jmp         short ErrorCycle 
                        
ErrorDone:              ret

wax:
                        pusha
                        mov         si, ax
                        mov         cx, 4
                        rol         si, cl  
                        
zzz:                    mov         ax, si
                        and         al, 0fh
                        lea         bx, HexTab
                        xlat
                        mov         ah, 0eh
                        mov         bx, 7
                        int         10h
                        rol         si, 4
                        loop        zzz
                        mov         al, 32
                        int         10h
                        popa
                        ret
   
    
SHOWREGSCMD             ENDP 

;*************************************************************************************************************************************               
_TEXT ENDS
END EntryPoint