#include <stdio.h>
#include <conio.h>
#include <string.h>
#include "rtl8139.h"

void printbinary(int val);

int main(int argc, char *argv[])
{
	unsigned long x=0x80000000;
	char buffer[10];

	int or = (TCR_IFG0 | TCR_IFG1 | TCR_MXDMA2 | TCR_MXDMA1);

	sprintf(buffer,"%08X", x);
	printf("%s\n", buffer);

	printf("0x%08X\n", or);
	printbinary(or);

	getch();

	return 0;
}

void printbinary(int val)
{
    int i;
    for (i = 31; i >= 0; i--)
    printf("%d", ((val >> i) & 1));
}