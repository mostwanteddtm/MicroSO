#include <stdio.h>
#include <dos.h>

#define ULONG unsigned long
extern far void seteax();
extern far unsigned long gethigh();
extern far unsigned long getlow();

extern unsigned long value;

void main()
{
   ULONG high = 0;
   ULONG low = 0;
   
   seteax();
   high = gethigh();
   low = getlow();
   
   if (value == 0x813910ec)
   {
	   printf("OK\n");
   }
   
   printf("0x%X", low);
   printf("%X", high);
}