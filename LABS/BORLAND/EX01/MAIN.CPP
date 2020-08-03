#include <stdio.h>
#include <conio.h>

extern "C" char getvalue();

void main()
{
	char value = getvalue();
	printf("%c", value);
	getch();
}