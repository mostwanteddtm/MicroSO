;Este programa le um arquivo de um disquete no drive 'A:' e mostra o conteudo 
;na tela. Utiliza a INT 13h (drive) e INT 10h (video).
;Imprime os dados sem tratamento.

PILHA           SEGMENT PARA STACK 'STACK'

                DW  100 DUP(?)

                TOP_PILHA LABEL WORD        
PILHA           ENDS


DADOS           SEGMENT PARA 'DATA'

ERRO_MSG        DB 'FALHA NA LEITURA DO DRIVE A: $'
BUFFER          DB 9*512 DUP (?)
LBUFFER	        =	$-BUFFER

DADOS           ENDS


CODIGO          SEGMENT PARA 'CODE'
                ASSUME CS:CODIGO,SS:PILHA,DS:DADOS,ES:DADOS

INICIO          PROC   FAR
                 
                MOV    AX,DADOS
                MOV    DS,AX 
		MOV    ES,AX             ;INICIALIZA REGISTROS DE SEGMENTO.    
                
                MOV    CH,0              ;TRILHA
                MOV    DH,0              ;FACE
                MOV    SI,3              ;# DE TENTATIVAS

LEIA:           MOV    DL,0              ;UNIDADE
                MOV    CL,2              ;SETOR INICIAL
                ;MOV    BX,OFFSET BUFFER  ;AREA DE ARMAZENAMENTO
                lea bx, BUFFER
                MOV    AH,2
                MOV    AL,9
                INT    13H               ;TENTA LER A TRILHA DA UNIDADE A:
                JNC    MOSTRAR
                CMP    AH,80H            ;NAO CONSEGUIU
                JE     ERRO              ;DESISTE SE "TIME-OUT"
                MOV    AH,0
                INT    13H               ;REINICIA INTERFACE
                DEC    SI
                JNZ    LEIA              ;REPETE NO MAXIMO 3 VEZES
                JMP    ERRO

ERRO:           lea    DX, ERRO_MSG
                MOV    AH,9		
                INT    21H	         ;MOSTRA MENSAGEM DE ERRO.	
		JMP     FIM
		                
MOSTRAR:	MOV	AH,15
		INT 	10H	         ;INFORMA ESTADO DO VIDEO	
		MOV     AH,02
		MOV     DL,1           
		MOV     DH,1
		INT     10H              ;POSICIONA CURSOR
		
		;MOV	CX,LBUFFER 
		MOV     CX, 15h    
 		LEA   	SI,BUFFER 
 		
MOSTRA:		MOV   	AL,[SI]	  	
		MOV 	AH,14
		INT 	10H              ;MOSTRA NA TELA O CONTEUDO DO BUFFER
		INC     SI
		JCXZ FIM		
		LOOP	MOSTRA 
		
			
FIM:            ret               ;ENCERRA O PROGRAMA
		  
INICIO          ENDP

CODIGO          ENDS 

END INICIO
