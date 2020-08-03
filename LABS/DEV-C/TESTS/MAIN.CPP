#include <stdio.h>
#include <string.h> 
#include <dos.h> 
#include <ctype.h>
#include <iostream.h>
#include <stdlib.h>
#include "myclass.h"
#include "func.h"

#define LWORD unsigned long

struct Person
{
    char *name;
    int age;
    float salary;
};

typedef struct
{
    int ddd;
    char *name;
} Cities;

void print(int func);
int mult(int val1, int val2);

void printbinary(int val);
void readfile();
LWORD atoip(char *str);

                      
int main(int argc, char *argv[])
{	
    MyClass myclass;
    Cities cities;
    struct Person person;
    struct SREGS segs;
    LWORD result;
	int *value = (int *)(100);
    int i, len;
    char *filename = "FILE.TXT";
    char *withspace = "   Teste";
    
    char *string;
    string = (char *) malloc(50);                       // inicializando ponteiro sem valor e alocando memóra pra ele
    cities.name = (char *) malloc(30);
    
    strncpy(string, "Aloquei com sucesso uma string de 50 bytes\n", 50);
    strcpy(cities.name, "Caruaru\n");                   // copiando string para o ponteiro

    len = (cities.name, '\n');
    printf("len - %d\n", len);

    printf("%s", cities.name);

    while(*string)                                      // iterando no ponteiro 
      putchar(*string++);                               // imprimindo caracter por caractere

    myclass.usecout();                                  // chamando método de uma classe

    printf("\n");

    for(i = 1; i < argc; i++)                           // iterando sobre parâmetro de linha de comando
    {
        printf("%s\n", argv[i]);
    }

    printbinary(0x80);                                  // imprimir valor binário
    printf("\n");
    print(sum(5, 6));                                   // teste de passar uma função como parâmetro
    print(mult(5, 6));                                  // teste de passar uma função como parâmetro
    readfile();                                         // le arquivo, caractere por caractere
    segread(&segs);
    printf("CS %X DS %X SS %X ES %X\n", segs.cs, segs.ds, segs.ss, segs.es);
    result = atoip((char *)("192.168.0.1"));            //transforma IP (string) em IP 
    printf("%lu\n", result);

    readfileline(filename);                             // le arquivo linha por linha
    printf("%i\n", strncmp("abcde", "abcdef", 6));

    while(isspace(*withspace))                          //remove espaço da string
        withspace++;
    
    printf("%s\n", withspace);

    printf("0x%04X\n", &filename);

 	return 0;
}     

int mult(int val1, int val2)
{
    return val1 * val2;
}

void print(int func)
{
    printf("%d\n", func);
}

void printbinary(int val)
{
    int i;
    for (i = 15; i >= 0; i--)
    printf("%d", ((val >> i) & 1));
}

void readfile()
{
    FILE *myfile;
    int letter;

    myfile = fopen(".\\FILE.TXT", "r");

    if (myfile != NULL)
    {
        while(feof(myfile) == 0)
        {
            letter = fgetc(myfile);
            putchar(letter);
        }
        fclose(myfile);
    }
}

LWORD atoip(char *str)
{
    LWORD ip=0L;
    int i=4, n;
    char c=1;

    while (--i>=0 && c)
    {
        n = 0;
        while (isdigit(c=*str++))
            n = n*10 + c-'0';
        ip += (LWORD)n << (i*8);
    }
    return(ip);
}