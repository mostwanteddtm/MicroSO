#include <stdarg.h>
#include "conio.h"

void printf (const char *fmt, ...) 
{
	int x = 0;
	va_list arglist;
	va_start (arglist, fmt);

	while (fmt[x]) 
	{
		if (fmt[x] == '\n') 
		{
			putch ('\r');
			putch ('\n');
		} 
		else
		{
			putch (fmt[x]);
		}
		
		x++;
	};
	
	va_end (arglist);
}
