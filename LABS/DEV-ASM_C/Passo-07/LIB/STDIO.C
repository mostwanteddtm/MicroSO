#include "stdio.h"
extern void cdecl print(char value[]);
void printf(char value[])
{
	value += 0;
	print(value);
}