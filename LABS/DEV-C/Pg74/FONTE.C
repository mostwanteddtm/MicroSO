#include <stdio.h>
#include <ctype.h>
#ifndef SOMA
#include "defs.h" //localiza o arquivo como no app.path
#endif

#undef _toupper //avisa ao pré-processador não dar mensagem de warning para linha abaixo
#define _toupper(c) ((((c) >= 'a' && ((c) <= 'z')) ? (c) - 'a' + 'A':c)) //redefine a função toupper da lib ctype.h

#pragma oninit() //não funcionou

void oninit(void)
{
	printf("Paula e Marcos Apaixonados!");
}

void main(void)
{
	char teste = _toupper('d'); 
	 
	//operação ternária
	int a = 0, i;
	scanf( "%d" , &i );
	( i % 2 ==0 ) ? (a++) : (a--);
	printf("\n i=%d e eh %s\n", i, (a<0) ? ("impar") : ("par") );

	printf("%c\n",teste); 
	printf("A soma de 5 + 3 %c = a %d\n", 130, SOMA(5,3)); 
	printf("O menor valor entre 4 e 3 %c %d\n", 130, MIN(4, 3));
	system("pause");
}