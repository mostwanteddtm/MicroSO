#include "stdarg.h"
#include "stdio.h"

extern void cdecl _printf(char *value);

void printf(char *value)
{
	_printf(value);
}	