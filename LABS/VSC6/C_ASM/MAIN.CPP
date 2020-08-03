#include <stdio.h>
#include <conio.h>
#include "io.h"

void main(void)
{
	unsigned long value = getvalue();
	unsigned long newValue = sum(1000, 2500);

	printf("%#x\n", value);
	printf("%d", newValue);

	getch();
}