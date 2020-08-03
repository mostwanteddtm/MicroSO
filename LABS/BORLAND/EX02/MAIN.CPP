#include <stdio.h>
#include <conio.h>

extern "C" int sum(int val1, int val2);

void main()
{
	int value = sum(5, 3);
	printf("%d\n", value);
	getch();
}