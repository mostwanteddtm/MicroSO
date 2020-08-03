#include <dos.h>
#include <stdio.h>

void main(void)
{
	int READCD[6] = {0xA8, 0x0, 0x0, 0x0, 0x1, 0x0};
	int ATAPI_RAW[1023];
	
	int i;
	int x;
	
	asm {
		mov dx,177h
		.loop1:
		in al,dx
		and al,10000000b
		jne .loop1
		
		mov dx,176h
		mov al,0A0h
		out dx,al
		mov dx,376h
		mov al,00001010b
		out dx,al
		mov dx,177h
		mov al,0a0h
		out dx,al
		mov cx,0FFFFh
		.waitloop:
		loopnz .waitloop
		mov dx,177h
		.loop3:
		in al,dx
		and al,10000000b
		jne .loop3
		
		mov dx,177h
		.loop4:
		in al,dx
		and al,00001000b
		je .loop4
	}

	for(i = 0; i <= 5; i++)
	{
		x = READCD[i];
		outport(0x170, x);
		inportb(0x376);
	}
	
	inportb(0x376);
	
	asm {
		mov dx,177h
		.loop5:
		in al,dx
		and al,10000000b
		jne .loop5
	}
	
	for(i = 0; i <= 1023; i++)
	{
		ATAPI_RAW[i] = inport(0x170);
		printf("%X ", ATAPI_RAW[i]);
	}
	
}