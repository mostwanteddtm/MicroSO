#include <conio.h>
#include <dos.h>
#include <stdio.h>
#include "8390.h"

void main(int argc, char *argv[])
{
	unsigned int i = 0, ret;
	
	char *base = (char *)malloc(lenbase);
    unsigned char *packet = (unsigned char *)malloc(lenpacket);
    char ch, exit = 0;

	FILE *file = fopen("baseaddr.cfg", "r");
	fgets(base, (lenbase + 1), file);

	baseaddr = strtol(base, NULL, 16);
	fclose(file);

    ne2k_init();

	for(i = 0; i <= lenpacket; i++)
	{
        packet[i] = 0xff;
	}

	while(1)
	{
		if(kbhit())
		{
			ch = getch();
			switch(ch)
			{
                case 13:
					put_ne2k(packet, lenpacket);
                    break;
				case 27: 
					exit = 1;
                    break;
			}
		}

		if(exit) break;
	}
}

void ne2k_init()
{
    _outp(baseaddr + NE_CMD, 0x21);               /* Stop, DMA abort, page 0 */
    _outp(baseaddr + NE_DCR, 0x49);        
    _outp(baseaddr + NE_RBCR0, 0x00);             /* Clear remote byte count */
    _outp(baseaddr + NE_RBCR1, 0x00);       
    _outp(baseaddr + NE_RCR, 0x20);               /* Rx monitor mode */
    _outp(baseaddr + NE_TCR, 0x02);               /* Tx internal loopback */       
    _outp(baseaddr + NE_TPSR, 0x40);              /* Set Tx start page */
    _outp(baseaddr + NE_PSTART, 0x46);            /* Set Rx start, stop, boundary */   
    _outp(baseaddr + NE_PSTOP, 0x7E); 
    _outp(baseaddr + NE_BNRY, 0x7D);  
    _outp(baseaddr + NE_ISR, 0xFF);               /* Clear interrupt flags */        
    _outp(baseaddr + NE_IMR, 0x00);               /* Mask all interrupts */

    _outp(baseaddr + NE_CMD, 0x61);               /* Stop, DMA abort, page 1 */
    _outp(baseaddr + DP_MAR0, 0xFF);              /* Multicast accept-all */
    _outp(baseaddr + DP_MAR1, 0xFF);
    _outp(baseaddr + DP_MAR2, 0xFF);
    _outp(baseaddr + DP_MAR3, 0xFF);
    _outp(baseaddr + DP_MAR4, 0xFF);
    _outp(baseaddr + DP_MAR5, 0xFF);
    _outp(baseaddr + DP_MAR6, 0xFF);
    _outp(baseaddr + DP_MAR7, 0xFF);

    _outp(baseaddr + DP_CURR, 0x47);              /* Set current Rx page -- startPage + 1*/
    _outp(baseaddr + NE_CMD,  0x20);              /* DMA abort, page 0 */

    _outp(baseaddr + NE_RCR, 0x14);               /* Allow broadcasts, maybe all pkts */
    _outp(baseaddr + NE_TCR, 0x00);               /* Normal Tx operation */
    _outp(baseaddr + NE_ISR, 0xFF);               /* Clear interrupt flags */

    _outp(baseaddr + NE_CMD, 0x22);               /* Start NIC */

    printf("Init NE 2000 is ok\n");
}

unsigned int put_ne2k(unsigned char *pkt, unsigned int len)
{
    _outp(baseaddr + NE_ISR, 0x0a);                       /* Clear interrupt flags */
    _outp(baseaddr + NE_TBCR0, len & 0xff);               /* Set Tx length regs */
    _outp(baseaddr + NE_TBCR1, len >> 8);
    put(TXSTART<<8, pkt, len);
    _outp(baseaddr + NE_CMD, 0x24);                       /* Transmit the packet */
    return(len);
}

/* Put a packet into a given address in the NIC's RAM */
void put(unsigned int addr, unsigned char data[], unsigned int len)
{
    register int count;
    register unsigned int *dataw, dataport;

    len += len & 1;                             /* Round length up to an even value */
    count = WORDMODE ? len>>1 : len;            /* Halve byte count if word O/P */
    dataport = baseaddr + DATAPORT;               /* Address of NIC data port */
    _outp(baseaddr + NE_ISR, 0x40);               /* Clear remote DMA interrupt flag */
    _outp(baseaddr + NE_RBCR0, len&0xff);         /* Byte count */
    _outp(baseaddr + NE_RBCR1, len>>8);
    _outp(baseaddr + EN0_RSARLO, addr&0xff);      /* Data addr */
    _outp(baseaddr + EN0_RSARHI, addr>>8);
    _outp(baseaddr + NE_CMD, 0x12);               /* Start, DMA remote write */
#if WORDMODE                                    /* Word transfer? */
    dataw = (unsigned int *)data;
    while(count--)
        _outpw(dataport, *dataw++);  /* O/P words */
#else
    while(count--)                  /* O/P bytes */
        outp(dataport, *data++);
#endif
    count = 10000;                      /* Done: must ensure DMA complete */
    while(count && (_inp(baseaddr + NE_ISR)&0x40)==0)
        count--;
}