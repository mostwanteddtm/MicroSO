#include <memory.h>
#include <io.h>
#include <stdio.h>
#include <conio.h>
#include <stdlib.h>

#define inp(a)      _inp(a)
#define outp(a, b)  _outp(a, b)
#define inpw(a)     _inpw(a)
#define outpw(a, b) _outpw(a, b)

#ifndef BYTE
#define BYTE unsigned char
#endif
#ifndef WORD
#define WORD unsigned short
#endif
#ifndef LWORD
#define LWORD unsigned long
#endif

#define MACLEN   6              /* Ethernet (MAC) address length */
#define CRCLEN   4              /* Ethernet hardware CRC length */
#define MAXNETS  4              /* Max net interfaces, must be power of 2 */
#define NETNUM_MASK (MAXNETS-1) /* Mask for network number */

#define MINFRAME 60             /* Minimum frame size (excl CRC) */
#define MAXFRAME 1514           /* Maximum frame size (excl CRC) */
#define MINFRAMEC 64            /* Minimum frame size (incl CRC) */
#define MAXFRAMEC 1518          /* Maximum frame size (incl CRC) */

#define delay(x) msdelay(x)

#define WORDMODE 1              /* Set to zero if using 8-bit XT-bus cards */

/* NE2000 definitions */
#define DATAPORT 0x10
#define NE_RESET 0x1f

/* 8390 Network Interface Controller (NIC) page0 register offsets */
#define CMDR    0x00            /* command register for read & write */
#define PSTART  0x01            /* page start register for write */
#define PSTOP   0x02            /* page stop register for write */
#define BNRY    0x03            /* boundary reg for rd and wr */
#define TPSR    0x04            /* tx start page start reg for wr */
#define TBCR0   0x05            /* tx byte count 0 reg for wr */
#define TBCR1   0x06            /* tx byte count 1 reg for wr */
#define ISR     0x07            /* interrupt status reg for rd and wr */
#define RSAR0   0x08            /* low byte of remote start addr */
#define RSAR1   0x09            /* hi byte of remote start addr */
#define RBCR0   0x0A            /* remote byte count reg 0 for wr */
#define RBCR1   0x0B            /* remote byte count reg 1 for wr */
#define RCR     0x0C            /* rx configuration reg for wr */
#define TCR     0x0D            /* tx configuration reg for wr */
#define DCR     0x0E            /* data configuration reg for wr */
#define IMR     0x0F            /* interrupt mask reg for wr */

/* NIC page 1 register offsets */
#define PAR0    0x01            /* physical addr reg 0 for rd and wr */
#define CURR    0x07            /* current page reg for rd and wr */
#define MAR0    0x08            /* multicast addr reg 0 for rd and WR */

/* Buffer Length and Field Definition Info */
#define TXSTART  0x40           /* Tx buffer start page */
#define TXPAGES  6              /* Pages for Tx buffer */
#define RXSTART  (TXSTART+TXPAGES)  /* Rx buffer start page */
#if WORDMODE
#define RXSTOP   0x7e           /* Rx buffer end page for word mode */
#define DCRVAL   0x49           /* DCR values for word mode */
#else
#define RXSTOP   0x5f           /* Ditto for byte mode */
#define DCRVAL   0x48
#endif
#define STARHACK 0              /* Set non-zero to enable Starlan length hack */

typedef struct                  /* Net driver configuration data */
{
    WORD dtype;                     /* Driver type */
    BYTE myeth[MACLEN];             /* MAC (Ethernet) addr */
    WORD ebase;                     /* Card I/O base addr */
    WORD next_pkt;                  /* Next (current) Rx page */
} CONFIGNE;

static CONFIGNE configs[MAXNETS];   /* Driver configurations */

static WORD ebase;              /* Temp I/O base addr; usually 280h for PC */
int promisc=0;                  /* Flag to enable promiscuous mode */

/* Default circular buffer size: MUST be power of 2
** This definition is for initialisation only, and may be overriden to
** create a larger or smaller buffer. To determine the actual buffer size, all
** functions MUST use the 'len' value below, not the _CBUFFLEN_ definition */
#ifndef _CBUFFLEN_
#define _CBUFFLEN_ 0x800
#endif
/* Circular buffer structure */
typedef struct
{
    WORD len;                   /* Length of data (must be first) */
    LWORD in;                   /* Incoming data */
    LWORD out;                  /* Outgoing data */
    LWORD trial;                /* Outgoing data 'on trial' */
    BYTE data[_CBUFFLEN_];      /* Buffer */
} CBUFF;

CBUFF rxpkts = {_CBUFFLEN_};        /* Rx and Tx circular packet buffers */
CBUFF txpkts = {_CBUFFLEN_};

/* General-purpose frame header, and frame including header */
typedef struct {
    WORD len;                   /* Length of data in genframe buffer */
    WORD dtype;                 /* Driver type */
    WORD fragoff;               /* Offset of fragment within buffer */
} GENHDR;

typedef struct {                /* NIC hardware packet header */
    BYTE stat;                  /*     Error status */
    BYTE next;                  /*     Pointer to next block */
    WORD len;                   /*     Length of this frame incl. CRC */
} NICHDR;

NICHDR nichdr;

/* Private prototypes */
void msdelay(WORD millisec);
BYTE innic(int reg);
void outnic(int reg, int b);

int init_etherne(WORD dtype, WORD baseaddr);
void resetnic(CONFIGNE *cp, char cold);

WORD put_etherne(WORD dtype, unsigned char *pkt, WORD len);
void getnic(WORD addr, BYTE data[], WORD len);
void putnic(WORD addr, BYTE data[], WORD len);

void main(int argc, char *argv[])
{
	unsigned int i = 0;
    printf("Init NE 2000 is %s\n", init_etherne(0, 0x300) ? "ok!" : "with error :(");

	txpkts.in = 0x64;
	for(i = 0; i <= txpkts.in; i++)
	{
		txpkts.data[i] = 0xff;
	}

    put_etherne(0, txpkts.data, 0x64);
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