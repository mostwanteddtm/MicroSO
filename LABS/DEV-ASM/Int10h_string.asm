.model small
.stack

.data
 
Text DB "This is some text"

.code

start:
push cs
pop ds
 
mov ax,@data 		; set up ds as the segment for data
mov es,ax 		; put this in es
 
mov bp,OFFSET Text 	; ES:BP points to message
mov al,01h 		; attrib in bl,move cursor
xor bh,bh 		; video page 0
mov bl,3 		; attribute - magenta 
xor cx,cx
mov cl,17 		; length of string
mov dh,0 		; row to put string
mov dl,0 		; column to put string 
mov ah,13h 		; function 13 - write string
int 10h 		; call BIOS service 

mov ah,00h
int 16h
 
jmp 0800h:0000h
 

 
end




