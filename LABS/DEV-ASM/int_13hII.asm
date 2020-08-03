org  100h

jmp st
  
;compilar e salvar um arquivo teste.txt no mesmo diretorio
  
filename    db 'teste.txt'       ; full path up to 128 chars can be specified.
buffer      db 512 dup (0)
buffer_size =  $ - offset buffer
handle      dw 0
kernel_flag db 0               ; if there is /k parameter, kernel_flag=1.

counter dw 0


sect  db 2 ; sector number (1..18).
cyld  db 0 ; cylinder number (0..79).
head  db 0 ; head number (0..1).
drive db 0 ; drive number (0..3) ; A:=0, B:=1...


; init
st: mov ax, cs
    mov ds, ax
    mov es, ax


    mov sect, 2            ; start write at sector 2.  


; open file
of: mov ah, 3dh
    mov al, 0
    mov dx, offset filename
    int 21h
    mov handle, ax
        

; read bytes from file
rd: mov ah, 3fh
    mov bx, handle
    mov cx, buffer_size
    mov dx, offset buffer
    int 21h
    jc er

    cmp ax, 0  ; no bytes left?
    jz  cf
    

; write bytes to disk
wr: mov ah, 03h
    mov al, 1 ; write 1 sector (512 bytes).
    mov cl, sect  ; sector (1..18)
    mov ch, cyld  ; cylinder (0..79)
    mov dh, head  ; head  (0..1)  
    mov dl, drive ; always 0 (A:)
    mov bx, offset buffer
    int 13h
    jc er
     

; close file
cf: mov bx, handle
    mov ah, 3eh
    int 21h
    jc er


    lea dx, msg
    mov ah, 09h
    int 21h 
    msg db 'fim$'
    
    ret
    

er: lea dx, e2
    mov ah, 9
    int 21h
    jmp e2e
    e2 db "   i/o error...",0Dh,0Ah,'$'
    e2e:

    ret        ; exit. 
    
    


