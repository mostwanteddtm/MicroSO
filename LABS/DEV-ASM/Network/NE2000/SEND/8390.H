#define lenbase      0x4
#define lenpacket    0x64

#define RSR_FO       0x08
#define RSR_PRX      0x01
#define DEF_ENABLED  0x200
 
#define OK 0

#define startPage    0x46
#define stopPage     0x7E
 
#define NE_CMD       0x00
#define NE_PSTART    0x01
#define NE_PSTOP     0x02
#define NE_BNRY      0x03
#define NE_TPSR      0x04
#define NE_TBCR0     0x05
#define NE_TBCR1     0x06
#define NE_ISR       0x07
#define NE_CURRENT   0x07
#define NE_RBCR0     0x0A
#define NE_RBCR1     0x0B
#define NE_RCR       0x0C
#define NE_TCR       0x0D
#define NE_DCR       0x0E
#define NE_IMR       0x0F
 
#define NE_DCR_WTS   0x01
#define NE_DCR_LS    0x08
#define NE_DCR_AR    0x10
#define NE_DCR_FT1   0x40
#define NE_DCR_FT0   0x20
 
#define E8390_STOP   0x01
#define E8390_NODMA  0x20
#define E8390_PAGE0  0x00
#define E8390_PAGE1  0x40
#define E8390_CMD    0x00
#define E8390_START  0x02
#define E8390_RREAD  0x08
#define E8390_RWRITE 0x10
#define E8390_RXOFF  0x20
#define E8390_TXOFF  0x00
#define E8390_RXCONFIG 0x04
#define E8390_TXCONFIG 0x00
 
#define EN0_COUNTER0 0x0d
#define EN0_DCFG     0x0e
#define EN0_RCNTLO   0x0a
#define EN0_RCNTHI   0x0b
#define EN0_ISR      0x07
#define EN0_IMR      0x0f
#define EN0_RSARLO   0x08
#define EN0_RSARHI   0x09
#define EN0_TPSR     0x04
#define EN0_RXCR     0x0c
#define EN0_TXCR     0x0D
#define EN0_STARTPG  0x01
#define EN0_STOPPG   0x02
#define EN0_BOUNDARY 0x03
 
#define EN1_PHYS     0x01
#define EN1_CURPAG   0x07
#define EN1_MULT     0x08
 
#define NE1SM_START_PG 0x20
#define NE1SM_STOP_PG 0x40
#define NESM_START_PG 0x40
#define NESM_STOP_PG  0x80
 
#define ENISR_ALL    0x3f
 
#define ENDCFG_WTS   0x01
 
#define NE_DATAPORT  0x10
 
#define TX_2X_PAGES 12
#define TX_1X_PAGES 6
#define TX_PAGES TX_2X_PAGES
 
#define DP_CURR         0x7     /* Current Page Register             */
#define DP_MAR0         0x8     /* Multicast Address Register 0      */
#define DP_MAR1         0x9     /* Multicast Address Register 1      */
#define DP_MAR2         0xA     /* Multicast Address Register 2      */
#define DP_MAR3         0xB     /* Multicast Address Register 3      */
#define DP_MAR4         0xC     /* Multicast Address Register 4      */
#define DP_MAR5         0xD     /* Multicast Address Register 5      */
#define DP_MAR6         0xE     /* Multicast Address Register 6      */
#define DP_MAR7         0xF     /* Multicast Address Register 7      */
 
#define DP_CNTR0        0xD     /* Tally Counter 0                   */
#define DP_CNTR1        0xE     /* Tally Counter 1                   */
#define DP_CNTR2        0xF     /* Tally Counter 2                   */
 
#define DP_PAGESIZE     256

#define WORDMODE    0x01
#define TXSTART     0x40
#define DATAPORT    0x10

unsigned long baseaddr = 0;

void ne2k_init();
unsigned int put_ne2k(unsigned char *pkt, unsigned int len);
void put(unsigned int addr, unsigned char data[], unsigned int len);
