#ifndef _conio_h_
#define _conio_h_


/*
   printf() stuff
                  */

/* Puts a formated ASCIIZ string to the screen (adjusts cursor position) */
/* Currently supports these specifiers:                                  */
/*   %%         for "%",                                                 */
/*   %c         for char                                                 */
/*   %s         for ASCIIZ strings                                       */
/*   %d and %i  for int                                                  */
/*   %u         for unsigned int                                         */
/*   %x and %X  for unsigned int                                         */
/* and these input-size modifiers:                                       */
/*   l          for long int                                             */
/* Supported width specifiers:                                           */
/*   n          for left-padded output   (n>0)                           */
/*  -n          for right-padded output  (n>0)                           */
/*  0n          for 0 left-padded output (n>0)                           */

void    printf (const char *fmt, ...);

#endif
