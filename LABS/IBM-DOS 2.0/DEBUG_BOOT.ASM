ORG 100H 

START:

;-----------------------------------------------------
; Aqui acontece o mesmo processo do boot pela BIOS
; Copio o primeiro setor de boot
; Para o endereco 0000h:7C00h 
;-----------------------------------------------------

MOV AL, 1
MOV CL, 1
MOV CH, 0
MOV DH, 0 
MOV DL, 0
MOV BX, 0   
MOV ES, BX
MOV BX, 7C00h 
MOV AH, 02
INT 13H  

push 0
push 7C00h
retf