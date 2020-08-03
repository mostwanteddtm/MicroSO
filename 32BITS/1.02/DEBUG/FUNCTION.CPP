#include <function.h>

extern "C" void asmfunction(char *ptrvalue, int linenumber);

void debugprint(char *ptrvalue, int linenumber)
{
	asmfunction(ptrvalue, linenumber);
}