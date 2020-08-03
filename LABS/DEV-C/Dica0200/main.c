#include <stdio.h> //printf, gets, putchar
#include <stdlib.h> //system
#include <ctype.h> //toupper
#include <conio.h> //getch, getchar
#include <string.h> //strlen, strcpy

#define VALOR 1					//Constante
#define SOMA(A, B) ((A) + (B)) //Macro

int main()
{
	char *frase = "abcd";
	char letra;
	char qtde;
	int i = 0;
	char string[10];
	char string2[10];

	printf("O valor %d e maior que 1? %s\n", VALOR, (VALOR > 1) ? "SIM" : "NAO");
	printf("%s%n\n", frase, &qtde);

	for (; i <= qtde; i++)
	{
		letra = frase[i];
		printf("%c", toupper(letra));
	}
	
	printf("\n");

	letra = getch();
	//letra = getchar(); //só funciona com ASCII
	if (letra == 27)
		printf("ESC\n");

	for (i = 0; i <= 10; i++)
	{
		if (i % 2 == 0)
			printf("%d PAR\n", i);
		else
			continue; //imprime de 0 a 10
			//break; sai do loop
	}

    switch (letra)
    {
        case 27:
        case 13:
            printf("NAO E ASCII\n");
            break;
        default:
            printf("%c\n", letra);
            break;
    }

	printf("Arquivo corrente: %s\n", __FILE__); //dica 135

	//#line 1 "main.c" //dica 137: define a linha para depuração de código
	printf("Estamos na linha %d\n", __LINE__);

	#ifdef __cplusplus  //dica 141 __STDC__ (Confere compilação em padrão ANSI)
		printf("USANDO C++\n");
	#else
		printf("USANDO C\n");
	#endif

	printf("Usando macro para soma de 2 + 3 = %d\n", SOMA(2, 3));

	gets(string);
	for (i = 0; string[i] != NULL; i++) //!= NULL causando warning
	{
		putchar(string[i]);
	}

	putchar('\n');
	printf("varivaels string com %d caracteres\n", strlen(string));

	strcpy(string2, string); // strcpy(destino, origem)
	puts(string2);
	//system("PAUSE");
	return 0;
}