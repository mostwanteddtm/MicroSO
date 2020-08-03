#include <conio.h>
#include <dos.h>
#include <stdlib.h>		//malloc
#include "rtl8139.h"

#define	RX_BUFFER_SIZE		16*1024

extern void printdw(unsigned long value);

/* Microsoft Visual C++ */
void (interrupt *inthandler)();

void resetnic(unsigned IOBase)
{
    // unsigned char *tmpBuffer = (unsigned char *)malloc(RX_BUFFER_SIZE + 2000);

    // int segment = FP_SEG(tmpBuffer);
    // int offset = FP_OFF(tmpBuffer);

    // unsigned long RxBufferPhysicalAddress = (segment << 4) + offset;

	outp(IOBase + CR, CR_RST);              //reset
	outp(IOBase + CR, CR_RE + CR_TE);       //enable Tx/Rx
	outpdw(IOBase + TCR, TCR_IFG0 | TCR_IFG1 | TCR_MXDMA2 | TCR_MXDMA1);
	// outpdw(IOBase + RCR, RCR_RBLEN0 | RCR_MXDMA2 | RCR_MXDMA1 | RCR_AB | RCR_AM | RCR_APM);
	// outpdw(IOBase + RBSTART, RxBufferPhysicalAddress);
	// outp(IOBase + IMR, R39_INTERRUPT_MASK); //enable interrupt
}