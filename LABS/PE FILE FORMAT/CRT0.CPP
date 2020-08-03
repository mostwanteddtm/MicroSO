/*
====================================================
	entry.cpp
		-This is the kernel entry point. This is called
		from the boot loader
====================================================
*/

//#pragma comment(linker, "/ENTRY:\"mainCRTStart\"" )

#define BGCOLOR 0x7

void _cdecl main() 
{
	char *message = "Microsoft Visual C++ 2.0 - COFF - Portable Executable File Format!";
	
	_asm {
		
		mov	ax, 50h
		mov	ds, ax
		mov es, ax
		
		mov ah, BGCOLOR
		mov	esi, message
		mov edi, 0B8000h
	
	cprint:
		lodsb
		cmp	al, 0
		je endprn
		stosw
		jmp cprint
		
	endprn:
		jmp $
	}
}
