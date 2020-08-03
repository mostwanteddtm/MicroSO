/*
====================================================
	entry.cpp
		-This is the kernel entry point. This is called
		from the boot loader
====================================================
*/

//#pragma comment(linker, "/ENTRY:\"mainCRTStart\"" )

extern void main();

void _cdecl mainCRTStart() 
{
	
#ifdef ARCH_X86
	_asm {
		mov	ax, 50h
		mov	ds, ax
		mov es, ax
	}
#endif

	//!	Call kernel entry point
	main();

	for (;;);
}
