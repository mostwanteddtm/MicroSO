#include <stdio.h>
#include <string.h>

int sum(int val1, int val2)
{
    return val1 + val2;
}

void readfileline(char *filename)
{
    FILE *file;
    char line[255];
    int i=1, position;
    char *str = "\t\r\n";
    
    if ((file = fopen(filename, "r")) != 0)
    {
        while(fgets(line, sizeof(line), file) != 0)
        {
            printf("Linha %d - str %d\n", i, strcspn(line, str)+1);
            printf("%s", line);
            i++;
        };
        fclose(file);
    }
    else
    {
        printf("error on open file %s\n", filename);
    }
    
}
