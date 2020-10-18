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

CBUFF txpkts = {_CBUFFLEN_};

/* Private prototypes */
void msdelay(WORD millisec);
BYTE innic(int reg);
void outnic(int reg, int b);

int init_etherne(WORD dtype, WORD baseaddr);
void resetnic(CONFIGNE *cp, char cold);

WORD put_etherne(WORD dtype, unsigned char *pkt, WORD len);
void getnic(WORD addr, BYTE data[], WORD len);
void putnic(WORD addr, BYTE data[], WORD len);
