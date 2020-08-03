#include "common.h"
#include <string.h>         // printf, fopen, fgets
#include <stdlib.h>         // strtol
#include <math.h>           // pow

#define LENCONFIG 0x10

unsigned long strtoulong(char *line)
{
    unsigned long ret = 0;
    char buffer[10];

    char str[3];                                                    // buffer para o octeto
    char *strvalue = "";                                            // 1 caractere do octeto
    int value = 0;                                                  // valor do caractere de octeto
    int o = 3;                                                      // variável para identificar qual octeto
    int i = 0;                                                      // variável para iterar dentro do octeto
    int p = 0;                                                      // variável para calcular o exponencial _
                                                                    // do valor dentro do octeto                                      

    while(*line)                                                    // linha com a string de octetos 
    {
        if (*line != '.')                                           
        {
           str[i] = *line;                                          // armazena o caractere dentro do octeto
           i++;
        }

        *line++;

        if (*line == '.' || *line == 0 || *line == '\n')            // se for fim do octeto ou fim de linha
        {
            i--;                                                    // retorno ao ultimo caractere obtido                           
            p = 0;                                                  // defino o inicio do exponencial

            while(i > -1)                                           // Ex: iteração dentro do octeto
            {                                                       // 192 | index[2] (2) -> index[1] (9) -> index[0] (1)
                *strvalue = str[i];
                value += (atoi(strvalue)) * (int)pow(10, p);         // 2 * (10^0) -> 9 * (10^1) -> 1 * (10^2)
                i--;                                                // iteração decrescente no octeto
                p++;                                                // iteração crescente do exponenciador
            }

            ret += (value * (pow(2, (o * 8))));                     // calculo: valor * (2 ^ (octeto * 8))
            o--;                                                    // EX: 192.168.0.1          
            value = 0;                                              // 192 octeto 3 - 168 octeto 2 - 0 octeto 1 - 1 octeto 0
            i = 0;                                                
        }   
    }
    
    return ret;
}

unsigned long getconfigvalue(int pos, char *line, int cfg)          // obtem o valor do arquivo de configuração
{
    char str[LENCONFIG];
    int i = 0;

    configs[cfg].strvalue = (char *)malloc(sizeof(str));

    while(*line)
    {
        if (i > pos) 
        {
            str[i - (pos+1)] = *line;
        }
        i++;
        *line++;
    }

    strcpy(configs[cfg].strvalue, str);

    return cfg == 0 ? strtol(str, NULL, 16) : strtoulong(str);      // converte string em Hexadeciamal;
}

char *getconfigkey(int pos, char *line, int cfg)                    // obtem a chave do arquivo de configuração
{
    char str[LENCONFIG];
    char *ret = (char *)malloc(sizeof(str));
    int i = 0;

    configs[cfg].strkey = (char *)malloc(20);

    while(*line)
    {
        if (i <= pos) str[i] = *line;
        *line++;
        i++;
    }

    switch(cfg)
    {
        case 0:
            configs[cfg].strkey = "Endereco Base E/S   ";
            break;

        case 1:
            configs[cfg].strkey = "Endereco IP         ";
            break;

        case 2:
            configs[cfg].strkey = "Mascara de Sub-Rede ";
            break;
    }

    strcpy(ret, str);
    return ret;
}

void readcfg()                                                               // le arquivo de configuração
{
    FILE *file;
    char line[255];
    char *space = " " ;
    int i = 0;

    file = fopen("main.cfg", "r");

    if (file != NULL)
    {
        while(fgets(line, sizeof(line), file) != 0)
        {
            configs[i].key = getconfigkey(strcspn(line, space), line, i);       // obtem o index do space dentro da string
            configs[i].value = getconfigvalue(strcspn(line, space), line, i);
            i++;
        };

        fclose(file);
    }
}

