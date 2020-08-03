// Teste.cpp : Defines the entry point for the console application.
//

#include "stdafx.h"
#include <conio.h>
#include <io.h>

const __int32 PCI_ENABLE_BIT = 0x80000000; 
const __int32 PCI_CONFIG_ADDRESS = 0xCF8; 
const __int32 PCI_CONFIG_DATA = 0xCFC;

// func - 0-7 
// slot - 0-31 
// bus - 0-255 
__int32 r_pci_32(__int8 bus, __int8 device, __int8 func, __int8 pcireg) 
{ 
	// unsigned long flags; 
	// local_irq_save(flags) 
	_outpw(PCI_ENABLE_BIT | (bus << 16) | (device << 11) | (func << 8) | (pcireg << 2), PCI_CONFIG_ADDRESS); 
	__int32 ret = _inpd(PCI_CONFIG_DATA); 
	
	// local_irq_restore(flags); 
	return ret; 
}

int _tmain(int argc, _TCHAR* argv[])
{
	__int8 bus, device, func; 
	__int32 data;

	for (bus = 0; bus != 0xff; bus++) 
	{ 
		for (device = 0; device < 32; device++) 
		{ 
			for (func = 0; func < 8; func++) 
			{ 
				data = r_pci_32(bus, device, func, 0); 
				if(data != 0xffffffff) 
				{ 
					printf("bus %d, device %d, func %d: vendor=0x%08x\n", bus, device, func, data); 
				} 
			} 
		} 
	}
	_getch();
	return 0;
}

