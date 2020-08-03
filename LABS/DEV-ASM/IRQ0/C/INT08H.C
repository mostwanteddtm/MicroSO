/*TimeTsr.c*/
#include<dos.h>

void interrupt far our();
void (interrupt far *prev)();
char far *scr=(char far*)0xB0008000L;
char ticks;

void main()
{
 prev=_dos_getvect(8);/*get the timer ISR address*/
 _dos_setvect(8,our);/*set our function address*/
 //keep(0,500);
}
void interrupt our()
{
 ticks++;
 *(scr) = ticks;
  //(*prev)();/*call the actual ISR*/
  _asm {
        mov     al, 20h
        out     20h, al
  }
}