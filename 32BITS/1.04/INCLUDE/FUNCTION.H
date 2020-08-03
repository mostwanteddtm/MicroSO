#ifndef _FUNCTION_H
#define _FUNCTION_H

#define VID_MEMORY	0xB8000
#define BASE_LINE 0xA0

void debugprint(char *ptrvalue, int linenumber);
unsigned char *defineline(int linenumber);

#endif
