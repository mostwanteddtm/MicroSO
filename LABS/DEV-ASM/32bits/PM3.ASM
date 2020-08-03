.386p
  
RM_CODE segment para public 'CODE' use16
assume  cs:RM_CODE, ss:RM_STACK

@@start:

    mov ax, 03h
    int 10h

	;-------------------------------------------------
	; Enables a20 line through system control port A
	;-------------------------------------------------
	
    in  al, 92h
    or  al, 02h
    out 92h, al

    xor     eax, eax
    mov  ax, PM_CODE
    shl eax, 4      ;*16d
    add eax, offset ENTRY_POINT
    mov dword ptr ENTRY_OFF, eax

    xor     eax, eax
    mov  ax, RM_CODE
    shl eax, 4
    add eax, offset GDT
    mov dword ptr GDTR+2, EAX

    lgdt    fword ptr GDTR

    cli

	;-------------------------------------------------
	; Entender o que esse codigo faz
	;-------------------------------------------------
	
    ;in  al, 70h
    ;or  al, 80h
    ;out 70h, al

    mov eax, cr0
    or  ax, 1
    mov cr0, eax

   
        db  66h
        db  0EAh
ENTRY_OFF   dd  ?
        dw  00001000b

 
GDT:
 
nulldescr   db  08h dup(0)
codedescr   db  0FFh, 0FFh, 00h, 00h, 00h, 10011010b, 11001111b, 00h
datadescr   db  0FFh, 0FFh, 00h, 00h, 00h, 10010010b, 11001111b, 00h
videdescr   db  0FFh, 0FFh, 00h, 80h, 0Bh, 10010010b, 11000000b, 00h
 
GDT_size    equ $ - GDT
 
GDTR        dw  GDT_size - 1
        dd  ?
 
RM_CODE ends
 
RM_STACK    segment para stack 'STACK' use16
 
    db  100h dup(?)
 
RM_STACK    ends
 
PM_CODE segment para public 'CODE' use32
assume  CS:PM_CODE, DS:PM_DATA
 
ENTRY_POINT:
 
    mov ax, 00010000b
    mov ds, ax
    mov ax, 00011000b
    mov es, ax
 
    xor esi, esi
    mov  si, PM_DATA
    shl esi, 4
    add esi, offset message
   
    xor     edi, edi
    mov ecx, mes_len
   
CO: LODSB
	MOV AH, 00001111b
	STOSW
	LOOP CO
    ;rep movsb
    jmp $  
 
PM_CODE ends
 
PM_DATA segment para public 'DATA' use32
 
    message db  "HelloWorld from PM!!"
    mes_len equ $ - message
 
PM_DATA ends
   
end @@start