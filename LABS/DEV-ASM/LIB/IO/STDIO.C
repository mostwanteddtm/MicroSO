#include "stdio.h"

extern void print(char *value);

void printf(char *value)
{
	print(value);
	return;
}