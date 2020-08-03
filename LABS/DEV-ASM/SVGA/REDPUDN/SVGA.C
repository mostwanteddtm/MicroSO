/****************************************************************************  
*  
*                          SuperVGA Test Library  
*  
*                   Copyright (C) 1993 SciTech Software  
*                           All rights reserved.  
*  
* Filename:     $RCSfile: svgac.c $  
* Version:      $Revision: 1.3 $  
*  
* Language:     ANSI C  
* Environment:  IBM PC (MSDOS)  
*  
* Description:  Simple library to collect together the functions in the  
*               SuperVGA test library for use in other C programs. The  
*               support is reasonably low level, so you can do what you  
*               want. The set of routines in this source file are general  
*               SuperVGA routines and are independant of the video mode  
*               selected.  
*  
*               MUST be compiled in the large model.  
*  
* $Id: svgac.c 1.3 1993/10/22 08:58:40 kjb release $  
*  
****************************************************************************/   
   
#include <string.h>   
#include <dos.h>   
#include <stdlib.h>   
#include "svga.h"   
#include "vesavbe.h"   
   
/*---------------------------- Global Variables ---------------------------*/   
   
#define MAXMODES    50              /* Maximum modes available in list  */   
   
int     maxx,maxy,memory;   
long    maxcolor,defcolor;   
int     maxpage,bytesperline;   
uchar   redMask,greenMask,blueMask;   
int     redPos,redAdjust;   
int     greenPos,greenAdjust;   
int     bluePos,blueAdjust;   
bool    twobanks = false,extendedflipping = false,widedac = false;   
short   modeList[MAXMODES];   
char    OEMString[80];   
   
int     oldMode;                    /* Old video mode number            */   
bool    old50Lines;                 /* Was old mode 80x50?              */   
int     curBank;                    /* Current read/write bank          */   
int     bankAdjust;                 /* Bank granularity adjust factor   */   
long    pagesize;                   /* Page size for current mode       */   
void    *bankSwitch;                /* Pointer to bank switch routine   */   
void    *writeBank;                 /* Relocated write bank routine     */   
void    *readBank;                  /* Relocated read bank routine      */   
void    *pageFlip;                  /* Relocated page flip routine      */   
void    (*putPixel)(int x,int y,long color);   
void    (*clear)(void);   
   
/*----------------------------- Implementation ----------------------------*/   
   
/* Declare all video mode dependent routines */   
   
void _putPixel16(int x,int y,long color);   
void _putPixel256(int x,int y,long color);   
void _putPixel32k(int x,int y,long color);   
void _putPixel64k(int x,int y,long color);   
void _putPixel16m(int x,int y,long color);   
void _clear16(void);   
void _clear256(void);   
void _clear32k(void);   
void _clear64k(void);   
void _clear16m(void);   
   
PRIVATE bool checkVESAPageFlip(void)   
/****************************************************************************  
*  
* Function:     checkVESAPageFlip  
* Returns:      True if VBE supports page flipping.  
*  
* Description:  Determines if the VESA VBE supports extended page  
*               flipping or not. Assume a suitable video mode has already  
*               been initialised.  
*  
****************************************************************************/   
{   
    union REGS  regs;   
   
    regs.x.ax = 0x4F07;         /* Set display start service            */   
    regs.x.bx = 0;              /* BH := 0, BL := 0 (set display start) */   
    regs.x.cx = 0;              /* Leftmost pixel in line               */   
    regs.x.dx = 0;              /* First displayed scanline             */   
    int86(0x10,®s,®s);   
    if (regs.x.ax != 0x004F)   
        return false;           /* Function failed, not page flip       */   
   
    regs.x.ax = 0x4F07;         /* Get display start service            */   
    regs.x.bx = 1;              /* BH := 0, BL := 1 (get display start) */   
    int86(0x10,®s,®s);   
    if (regs.x.ax != 0x004F)   
        return false;           /* Function failed, not page flip       */   
    if (regs.h.bh != 0)   
        return false;   
    if (regs.x.cx != 0)   
        return false;   
    if (regs.x.dx != 0)   
        return false;   
    return true;   
}   
   
bool checkWideDAC(void)   
/****************************************************************************  
*  
* Function:     checkWideDAC  
* Returns:      True if 8 bit wide DAC is supported.  
*  
* Description:  Tests to see if the VBE BIOS supports an 8 bit wide  
*               DAC. This assumes the video card is in an appropriate  
*               video mode before being called.  
*  
****************************************************************************/   
{   
    union REGS  regs;   
    short       bits;   
   
    regs.x.ax = 0x4F08;         /* Set DAC service                      */   
    regs.x.bx = 0x0800;         /* BH := 8, BL := 0 (set DAC width)     */   
    int86(0x10,®s,®s);   
    if (regs.x.ax != 0x004F)   
        return false;           /* Function failed, no wide dac         */   
    if (regs.h.bh == 6)   
        return false;   
    regs.x.ax = 0x4F08;   
    regs.x.bx = 0x0001;         /* Get DAC width (should now be 8)      */   
    int86(0x10,®s,®s);   
    if (regs.x.ax != 0x004F)   
        return false;   
    bits = regs.h.bh;   
    regs.x.ax = 0x4F08;   
    regs.x.bx = 0x0600;   
    int86(0x10,®s,®s);    /* Restore to 6 bit DAC                 */   
    if (regs.x.ax != 0x004F)   
        return false;   
   
    return (bits == 8);   
}   
   
PUBLIC int initSuperVGA(void)   
/****************************************************************************  
*  
* Function:     initSuperVGA  
* Returns:      VBE version number for the SuperVGA (0 if no SuperVGA).  
*  
* Description:  Detects if a VESA VBE compliant SuperVGA is out there, and  
*               initialises the library if one is. The VBE version number  
*               is specified with the major version number in the high  
*               byte and the minor version number in the low byte. So  
*               version 1.2 is the number 0x102.  
*  
****************************************************************************/   
{   
    VgaInfoBlock    vgaInfo;   
    ModeInfoBlock   modeInfo;   
    union REGS      regs;   
    struct SREGS    sregs;   
    short           *p,i;   
   
    sregs.es = SEG(&vgaInfo);   
    regs.x.di = OFF(&vgaInfo);   
    regs.x.ax = 0x4F00;   
    int86x(0x10,®s,®s,&sregs);    /* Get SuperVGA information     */   
    if (regs.x.ax != 0x004F)   
        return false;   
    if (strncmp(vgaInfo.VESASignature,"VESA",4) != 0)   
        return false;   
   
    /* Copy relavent information from the mode block into our globals.  
     * Note that the video mode list _may_ be built in the information  
     * block that we have passed, so we _must_ copy this from here  
     * into our our storage if we want to continue to use it. Note  
     * that we filter out the mode 0x6A, which some BIOSes include as  
     * well as the 0x102 mode for 800x600x16.  
     */   
   
    for (i = 0,p = vgaInfo.VideoModePtr; *p != -1; p++,i++) {   
        if (*p != 0x6A)   
            modeList[i] = *p;   
        }   
    modeList[i] = -1;   
    memory = vgaInfo.TotalMemory * 64;   
    strcpy(OEMString,vgaInfo.OEMStringPtr);   
   
    /* Determine if the board supports separate read/write banks and  
     * extended page flipping. Some VESA VBE's require the card to be  
     * in a graphics mode for these tests to work, so we find a suitable  
     * mode and use that.  
     */   
   
    for (p = modeList; *p != -1; p++) {   
        sregs.es = SEG(&modeInfo);   
        regs.x.di = OFF(&modeInfo);   
        regs.x.ax = 0x4F01;   
        regs.x.cx = *p;   
        int86x(0x10,®s,®s,&sregs);    /* Get SuperVGA mode info   */   
        if (regs.x.ax == 0x004F &&   
                (modeInfo.MemoryModel == 3 || modeInfo.MemoryModel == 4)) {   
            modeInfo.WinBAttributes &= 0x7;   
            twobanks = (modeInfo.WinBAttributes == 0x3);   
            setSuperVGAMode(*p);   
            extendedflipping = checkVESAPageFlip();   
            widedac = checkWideDAC();   
            restoreMode();   
            break;   
            }   
        }   
   
    return vgaInfo.VESAVersion;   
}   
   
PRIVATE void computePageInfo(ModeInfoBlock *modeInfo,int *maxpage,   
    long *pagesize)   
/****************************************************************************  
*  
* Function:     computePageInfo  
* Parameters:   modeInfo    - Pointer to valid mode information block  
*               maxpage     - Number of display pages - 1  
*               pagesize    - Size of each logical display page in bytes  
*  
* Description:  Computes the number of image pages and size of each image  
*               page for a specified video mode.  
*  
****************************************************************************/   
{   
    long    memsize,size;   
   
    if (extendedflipping)   
        memsize = memory * 1024L;   
    else   
        memsize = 256 * 1024L;      /* Use only 256k to compute pages   */   
   
    size = (long)modeInfo->BytesPerScanLine * (long)modeInfo->YResolution;   
    if (modeInfo->BitsPerPixel == 4) {   
        /* We have a 16 color video mode, so round up the page size to  
         * 8k, 16k, 32k or 64k boundaries depending on how large it is.  
         */   
   
        size = (size + 0x1FFFL) & 0xFFFFE000L;   
        if (size != 0x2000) {   
            size = (size + 0x3FFFL) & 0xFFFFC000L;   
            if (size != 0x4000) {   
                size = (size + 0x7FFFL) & 0xFFFF8000L;   
                if (size != 0x8000)   
                    size = (size + 0xFFFFL) & 0xFFFF0000L;   
                }   
            }   
        }   
    else   
        size = (size + 0xFFFFL) & 0xFFFF0000L;   
   
    if (modeInfo->MemoryModel == memPL)   
        memsize /= 4;   
    if (size <= memsize)   
        *maxpage = (memsize / size) - 1;   
    else   
        *maxpage = 0;   
    *pagesize = size;   
}   
   
PUBLIC bool getSuperVGAModeInfo(int mode,int *xres,int *yres,   
    int *bytesperline,int *bitsperpixel,int *memmodel,int *maxpage,   
    long *pagesize)   
/****************************************************************************  
*  
* Function:     getSuperVGAModeInfo  
* Parameters:   mode            - Mode to get information about  
*               xres            - Place to store x resolution  
*               yres            - Place to store y resolution  
*               bytesperline    - Bytes per scanline  
*               bitsperpixel    - Place to store bits per pixel (2^n colors)  
*               memmodel        - Memory model for mode (planar, packed etc)  
*               maxpage         - Number of display pages - 1  
*               pagesize        - Size of each logical display page in bytes  
* Returns:      True if mode number was valid, false if not.  
*  
* Description:  Obtains information about a specific video mode from the  
*               VBE. You should use this function to find the video mode  
*               you wish to set, as the new VBE 2.0 mode numbers may be  
*               completely arbitrary.  
*  
****************************************************************************/   
{   
    ModeInfoBlock   modeInfo;   
    union REGS      regs;   
    struct SREGS    sregs;   
   
    if (mode <= 0x13) {   
        /* This is a standard VGA mode, so fill in the required information  
         * ourselves.  
         */   
   
        switch (mode) {   
            case 0x0D:   
                modeInfo.XResolution = 320;   
                modeInfo.YResolution = 200;   
                modeInfo.BytesPerScanLine = 40;   
                modeInfo.BitsPerPixel = 4;   
                modeInfo.MemoryModel = memPL;   
                break;   
            case 0x0E:   
                modeInfo.XResolution = 640;   
                modeInfo.YResolution = 200;   
                modeInfo.BytesPerScanLine = 80;   
                modeInfo.BitsPerPixel = 4;   
                modeInfo.MemoryModel = memPL;   
                break;   
            case 0x10:   
                modeInfo.XResolution = 640;   
                modeInfo.YResolution = 350;   
                modeInfo.BytesPerScanLine = 80;   
                modeInfo.BitsPerPixel = 4;   
                modeInfo.MemoryModel = memPL;   
                break;   
            case 0x12:   
                modeInfo.XResolution = 640;   
                modeInfo.YResolution = 480;   
                modeInfo.BytesPerScanLine = 80;   
                modeInfo.BitsPerPixel = 4;   
                modeInfo.MemoryModel = memPL;   
                break;   
            case 0x13:   
                modeInfo.XResolution = 320;   
                modeInfo.YResolution = 200;   
                modeInfo.BytesPerScanLine = 320;   
                modeInfo.BitsPerPixel = 8;   
                modeInfo.MemoryModel = memPK;   
                break;   
            default:   
                return false;   
            }   
        }   
    else {   
        /* This is a VESA mode, so call the BIOS to get information about  
         * it.  
         */   
   
        sregs.es = SEG(&modeInfo);   
        regs.x.di = OFF(&modeInfo);   
        regs.x.ax = 0x4F01;   
        regs.x.cx = mode;   
        int86x(0x10,®s,®s,&sregs);    /* Get mode information         */   
        if (regs.x.ax != 0x004F)   
            return false;   
        if ((modeInfo.ModeAttributes & 0x1) == 0)   
            return false;   
        }   
    *xres = modeInfo.XResolution;   
    *yres = modeInfo.YResolution;   
    *bytesperline = modeInfo.BytesPerScanLine;   
    *memmodel = modeInfo.MemoryModel;   
    *bitsperpixel = modeInfo.BitsPerPixel;   
    if (*memmodel == memPK && *bitsperpixel > 8) {   
        /* Support old style definitions, which some BIOS'es still use :-( */   
        *memmodel = memRGB;   
        switch (*bitsperpixel) {   
            case 15:   
                redMask = 0x1F;     redPos = 10;    redAdjust = 3;   
                greenMask = 0x1F;   greenPos = 5;   greenAdjust = 3;   
                blueMask = 0x1F;    bluePos = 0;    blueAdjust = 3;   
                break;   
            case 16:   
                redMask = 0x1F;     redPos = 11;    redAdjust = 3;   
                greenMask = 0x3F;   greenPos = 5;   greenAdjust = 2;   
                blueMask = 0x1F;    bluePos = 0;    blueAdjust = 3;   
                break;   
            case 24:   
                redMask = 0xFF;     redPos = 16;    redAdjust = 0;   
                greenMask = 0xFF;   greenPos = 8;   greenAdjust = 0;   
                blueMask = 0xFF;    bluePos = 0;    blueAdjust = 0;   
                break;   
            }   
        }   
    else if (*memmodel == memRGB) {   
        /* Convert the 32k direct color modes of VBE 1.2+ BIOSes to  
         * be recognised as 15 bits per pixel modes.  
         */   
   
        if (*bitsperpixel == 16 && modeInfo.RsvdMaskSize == 1)   
            *bitsperpixel = 15;   
   
        /* Save direct color info mask positions etc */   
   
        redMask = (0xFF >> (redAdjust = 8 - modeInfo.RedMaskSize));   
        redPos = modeInfo.RedFieldPosition;   
        greenMask = (0xFF >> (greenAdjust = 8 - modeInfo.GreenMaskSize));   
        greenPos = modeInfo.GreenFieldPosition;   
        blueMask = (0xFF >> (blueAdjust = 8 - modeInfo.BlueMaskSize));   
        bluePos = modeInfo.BlueFieldPosition;   
        }   
    if (mode == 0x13 && !extendedflipping)   
        *maxpage = 0;   
    else   
        computePageInfo(&modeInfo,maxpage,pagesize);   
    return true;   
}   
   
typedef struct {   
    short   writeBankLen;   
    void    *writeBank;   
    short   readBankLen;   
    void    *readBank;   
    short   newPageLen;   
    void    *newPage;   
    } PMInfoBlock;   
   
PUBLIC bool setSuperVGAMode(int mode)   
/****************************************************************************  
*  
* Function:     setSuperVGAMode  
* Parameters:   mode    - SuperVGA video mode to set.  
* Returns:      True if the mode was set, false if not.  
*  
* Description:  Attempts to set the specified video mode. This routine  
*               assumes that the library and SuperVGA have been initialised  
*               with the initSuperVGA() routine first.  
*  
****************************************************************************/   
{   
    ModeInfoBlock   modeInfo;   
    PMInfoBlock     *pmInfo = (PMInfoBlock*)&modeInfo;   
    union REGS      regs;   
    struct SREGS    sregs;   
    int             bitsperpixel,memmodel;   
   
    regs.x.ax = 0x0F00;   
    int86(0x10,®s,®s);   
    oldMode = regs.x.ax & 0x7F;         /* Save old video mode          */   
    old50Lines = false;                 /* Default to 25 line mode      */   
    if (oldMode == 0x3) {   
        regs.x.ax = 0x1130;   
        regs.x.bx = 0;   
        regs.x.dx = 0;   
        int86(0x10,®s,®s);   
        old50Lines = (regs.h.dl == 49);   
        }   
   
    regs.x.ax = 0x4F02;   
    regs.x.bx = mode;   
    int86(0x10,®s,®s);            /* Set the video mode           */   
    if (regs.x.ax != 0x004F)   
        return false;   
   
    getSuperVGAModeInfo(mode,&maxx,&maxy,&bytesperline,&bitsperpixel,   
        &memmodel,&maxpage,&pagesize);   
    maxx--; maxy--;   
   
    /* Now set up the vectors to the correct routines for the video  
     * mode type.  
     */   
   
    switch (bitsperpixel) {   
        case 4:   
            putPixel = _putPixel16;   
            clear = _clear16;   
            maxcolor = defcolor = 15;   
            break;   
        case 8:   
            putPixel = _putPixel256;   
            clear = _clear256;   
            maxcolor = 255;   
            defcolor = 15;   
            break;   
        case 15:   
            putPixel = _putPixel32k;   
            clear = _clear32k;   
            maxcolor = defcolor = 0x7FFF;   
            break;   
        case 16:   
            putPixel = _putPixel64k;   
            clear = _clear64k;   
            maxcolor = defcolor = 0xFFFF;   
            break;   
        case 24:   
            putPixel = _putPixel16m;   
            clear = _clear16m;   
            maxcolor = defcolor = 0xFFFFFF;   
            break;   
        }   
   
    if (mode <= 0x13) {   
        /* This is a normal VGA style mode, so we need to determine the  
         * correct information for bank switching from the BIOS  
         */   
   
        if (mode == 0x13)   
            mode = 0x101;   
        else   
            mode = 0x102;   
        }   
    sregs.es = SEG(&modeInfo);   
    regs.x.di = OFF(&modeInfo);   
    regs.x.ax = 0x4F01;   
    regs.x.cx = mode;   
    int86x(0x10,®s,®s,&sregs);    /* Get mode information         */   
    bankAdjust = 64 / modeInfo.WinGranularity;   
    curBank = -1;   
    bankSwitch = modeInfo.WinFuncPtr;   
   
    /* Now set up the vectors to the appropriate bank switching routines.  
     * If the Universal VESA VBE is installed, we can move the bank  
     * switching routines from there into our own code space for speed  
     * (especially under protected mode).  
     */   
   
    sregs.es = SEG(&modeInfo);   
    regs.x.di = OFF(&modeInfo);   
    regs.x.ax = 0x4F01;   
    regs.x.cx = -1;   
    int86x(0x10,®s,®s,&sregs);    /* Get mode information         */   
    writeBank = readBank = pageFlip = NULL;   
    if (regs.x.ax == 0x004F && regs.x.cx == 0xCABD) {   
        /* The Universal VESA VBE is there and functioning, so copy the  
         * routines onto the heap and execute from there.  
         */   
   
        writeBank = malloc(pmInfo->writeBankLen);   
        memcpy(writeBank,pmInfo->writeBank,pmInfo->writeBankLen);   
        if (pmInfo->readBankLen > 0) {   
            readBank = malloc(pmInfo->readBankLen);   
            memcpy(readBank,pmInfo->readBank,pmInfo->readBankLen);   
            }   
        pageFlip = malloc(pmInfo->newPageLen);   
        memcpy(pageFlip,pmInfo->newPage,pmInfo->newPageLen);   
        }   
   
    return true;   
}   
   
PUBLIC void restoreMode(void)   
/****************************************************************************  
*  
* Function:     restoreMode  
*  
* Description:  Restore the previous video mode in use before the SuperVGA  
*               mode was set. This routine will also restore the 50 line  
*               display mode if this mode was previously set.  
*  
****************************************************************************/   
{   
    union REGS  regs;   
   
    regs.x.ax = oldMode;   
    int86(0x10,®s,®s);            /* Set the old video mode       */   
    if (old50Lines) {   
        regs.x.ax = 0x1112;   
        regs.x.bx = 0;   
        int86(0x10,®s,®s);        /* Restore 50 line mode         */   
        }   
}   
   
void setSuperVGADisplayStart(int x,int y)   
/****************************************************************************  
*  
* Function:     setDisplayStart  
* Parameters:   x,y - Position of the first pixel to display  
*  
* Description:  Sets the new starting display position to implement  
*               hardware scrolling.  
*  
****************************************************************************/   
{   
    union REGS  regs;   
   
    if (extendedflipping) {   
        regs.x.ax = 0x4F07;   
        regs.x.bx = 0x0000;   
        regs.x.cx = x;   
        regs.x.dx = y;   
        int86(0x10,®s,®s);   
        }   
}   
   
long rgbColor(uchar r,uchar g,uchar b)   
/****************************************************************************  
*  
* Function:     rgbColor  
*  
* Returns:      Value representing the color. The value is converted from  
*               24 bit RGB space into the appropriate color for the  
*               video mode.  
*  
****************************************************************************/   
{   
    return ((long)((r >> redAdjust) & redMask) << redPos)   
         | ((long)((g >> greenAdjust) & greenMask) << greenPos)   
         | ((long)((b >> blueAdjust) & blueMask) << bluePos);   
}   
   
PUBLIC void line(int x1,int y1,int x2,int y2,long color)   
/****************************************************************************  
*  
* Function:     line  
* Parameters:   x1,y1       - First endpoint of line  
*               x2,y2       - Second endpoint of line  
*               color       - Color to draw the line in  
*  
* Description:  Scan convert a line segment using the MidPoint Digital  
*               Differential Analyser algorithm.  
*  
****************************************************************************/   
{   
    int     d;                      /* Decision variable                */   
    int     dx,dy;                  /* Dx and Dy values for the line    */   
    int     Eincr,NEincr;           /* Decision variable increments     */   
    int     yincr;                  /* Increment for y values           */   
    int     t;                      /* Counters etc.                    */   
   
    dx = ABS(x2 - x1);   
    dy = ABS(y2 - y1);   
   
    if (dy <= dx) {   
   
        /* We have a line with a slope between -1 and 1  
         *  
         * Ensure that we are always scan converting the line from left to  
         * right to ensure that we produce the same line from P1 to P0 as the  
         * line from P0 to P1.  
         */   
   
        if (x2 < x1) {   
            t = x2; x2 = x1; x1 = t;    /* Swap X coordinates           */   
            t = y2; y2 = y1; y1 = t;    /* Swap Y coordinates           */   
            }   
   
        if (y2 > y1)   
            yincr = 1;   
        else   
            yincr = -1;   
   
        d = 2*dy - dx;              /* Initial decision variable value  */   
        Eincr = 2*dy;               /* Increment to move to E pixel     */   
        NEincr = 2*(dy - dx);       /* Increment to move to NE pixel    */   
   
        putPixel(x1,y1,color);      /* Draw the first point at (x1,y1)  */   
   
        /* Incrementally determine the positions of the remaining pixels  
         */   
   
        for (x1++; x1 <= x2; x1++) {   
            if (d < 0) {   
                d += Eincr;         /* Choose the Eastern Pixel         */   
                }   
            else {   
                d += NEincr;        /* Choose the North Eastern Pixel   */   
                y1 += yincr;        /* (or SE pixel for dx/dy < 0!)     */   
                }   
            putPixel(x1,y1,color);  /* Draw the point                   */   
            }   
        }   
    else {   
   
        /* We have a line with a slope between -1 and 1 (ie: includes  
         * vertical lines). We must swap our x and y coordinates for this.  
         *  
         * Ensure that we are always scan converting the line from left to  
         * right to ensure that we produce the same line from P1 to P0 as the  
         * line from P0 to P1.  
         */   
   
        if (y2 < y1) {   
            t = x2; x2 = x1; x1 = t;    /* Swap X coordinates           */   
            t = y2; y2 = y1; y1 = t;    /* Swap Y coordinates           */   
            }   
   
        if (x2 > x1)   
            yincr = 1;   
        else   
            yincr = -1;   
   
        d = 2*dx - dy;              /* Initial decision variable value  */   
        Eincr = 2*dx;               /* Increment to move to E pixel     */   
        NEincr = 2*(dx - dy);       /* Increment to move to NE pixel    */   
   
        putPixel(x1,y1,color);      /* Draw the first point at (x1,y1)  */   
   
        /* Incrementally determine the positions of the remaining pixels  
         */   
   
        for (y1++; y1 <= y2; y1++) {   
            if (d < 0) {   
                d += Eincr;         /* Choose the Eastern Pixel         */   
                }   
            else {   
                d += NEincr;        /* Choose the North Eastern Pixel   */   
                x1 += yincr;        /* (or SE pixel for dx/dy < 0!)     */   
                }   
            putPixel(x1,y1,color);  /* Draw the point                   */   
            }   
        }   
}   
   
PUBLIC void writeText(int x,int y,uchar *str,long color)   
/****************************************************************************  
*  
* Function:     writeText  
* Parameters:   x,y     - Position to begin drawing string at  
*               str     - String to draw  
*  
* Description:  Draws a string using the BIOS 8x16 video font by plotting  
*               each pixel in the characters individually. This should  
*               work for all video modes.  
*  
****************************************************************************/   
{   
    uchar           byte;   
    int             i,j,k,length,ch;   
    uchar           *font;   
   
    font = getFontVec();   
    length = strlen(str);   
    for (k = 0; k < length; k++) {   
        ch = str[k];   
        for (j = 0; j < 16; j++) {   
            byte = *(font + ch * 16 + j);   
            for (i = 0; i < 8; i++) {   
                if ((byte & 0x80) != 0)   
                    putPixel(x+i,y+j,color);   
                byte <<= 1;   
                }   
            }   
        x += 8;   
        }   
}  