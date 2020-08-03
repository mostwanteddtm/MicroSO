#include <stdio.h>
#include <ctype.h>
#include <conio.h>

void main(void)
{     
	char letra;
	
	Voltar:
	
	do
	{
		letra = getch();  

		switch(letra)
		{
			case 8:
				printf("\b \b");
				break;
						
			case 13:
				printf("\n");
				break;
				
			case 27:
				printf("\n");
				break;
				        
			default:
				printf("%c",letra);
		};
		
	}while(letra != 27); //ascii 27 = ESC 

}