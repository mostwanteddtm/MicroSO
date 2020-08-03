#include <stdio.h>
#include <string.h> 

char* copiar(char* src, char* dest); //tem que declarar aqui
char* frase = "Paula e Marcos Apaixonados!";

void main(void)
{
    char texto[30];
    printf("%s\n",copiar(texto, frase));
    system("pause");

}

char* copiar(char* dest, char* origem)  //não basta só criar a função tem que declarar em cima tmb
{
    strcpy(dest,origem);  
    return dest ;
}