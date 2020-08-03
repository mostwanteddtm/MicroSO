#include "stdio.h"

#define		TRUE	1
#define		FALSE	0

void main()
{
	char chrs[10];
	char chr;
	char cmp;
	int i = 0;
	
	cmp = strcmp("TESTE", "TESTE", 5);
	
	if (cmp)
		printf("String Igual!\r\n");
	else
		printf("String Diferente!\r\n");
	
	printf("Programa combinando C e ASM!...\r\n");
	printf("O resultado da soma de 6 e 2 = "); 
	calc(6, 2);
	printf("\r\n");
	
	for(;;)
	{
		chr = getch();
		
		if (chr == 27) break;
		
		if (chr == 13)
		{
			printf("\r\n");
			printf(chrs);
			printf("\r\n");
			
			cmp = strcmp("marcos", chrs, 6);
			
			if (cmp)
				printf("Igual!\r\n");
			else
				printf("Diferente!\r\n");
			
			i = 0;
		}
		else{
			chrs[i] = chr;
			chrs[i+1] = 0x00;
			i ++;
		}
	}
}
