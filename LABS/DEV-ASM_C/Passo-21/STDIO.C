#include "stdio.h"
#include <stdarg.h>

typedef struct {
	int	quot;
	int	rem;
}div_t;

/* External Functions in Assembly */
extern void cdecl _putch(char value);

/* Internal Functions */
void putsr(char *value);
void putint(unsigned int value);

void printf(char *value,...)
{	
	va_list mylist;
		
	char *ptr = value;									//aqui eu pego o primeiro parametro
	char *sptr = "";									//para pegar o segundo parametro em diante: va_arg(mylist, char* || int || long);
	unsigned int iptr;
	int i;
	
	va_start(mylist, value);
	
	while(value[i])
	{
		while (*ptr)
		{
			if (ptr[0] == '%')
			{
				switch(ptr[1])
				{
					case 's':
						sptr = va_arg(mylist, char*);
						putsr(sptr);
						break;
					
					case 'd':
						iptr = va_arg(mylist, int);
						putint(iptr);
						break;
				}
			}
			else
			{
				if (ptr[-1] != '%') 
					_putch(ptr[0]);	
			}
			ptr++;
		}
		i++;
	}

	va_end(mylist);
}

void putsr(char *value)
{
	while(*value)
	{
		_putch(value[0]);
		value++;
	}
}

void putint(unsigned int value)
{
	div_t mydiv;
	char ch;
	int base = 10;
	char *buffer;
	int i = 0;
	
	if (value < 10)
	{
		ch += value;
		_putch(ch);
	}
	else {
		do {
			mydiv.quot = value / base;
			mydiv.rem = value % base;
			buffer[i] = mydiv.rem;
			i++;
			value = mydiv.quot;	
		}while (value > 9);
		buffer[i] = mydiv.quot;
		for (; i >= 0; i--)
		{
			ch = 0x30;
			ch += buffer[i];
			_putch(ch);
		}
	}

}