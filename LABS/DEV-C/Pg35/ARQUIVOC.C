#include <stdio.h>
void main(void)
{
	int result;
	char *meu_bem = "Marcos e Paula Apaixonados!";
	
	//verificando se não houve erro ao executar printf
	result = printf("%s\n",meu_bem);
	if (result == EOF)
		fprintf(stderr, "Erro na execucao de printf\n");   
	
	// Limpa a tela a tela	
	//printf("\033[2J");
	
	//cor de fundo branca e a letra verde
	printf("\033[47m\033[32mTestando...\n");

	system("pause");
}