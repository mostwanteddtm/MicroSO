org 100h
        
.data
 
Text db "This is some text"
msgLen dw $-Text

.code

    start:
         
        mov ax, @data 		    ; set up ds as the segment for data
        mov es, ax 		        ; put this in es
         
        mov bp, offset Text 	; ES:BP points to message
        mov al, 01h 		    ; attrib in bl,move cursor
        xor bh, bh 		        ; video page 0
        mov bl, 0Fh 		    ; attribute - magenta 
        xor cx, cx
        mov cx, msgLen 		    ; length of string
        mov dh, 0 		        ; row to put string
        mov dl, 0 		        ; column to put string 
        mov ah, 13h 		    ; function 13 - write string
        int 10h 		        ; call BIOS service 
        
        mov ah,00h
        int 16h
   
 
ret   






