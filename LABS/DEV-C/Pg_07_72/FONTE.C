#define TAM_FRASE 128 //constantes podem ser do tipo int, float e char
#define FRASE "Paula e Marcos Apaixonados!\n" //macros são utilizadas com strings

#include <stdio.h>
#include <math.h> 
#include <ctype.h>
#include <conio.h>

void main(void)
{  
	Pg_16_26();
	Pg_27_36();   
	Pg_37_60();
	Pg_61_72();
	system("pause"); 
} 
  
int Pg_16_26()
{         
	typedef unsigned long int ULINT; 
	//com unsigned a variavel pode ir de 0 a 65535
	//se nao usar unsigned ela vai de -32.768 a 32.767
	unsigned int teste = 65535;  //igual ao decimal 65535 
	unsigned long int teste2 = 0xffffffff; //igual ao decimal 4.292.967.265
	
	ULINT valor = 0xffffffff;
	printf("Imprimindo unsigned long %lu\n",valor); 
	
	printf("Sem unsigned %i\n",teste);
	printf("Com unsigned %u\n",teste);
	printf("Formatando numero para exadecimal %0x\n", teste); 
	printf("Teste2 de unsigned long %lu\n",teste2);
	
 	return 0;
} 
 
int Pg_27_36()
{
	float pi = 3.14159;    
	char nomes[255] = "Marcos e Paula Apaixonados!"; 
	int tamanho_frase;
	char *nomes2 = "Toda familia juntos.";
	int negativo = -500;
	int positivo = +500;
	
	//formata o número de forma exponencial
	printf("Exponencial %E\n",pi); 
	
	//nessa caso %s exibe a string
	//Já no caso %n armazena na variável tamanho_frase
	//através de ponteiro, o tamanho da frase exibida por printf
	printf("%s%n\n",nomes, &tamanho_frase); 
	printf("A frase anterior tem %d letras \n ", tamanho_frase); 
	  
	//imprime a string
	printf("%s\n",nomes2);                                          
	
	//isso é ponteiro
	printf("A variavel nomes esta na posicao de memoria %p\n", &nomes);   
	
	//formata a saída e exibe o sinal antes do número no caso de ser positivo
	printf("Valor = %+i %+i\n",negativo, positivo); 
	
	//formatando float  ex: 1.4 igual ao sql (1,4)
	printf("Formatando valor de pi %1.4f\n",pi);
	
	//20 espaços a esquerda
	printf("%+20i %i\n",negativo, positivo); 
	
	//20 espaços a direita
	printf("%-20i %i\n",negativo, positivo);  
	
	//quebra de kinha em texto
	printf("Eu conheco meu bem a 3 anos \
isso foi em 2009.\n");

	return 0;
} 

int Pg_37_60()
{
	char *frase = "Paula e Marcos Apaixonados!";
	float altura = 1.83;
	float peso = 90.7;
	//imc é Indice de Massa Corpórea
	float imc = peso / (pow(altura,2)); //função pow() está na biblioteca math.h
	
	int val1 = 10;
	int val2 = 3;
	int resto = 10 % 3;
	
	int x = 2;
	
	printf("%0x\n",frase);
	
	printf("Seu IMC e igual a %1.2f\n",imc);
	
	printf("O resto da divisao entre 10 e 3 = %i\n",resto);    
	
	//sizeof representa o tamanho da variável
	printf("O tamanho da variavel int = %i bytes\n", sizeof(int));
	
	//desloca bit a bit o valor da variável (esquerda <<) (direita >>)
	//então a variável x = 2 ------------- (0000 0010)
	//se fizer: x <<= 2 ela passa a ser 8  (0000 1000)
	printf("Novo valor d x = %i\n",x << 2);
	
	return 0;
}

int Pg_61_72()
{
	char letra; 
	int contador;
	printf("Escolha a opcao? (A/B/C/S):\n");
	
	do
	{
		letra = getch();  //obtem a tecla digitada. Faz parte da biblioteca conio.h
		letra = toupper(letra); //faz parte da biblioteca ctype.h
		
		switch (letra)
		{
			case 'A': 
				system("dir");
				printf("\n");
				break;
				
			case 'B':
				system("TIME");
				printf("\n");
				break;
				
			case 'C':
				system("date");
				printf("\n");
				break;
		};  
		
	} 
	while (letra != 'S'); 
	                           
	printf("Vc apertou a letra %c e o programa continuou normalmente\n",letra);

	#ifdef __STDC__ //verifica se o compilador utiliza o padrão ANSI
		printf("Compila no padrao ANSI!\n");
	#else 
		printf("Nao compila no padrao ANSI!\n");
	#endif

	printf("%s\n", FRASE); //imprime o conteudo da macro
	
	printf("O programa %s esta em beta teste\n", __FILE__); //constante de pré-processador __FILE__
	
	printf("Esta linha do programa %c a linha %d\n", 130, __LINE__); //constante de pré-processador __LINE__ 
	
	return 0;
}