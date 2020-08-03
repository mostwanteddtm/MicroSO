org 100h

mov  ax,0013h                ; set screen to 13h (320x200x256)
           int  10h                     ;

           push es                      ; copy random bytes (colors) to
           mov  ax,0A000h               ;  screen for example
           mov  es,ax                   ;
           xor  di,di                   ; start at first of screen
           xor  si,si                   ; start at first of this segment
           mov  cx,64000                ; copy 64000 bytes of random code
           rep                          ;
           movsb                        ;
           pop  es                      ;

           xor  ax,ax                   ; reset mouse
           int  33h                     ;
           
           mov  ax,0009h
           mov  bx,0008h                ; Horz Hot Spot
           mov  cx,0008h                ; Vert Hot Spot
           mov  dx,offset Mask7         ; es:dx points to mask
           int  33h
           
           mov  ax,0001h                ; show mouse cursor
           int  33h                     ;

Wait4Press:
           mov  ax,0003h                ; wait for the user to press a 
           int  33h                     ;  mouse button
           or   bx,bx                   ;
           jz   short Wait4Press        ;


           mov  ax,0002h                ; hide mouse cursor
           int  33h

           mov  ax,0003h                ;
           int  10h                     ;

           .exit

Mask7      dw  1111111010111111b  ;Background
           dw  1111111010111111b
           dw  1110011010110011b
           dw  1110101010101011b
           dw  1111010010010111b
           dw  1111101010101111b
           dw  1100000111000011b
           dw  1011111111111101b
           dw  1100000111000011b
           dw  1111101010101111b
           dw  1111010010010111b
           dw  1110101010101011b
           dw  1110011010110011b
           dw  1111111010111111b
           dw  1111111010111111b
           dw  1111111101111111b

           dw  0000000101000000b  ;start cursor
           dw  0000000101000000b
           dw  0001100101001100b
           dw  0001010101010100b
           dw  0000101101101000b
           dw  0000010101010000b
           dw  0011111000111100b
           dw  0100000000000010b
           dw  0011111000111100b
           dw  0000010101010000b
           dw  0000101101101000b
           dw  0001010101010100b
           dw  0001100101001100b
           dw  0000000101000000b
           dw  0000000101000000b
           dw  0000000010000000b
end