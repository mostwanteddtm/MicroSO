#include <stdio.h>
#include <stdlib.h>
#include <ctype.h>
#include <conio.h>
#include <time.h>

#undef isalpha //removo a definição da função isalpha, encontrada em ctype.h
#define isalpha(c) (toupper((c)) >= 'A' && toupper((c)) <= 'Z') //igual ao override

int Soma(int a, int b, const int c); //Dica 225 Prototype do método
char* Ponteiro(char *value);
void Alterar(int *val);
int Contar(); //Dica 246 variaveis staticas
void InverteString(char *str);

extern int totalDicas; //Dica 268
extern void ExibeDicas();

volatile int teste; //Dica 270

int main()
{
	char letra = getch();
	int numero_func = 123456;
	char regiao[] = "REC";
	char nome_arq[64];

	char *nome = "Marcos";

	int a = 9;
	int b = 12;

	int *ponteiroA = &a; //Dica 242

	time_t hora;

	printf("%d\n", isalpha(letra));
	sprintf(nome_arq, "%s%d", regiao, numero_func);
	printf("Nome do arquivo do func: %s\n", nome_arq);

	printf("%d\n", Soma(a, b, 5));
	printf("%d\n", a);
	printf("Endereco de memoria a = %X\n", &a);

	*ponteiroA = 10;
	printf("%d\n", *ponteiroA);
	Alterar(&a);
	printf("%d\n", a);

	time(&hora);
	printf("Hora em segundos  %ld\n", hora);

	printf("%s\n", nome);
	printf("%s\n", Ponteiro(nome));

	printf("%d\n", Contar());
	printf("%d\n", Contar());

	InverteString("ABCD");
	printf("\n");

	ExibeDicas();
	printf("Total de dicas do livro: %d\n", totalDicas);

	system("PAUSE");

	return 0;
}

int Soma(int a, int b, const int c)
{
	a = 15;
	b = 17;
	//c não pode ser alterado, por ser const
	return a + b + c;
}

char* Ponteiro(char *value)
{
	return "e Paula";
}

void Alterar(int *val)
{
	*val *= 2;
}

int Contar()
{
	static int count = 100; //Apenas a primeira vez que chamar o método o valor 100 é atribuído
	return count += 1;
}

void InverteString(char *str)
{
	if (*str)
	{
		InverteString(str +1);
		putchar(*str);
	}
}