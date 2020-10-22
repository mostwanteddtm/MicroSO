#include <stdio.h>
#include <conio.h>
#include <dos.h>
#include "8390.h"

#define lenbase 0x4

void main(int argc, char *argv[])
{
	unsigned int i = 0;
    unsigned long baseaddr = 0;
	char *base = (char *)malloc(lenbase);

	FILE *file = fopen("baseaddr.cfg", "r");
	fgets(base, (lenbase + 1), file);

	baseaddr = strtol(base, NULL, 16);
	fclose(file);

    printf("Init NE 2000 is %s\n", init_etherne(0, baseaddr) ? "ok!" : "with error :(");

	while(!kbhit())
	{
		gotoxy(0, 0);
		poll_etherne(0);
	}
}

void gotoxy (int x, int y)
{ union REGS regs;
  regs.h.ah = 2; /* cursor position */
  regs.h.dh = y;
  regs.h.dl = x;
  regs.h.bh = 0; /* vi­deo page #0 */
  int86(0x10, &regs, &regs);
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

/* Poll network interface to keep it alive; send & receive frames */
void poll_etherne(WORD dtype)
{
    WORD len;
	WORD i = 0;
    static BYTE ebuff[MAXFRAMEC];
    CONFIGNE *cp;

    cp = &configs[dtype & NETNUM_MASK];
    if (cp->ebase)                          /* If Ether card in use.. */
    {
        ebase = cp->ebase;                  /* Set card I/O address */
        outnic(ISR, 0x01);                  /* Clear interrupt flag */
        /* Receive */
        while ((len=get_etherne(cp->dtype, ebuff))>0)
        {                                   /* Store frames in buff */
            receive_upcall(cp->dtype, ebuff, len);
            system("CLS");
			for(i = 0; i < len; i++)
			{
				if (i % 16 == 0) printf("\n");
				ebuff[i] <= 0xf ? printf("0%X ", ebuff[i]) : printf("%X ", ebuff[i]);
			}			
        }
    }
}

/* Get packet into buffer, return length (excl CRC), or 0 if none available */
WORD get_etherne(WORD dtype, unsigned char *pkt)
{
    WORD len=0, curr;
    BYTE bnry;
    CONFIGNE *cp;
#if STARHACK
    int hilen, lolen;
#endif
    cp = &configs[dtype & NETNUM_MASK];
    ebase = cp->ebase;
    if (innic(ISR) & 0x10)              /* If Rx overrun.. */
    {
        printf("  NIC Rx overrun\n");
        resetnic(cp, 0);                /* ..reset controller (drastic!) */
    }
    outnic(CMDR, 0x60);                 /* DMA abort, page 1 */
    curr = innic(CURR);                 /* Get current page */
    outnic(CMDR, 0x20);                 /* DMA abort, page 0 */
    if (curr != cp->next_pkt)           /* If Rx packet.. */
    {
        memset(&nichdr, 0xee, sizeof(nichdr));  /* ..get NIC header */
        getnic((WORD)(cp->next_pkt<<8), (BYTE *)&nichdr, sizeof(nichdr));
#if STARHACK
        hilen = nichdr.next - cp->next_pkt - 1;
        lolen = nichdr.len & 0xff;
        if (hilen < 0)                  /* Do len calc from NIC datasheet */
            hilen = RXSTOP - cp->next_pkt + nichdr.next - RXSTART - 1;
        if (lolen > 0xfc)
            hilen++;
        len = (hilen<<8) + lolen;
        if (len != nichdr.len)          /* ..and compare with actual value */
        {
            if (netdebug)
                printf("  NIC length mismatch %Xh - %Xh\n", len, nichdr.len);
        }
#else
        len = nichdr.len;               /* Take length from stored header */
#endif
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

/* Rx upcall from network driver; store a received frame, return 0 if no room
** If buffer pointer is null, only check if the required space is available
** Beware: this function may be called by an interrupt handler */
WORD receive_upcall(WORD dtype, unsigned char *buff, WORD len)
{
    static GENHDR gh;                       /* Static for BC 4.5 interrupts! */

    len = minw(len, MAXFRAME);              /* Truncate to max size */
    if (len>0 && buff_freelen(&rxpkts) >= len+sizeof(GENHDR))
    {                                       /* If space in circ buffer..*/
        if (buff)
        {
            gh.len = len;                   /* Store general frame hdr */
            gh.dtype = dtype;
            buff_in(&rxpkts, (BYTE *)&gh, sizeof(gh));
            buff_in(&rxpkts, buff, len);    /* ..and frame */
        }
    }
    else                                    /* If no space, discard frame */
        len = 0;
    return(len);
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

/* Return length of free space in buffer */
WORD buff_freelen(CBUFF *bp)
{
    return(bp->len ? bp->len - 1 - buff_dlen(bp) : 0);
}

/* Load data into buffer, return byte count that could be accepted
** If data pointer is null, adjust pointers but don't transfer data */
WORD buff_in(CBUFF *bp, BYTE *data, WORD len)
{
    WORD in, n, n1, n2;

    in = (WORD)bp->in & (bp->len-1);        /* Mask I/P ptr to buffer area */
    n = minw(len, buff_freelen(bp));        /* Get max allowable length */
    n1 = minw(n, (WORD)(bp->len - in));     /* Length up to end of buff */
    n2 = n - n1;                            /* Length from start of buff */
    if (n1 && data)                         /* If anything to copy.. */
        memcpy(&bp->data[in], data, n1);    /* ..copy up to end of buffer.. */
    if (n2 && data)                         /* ..and maybe also.. */
        memcpy(bp->data, &data[n1], n2);    /* ..copy into start of buffer */
    bp->in += n;                            /* Bump I/P pointer */
    return(n);
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

/* Return total length of data in buffer */
WORD buff_dlen(CBUFF *bp)
{
    return((WORD)((bp->in - bp->out) & (bp->len - 1)));
}