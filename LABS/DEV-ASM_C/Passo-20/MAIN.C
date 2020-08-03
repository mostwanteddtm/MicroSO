#include "stdio.h"

void main(void)
{
	char *name = "Marcos Roberto da Costa !!";
	char *buffer = "";
	strcpy(buffer, name);
	
	printf(buffer);
}