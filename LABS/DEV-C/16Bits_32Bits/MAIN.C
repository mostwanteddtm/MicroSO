#include <stdio.h>
#include "main.h"

void main(void)
{
	PESSOA p = { 41, "Marcos!" };
	PESSOA *ptr = &p;
	
	printf("%d %s", ptr->idade, ptr->nome);
	return;
}