.386P

SEGS32 GROUP CODESEG32, DATASEG32

PUBLIC DEVICEIOADDR
PUBLIC PCICONFIG

;======================================================================================|
;	PCIFINDDEVICE
;		IN: PCIDEVICE (DWORD)
;		OUT: EAX = [PCICONFIG = BUS, DEVICE, FUNCTION ]
;			 EDX = DEVICE FOUND (PCICONFIG)
;
;		ERR: EDX = DEVICE NOT FOUND (PCICONFIG)
;======================================================================================|
PCIFINDDEVICE			PROTO C PCIDEVICE:DWORD
RTL8139					EQU 813910ECh					; REALTEK VENDOR_ID: 10EC - DEVICE_ID: 8139

;======================================================================================|
;	GETPCIDATA
;		IN: NOTHING
;		OUT: EAX = NETOWORK CARD BASE ADDRESS
;======================================================================================| 
GETPCIDATA 				PROTO C

;======================================================================================|
;	GETREGVALUES
;		IN: NOTHING
;		OUT: CONTENTLOADED = BUFFER (0FFh) TOTAL PCI REGISTERS
;======================================================================================|
GETREGVALUES			PROTO C

;---------------------------------------------------------------------------------------

SELDATADESC32			EQU 20h

ETH_ALEN               	EQU 6
ETH_HLEN               	EQU (2 * ETH_ALEN + 2)
ETH_ZLEN               	EQU 60 							; 60 + 4bytes auto payload for
														; mininmum 64bytes frame length
			
PCI_REG_COMMAND        	EQU 04h 						; command register
PCI_BIT_PIO            	EQU 0 							; bit0: io space control
PCI_BIT_MMIO           	EQU 1 							; bit1: memory space control
PCI_BIT_MASTER         	EQU 2 							; bit2: device acts as a PCI master
			
RTL8139_REG_MAR0       	EQU 08h 						; multicast filter register 0
RTL8139_REG_MAR4       	EQU 0ch 						; multicast filter register 4
RTL8139_REG_TSD0       	EQU 10h 						; transmit status of descriptor
RTL8139_REG_TSAD0      	EQU 20h 						; transmit start address of descriptor
RTL8139_REG_RBSTART    	EQU 30h 						; RxBuffer start address
RTL8139_REG_COMMAND    	EQU 37h 						; command register
RTL8139_REG_CAPR       	EQU 38h 						; current address of packet read
RTL8139_REG_IMR        	EQU 3ch 						; interrupt mask register
RTL8139_REG_ISR        	EQU 3eh 						; interrupt status register
RTL8139_REG_TXCONFIG   	EQU 40h 						; transmit configuration register
RTL8139_REG_TXCONFIG_0 	EQU 40h 						; transmit configuration register 0
RTL8139_REG_TXCONFIG_1 	EQU 41h 						; transmit configuration register 1
RTL8139_REG_TXCONFIG_2 	EQU 42h 						; transmit configuration register 2
RTL8139_REG_TXCONFIG_3 	EQU 43h 						; transmit configuration register 3
RTL8139_REG_RXCONFIG   	EQU 44h 						; receive configuration register 0
RTL8139_REG_RXCONFIG_0 	EQU 44h 						; receive configuration register 0
RTL8139_REG_RXCONFIG_1 	EQU 45h 						; receive configuration register 1
RTL8139_REG_RXCONFIG_2 	EQU 46h 						; receive configuration register 2
RTL8139_REG_RXCONFIG_3 	EQU 47h 						; receive configuration register 3
RTL8139_REG_MPC        	EQU 4ch 						; missed packet counter
RTL8139_REG_9346CR     	EQU 50h 						; serial eeprom 93C46 command register
RTL8139_REG_CONFIG1    	EQU 52h 						; configuration register 1
RTL8139_REG_CONFIG4    	EQU 5ah 						; configuration register 4
RTL8139_REG_HLTCLK     	EQU 5bh 						; undocumented halt clock register
RTL8139_REG_BMCR       	EQU 62h 						; basic mode control register
RTL8139_REG_ANAR       	EQU 66h 						; auto negotiation advertisement register

; 5.1 packet header
											
RTL8139_BIT_RUNT       	EQU 4 							; total packet length < 64 bytes
RTL8139_BIT_LONG       	EQU 3 							; total packet length > 4k
RTL8139_BIT_CRC        	EQU 2 							; crc error occured
RTL8139_BIT_FAE        	EQU 1 							; frame alignment error occured
RTL8139_BIT_ROK        	EQU 0 							; received packet is ok
				
; 5.4 command register				
															
RTL8139_BIT_RST        	EQU 4 							; reset bit
RTL8139_BIT_RE         	EQU 3 							; receiver enabled
RTL8139_BIT_TE         	EQU 2 							; transmitter enabled
RTL8139_BIT_BUFE       	EQU 0 							; rx buffer is empty, no packet stored
			
; 5.6 interrupt status register			
														
RTL8139_BIT_ISR_TOK    	EQU 2 							; transmit ok
RTL8139_BIT_ISR_RER    	EQU 1 							; receive error interrupt
RTL8139_BIT_ISR_ROK    	EQU 0 							; receive ok
																			; 5.7 transmit configyration register
RTL8139_BIT_TX_MXDMA   	EQU 8 							; Max DMA burst size per Tx DMA burst
RTL8139_BIT_TXRR       	EQU 4 							; Tx Retry count 16+(TXRR*16)
			
; 5.8 receive configuration register			
			
RTL8139_BIT_RXFTH      	EQU 13 							; Rx fifo threshold
RTL8139_BIT_RBLEN      	EQU 11 							; Ring buffer length indicator
RTL8139_BIT_RX_MXDMA   	EQU 8 							; Max DMA burst size per Rx DMA burst
RTL8139_BIT_NOWRAP     	EQU 7 							; transfered data wrapping
RTL8139_BIT_9356SEL    	EQU 6 							; eeprom selector 9346/9356
RTL8139_BIT_AER        	EQU 5 							; accept error packets
RTL8139_BIT_AR         	EQU 4 							; accept runt packets
RTL8139_BIT_AB         	EQU 3 							; accept broadcast packets
RTL8139_BIT_AM         	EQU 2 							; accept multicast packets
RTL8139_BIT_APM        	EQU 1 							; accept physical match packets
RTL8139_BIT_AAP        	EQU 0 							; accept all packets

; 5.9 93C46/93C56 command register

RTL8139_BIT_93C46_EEM1 	EQU 7 							; RTL8139 eeprom operating mode1
RTL8139_BIT_93C46_EEM0 	EQU 6 							; RTL8139 eeprom operating mode0
RTL8139_BIT_93C46_EECS 	EQU 3 							; chip select
RTL8139_BIT_93C46_EESK 	EQU 2 							; serial data clock
RTL8139_BIT_93C46_EEDI 	EQU 1 							; serial data input
RTL8139_BIT_93C46_EEDO 	EQU 0 							; serial data output
			
; 5.11 configuration register 1			
			
RTL8139_BIT_LWACT      	EQU 4 							; see RTL8139_REG_CONFIG1
RTL8139_BIT_SLEEP      	EQU 1 							; sleep bit at older chips
RTL8139_BIT_PWRDWN     	EQU 0 							; power down bit at older chips
RTL8139_BIT_PMEn       	EQU 0 							; power management enabled
			
; 5.14 configuration register 4			
			
RTL8139_BIT_LWPTN      	EQU 2 							; see RTL8139_REG_CONFIG4
			
; 6.2 transmit status register			
			
RTL8139_BIT_ERTXTH     	EQU 16 							; early TX threshold
RTL8139_BIT_TOK        	EQU 15 							; transmit ok
RTL8139_BIT_OWN        	EQU 13 							; tx DMA operation is completed
			
; 6.18 basic mode control register			
			
RTL8139_BIT_ANE        	EQU 12 							; auto negotiation enable

; 6.20 auto negotiation advertisement register

RTL8139_BIT_TXFD       	EQU 8 							; 100base-T full duplex
RTL8139_BIT_TX         	EQU 7 							; 100base-T
RTL8139_BIT_10FD       	EQU 6 							; 10base-T full duplex
RTL8139_BIT_10         	EQU 5 							; 10base-T
RTL8139_BIT_SELECTOR   	EQU 0 							; binary encoded selector CSMA/CD=00001

; RX/TX buffer size

RTL8139_RBLEN          	EQU 0 							; 0==8K 1==16k 2==32k 3==64k
RTL8139_RX_BUFFER_SIZE 	EQU (8192 shl RTL8139_RBLEN)
MAX_ETH_FRAME_SIZE     	EQU 1516 						; exactly 1514 wthout CRC
RTL8139_NUM_TX_DESC    	EQU 4
RTL8139_TX_BUFFER_SIZE 	EQU (MAX_ETH_FRAME_SIZE * RTL8139_NUM_TX_DESC)
RTL8139_TXRR           	EQU 8 							; total retries = 16+(TXRR*16)
RTL8139_TX_MXDMA       	EQU 6 							; 0==16 1==32 2==64 3==128
															; 4==256 5==512 6==1024 7==2048
RTL8139_ERTXTH         	EQU 8 							; in unit of 32 bytes e.g:(8*32)=256
RTL8139_RX_MXDMA       	EQU 7 							; 0==16 1==32 2==64 3==128
															; 4==256 5==512 6==1024 7==unlimited
RTL8139_RXFTH          	EQU 7 							; 0==16 1==32 2==64 3==128
															; 4==256 5==512 6==1024 7==no threshold
												
RTL8139_RX_PRECON      	EQU   ((RTL8139_RBLEN shl RTL8139_BIT_RBLEN) \
							or (RTL8139_RX_MXDMA shl RTL8139_BIT_RX_MXDMA) \
							or (1 shl RTL8139_BIT_NOWRAP) \
							or (RTL8139_RXFTH shl RTL8139_BIT_RXFTH)) 
							
RTL8139_RX_CONFIG      	EQU  (RTL8139_RX_PRECON \
							or (1 shl RTL8139_BIT_AB) or (1 shl RTL8139_BIT_APM) \
							or (1 shl RTL8139_BIT_AER) or (1 shl RTL8139_BIT_AR) \
							or (1 shl RTL8139_BIT_AM))
							
DATASEG32 SEGMENT USE32

	DEVICEIOADDR	DD ?
	PCICONFIG		DD ?

DATASEG32 ENDS

CODESEG32 SEGMENT USE32
	ASSUME CS:SEGS32, DS:SEGS32
	
	;======================================================================================|
	;	ETHPOOL
	;		IN: NOTHING
	;		OUT: EAX 		   	= BITS RTL8139_REG_COMMAND
	;			 DEVICEIOADDR  	= IO BASE ADDRESS
	;			 CONTENTLOADED 	= BUFFER (3Fh DWORD) TO PCI DEVICE REGISTERS
	;			 EDX 			= DEVICE FOUND (PCICONFIG)
	;
	;		ERR: EDX 			= DEVICE NOT FOUND (PCICONFIG)
	;======================================================================================|

	ETHPOOL PROC C 
	
		PUSH	DS
		MOV		AX, SELDATADESC32
		MOV		DS, AX
		INVOKE	PCIFINDDEVICE, RTL8139
		MOV		DWORD PTR PCICONFIG, EDX
		JC		@f
		INVOKE  GETREGVALUES
		INVOKE	GETPCIDATA
		MOV		DWORD PTR DEVICEIOADDR, EAX
		MOV		EDX, EAX
		XOR		EAX, EAX
		ADD		EDX, RTL8139_REG_COMMAND
		IN		AL, DX
		POP		DS
		RET
		
	@@: POP		DS
		RET
		
	ETHPOOL ENDP
	
CODESEG32 ENDS

END	