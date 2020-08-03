HEADERCOLOR 	EQU 0Fh
VIDEOCOLOR		EQU 07h
OPTIONSCOLOR	EQU 0Eh 
;========================================|
;                                        |
;	0      0000      black               |
;	1      0001      blue                |
;	2      0010      green               |
;	3      0011      cyan                |
;	4      0100      red                 |
;	5      0101      magenta             |
;	6      0110      brown               |
;	7      0111      light gray          |
;	8      1000      dark gray           |
;	9      1001      light blue          |
;	A      1010      light green         |
;	B      1011      light cyan          |
;	C      1100      light red           |
;	D      1101      light magenta       |
;	E      1110      yellow              |
;	F      1111      white               |
;                                        |
;========================================|

NEWLINE		EQU 0A0h
STARTBUFFER EQU 140h
TOTALFLAGS	EQU 0Ch

REG16		EQU 02h
BIT16		EQU 10h

REG32		EQU 04h	
BIT32		EQU 20h
						
SPACE		EQU 20h

GENERALREGS STRUCT
	RAX	DD	?
	RBX	DD 	?
	RCX	DD 	?
	RDX	DD 	?
	RSI	DD	?
	RDI	DD	?
	RBP	DD 	?
	RSP	DD	?
GENERALREGS ENDS

SEGREGISTERS STRUCT
	RCS		DD	?
	RDS		DD	?
	RES		DD	?
	RSS		DD	?
SEGREGISTERS ENDS

FLAGREGISTERS STRUCT
	RCF		DD	?
	RPF		DD	?
	RAF		DD	?
	RZF		DD	?
	RSF		DD	?
	RTF		DD	?
	RIF		DD	?
	RDF		DD	?
	ROF		DD	?
FLAGREGISTERS ENDS