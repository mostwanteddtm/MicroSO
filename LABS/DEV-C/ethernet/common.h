#include <stdio.h>

extern void printdw(unsigned long value);
extern void readcfg();

typedef struct {
    char *key;
    unsigned value;
    char *strkey;
    char *strvalue;
} ETHCFG;

typedef enum {
    false = 0, 
    true = 1
} bool;

ETHCFG configs[3];