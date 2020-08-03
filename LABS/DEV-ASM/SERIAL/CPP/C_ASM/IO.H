#ifndef _IO_
#define _IO_

#define COM1 0x3f8

extern "C" void outport(short int port, unsigned char ch);
extern "C" void initcom1();

#endif
