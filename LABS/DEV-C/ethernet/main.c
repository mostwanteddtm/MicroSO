#include "common.h"
#include "rtl8139.h"

int main(int argc, char *argv[])
{
    int i = 0, lenconfigs = (sizeof(configs)/sizeof(configs[0]));

    printf("Analise do modelo OSI de rede - Baseado na placa Realtek 8029(AS) - 09/07/2020\n");
    
    readcfg();

    for(i = 0; i < lenconfigs; i++)
          printf("%s %s", configs[i].strkey, configs[i].strvalue);

    printf("\n");
  
    resetnic(configs[0].value);

    //printf("0x%04X\n", configs[0].value);

    return 0;
}