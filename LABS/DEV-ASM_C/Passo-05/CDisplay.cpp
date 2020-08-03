// CDisplay.cpp
#include "CDisplay.h"
void printf()
{
	char teste = 'A';
	
    __asm
    {
		mov ah, 0eh   
		mov al, teste
		int 10h 
	   
		mov al, 3ah
		int 10h
		  
		mov al, 3eh
		int 10h
		
		while: 
    		mov ah, 00h
    		int 16h
    		   
    		mov ah, 0eh
    		int 10h
    	jmp while
    } 
}
