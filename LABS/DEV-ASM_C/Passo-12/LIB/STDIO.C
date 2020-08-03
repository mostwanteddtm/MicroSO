#include "stdio.h"
extern void cdecl _printf(char value[]);
void printf(char value[])
{
	value += 0;
	_printf(value);
}