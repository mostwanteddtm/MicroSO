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
		cli						// clear interrupts--Do not enable them yet
		mov ax, 10h				// offset 0x10 in gdt for data selector, remember?
		mov ds, ax
		mov es, ax
	}
#endif

	//!	Call kernel entry point
	main();


#ifdef ARCH_X86
	_asm cli
#endif
	for (;;);
}
