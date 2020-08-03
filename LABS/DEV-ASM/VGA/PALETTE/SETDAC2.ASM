	ORG 100h
	
	mov     AX,CS
	mov     DS,AX  
	
	mov     AH, 0h                  ; SET VIDEO MODE	
	mov     AL, 12h	                ; 640X480
	int     10h	
	
	mov     ax, 1010h               ; SET INDIVIDUAL DAC REGISTER (VGA/MCGA)
    mov     bx, 0                   ; PALETTE 0 (BLACK) ~ Fh (WHITE)
    mov     cl, 20                  ; blue
    mov     ch, 63                  ; green
    mov     dh, 63                  ; red
    int     10h

	mov     AH, 0Bh                 ; SET BACKGROUND/BORDER COLOR	
	mov     BX, 0	                ; PALETTE 0
	int     10h  
	        
	mov     AH, 0Ch                 ; WRITE GRAPHICS PIXEL
	xor     bx, bx
	mov     cx, 10
	mov     dx, 10			
	mov     AL, 2	
	int     10h		 
	        
	XOR     AX, AX
	INT     16H
            
	mov     AH, 0h	
	mov     AL, 03h	
	int     10h		
            
	mov     AH, 4Ch	
	int     21h		