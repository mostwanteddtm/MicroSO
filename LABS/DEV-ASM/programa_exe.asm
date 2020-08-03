TITLE Ola Mundo

#MAKE_EXE# 

INCLUDE biblio.inc

DADOS SEGMENT 'DATA'
    nome1 db 'Paula e ', 0dh, 0ah, 24h
    nome2 db 'Marcos, super apaixonados!$'
DADOS ENDS

PILHA SEGMENT STACK 'STACK'
    dw 0100h dup(?)
PILHA ENDS  

CODIGO SEGMENT 'CODE'
    
    ASSUME CS:CODIGO, DS:DADOS, SS:PILHA 
    
    ;a macro ou proc pode vir aqui
    
    INICIO PROC FAR
        mov ax, DADOS
        mov ds, ax
        mov es, ax 
        
        mov ah, 00h
        mov al, 03h
        int 10h
        
        mov ah, 06h
        mov al, 0h
        mov bh, 10011100b
        mov ch, 0h
        mov cl, 0h
        mov dh, 18h
        mov dl, 4fh
        int 10h
        
        EXIBIR nome1, nome2
        
        mov ah, 4ch
        int 21h
        
        ret   
        
    INICIO ENDP 
    
CODIGO ENDS

END INICIO