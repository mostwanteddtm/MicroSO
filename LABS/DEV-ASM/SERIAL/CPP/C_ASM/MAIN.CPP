#include <stdio.h>
#include <conio.h>
#include "io.h"

void main()
{
	unsigned char ch;
	
	initcom1();
	
    do 
	{
		ch = getch();
		outport(COM1, ch);
        printf("%c", ch);
    
    } while(ch != 27);
}