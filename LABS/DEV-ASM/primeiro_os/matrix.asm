org 0000h

EntryPoint: 

    push cs
    pop ds

    mov ah, 00h
    mov al, 03h ;modo de video 25 linhas, 80 colunas
    int 10h
    
    while:
 
        call ImprimirLinha
        mov Line, 50h ;sempre o mesmo valor inicial da variavel 
         
        call Timer
        
        inc Count
        
        cmp Count, 18h
        jg  call Scroll_line
        ContinueScroll_line: 
        
        call PularLinha
        
        cmp Count, 50h ;define a quantidade total de linhas que sera exibido
        je call Continue
        
    jmp while
    
    Continue:
    call Sair
    jmp 0800h:0000h 
    ;ret
    
    ImprimirLinha proc near
        
        do: 
            
            mov al, [Rnd] 
            sub al, 30h 
            and al, 01h
            jpe call Zero
            jpo call Um
            ContinueImprimirLinha: 
            mov cx, 01h         ;numero de caracteres a ser escrito  
            mov bl, 0000_0010b  ;cor de fundo e letra
            mov bh, 00h         ;pagina 0
            mov ah, 09h         ;escreve o numero de caractere em cx
            int 10h
            
            inc Rnd 
            
            call AvancarColuna
            
            dec Line
            jz SairLinha
            
        jmp do
        
        SairLinha:
         
        ret
      
    endp 
    
    PularLinha proc near
        
        inc CurX 
        inc Rnd
        
        mov CurY, 00h
        mov dh, CurX
        mov dl, CurY
        mov bh, 00h 
        mov ah, 02h
        int 10h
        
        ret 
    
    endp 
    
    AvancarColuna proc near
        
        inc CurY
        mov dh, CurX
        mov dl, CurY
        mov bh, 00h 
        mov ah, 02h
        int 10h
        
        ret 
    
    endp
    
    Timer proc near
        
        ;TIMER
        ;1.000.000 microseconds = 1 second  
        ;interval for 1 second, set CX=000fH and DX=2440H.
        ;interval for 2 seconds, set CX=001eH and DX=8480H. 
        
        mov     cx, 04h
        mov     dx, 1220h
        mov     ah, 86h
        int     15h
        
        ret
         
    endp
    
    Zero proc near
        mov al, 30h 
        jmp ContinueImprimirLinha
    endp
    
    Um proc near
        mov al, 31h 
        jmp ContinueImprimirLinha
    endp 
    
    Scroll_line proc near

         push bp
         mov bp, sp
         mov ah, 07h          ;function 7H scroll down
         mov al, 01h          ;number of lines to scroll
         mov ch, 00h          ;row of top left corner
         mov cl, 00h          ;col of top left corner
         mov dh, 18h          ;row of bottom right corner
         mov dl, 4fh          ;col of bottom right corner
         mov bh, 0000_0010b   ;attribute of line
         int 10h              ;interrupt 10h
         pop bp
         
         stc
         mov CurX, 0FFh
         mov CurY, 0FFh
         
         jmp ContinueScroll_line

    endp
    
    Sair proc near 
        
        mov al, 03h
        mov ah, 0
        int 10h
        
        mov     bh, 00h
        mov     dl, 00h
        mov     dh, 0h
        mov     ah, 02h
        int     10h
        
        ret 
           
    endp
    
    Count db 00h ;define o numero de linhas que sera impressa na tela
    CurX db 00h  ;posicao do cursor (Linha)
    CurY db 00h  ;posicao do cursor (Coluna)
    Line db 50h  ;Caractere por linha
    Rnd db 30h   ;numero que sera usado para exibir 0 e 1

end 