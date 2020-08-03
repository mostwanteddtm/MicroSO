#include "stdio.h"

extern void print(char value[]);
extern void calcular(char a, char b);
extern char getchar();
extern char strcompare(char str1[], char str2[], char strLen);

void printf(char value[])
{
	value += 0;
	print(value);
	return;
}

void calc(char a, char b)
{
	calcular(a, b);
	return;
}

char getch()
{
	return getchar();
}

char strcmp(char str1[], char str2[], char strLen)
{
	strcompare(str1, str2, strLen);
	return;
}