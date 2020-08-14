#include <conio.h>
#include <dos.h>
#include <stdlib.h>		//malloc
#include "common.h"
#include "rtl8139.h"

typedef	struct _TX_DESCRIPTOR {
	unsigned char  *OriginalBufferAddress;	//only used to work around
						//dword alignment problem	
	unsigned char  *buffer;		//virtual address
	unsigned long	PhysicalAddress;//physical address
	unsigned int	PacketLength;
} TX_DESCRIPTOR, *PTX_DESCRIPTOR;

typedef struct _BufferList{
	unsigned char 		*Buffer;
	unsigned int		BufferLength;
	struct _BufferList      *Next;
} BufferList,*PBufferList;

typedef struct _PACKET {
	unsigned char	BufferCount;
	unsigned int	PacketLength;
	BufferList	Buffers;
} PACKET,*PPACKET;

#define	RX_BUFFER_SIZE		16*1024

//Transmit variables
#define TX_SW_BUFFER_NUM	4
TX_DESCRIPTOR TxDesc[TX_SW_BUFFER_NUM];
unsigned char TxHwSetupPtr;
unsigned char TxHwFinishPtr;
unsigned char TxHwFreeDesc;

unsigned char *Buffer;
unsigned char *RxBuffer,*RxBufferOriginal;
unsigned long RxBufferPhysicalAddress;
unsigned long PhysicalAddrBuffer;
unsigned int RxReadPtrOffset;

extern void printdw(unsigned long value);

/* Microsoft Visual C++ */
void (interrupt *inthandler)();

void resetnic(unsigned IOBase)
{
	outp(IOBase + CR, CR_RST);              //reset
	outp(IOBase + CR, CR_RE + CR_TE);       //enable Tx/Rx
	outpdw(IOBase + TCR, TCR_IFG0 | TCR_IFG1 | TCR_MXDMA2 | TCR_MXDMA1);
	outpdw(IOBase + RCR, RCR_RBLEN0 | RCR_MXDMA2 | RCR_MXDMA1 | RCR_AB | RCR_AM | RCR_APM);
	outpdw(IOBase + RBSTART, RxBufferPhysicalAddress);
	outp(IOBase + IMR, R39_INTERRUPT_MASK); //enable interrupt
}

void initsoftware()
{
	unsigned long Offset,Segment,Delta,i;
	unsigned char *tmpBuffer;
//Init Tx Variables
	TxHwSetupPtr = 0;
	TxHwFinishPtr    = 0;
	TxHwFreeDesc = TX_SW_BUFFER_NUM;
//initialize TX descriptor
	for(i=0;i<TX_SW_BUFFER_NUM;i++)
	{	//allocate memory
		Buffer=(unsigned char *)malloc( 1600 / sizeof(int) );
		TxDesc[i].OriginalBufferAddress = Buffer;
		Offset=FP_OFF(Buffer);
		//align to DWORD
		if( Offset & 0x3 )
		{
			Delta = 4 - (Offset & 0x3);
			Offset = Offset + Delta;
			Buffer = Buffer + Delta;
		}
		TxDesc[i].buffer = Buffer;
		Segment=FP_SEG(Buffer);
		PhysicalAddrBuffer = (Segment << 4) + Offset;
		TxDesc[i].PhysicalAddress = PhysicalAddrBuffer;
//		TxDesc[i].DescriptorStatus = TXDESC_INIT;
	}
//Init Rx Buffer
	RxBufferOriginal =
	tmpBuffer	 = (unsigned char *)malloc( RX_BUFFER_SIZE + 2000 );
	Offset=FP_OFF(tmpBuffer);
	//align to DWORD
	if( Offset & 0x3 )
	{
		Delta = 4 - (Offset & 0x3);
		Offset = Offset + Delta;
		tmpBuffer = tmpBuffer + Delta;
	}
	RxBuffer = tmpBuffer;
	Segment=FP_SEG(tmpBuffer);
	RxBufferPhysicalAddress = (Segment << 4) + Offset;
//Init Rx Variable
	RxReadPtrOffset = 0;
}

PPACKET BuildPacket()
{
	int i;
	PPACKET tmpPacket = (PPACKET) malloc(sizeof(PACKET));
	tmpPacket->BufferCount  = 1;
	tmpPacket->PacketLength = 64;
	tmpPacket->Buffers.Buffer = (unsigned char *) malloc(2000);
	tmpPacket->Buffers.Next   = NULL;
	tmpPacket->Buffers.BufferLength = 64;
	for(i=0;i<12;i++)
	{
		tmpPacket->Buffers.Buffer[i] = 0xff;
	}
	for(i=12;i<2000;i++)
	{
		tmpPacket->Buffers.Buffer[i] = i & 0xff;
	}
	return	tmpPacket;
}

unsigned char NextDesc(unsigned char CurrentDescriptor)
{
//    (CurrentDescriptor == TX_SW_BUFFER_NUM-1) ? 0 : (1 + CurrentDescriptor);
    if(CurrentDescriptor == TX_SW_BUFFER_NUM-1)
    {
		return  0;
    }
    else
    {
		return ( 1 + CurrentDescriptor);
    }
}

void IssueCMD(unsigned char descriptor)
{
	unsigned IOBase = configs[0].value;
	unsigned long offset = descriptor << 2;
	outpdw(IOBase + TSAD0 + offset, TxDesc[TxHwSetupPtr].PhysicalAddress);
	outpdw(IOBase + TSD0 + offset , TxDesc[TxHwSetupPtr].PacketLength);
}

unsigned int CopyFromPacketToBuffer(PPACKET pPacket, unsigned char *pBuffer)
{
	unsigned char	bufferCount;
	unsigned int    offset = 0;
	PBufferList	pBufList;
	for(pBufList=&(pPacket->Buffers) , bufferCount = 0;
		bufferCount < pPacket->BufferCount;
		bufferCount++)
	{
		memcpy(pBuffer+offset , pBufList->Buffer , pBufList->BufferLength);
		offset += pBufList->BufferLength;
		pBufList = pBufList->Next;
	}
	return offset;
}

int SendPacket(PPACKET pPacket)
{
    _disable();
    if(TxHwFreeDesc > 0 )
    {
		TxDesc[TxHwSetupPtr].PacketLength = CopyFromPacketToBuffer(pPacket, TxDesc[TxHwSetupPtr].buffer);
		IssueCMD(TxHwSetupPtr);
		TxHwSetupPtr = NextDesc(TxHwSetupPtr);
		TxHwFreeDesc--;
		_enable();
		putchar('1');
		return 1;//success
    }
    else
    {
		_enable();
		putchar('0');
		return 0;//out of resource
    }
}

void send()
{
	PPACKET	pTestPacket;
	int	i;

// Send Test
	pTestPacket = BuildPacket();
	//for(i=0;i<2000;i++)
	//{
		pTestPacket->PacketLength=pTestPacket->Buffers.BufferLength = 64 + (i%1430);
		SendPacket(pTestPacket);
	//	while(!SendPacket(pTestPacket))
	//	{
	//	};
//	//	delay(5);
	//}
	//return 1;
}