bits 16
global _print
	
	_print
		mov ah, 0eh
		mov al, 41h
		int 10h
		retf