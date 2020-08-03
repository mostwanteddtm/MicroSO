#include <stdarg.h>

extern void cdecl printf(char value);

void printargs(char arg1, ...)
{
	va_list ap;
	char arg;

	va_start(ap, arg1); 
	//for (arg = arg1; arg != '\0'; arg = va_arg(ap, char))
	//  printf(arg);

	arg = arg1;
	do 	
		printf(arg);
	while((arg = va_arg(ap, char)) != '\0');
		
	va_end(ap);
}

void main()
{
	printargs('M', 'a', 'r', 'c', 'o', 's', '\0');
}