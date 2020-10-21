//
// Driver to fool Qemu into sending and receiving packets for us via it's ne2k_isa emulation
//
// This driver is unlikely to work with real hardware without substantial modifications
// and is purely for helping with the development of network stacks.
//
// Interrupts are not supported.
//


#include "io.h"
#include <string.h>
#include <stdio.h>
#include "syslog.h"
#include <netdevice.h>
#include <ether.h>
#include "ne2k.h"


// Make concrete class out of netdevice abstract one


class Ne2k: public NetDevice
{
public:

  // Setup ring buffers and so on.
  virtual void Init();

  // enable packet reception
  virtual void rx_enable();

  // enable packet transmission
  virtual void rx_disable();

  // transmit a packet
  virtual void Transmit(unsigned char* pkt, size_t length);

  // receive a packet
  virtual size_t Receive(unsigned char* pkt, size_t max_len);

  // get link stats
  virtual void GetStats(u32& rx, u32& tx);
};


// Port addresses
#define NE_BASE		0x300
#define NE_CMD          (NE_BASE + 0x00)


#define EN0_STARTPG      (NE_BASE + 0x01)
#define EN0_STOPPG       (NE_BASE + 0x02)


#define EN0_BOUNDARY    (NE_BASE + 0x03)
#define EN0_TPSR        (NE_BASE + 0x04)

#define EN0_TBCR_LO     (NE_BASE + 0x05)
#define EN0_TBCR_HI     (NE_BASE + 0x06)

#define EN0_ISR         (NE_BASE + 0x07)
#define NE_DATAPORT     (NE_BASE + 0x10)    // NatSemi-defined port window offset


#define EN1_CURR        (NE_BASE + 0x07)    // current page
#define EN1_PHYS        (NE_BASE + 0x11)    // physical address


// Where to DMA data to/from
#define EN0_REM_START_LO     (NE_BASE + 0x08)
#define EN0_REM_START_HI     (NE_BASE + 0x09)

// How much data to DMA
#define EN0_REM_CNT_LO     (NE_BASE + 0x0a)
#define EN0_REM_CNT_HI     (NE_BASE + 0x0b)


#define EN0_RSR		   (NE_BASE + 0x0c)

// Commands to select the different pages.
#define NE_PAGE0_STOP        0x21
#define NE_PAGE1_STOP        0x61

#define NE_PAGE0        0x20
#define NE_PAGE1        0x60


#define NE_START        0x02
#define NE_STOP         0x01


#define NE_PAR0         (NE_BASE + 0x01)
#define NE_PAR1         (NE_BASE + 0x02)
#define NE_PAR2         (NE_BASE + 0x03)
#define NE_PAR3         (NE_BASE + 0x04)
#define NE_PAR4         (NE_BASE + 0x05)
#define NE_PAR5         (NE_BASE + 0x06)


#define ENISR_RESET   0x80


#define TX_BUFFER_START ((16*1024)/256)
#define RX_BUFFER_START ((16*1024)/256+6)
#define RX_BUFFER_END ((32*1024)/256)    // could made this a lot higher



// statistics
static u32 g_RX_packets;
static u32 g_TX_packets;

void Ne2k::GetStats(u32& rx, u32& tx)
{
  rx = g_RX_packets;
  tx = g_TX_packets;
}



// Applies to ne2000 version of the card.
#define NESM_START_PG   0x40    /* First page of TX buffer */
#define NESM_STOP_PG    0x80    /* Last page +1 of RX ring */


void Ne2k::rx_enable()
{
  outb(NE_PAGE0_STOP, NE_CMD);
  outb(RX_BUFFER_START, EN0_BOUNDARY);
  outb(NE_PAGE1_STOP, NE_CMD);
  outb(RX_BUFFER_START, EN1_CURR);
  outb(NE_START, NE_CMD);
}

void Ne2k::rx_disable()
{
  // do nothing
  outb(NE_STOP, NE_CMD);
}


// setup descriptors, start packet reception
void Ne2k::Init(void)
{
  // Clear stats.
  g_RX_packets = 0;
  g_TX_packets = 0;
  
  rx_disable();
}


static void SetTxCount(u32 val)
{
  // Set how many bytes we're going to send.
  outb(u8(val & 0xff), EN0_TBCR_LO);
  outb(u8((val & 0xff00) >> 8), EN0_TBCR_HI);  
}



static void SetRemAddress(u32 val)
{
  // Set how many bytes we're going to send.
  outb(u8(val & 0xff), EN0_REM_START_LO);
  outb(u8((val & 0xff00) >> 8), EN0_REM_START_HI);  
}


static void SetRemByteCount(u32 val)
{
  // Set how many bytes we're going to send.
  outb(u8(val & 0xff), EN0_REM_CNT_LO);
  outb(u8((val & 0xff00) >> 8), EN0_REM_CNT_HI);  
}


static void CopyDataToCard(u32 dest, u8* src, u32 length)
{
  SetRemAddress(dest);
  SetRemByteCount(length);
  for (u32 i=0;i<length;i++)
  {
    outb(*src, NE_BASE + 0x10);
    src++;
  }

}


static void CopyDataFromCard(u32 src, u8* dest, u32 length)
{
  SetRemAddress(src);
  SetRemByteCount(length);
  for (u32 i=0;i<length;i++)
  {
    *dest = inb(NE_BASE + 0x10);
    dest++;
  }
}


// Copy data out of the receive buffer.
static size_t CopyPktFromCard(u8* dest, u32 max_len)
{
  // Find out where the next packet is in card memory
  u32 src = inb(EN0_BOUNDARY) * 256;
  
  u8 header[4];
  CopyDataFromCard(src, header, sizeof(header));
  
  u32 next = header[1];
  
  u32 total_length = header[3];
  total_length <<= 8;
  total_length |=  header[2];
  
  // Now copy it to buffer, if possible, skipping the info header.
  src += 4;
  total_length -= 4;
  CopyDataFromCard(src, dest, total_length);
  
  // Release the buffer by increasing the boundary pointer.
  outb(next, EN0_BOUNDARY);
  
  return total_length;
}




// Returns size of pkt, or zero if none received.
size_t Ne2k::Receive(u8* pkt, size_t max_len)
{
  size_t ret = 0;
  
  outb(NE_PAGE1, NE_CMD);
  u32 current = inb(EN1_CURR);
  
  // Check if rsr fired.
  outb(NE_PAGE0, NE_CMD);
  u32 boundary = inb(EN0_BOUNDARY);
  
  if (boundary != current)
  {
    ret = CopyPktFromCard(pkt, max_len);
    g_RX_packets++;
  }
  
  return ret;  
}


// queue packet for transmission
void Ne2k::Transmit(u8* pkt, size_t length)
{
  // Set TPSR, start of tx buffer memory to zero (this value is count of pages).
  outb((16*1024)/256, EN0_TPSR);
  
  CopyDataToCard(16*1024, pkt, length);
  
  // Set how many bytes to transmit
  SetTxCount(length);

  outb(0x04, NE_CMD);  // issue command to actually transmit a frame
  
  // Wait for transmission to complete.
  while (inb(NE_CMD) & 0x04);

  //printf("Done transmit\n");
  // update our stats.
  g_TX_packets++;
}




// Wait for the link to come up and init the buffers if it does
void Ne2k_Linkup::Main(const char* args)
{
  NetDevice* nic = new Ne2k;
  
  // Back to page 0
  outb(NE_PAGE0_STOP, NE_CMD);

  // That's for the card area, however we must also set the mac in the card ram as well, because that's what the
  // qemu emulation actually uses to determine if the packet's bound for this NIC.
  u8* mac = (u8*)ETHER_MAC;
  for (u32 i=0;i<6;i++)
  {
    CopyDataToCard(i*2, mac, 1);
    mac++;
  }

  // 8-bit access only, makes the maths simpler.
  outb(0, NE_BASE + 0x0e);

  // setup receive buffer location
  outb(RX_BUFFER_START, EN0_STARTPG);
  outb(RX_BUFFER_END, EN0_STOPPG);

  SetNetDevice(nic);
}






