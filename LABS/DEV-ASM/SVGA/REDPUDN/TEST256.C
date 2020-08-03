/****************************************************************************  
*  
*                          SuperVGA Test Library  
*  
*                   Copyright (C) 1993 SciTech Software  
*                           All rights reserved.  
*  
* Filename:     $RCSfile: test256.c $  
* Version:      $Revision: 1.2 $  
*  
* Language:     ANSI C  
* Environment:  IBM PC (MSDOS)  
*  
* Description:  Simple program to test the operation of the SuperVGA  
*               bank switching code and page flipping code for the  
*               256 color SuperVGA video modes.  
*  
*               MUST be compiled in the large model.  
*  
* $Id: test256.c 1.2 1993/10/22 08:58:40 kjb release $  
*  
****************************************************************************/   
   
#include <stdio.h>   
#include <stdlib.h>   
#include <string.h>   
#include <dos.h>   
#include <conio.h>   
#include "svga.h"   
   
/*---------------------------- Global Variables ---------------------------*/   
   
#include "version.c"   
   
int     x,y;   
   
/* External routines */   
   
void _copyTest256(void);   
   
/*----------------------------- Implementation ----------------------------*/   
   
void moireTest(void)   
/****************************************************************************  
*  
* Function:     moireTest  
*  
* Description:  Draws a simple Moire pattern on the display screen using  
*               lines, and waits for a key press.  
*  
****************************************************************************/   
{   
    uchar   buf[80];   
    int     i;   
   
    clear();   
    for (i = 0; i < maxx; i += 10) {   
        line(maxx/2,maxy/2,i,0,i % maxcolor);   
        line(maxx/2,maxy/2,i,maxy,(i+1) % maxcolor);   
        }   
    for (i = 0; i < maxy; i += 10) {   
        line(maxx/2,maxy/2,0,i,(i+2) % maxcolor);   
        line(maxx/2,maxy/2,maxx,i,(i+3) % maxcolor);   
        }   
    line(0,0,maxx,0,defcolor);   
    line(0,0,0,maxy,defcolor);   
    line(maxx,0,maxx,maxy,defcolor);   
    line(0,maxy,maxx,maxy,defcolor);   
   
    if (maxx != 319) {   
        x = 80;   
        y = 80;   
        writeText(x,y,"Bank switching test",defcolor);  y += 32;   
        sprintf(buf,"Video mode: %d x %d 256 color",maxx+1,maxy+1);   
        writeText(x,y,buf,defcolor);    y += 16;   
        sprintf(buf,"Maximum x: %d, Maximum y: %d, BytesPerLine %d, Pages: %d",   
            maxx,maxy,bytesperline,maxpage+1);   
        writeText(x,y,buf,defcolor);    y += 32;   
        writeText(x,y,"You should see a colorful Moire pattern on the screen",defcolor);   
        y += 16;   
        }   
    else {   
        x = 40;   
        y = 40;   
        }   
    writeText(x,y,"Press any key to continue",defcolor);   
    y += 32;   
    getch();   
}   
   
void readWriteTest(void)   
/****************************************************************************  
*  
* Function:     readWriteTest  
*  
* Description:  Test the separate read/write bank routines if available.  
*               We do this by copying the top 100 scanlines of video memory  
*               to another location in video memory.  
*  
*               This test is desgined to work only in 640 wide video modes.  
*  
****************************************************************************/   
{   
    if (twobanks && (maxx == 639)) {   
        _copyTest256();   
        writeText(x,y,"To test the separate read/write banks, the top 100 scanlines of",defcolor);   
        y += 16;   
        writeText(x,y,"this display page should be moved to start at scanline 205.",defcolor);   
        y += 16;   
        writeText(x,y,"This ensures that a bank boundary will have been crossed",defcolor);   
        y += 78;   
        writeText(x,y,"Press any key to continue",defcolor);   
        getch();   
        }   
}   
   
void pageFlipTest(void)   
/****************************************************************************  
*  
* Function:     pageFlipTest  
*  
* Description:  Animates a line on the display using page flipping if  
*               page flipping is active.  
*  
****************************************************************************/   
{   
    int     i,j,istep,jstep,color,apage,vpage;   
    char    buf[80];   
   
    if (maxpage != 0) {   
        vpage = 0;   
        apage = 1;   
        setActivePage(apage);   
        setVisualPage(vpage);   
        i = 0;   
        j = maxy;   
        istep = 2;   
        jstep = -2;   
        color = 15;   
        while (!kbhit()) {   
            setActivePage(apage);   
            clear();   
            sprintf(buf,"Page %d of %d", vpage+1, maxpage+1);   
            if (maxx == 319) {   
                writeText(0,80,"Page flipping - should be no flicker",defcolor);   
                writeText(0,100,buf,defcolor);   
                }   
            else {   
                writeText(80,80,"Page flipping - should be no flicker",defcolor);   
                writeText(80,100,buf,defcolor);   
                }   
            line(i,0,maxx-i,maxy,color);   
            line(0,maxy-j,maxx,j,color);   
            vpage = ++vpage % (maxpage+1);   
            setVisualPage(vpage);   
            apage = ++apage % (maxpage+1);   
            i += istep;   
            if (i > maxx) {   
                i = maxx-2;   
                istep = -2;   
                }   
            if (i < 0)  i = istep = 2;   
            j += jstep;   
            if (j > maxy) {   
                j = maxy-2;   
                jstep = -2;   
                }   
            if (j < 0)  j = jstep = 2;   
            }   
        getch();                /* Swallow keypress */   
        }   
}   
   
void testingComplete(void)   
/****************************************************************************  
*  
* Function:     testingComplete  
*  
* Description:  Clears the first display page and puts up a message.  
*  
****************************************************************************/   
{   
    setActivePage(0);   
    setVisualPage(0);   
    clear();   
   
    if (maxx == 319) {   
        writeText(0,40,"Testing complete",defcolor);   
        writeText(0,60,"press any key to return to text mode",defcolor);   
        }   
    else   
        writeText(80,80,"Testing complete - press any key to return to text mode",defcolor);   
    getch();   
}   
   
int queryCpu(void);   
   
void main(void)   
{   
    int     i,choice,maxmenu;   
    int     xres,yres,bitsperpixel,memmodel,maxpage;   
    long    pagesize;   
    int     menu[20];   
    char    buf[80];   
   
    if (queryCpu() < 4) {   
        printf("This program contains '386 specific instructions, and will not work on\n");   
        printf("this machine - sorry\n");   
        }   
   
    if (initSuperVGA() != 0x102) {   
        printf("This program requires a VESA VBE 1.2 compatible SuperVGA. Try installing\n");   
        printf("the Universal VESA VBE for your video card, or contact your video card\n");   
        printf("vendor and ask for a suitable TSR\n");   
        exit(1);   
        }   
   
    while (true) {   
#ifdef  __TURBOC__   
        clrscr();   
#endif   
        printf("256 color SuperVGA test program (Version %s)\n\n",version);   
        printf("VBE OEM string: %s\n",OEMString);   
        printf("Memory:         %dk\n",memory);   
        printf("\n");   
        printf("Separate read/write banks: %s\n", twobanks ? "Yes" : "No");   
        printf("Extended page flipping:    %s\n", extendedflipping ? "Yes" : "No");   
        printf("8 bit wide DAC support:    %s\n", widedac ? "Yes" : "No");   
        printf("\n");   
        printf("Which video mode to test:\n\n");   
   
        maxmenu = 0;   
   
        /* Add standard VGA modes to menu */   
   
        getSuperVGAModeInfo(menu[maxmenu] = 0x13,&xres,&yres,&bytesperline,   
                &bitsperpixel,&memmodel,&maxpage,&pagesize);   
        printf("    [%2d] - %d x %d 256 color (%d page)\n",maxmenu++,   
            xres,yres,maxpage+1);   
   
        for (i = 0; modeList[i] != -1; i++) {   
            /* Filter out the 256 color packed pixel video modes */   
   
            if (!getSuperVGAModeInfo(modeList[i],&xres,&yres,&bytesperline,   
                    &bitsperpixel,&memmodel,&maxpage,&pagesize))   
                continue;   
            if ((bitsperpixel == 8) && (memmodel == memPK)) {   
                printf("    [%2d] - %d x %d 256 color (%d page)\n",maxmenu,   
                    xres,yres,maxpage+1);   
                menu[maxmenu++] = modeList[i];   
                }   
            }   
        printf("    [ Q] - Quit\n\n");   
        printf("Choice: ");   
   
        gets(buf);   
        if (buf[0] == 'q' || buf[0] == 'Q')   
            break;   
   
        choice = atoi(buf);   
        if (0 <= choice && choice < maxmenu) {   
            if (!setSuperVGAMode(menu[choice])) {   
                printf("\n");   
                printf("ERROR: Video mode did not set correctly!\n\n");   
                printf("\nPress any key to continue...\n");   
                getch();   
                }   
            else {   
                moireTest();   
                readWriteTest();   
                pageFlipTest();   
                testingComplete();   
                restoreMode();   
                }   
            }   
        }   
}