
;---------------------------------------------------------------------------------------------------|
;                                                                                                   |
;            MEMVIEW 1.00 compilado com MASM 6.15 em 30 de Dezembro de 2015                         |
;                                                                                                   |
;---------------------------------------------------------------------------------------------------|  

.286
.MODEL TINY
.STACK 100					   
_Text SEGMENT PUBLIC USE16
.DATA
                CR                  EQU     0Dh 
                LF                  EQU     0Ah
                
                MAXLENCMD           EQU     9                   ;numero maximo de caractere que formara o comando
                
                REALENDDESLOC       EQU     0F0h                ;defino quantas coluas ira aparecer na tela 0000-0010-0020~00F0
                
                MARGEMDIR           EQU     20h, 20h, 20h 
                
                CRLF                BYTE    CR, LF, 0
                Espaco              BYTE    20h, 20h, 0
                
                inimargem           BYTE    MARGEMDIR, 0        ;alinhamento centralizado para as mensagens abaixo
     
                copyright           BYTE    MARGEMDIR
                                    BYTE    MARGEMDIR
                                    BYTE    " Copyright MEMVIEW 1.00 By Marcos R. Costa, 30 de Dezembro de 2015", CR, LF
                                    BYTE    MARGEMDIR
                                    BYTE    MARGEMDIR
                                    BYTE    " Para exibir os dados do computador, digite: SEGMENTO:DESLOCAMENTO", CR, LF, CR, LF
                                    BYTE    MARGEMDIR
                                    BYTE    MARGEMDIR
                                    BYTE    " Entre com o comando: 0000:0000", 0

                minCurPos	        BYTE	28		            ;posicao na tela onde o cursor espera comecar o comando
                atualPos	        BYTE	0
                lenCommand	        BYTE	0
                
                tabela              BYTE    CR, LF, CR, LF, "         "
                                    BYTE    "00 01 02 03 04 05 06 07 08 09 0A 0B 0C 0D 0E 0F   ASCII", CR, LF, CR, LF, 0 
                                    
                tabconvert          BYTE    "0123456789ABCDEF" 
                 
                segmento            WORD    0                   ;segmento digitado
                deslocamento        WORD    0                   ;deslocamento digitado
                
                contseg             WORD    0                   ;conta os 16 bytes que sera exibido por linha
                
                startdesloc         WORD    0                   ;valor inicial de deslocamento da imagem 0000
                enddesloc           WORD    REALENDDESLOC       ;valor final de deslocamento da imagem   00F0
                
                command             BYTE    0, 0, 0, 0, 3Ah, 0, 0, 0, 0           
.CODE 

ORG 100h 

main:

                        push        cs
                        pop         ds

                        mov         ah, 00h
                        mov         al, 03h
                        int         10h
                        
                        call        SETBGCOLOR
                        
                        mov         si, OFFSET copyright
                        call        PRINT 
                        
iniciar:                mov         si, OFFSET tabela           ;se um novo comando for digitado, reinicio as operacoes
                        call        PRINT
                        
                        call        SETSEG
                        call        SETOFF
                        
continuar:              call        SHOWDATA                    ;se apertar seta para cima ou para baixo
                                                                ;nao precisa definir novamente o segmento:deslocamento
                        call        RESETCUR 
                        call        GETCMD
                        
finalizar:              mov         ax, 4E00h                   ;informa ao KERNEL.SYS que reset a cor de fundo da tela
                        int         20h  
                        
                        
;*********************************************************************************************************************
;*********************************************************************************************************************
  
SETBGCOLOR              PROC        NEAR 
                        
                        mov         al, 00h
                    	mov         ch, 00h
                    	mov         cl, 00h
                    	mov         bh, 00011111b
                    	mov         dh, 18h                     ;18h = 24d, numero de linhas do video
                    	mov         dl, 4fh                     ;4fh = 84d, numero de colunas
                    	mov         ah, 06h
                    	int         10h
            	
                    	;HEX        BIN       COLOR
                    	;0          0000      black				- preto
                    	;1          0001      blue				- azul  
                    	;2          0010      green				- verde
                    	;3          0011      cyan				- ciano
                    	;4          0100      red				- vermelho
                    	;5          0101      magenta			- magenta
                    	;6          0110      brown				- marrom
                    	;7          0111      light gray		- cinza claro 
                    	;8          1000      dark gray			- cinza escuro
                    	;9          1001      light blue		- azul claro
                    	;A          1010      light green		- verde claro
                    	;B          1011      light cyan		- ciano claro
                    	;C          1100      light red			- vermelho claro
                    	;D          1101      light magenta		- magenta claro
                    	;E          1110      yellow			- amarelo
                    	;F          1111      white				- branco 
                    	
                    	;BH = Bit 8-5 BackGround | Bit 4-1 ForeColor
                    	
                    	ret
    
SETBGCOLOR              ENDP                
                
;*********************************************************************************************************************

PRINT                   PROC        NEAR
     
                        mov         ah, 0Eh 
                
cprint:                 lodsb
                        cmp         al, 0
                        je          sprint
                        int         10h
                        jmp         cprint
                                
sprint:                 ret    
    
PRINT                   ENDP

;********************************************************************************************************************* 

GETCMD		    		PROC 

get:		    		xor		    ax, ax
						int		    16h
						          
						cmp         ah, 48h                     ;seta para cima
						je          UPCMD
						cmp         ah, 50h                     ;seta para baixo
						je          DOWNCMD
						
						jmp		    getPos                      ;verifico a posicao atual do cursor na tela
			
cGetPos:	    		cmp		    al, 08
						je		    calcPos                     ;rotina para impedir que possa apagar o prompt
			
						cmp		    al, 0Dh
						je		    sGetChar
						
						cmp         al, 1Bh
						je          finalizar
						
						mov		    bh, MAXLENCMD
						mov		    bl, lenCommand
						cmp		    bh, bl
						jle		    get
						
						cmp         lenCommand, 9               ;se o comando digitado for maior que 9
						jge         cLenCommand                 ;nao armazenar na memoria o caractere digitado
						
						mov         bx, OFFSET command 
						add         bl, lenCommand
						mov         dl, al                      ;passo o caractere digitado para o registrador DL 
						
						cmp         dl, 30h
						jge         cNum
						
cNum:					cmp         dl, 39h
						jle         isNum
						
						cmp         dl, 3Ah                     ;3Ah ASCII :
						je          defValor 
						
                        sub         dl, 57h                     ;ja armazeno no command o valor e nao o codigo ASCII digitado
                        and         al, 0DFh                    ;Convert.ToUpper(DL)
                        jmp         defValor
                        						 
isNum:    				sub         dl, 30h                     ;ja armazeno no command o valor e nao o codigo ASCII digitado
                        
defValor:       		mov         byte ptr [bx], dl           ;monto na memoria o comando a ser executado
    			
cLenCommand:			inc		    lenCommand 

cGetChar:       		mov		    ah, 0Eh
						int		    10h
			
						jmp		    get
			
sGetChar:	    		cmp         lenCommand, 0
						je          get
						
						mov         lenCommand, 0               ;zero as variaveis para receber o proximo comando
						mov         startdesloc, 0
						mov         enddesloc, REALENDDESLOC 
						mov         contseg, 0
						
						jmp         iniciar                     ;reexibe o novo valor digitado
			
calcPos:	    		mov		    bh, minCurPos               ;se a posicao atual do cursor for = 4
						mov		    bl, atualPos                ;nao exibe nada e volta a solicitar que digite uma tecla
						cmp		    bh, bl
						je		    get  
						
						dec		    lenCommand
						
						cmp         lenCommand, 9               ;se apertou o backspace e o comando digitado for maior que 9
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

GETCMD         		    ENDP

;*********************************************************************************************************************  

SETSEG                  PROC        NEAR
                        
                        mov         si, OFFSET command          ;defino o segmento digitado em command
            	
                    	mov         dl, [si]
                    	mov         dh, [si+1]
                    	rol         dh, 4
                    	rol         dx, 4  
                    	
                    	mov         bl, [si+2]
                    	mov         bh, [si+3]
                    	rol         bh, 4
                    	rol         bx, 4
                    	
                    	mov         bh, dl
                    	mov         word ptr segmento, bx 
                    	        
                        ret
    
SETSEG                  ENDP 

;*********************************************************************************************************************

SETOFF                  PROC        NEAR
                        
                        mov         si, OFFSET command          ;defino o deslocamento digitado em command
            	
                    	mov         dl, [si+5]
                    	mov         dh, [si+6]
                    	rol         dh, 4
                    	rol         dx, 4  
                    	
                    	mov         bl, [si+7]
                    	mov         bh, [si+8]
                    	rol         bh, 4
                    	rol         bx, 4
                    	
                    	mov         bh, dl
                    	mov         word ptr deslocamento, bx 
                    	        
                        ret
    
SETOFF                  ENDP 

;*********************************************************************************************************************

SHOWDATA                PROC        NEAR
                        
                        mov         si, deslocamento            ;aponto para o deslocamento

inishowdata:   	        push        si
                        mov         si, OFFSET inimargem        ;margem direita para centralizar no monitor
                        call        PRINT
                        pop         si
                        
                        mov         cx, 4
                        mov         dx, startdesloc             ;variavel armazena o deslocamento 0000-0010-0020~00F0
                        rol         dx, 4
                        
cshowdesloc:            mov         bx, OFFSET tabconvert       ;tabela de caracteres 0123456789ABCDEF
                        mov         al, dl   
                        and         al, 00001111b
                        xlat                                    ;percorro o startdesloc para exibir 0000-0010-0020~00F0
                        mov         ah, 0Eh
                        int         10h
                        rol         dx, 4
                        loop        cshowdesloc 
                        
                        push        si
                        mov         si, OFFSET espaco           ;espaco de 2 caracteres pra comecar a exibir os bytes de dados
                        call        PRINT
                        pop         si
                        
inidesloc:              cmp         contseg, 10h                ;verifico se a linha ja foi preenchida com os 10h bytes de dados por linha
                        je          fimdesloc
                        push        ds
                        
                        mov         ax, segmento                ;defino segmento onde estao os bytes de dados
                        mov         ds, ax
                        xor         dx, dx
                        mov         dl, ds:[si]
                        
                        pop         ds
                        
                        mov         cx, 2
                        ror         dl, 4
cshowdata:              mov         bx, OFFSET tabconvert       ;tabela de caracteres 0123456789ABCDEF
                        mov         al, dl
                        and         al, 00001111b
                        xlat                                    ;exibo o byte na tela
                        mov         ah, 0Eh
                        int         10h
                        rol         dl, 4
                        loop        cshowdata 
                        
                        mov         al, 20h                     ;espaco para o proximo byte
                        mov         ah, 0Eh
                        int         10h
                                                 
                        inc         si
                        inc         contseg                     ;vou exibir 10h bytes por linha
                        jmp         inidesloc                   ;ainda nao exibiu os 10h bytes da linha
                        
fimdesloc:              push        si                          ;ja exibiu os 10h bytes por linha
                        mov         si, OFFSET espaco           ;espaco para comecar a preencher os caracteres ASCII
                        call        PRINT
                        pop         si
                        push        ds
                        mov         ax, segmento
                        mov         ds, ax
                        sub         si, 10h
                        mov         cx, 10h
                        mov         ah, 0Eh
showascii:              lodsb
                        cmp         al, 0Dh
                        je          setascii
                        cmp         al, 0Ah
                        je          setascii
                        jmp         nosetascii
setascii:               mov         al, 20h
nosetascii:             int         10h
                        loop        showascii
                        pop         ds
                        
                        
                        add         startdesloc, 10h           ;adiciono 10h para exibir na linha debaixo o proximo delocamento 0000-0010
                        mov         dx, enddesloc
                        cmp         word ptr startdesloc, dx   ;se ja exibiu os deslocamentos de 0000~00F0
                        jG          fimshowdata                ;fim da sub rotina
                        
                        push        si
                        mov         si, OFFSET CRLF
                        call        PRINT
                        pop         si
                        
                        mov         contseg, 0
                        jmp         inishowdata
                        
fimshowdata:            ret         
    
SHOWDATA                ENDP

;*********************************************************************************************************************  
 
RESETCUR                PROC        NEAR 
                                        
                        mov         ah, 02h
                        mov         dh, 03h
                        mov         dl, minCurPos
                        mov         bh, 0
                        int         10h
                        
                        ret                
                                        
RESETCUR                ENDP

;********************************************************************************************************************* 

UPCMD                   PROC        NEAR
    
                        mov         lenCommand, 0
                        mov         dx, enddesloc             ;ao mover a seta para cima subtraio 0F0h-0E0h
                        sub         dx, 0E0h                  ;entao comeco a exibir a partir de 0010
						mov         startdesloc, dx
						add         enddesloc, 10h
						add         deslocamento, 10h 
						mov         contseg, 0
						
						mov         si, OFFSET tabela
                        call        PRINT
						
						jmp         continuar                 ;continuo sem precisar redefinir o segmento:deslocamento
    
UPCMD                   ENDP

;*********************************************************************************************************************

DOWNCMD                 PROC        NEAR
    
                        mov         lenCommand, 0
                        mov         dx, enddesloc             ;ao mover a seta para baixo subtraio 0F0h-100h
                        sub         dx, 100h                  ;entao vou retroagir em 10h 0010->0000
						mov         startdesloc, dx
						sub         enddesloc, 10h
						sub         deslocamento, 10h 
						mov         contseg, 0
						
						mov         si, OFFSET tabela
                        call        PRINT
						
						jmp         continuar                ;continuo sem precisar redefinir o segmento:deslocamento
    
DOWNCMD                 ENDP

;*********************************************************************************************************************
    
_Text ENDS
end main
