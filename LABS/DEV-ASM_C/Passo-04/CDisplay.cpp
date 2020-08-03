// CDisplay.cpp

#include "CDisplay.h"
void CDisplay::ClearScreen()
{
    __asm
    {
		jmp main 
		
		prompt:
			cmp al, 8 
			je ok
			inc cx
			ret 
        
        ok: 
			cmp cx, 0
			jle while 
			sub cx, 1 
			call voltar
			jmp while
        
		voltar:
			mov ah, 0eh
			mov al, 08h
			int 10h
			
			mov ah, 0eh
			mov al, 20h
			int 10h
			
			mov ah, 0eh
			mov al, 08h
			int 10h
			ret
    
		main:
			mov ah, 0eh   
			mov al, 41h
			int 10h 
		   
			mov al, 3ah
			int 10h
			  
			mov al, 3eh
			int 10h
			 
			xor cx, cx
			
			while: 
				mov ah, 00h
				int 16h

				call prompt
					   
				mov ah, 0eh
				int 10h
			jmp while 
    } 
}
