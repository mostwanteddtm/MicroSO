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
	        setor   db  1         
.CODE 

ORG 100h 

main:       push    cs                          ; Programa para obter os dados 
            pop     ds                          ; da ROM BIOS referentes a Font 8x16
            push    es
            
            mov     ax, 1130h                   ; service 11/30 ­ get font info
            mov     bx, 0600h                   ; ROM 8x16 font
            int     10h                         ; retorno em ES:BP 

write:      cmp     byte ptr [setor], 9
            je      fim            
            mov     ah, 03h
            mov     al, 1
            mov     ch, 0                       ; Cylinder
            mov     dh, 0                       ; Head
            mov     cl, byte ptr [setor]        ; Sector
            mov     dh, 0
            mov     dl, 0
            mov     bx, bp
            int     13h                         ; gravando de ES:BP
            
            add     byte ptr [setor], 1 
            add     bp, 512
            jmp     write
             
fim:        pop     es
            int     20h
		
    
_TEXT ENDS
END main
