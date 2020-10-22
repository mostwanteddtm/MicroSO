#include <stdio.h>
#include "8390.h"

void main(int argc, char *argv[])
{
	unsigned int i = 0;
	unsigned long baseaddr = 0;
	char *base = (char *)malloc(lenbase);
    char ch, exit = 0;

	FILE *file = fopen("baseaddr.cfg", "r");
	fgets(base, (lenbase + 1), file);

	baseaddr = strtol(base, NULL, 16);
	fclose(file);
	
    printf("Init NE 2000 is %s\n", init_etherne(0, baseaddr) ? "ok!" : "with error :(");

	txpkts.in = 0x64;
	for(i = 0; i <= txpkts.in; i++)
	{
		txpkts.data[i] = 0xff;
	}

	while(1)
	{
		if(kbhit())
		{
			ch = getch();
			switch(ch)
			{
                case 13:
					put_etherne(0, txpkts.data, 0x64);
                    break;
				case 27: 
					exit = 1;
                    break;
			}
		}

		if(exit) break;
	}
}

/* Initialise card given driver type and base addr.
** Return driver type, 0 if error */
int init_etherne(WORD dtype, WORD baseaddr)
{
    int ok=0;
    CONFIGNE *cp;

    cp = &configs[dtype & NETNUM_MASK]; /* Get pointer into driver data */
    cp->dtype = dtype;                  /* Set driver type */
    cp->ebase = ebase = baseaddr;       /* Set card I/O base address */
    outnic(NE_RESET, innic(NE_RESET));  /* Do reset */
    delay(2);
    if ((innic(ISR) & 0x80) == 0)       /* Report if failed */
    {
        printf("  Ethernet card failed to reset!\n");
    }
    else
    {
        resetnic(cp, 1);                /* Reset Ethernet card, get my addr */
        ok = 1;
    }
    return(ok);
}

/* Reset the Ethernet card, if 'cold' start, get my 6-byte address */
void resetnic(CONFIGNE *cp, char cold)
{
    int i;
    BYTE temp[MACLEN*2];

    outnic(CMDR, 0x21);                 /* Stop, DMA abort, page 0 */
    delay(2);                           /* ..wait to take effect */
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
    delay(2);
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

/* Send Ethernet packet given len excl. CRC, return 0 if NIC is busy */
WORD put_etherne(WORD dtype, unsigned char *pkt, WORD len)
{
    CONFIGNE *cp;

    cp = &configs[dtype & NETNUM_MASK];
    ebase = cp->ebase;
    memcpy((BYTE *)pkt+MACLEN, cp->myeth, MACLEN);  /* Set source addr */
    outnic(ISR, 0x0a);              /* Clear interrupt flags */
    outnic(TBCR0, len & 0xff);      /* Set Tx length regs */
    outnic(TBCR1, len >> 8);
    putnic(TXSTART<<8, pkt, len);
    outnic(CMDR, 0x24);             /* Transmit the packet */
    return(len);
}

/* Put a packet into a given address in the NIC's RAM */
void putnic(WORD addr, BYTE data[], WORD len)
{
    register int count;
    register WORD *dataw, dataport;

    len += len & 1;                     /* Round length up to an even value */
    count = WORDMODE ? len>>1 : len;    /* Halve byte count if word O/P */
    dataport = ebase + DATAPORT;        /* Address of NIC data port */
    outnic(ISR, 0x40);                  /* Clear remote DMA interrupt flag */
    outnic(RBCR0, len&0xff);            /* Byte count */
    outnic(RBCR1, len>>8);
    outnic(RSAR0, addr&0xff);           /* Data addr */
    outnic(RSAR1, addr>>8);
    outnic(CMDR, 0x12);                 /* Start, DMA remote write */
#if WORDMODE                            /* Word transfer? */
    dataw = (WORD *)data;
    while(count--)
        outpw(dataport, *dataw++);  /* O/P words */
#else
    while(count--)                  /* O/P bytes */
        outp(dataport, *data++);
#endif
    count = 10000;                      /* Done: must ensure DMA complete */
    while(count && (innic(ISR)&0x40)==0)
        count--;
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

void msdelay(WORD millisec)
{
    int n;

    while (millisec--)
    {
        for (n=0; n<1500; n++)
            inp(0x61);
    }
}