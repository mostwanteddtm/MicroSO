#include <stdio.h>
#include <stdlib.h>

typedef unsigned long int MEUTIPO; //dica 48

int main()
{
	MEUTIPO a = 100000000;
	unsigned char c = 0xFF; //dica 42
	char nome[10] = "Marcos";
	int t_nome;
	char *nome2 = "Paula"; //como padrão o ponteiro usa near
	
	float exato = 0.123456789087654321;
	double mais_exato = 30.123456789087654321;
	int d = 5;
	int e = 2;
	
	printf("%d\n", a);
	
	printf("Valor de float\t %f\n", exato);
	printf("Valor de double\t %1.10f\n", mais_exato); //dica 51 - 1 numero minimo de digitos a ser exibido e 10 depois da virgula
	printf("Saida decimal %#X\n", c); //dica 55/67 x minusculo tmb funciona
	printf("%u\n", c); //dica 56
	printf("%s\n", nome); //dica 62 (sem anotação)
	printf("%p\n", &exato); //dica 64
	printf("%03d\n", d); //dica 66 (sem anotação)
	printf("Valor %-+3d\n", d); //dica 71 - Combinando alinhamento e sinal de exibição + (sem anotação)
	printf("%s\n", nome2); //dica 73 (sem anotação)
	printf("%s%n\n", nome, &t_nome);
	printf("A palavra Marcos tem %d carcteres.\n", t_nome); //funciona no VS C++ 6.0
	
	d = printf("Teste\n");
	if (d == EOF)
		fprintf(stderr, "Erro");
	
	e <<= 1;
	printf("%d\n", e); //dica 91 (sem anotação)
	printf("%d e maior que 3? %s\n", e, (e > 3) ? "SIM" : "NAO"); //dica 92 (sem anotação)
	printf("Tamanho de char em bytes = %d\n", sizeof(char));
	
	system("PAUSE");
	return 0;
}