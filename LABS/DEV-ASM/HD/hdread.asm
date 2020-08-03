
;--------------------------------------------------------|
;                                                        |
;       Template para compilacao com MASM 6.15           |
;     Facimente testado no EMU8086 com a diretiva        |
;                       #masm#                           |
;                                                        |
;--------------------------------------------------------|  

.286
.MODEL TINY
.STACK					   
_TEXT SEGMENT PUBLIC USE16
.DATA     
		    message         DB  'Erro ao tentar ler o primeiro setor do HD...', 0  
		    tabconvert      DB  '0123456789ABCDEF' 
		    count           DW  0
		    buffer          DB  512 DUP(0) 	            
.CODE 

ORG 100h

;==========================================================================================================  

start:	            mov     ax, cs
                    mov     ds, ax
                    push    es
                    mov     es, ax
                    
                    mov     ax, 01h
                    mov     ch, 00h             ;c 
                    mov     dh, 00h             ;H
                    mov     cl, 01h             ;s
                    mov     dl, 80h
                    mov     bx, OFFSET buffer
                    mov     ah, 02h
                    int     13h
                    jc      error
                    mov     si, OFFSET buffer
                    mov     bx, OFFSET tabconvert 
                    mov     ah, 0Eh 
                    mov     cx, 512
                    call    showvalue
                    jmp     fim
                    
 
error:              mov     si, OFFSET message  
                    call    prn 
                    
                    pop     es                                                   
fim:           		int		20h  

;========================================================================================================== 

showvalue           PROC    NEAR
                	
svalue::            mov     al, [si] 
                    rol     al, 4
                    and     al, 00001111b
                    xlat
                    int     10h
                    
                    mov     al, [si]
                    and     al, 00001111b
                    xlat
                    int     10h 
                    
                    add     count, 3
                    cmp     count, 80
                    jge     nextline 
                    
                    mov     al, 20h
                    int     10h
                    
                    inc     si 
                    
                    loop    svalue 

                    ret
                    
showvalue           ENDP

;==========================================================================================================            		
            		
prn                 PROC    NEAR
                    
                    lodsb
                    cmp     al, 0
                    je      fprn
                    mov     ah, 0Eh
                    int     10h
                    jmp     prn
                    
fprn:               ret 

prn                 ENDP 

;========================================================================================================== 

nextline:           mov     count, byte ptr 0 
                    inc     si

                    jmp     svalue

_TEXT ENDS
END start
