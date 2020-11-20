#include <stdio.h>
#include <conio.h>
#include <dos.h>
#include "8390.h"

#define lenbase 0x4
CONFIGNE *cp;

void main(int argc, char *argv[])
{
	unsigned int i = 0;
    unsigned int baseaddr = 0;
	char *base = (char *)malloc(lenbase);

	FILE *file = fopen("base.cfg", "r");
	fgets(base, (lenbase + 1), file);

	baseaddr = strtol(base, NULL, 16);
	fclose(file);

    cp = &configs[0 & NETNUM_MASK]; /* Get pointer into driver data */
    cp->dtype = 0;                  /* Set driver type */
    cp->ebase = ebase = baseaddr;       /* Set card I/O base address */

    if (!resetnic()) printf("Error on init NE2000 :(");
    cp->next_pkt = RXSTART + 1;

    system("CLS");

	while(!kbhit())
        poll_etherne();
}

/* Poll network interface to keep it alive; send & receive frames */
void poll_etherne()
{
    WORD len;
	WORD i = 0;
    static BYTE ebuff[MAXFRAMEC];

    if (cp->ebase)                          /* If Ether card in use.. */
    {   
        ebase = cp->ebase;                  /* Set card I/O address */
        outnic(ISR, 0x01);                  /* Clear interrupt flag */
        /* Receive */
        while ((len = get_etherne(ebuff)) > 0)
        {                                   /* Store frames in buff */
            system("CLS");
            gotoxy(0, 0);
            printf("0x%X", cp->next_pkt);
			for(i = 0; i < len; i++)
			{
				if (i % 16 == 0) printf("\n");
				ebuff[i] <= 0xf ? printf("0%X ", ebuff[i]) : printf("%X ", ebuff[i]);
			}			
        }
    }
}

/* Get packet into buffer, return length (excl CRC), or 0 if none available */
WORD get_etherne(unsigned char *pkt)
{
    WORD len=0, curr;
    BYTE bnry;

    if (innic(ISR) & 0x10)              /* If Rx overrun.. */
    {
        printf("  NIC Rx overrun\n");
        //resetnic(cp, 0);                /* ..reset controller (drastic!) */
    }

    outnic(CMDR, 0x60);                 /* DMA abort, page 1 */
    curr = innic(CURR);                 /* Get current page */
    outnic(CMDR, 0x20);                 /* DMA abort, page 0 */
    if (curr != cp->next_pkt)           /* If Rx packet.. */
    {
        memset(&nichdr, 0xee, sizeof(nichdr));  /* ..get NIC header */
        getnic((WORD)(cp->next_pkt<<8), (BYTE *)&nichdr, sizeof(nichdr));

        len = nichdr.len;               /* Take length from stored header */
        if ((nichdr.stat&1) && len>=MINFRAMEC && len<=MAXFRAMEC)
        {                               /* If hdr is OK, get packet */
            len -= CRCLEN;              /* ..without CRC! */
            if (pkt)
                getnic((WORD)((cp->next_pkt<<8)+sizeof(nichdr)), pkt, len);
        }
        else                            /* If not, no packet data */
        {
            printf("  NIC packet error\n");
        }                               /* Update next packet ptr */
        if (nichdr.next>=RXSTART && nichdr.next<RXSTOP)
            cp->next_pkt = nichdr.next;
        else                            /* If invalid, use prev+1 */
        {
            printf("  NIC pointer error\n");
            cp->next_pkt = nicwrap(cp->next_pkt + 1);
        }                               /* Update boundary register */
        bnry = nicwrap(cp->next_pkt - 1);
        outnic(BNRY, bnry);
    }
    return(len);                        /* Return length excl. CRC */
}

/* Get a packet from a given address in the NIC's RAM */
void getnic(WORD addr, BYTE data[], WORD len)
{
    register int count;
    register WORD *dataw, dataport;

    count = WORDMODE ? len>>1 : len;    /* Halve byte count if word I/P */
    dataport = ebase + DATAPORT;        /* Address of NIC data port */
    outnic(ISR, 0x40);                  /* Clear remote DMA interrupt flag */
    outnic(RBCR0, len&0xff);            /* Byte count */
    outnic(RBCR1, len>>8);
    outnic(RSAR0, addr&0xff);           /* Data addr */
    outnic(RSAR1, addr>>8);
    outnic(CMDR, 0x0a);                 /* Start, DMA remote read */
#if WORDMODE
    dataw = (WORD *)data;               /* Use pointer for speed */
    while(count--)                      /* Get words */
        *dataw++ = inpw(dataport);
    if (len & 1)                        /* If odd length, do last byte */
        *(BYTE *)dataw = inp(dataport);
#else
    while(count--)                      /* Get bytes */
        *data++ = inp(dataport);
#endif
}

/* Reset the Ethernet card, if 'cold' start, get my 6-byte address */
int resetnic()
{
    int i, cold = 1;
    BYTE temp[MACLEN*2];

    outnic(CMDR, 0x21);                 /* Stop, DMA abort, page 0 */

    outnic(DCR, DCRVAL);
    outnic(RBCR0, 0);                   /* Clear remote byte count */
    outnic(RBCR1, 0);
    outnic(RCR, 0x20);                  /* Rx monitor mode */
    outnic(TCR, 0x02);                  /* Tx internal loopback */
    outnic(TPSR, TXSTART);              /* Set Tx start page */
    outnic(PSTART, RXSTART);            /* Set Rx start, stop, boundary */
    outnic(PSTOP, RXSTOP);
    outnic(BNRY, (BYTE)(RXSTOP-1));
    outnic(ISR, 0xff);                  /* Clear interrupt flags */
    outnic(IMR, 0);                     /* Mask all interrupts */
    if (cold)
    {
        outnic(CMDR, 0x22);             /* Start NIC, DMA abort */
        getnic(0, temp, 12);            /* Get 6-byte addr */
        for (i=0; i<MACLEN; i++)        /* Convert addr words to bytes */
            cp->myeth[i] = temp[WORDMODE ? i+i : i];
    }

    outnic(CMDR, 0x61);                 /* Stop, DMA abort, page 1 */

    for (i=0; i<6; i++)                 /* Set Phys addr */
        outnic(PAR0+i, cp->myeth[i]);

    for (i=0; i<8; i++)                 /* Multicast accept-all */
        outnic(MAR0+i, 0xff);
    outnic(CURR, RXSTART+1);            /* Set current Rx page */
    cp->next_pkt = RXSTART + 1;
    outnic(CMDR, 0x20);                 /* DMA abort, page 0 */
    outnic(RCR, promisc ? 0x14 : 0x04); /* Allow broadcasts, maybe all pkts */
    outnic(TCR, 0);                     /* Normal Tx operation */
    outnic(ISR, 0xff);                  /* Clear interrupt flags */
    outnic(CMDR, 0x22);                 /* Start NIC */

    return 1;
}

void gotoxy (int x, int y)
{ union REGS regs;
  regs.h.ah = 2; /* cursor position */
  regs.h.dh = y;
  regs.h.dl = x;
  regs.h.bh = 0; /* vi­deo page #0 */
  int86(0x10, &regs, &regs);
}

/* Input a byte from a NIC register */
BYTE innic(int reg)
{
    return(inp((WORD)(ebase+reg)));
}

/* Output a byte to a NIC register */
void outnic(int reg, int b)
{
    outp((WORD)(ebase+reg), b);
}

/* Wrap an NIC Rx page number */
BYTE nicwrap(int page)
{
   if (page >= RXSTOP)
       page += RXSTART - RXSTOP;
   else if (page < RXSTART)
       page += RXSTOP - RXSTART;
   return(page);
}

/* Safe versions of the min() & max() macros for use on re-entrant code
** Ensures that any function arguments aren't called twice */
WORD minw(WORD a, WORD b)
{
    return(a<b ? a : b);
}
WORD maxw(WORD a, WORD b)
{
    return(a>b ? a : b);
}