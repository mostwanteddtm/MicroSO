#include "stdio.h"
#include <stdarg.h>

extern void cdecl _putch(char value);

void printf(char *value,...)
{
	va_list mylist;
	
	char *parameter;
	char *parameters[0xF];
	int i;
	int x;
	
	va_start(mylist, value);

	for (parameter = value; parameter != NULL; parameter = va_arg(mylist, char*))
	{
		parameters[i] = parameter;
		i++;
	}
	
	for (x = 0; x < (i / 2); x++)
	{
		parameter = parameters[x];
		_putch(parameter[0]);
		
		while (*parameter++)
		{
			_putch(parameter[0]);
		}
	}

	va_end(mylist);
}