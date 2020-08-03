#masm#

;--------------------------------------------------------|
;                                                        |
;       Template para compilacao com MASM 6.15           |
;     Facimente testado no EMU8086 com a diretiva        |
;                       #masm#                           |
;                                                        |
;--------------------------------------------------------|  

.286
.model tiny
.STACK 100					   
_Text SEGMENT PUBLIC USE16
     
            OPTION EXPR16               ;CONSTANTES COM TAMANHO DE 16 BITS   

.data
            DADOS EQU 21                ;PODE SER TMB DADOS = 21
            CHAR TYPEDEF BYTE           ;define um tipo persolnalizado de variavel  
            CHR CHAR 'A' 
            
            buffer EQU 5
            
            IFDEF buffer
            buff BYTE buffer DUP(15)
            ENDIF            
.code 

org 100h 

main:
            mov ax, OFFSET [DADOS]
            mov al, CHR
        
        .IF (CHR == 41h)
            
            mov bl, al
          
        .ENDIF 
        
            COMMENT ^ 
                COMENTANDO VARIAS
                LINHAS
            ^
            
            
            int 20h
    
_Text ENDS
end main
