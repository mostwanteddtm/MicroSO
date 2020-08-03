#include "stdio.h"

extern void cdecl _printf(char *arg_0, int arg_1);

void printf(char *arg_0, int arg_1)
{
	_printf(arg_0, arg_1);
}