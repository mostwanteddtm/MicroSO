#include "base.h"

extern void cdecl _putstr(const char *param);			
extern int cdecl __factorial(int factor, int power);

void putstr(const char *param)
{
	_putstr(param);
}

int factorial(int factor, int power)
{
	__factorial(factor, power);
}