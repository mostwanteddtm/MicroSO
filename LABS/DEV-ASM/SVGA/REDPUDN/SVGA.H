/**************************************************************************** 
* 
*                            SuperVGA Test Kit 
* 
*                   Copyright (C) 1993 SciTech Software 
*                           All rights reserved. 
* 
* Filename:     $RCSfile: svga.h $ 
* Version:      $Revision: 1.2 $ 
* 
* Language:     ANSI C 
* Environment:  IBM PC (MS DOS) 
* 
* Description:  Header file for the small SuperVGA test library. 
*               This library provides a simplified interface to SuperVGA 
*               cards that have a VESA VBE (or with the Universal VESA 
*               VBE installed). This library requires at least a 
*               VBE 1.2 interface to function correctly. 
* 
*               NOTE: This library only works in the large model. 
* 
* $Id: svga.h 1.2 1993/10/22 08:58:40 kjb release $ 
* 
****************************************************************************/ 
 
#ifndef __SVGA_H 
#define __SVGA_H 
 
#ifndef __DEBUG_H 
#include "debug.h" 
#endif 
 
/*--------------------------- Global Variables ----------------------------*/ 
 
extern  int     maxx,maxy;          /* Maximum coordinate values        */ 
extern	long	maxcolor,defcolor;	/* Maximum and default colors		*/ 
extern  int     maxpage;            /* Maximum video page number        */ 
extern  int     bytesperline;       /* Bytes in a logical scanline      */ 
extern  bool    twobanks;           /* True if separate banks available */ 
extern  bool    extendedflipping;   /* True if extended page flipping   */ 
extern  bool    widedac;            /* True if wide dac is supported    */ 
extern  int     memory;             /* Memory on board in k             */ 
extern  short   modeList[];         /* List of available video modes    */ 
extern  char    OEMString[];        /* OEM string from VBE              */ 
 
typedef enum { 
    memPL       = 3,                /* Planar memory model              */ 
    memPK       = 4,                /* Packed pixel memory model        */ 
    memRGB      = 6,                /* Direct color RGB memory model    */ 
    memYUV      = 7,                /* Direct color YUV memory model    */ 
    } memModels; 
 
/*------------------------- Function Prototypes ---------------------------*/ 
 
#ifdef  __cplusplus 
extern "C" {            /* Use "C" linkage when in C++ mode */ 
#endif 
 
/* In svga.c */ 
 
int initSuperVGA(void); 
bool setSuperVGAMode(int mode); 
void restoreMode(void); 
bool getSuperVGAModeInfo(int mode,int *xres,int *yres,int *bytesperline, 
    int *bitsperpixel,int *memmodel,int *maxpage,long *pagesize); 
void setSuperVGADisplayStart(int x,int y); 
long rgbColor(uchar r,uchar g,uchar b); 
void line(int x1,int y1,int x2,int y2,long color); 
void writeText(int x,int y,uchar *str,long color); 
 
/* In svga.asm */ 
 
void setActivePage(int page); 
void setVisualPage(int page); 
void setBank(int bank); 
void setReadBank(int bank); 
void *getFontVec(void); 
 
extern void (*putPixel)(int x,int y,long color); 
extern void (*clear)(void); 
 
#ifdef  __cplusplus 
}                       /* End of "C" linkage for C++   */ 
#endif 
 
#endif  /* __SVGA_H */
