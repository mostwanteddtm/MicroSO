
; You may customize this and other start-up templates; 
; The location of this template is c:\emu8086\inc\0_com_template.txt

org 100h
.data 
    value db 31h 
.code
main:
     
    ;macro deve ser declarada sempre acima
    ;pode-se utilizar com include
    print_screen macro print_value
        mov ah, 02h 
        mov dl, print_value
        int 21h 
    endm
    
    mov ax, @data
    mov ds, ax
    
    mov al, 'F' ;valor hexadecimal a ser convertido de 0 a F
    cmp al, 3Ah
    jge call hexadecimal
    
    mov dl, al
    mov ah, 02h
    int 21h            
    int 20h 
    
    hexadecimal:
        push ax 
        print_screen value 
        pop ax
        sub al, 11h ;subtraio a diferenca do ascii 41h[A] de 30h[0] = 11h ou 17d
        print_screen al

end main





