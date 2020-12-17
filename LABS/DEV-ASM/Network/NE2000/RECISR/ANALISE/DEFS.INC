MAX_ADDR_LEN	equ	16		;maximum number of bytes in our address.
EADDR_LEN		equ	6		;Ethernet address length.
	
segmoffs	struc			; defines offs as 0, segm as 2
offs		dw	?
segm		dw	?
segmoffs	ends
