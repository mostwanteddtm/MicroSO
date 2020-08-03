
		.286p
		.model tiny

; ===========================================================================

; Segment type:	Pure code
seg000		segment PAGE public 'CODE'
		assume cs:seg000
		org 100h
		assume es:nothing, ss:nothing, ds:seg000

; =============== S U B	R O U T	I N E =======================================

; Attributes: thunk

		public start
start		proc near
		jmp	start_0
start		endp

; ---------------------------------------------------------------------------
byte_10103	db 1			; DATA XREF: sub_11023+7r sub_11023+Er ...
byte_10104	db 0			; DATA XREF: sub_10915:loc_10ACEw
					; sub_10915:loc_10B69w	...
word_10105	dw 0			; DATA XREF: sub_10915+3r
					; sub_10915+7Ar ...
byte_10107	db 0			; DATA XREF: sub_10915+10r
					; sub_10C2E+10r ...
byte_10108	db 0			; DATA XREF: sub_10915+2CAr
					; sub_11400+32r ...
byte_10109	db 0			; DATA XREF: sub_10915+F1r
					; sub_10915+122r ...
byte_1010A	db 0			; DATA XREF: sub_10915+EDr
					; sub_10915+11Er ...
word_1010B	dw 0			; DATA XREF: sub_11400+2Er
					; sub_11400+48r ...
word_1010D	dw 0			; DATA XREF: sub_10915+89r
					; sub_11164+7r	...
byte_1010F	db 0			; DATA XREF: sub_10F56+2Dr
					; sub_11023+2w	...
		db 14h dup(0)
word_10124	dw 0			; DATA XREF: sub_10915:loc_10A8Fw
					; sub_10915+19Dr ...
word_10126	dw 0			; DATA XREF: sub_10915+188w
					; sub_10915+1F6r
word_10128	dw 0			; DATA XREF: sub_10915:loc_10AECw
					; sub_10915+23Cr ...
word_1012A	dw 0			; DATA XREF: sub_10915:loc_10B1Aw
					; sub_10915:loc_10B39r	...
word_1012C	dw 0			; DATA XREF: sub_10C2E+96r
					; sub_10C2E:loc_10CDAr	...
word_1012E	dw 0			; DATA XREF: sub_10915+ACr
					; sub_10915+283r ...
byte_10130	db 0			; DATA XREF: sub_10C2E+3Fr
					; sub_10C2E:loc_10C81r	...
byte_10131	db 0			; DATA XREF: sub_10915+2E2w
					; sub_10D34+86w ...
byte_10132	db 0			; DATA XREF: sub_10F56:loc_10F95r
					; sub_10F56+46w
		db 2 dup(0), 0Fh, 7, 4Eh, 6Fh, 20h, 66h, 69h, 78h, 65h
		db 64h,	20h, 64h, 69h, 73h, 6Bh, 73h, 20h, 70h,	72h, 65h
		db 73h,	65h, 6Eh, 74h, 2Eh, 2 dup(0FFh), 0, 16h, 0Fh, 7
		db 45h,	2 dup(72h), 6Fh, 72h, 20h, 72h,	65h, 61h, 64h
		db 69h,	6Eh, 67h, 20h, 66h, 69h, 78h, 65h, 64h,	20h, 64h
		db 69h,	73h, 6Bh, 2Eh, 2 dup(0FFh), 0, 16h, 0Fh, 7, 45h
		db 2 dup(72h), 6Fh, 72h, 20h, 77h, 72h,	69h, 74h, 69h
		db 6Eh,	67h, 20h, 66h, 69h, 78h, 65h, 64h, 20h,	64h, 69h
		db 73h,	6Bh, 2Eh, 2 dup(0FFh), 2 dup(0), 0Fh, 7, 49h, 6Eh
		db 63h,	6Fh, 2 dup(72h), 65h, 63h, 74h,	20h, 44h, 4Fh
		db 53h,	20h, 76h, 65h, 72h, 73h, 69h, 6Fh, 6Eh,	2Eh, 0Dh
		db 2 dup(0FFh),	0, 12h,	0Fh, 7,	4Eh, 6Fh, 20h, 44h, 4Fh
		db 53h,	20h, 70h, 61h, 72h, 74h, 69h, 74h, 69h,	6Fh, 6Eh
		db 20h,	74h, 6Fh, 20h, 64h, 65h, 6Ch, 65h, 74h,	65h, 2Eh
		db 2 dup(0FFh),	0, 12h,	0Fh, 7,	46h, 69h, 78h, 65h, 64h
		db 20h,	64h, 69h, 73h, 6Bh, 20h, 61h, 6Ch, 72h,	65h, 61h
		db 64h,	79h, 20h, 68h, 61h, 73h, 20h, 61h, 20h,	44h, 4Fh
		db 53h,	20h, 70h, 61h, 72h, 74h, 69h, 74h, 69h,	6Fh, 6Eh
		db 2Eh,	2 dup(0FFh), 0,	12h, 0Fh, 7, 4Eh, 6Fh, 20h, 73h
		db 70h,	61h, 63h, 65h, 20h, 74h, 6Fh, 20h, 63h,	72h, 65h
		db 61h,	74h, 65h, 20h, 61h, 20h, 44h, 4Fh, 53h,	20h, 70h
		db 61h,	72h, 74h, 69h, 74h, 69h, 6Fh, 6Eh, 2Eh,	2 dup(0FFh)
		db 0, 15h, 0Fh,	7, 4Eh,	6Fh, 20h, 73h, 70h, 61h, 63h, 65h
		db 20h,	66h, 6Fh, 72h, 20h, 61h, 6 dup(20h), 63h, 79h
		db 6Ch,	69h, 6Eh, 64h, 65h, 72h, 20h, 70h, 61h,	72h, 74h
		db 69h,	74h, 69h, 6Fh, 6Eh, 20h, 2 dup(0FFh), 26h, 15h
		db 0Fh,	2Eh, 2 dup(0FFh), 0, 16h, 0Fh, 61h, 74h, 20h, 63h
		db 79h,	6Ch, 69h, 6Eh, 64h, 65h, 72h, 5	dup(20h), 2Eh
		db 2 dup(0FFh),	0, 12h,	0Fh, 7,	50h, 61h, 72h, 74h, 69h
		db 74h,	69h, 6Fh, 6Eh, 20h, 31h, 20h, 69h, 73h,	20h, 61h
		db 6Ch,	72h, 65h, 61h, 64h, 79h, 20h, 61h, 63h,	74h, 69h
		db 76h,	65h, 2 dup(0FFh), 0, 12h, 0Fh, 7, 4Eh, 6Fh, 20h
		db 70h,	61h, 72h, 74h, 69h, 74h, 69h, 6Fh, 6Eh,	73h, 20h
		db 74h,	6Fh, 20h, 6Dh, 61h, 6Bh, 65h, 20h, 61h,	63h, 74h
		db 69h,	76h, 65h, 2Eh, 2 dup(0FFh), 0, 12h, 0Fh, 44h, 4Fh
		db 53h,	20h, 70h, 61h, 72h, 74h, 69h, 74h, 69h,	6Fh, 6Eh
		db 20h,	64h, 65h, 6Ch, 65h, 74h, 65h, 64h, 2 dup(0FFh)
		db 0, 12h, 0Fh,	50h, 61h, 72h, 74h, 69h, 74h, 69h, 6Fh
		db 6Eh,	20h
byte_102D8	db 0			; DATA XREF: sub_10C2E+92w
		db 20h,	6Dh, 61h, 64h, 65h, 20h, 61h, 63h, 74h,	69h, 76h
		db 65h,	2 dup(0FFh), 0,	15h, 0Fh, 44h, 4Fh, 53h, 20h, 70h
		db 61h,	72h, 74h, 69h, 74h, 69h, 6Fh, 6Eh, 20h,	63h, 72h
		db 65h,	61h, 74h, 65h, 64h, 2 dup(0FFh), 2 dup(0), 7, 49h
		db 42h,	4Dh, 20h, 50h, 65h, 72h, 73h, 6Fh, 6Eh,	61h, 6Ch
		db 20h,	43h, 6Fh, 6Dh, 70h, 75h, 74h, 65h, 72h,	0Dh, 46h
		db 69h,	78h, 65h, 64h, 20h, 44h, 69h, 73h, 6Bh,	20h, 53h
		db 65h,	74h, 75h, 70h, 20h, 50h, 72h, 6Fh, 67h,	72h, 61h
		db 6Dh,	20h, 56h, 65h, 72h, 73h, 69h, 6Fh, 6Eh,	20h, 32h
		db 2Eh,	2 dup(30h), 0Dh, 28h, 43h, 29h,	43h, 6Fh, 70h
		db 79h,	72h, 69h, 67h, 68h, 74h, 20h, 49h, 42h,	4Dh, 20h
		db 43h,	6Fh, 72h, 70h, 2Eh, 20h, 31h, 39h, 38h,	33h, 2 dup(0FFh)
		db 0, 4, 0Fh, 46h, 44h,	49h, 53h, 4Bh, 20h, 4Fh, 70h, 74h
		db 69h,	6Fh, 6Eh, 73h, 0FFh, 7,	4 dup(0Dh), 43h, 68h, 2	dup(6Fh)
		db 73h,	65h, 20h, 6Fh, 6Eh, 65h, 20h, 6Fh, 66h,	20h, 74h
		db 68h,	65h, 20h, 66h, 6Fh, 2 dup(6Ch),	6Fh, 77h, 69h
		db 6Eh,	67h, 3Ah, 0FFh,	0Fh, 2 dup(0Dh), 4 dup(20h), 31h
		db 0FFh, 7, 2Eh, 2 dup(20h), 43h, 72h, 65h, 61h, 74h, 65h
		db 20h,	44h, 4Fh, 53h, 20h, 50h, 61h, 72h, 74h,	69h, 74h
		db 69h,	6Fh, 6Eh, 0Dh, 0FFh, 0Fh, 4 dup(20h), 32h, 0FFh
		db 7, 2Eh, 2 dup(20h), 43h, 68h, 61h, 6Eh, 67h,	65h, 20h
		db 41h,	63h, 74h, 69h, 76h, 65h, 20h, 50h, 61h,	72h, 74h
		db 69h,	74h, 69h, 6Fh, 6Eh, 0Dh, 0FFh, 0Fh, 4 dup(20h)
		db 33h,	0FFh, 7, 2Eh, 2	dup(20h), 44h, 65h, 6Ch, 65h, 74h
		db 65h,	20h, 44h, 4Fh, 53h, 20h, 50h, 61h, 72h,	74h, 69h
		db 74h,	69h, 6Fh, 6Eh, 0Dh, 0FFh, 0Fh, 4 dup(20h), 34h
		db 0FFh, 7, 2Eh, 2 dup(20h), 44h, 69h, 73h, 70h, 6Ch, 61h
		db 79h,	20h, 50h, 61h, 72h, 74h, 69h, 74h, 69h,	6Fh, 6Eh
		db 20h,	44h, 61h, 74h, 61h, 3 dup(0Dh),	45h, 6Eh, 74h
		db 65h,	72h, 20h, 63h, 68h, 6Fh, 69h, 63h, 65h,	3Ah, 20h
		db 0FFh, 0Fh, 5Bh, 0, 5Dh, 2 dup(0FFh),	0, 18h,	7, 50h
		db 72h,	65h, 2 dup(73h), 20h, 0FFh, 0Fh, 45h, 73h, 63h
		db 0FFh, 7, 20h, 74h, 6Fh, 20h,	72h, 65h, 74h, 75h, 72h
		db 6Eh,	20h, 74h, 6Fh, 20h, 44h, 4Fh, 53h, 2 dup(0FFh)
		db 0, 6, 7, 43h, 75h, 2	dup(72h), 65h, 6Eh, 74h, 20h, 46h
		db 69h,	78h, 65h, 64h, 20h, 44h, 69h, 73h, 6Bh,	20h, 44h
		db 72h,	69h, 76h, 65h, 3Ah, 20h, 0FFh, 0Fh
byte_10473	db 31h			; DATA XREF: sub_11023+33w
		db 2 dup(0FFh),	0, 0Eh,	0Fh, 4 dup(20h), 35h, 0FFh, 7
		db 2Eh,	2 dup(20h), 53h, 65h, 6Ch, 65h,	63h, 74h, 20h
		db 4Eh,	65h, 78h, 74h, 20h, 46h, 69h, 78h, 65h,	64h, 20h
		db 44h,	69h, 73h, 6Bh, 20h, 44h, 72h, 69h, 76h,	65h, 2 dup(0Dh)
		db 2 dup(0FFh),	0, 4, 0Fh, 43h,	72h, 65h, 61h, 74h, 65h
		db 20h,	44h, 4Fh, 53h, 20h, 50h, 61h, 72h, 74h,	69h, 74h
		db 69h,	6Fh, 6Eh, 2 dup(0FFh), 0, 4, 0Fh, 43h, 68h, 61h
		db 6Eh,	67h, 65h, 20h, 41h, 63h, 74h, 69h, 76h,	65h, 20h
		db 50h,	61h, 72h, 74h, 69h, 74h, 69h, 6Fh, 6Eh,	2 dup(0FFh)
		db 0, 4, 0Fh, 44h, 65h,	6Ch, 65h, 74h, 65h, 20h, 44h, 4Fh
		db 53h,	20h, 50h, 61h, 72h, 74h, 69h, 74h, 69h,	6Fh, 6Eh
		db 2 dup(0FFh),	0, 4, 0Fh, 44h,	69h, 73h, 70h, 6Ch, 61h
		db 79h,	20h, 50h, 61h, 72h, 74h, 69h, 74h, 69h,	6Fh, 6Eh
		db 20h,	49h, 6Eh, 66h, 6Fh, 72h, 6Dh, 61h, 74h,	69h, 6Fh
		db 6Eh,	2 dup(0FFh), 0,	18h, 7,	50h, 72h, 65h, 2 dup(73h)
		db 20h,	0FFh, 0Fh, 45h,	73h, 63h, 20h, 0FFh, 7,	74h, 6Fh
		db 20h,	72h, 65h, 74h, 75h, 72h, 6Eh, 20h, 74h,	6Fh, 20h
		db 46h,	44h, 49h, 53h, 4Bh, 20h, 4Fh, 70h, 74h,	69h, 6Fh
		db 6Eh,	73h, 2 dup(0FFh), 0, 18h, 7, 50h, 72h, 65h, 2 dup(73h)
		db 20h,	0FFh, 0Fh, 45h,	73h, 63h, 20h, 0FFh
aToReturnToFdis	db 7,'to return to FDISK Options ',0
		db 2 dup(0FFh),	0, 8, 7, 44h, 6Fh, 20h,	79h, 6Fh, 75h
		db 20h,	77h, 69h, 73h, 68h, 20h, 74h, 6Fh, 20h,	75h, 73h
		db 65h,	20h, 74h, 68h, 65h, 20h, 65h, 6Eh, 74h,	69h, 72h
		db 65h,	20h, 66h, 69h, 78h, 65h, 64h, 0Dh, 64h,	69h, 73h
		db 6Bh,	20h, 66h, 6Fh, 72h, 20h, 44h, 4Fh, 53h,	20h, 28h
		db 59h,	2Fh, 4Eh, 29h, 10h dup(2Eh), 3Fh, 20h, 0FFh, 0Fh
		db 5Bh,	0, 5Dh,	2 dup(0FFh), 0,	0Dh, 0Fh, 53h, 79h, 73h
		db 74h,	65h, 6Dh, 20h, 77h, 69h, 2 dup(6Ch), 20h, 6Eh
		db 6Fh,	77h, 20h, 72h, 65h, 62h, 2 dup(6Fh), 74h, 2 dup(0Dh)
		db 0FFh
aInsertDosDiske	db 7,'Insert DOS diskette in drive A:',0Dh,'Press any key when ready . . '
		db '.',0
		db 2 dup(0FFh),	0, 8, 7, 50h, 61h, 72h,	74h, 69h, 74h
		db 69h,	6Fh, 6Eh, 20h, 53h, 74h, 61h, 74h, 75h,	73h, 3 dup(20h)
		db 54h,	79h, 70h, 65h, 2 dup(20h), 53h,	74h, 61h, 72h
		db 74h,	2 dup(20h), 45h, 6Eh, 64h, 20h,	53h, 69h, 7Ah
		db 65h,	2 dup(0FFh), 0,	8, 7, 4Eh, 6Fh,	20h, 70h, 61h
		db 72h,	74h, 69h, 74h, 69h, 6Fh, 6Eh, 73h, 20h,	64h, 65h
		db 66h,	69h, 6Eh, 65h, 64h, 2Eh, 2 dup(0FFh), 0
byte_10668	db 0			; DATA XREF: sub_10E39+14w
					; sub_10E39+C2w
		db 7, 4	dup(20h)
byte_1066E	db 0			; DATA XREF: sub_10E39:loc_10E82w
		db 8 dup(20h)
byte_10677	db 0			; DATA XREF: sub_10E39:loc_10EA8w
					; sub_10E39+79w
		db 3 dup(20h), 7 dup(0), 2 dup(20h), 4 dup(0), 20h, 4 dup(0)
		db 20h,	4 dup(0), 2 dup(0FFh), 2 dup(20h), 44h,	4Fh, 53h
		db 2 dup(20h), 6Eh, 6Fh, 6Eh, 2Dh, 44h,	4Fh, 53h, 0, 0Eh
aTotalDiskSpace	db 7,'Total disk space is ',0
		db 3 dup(0), 20h, 63h, 79h, 6Ch, 69h, 6Eh, 64h,	65h, 72h
		db 73h,	2Eh, 2 dup(0FFh), 0, 0Fh
aMaximumAvailab	db 7,'Maximum available space is ',0
		align 4
aCylindersAtCyl	db 0Dh,'cylinders at cylinder ',0
		db 3 dup(0), 2Eh, 2 dup(0FFh), 0, 0Fh, 7, 54h, 68h, 65h
		db 20h,	63h, 75h, 2 dup(72h), 65h, 6Eh,	74h, 20h, 61h
		db 63h,	74h, 69h, 76h, 65h, 20h, 70h, 61h, 72h,	74h, 69h
		db 74h,	69h, 6Fh, 6Eh, 20h, 69h, 73h, 20h
byte_1072D	db 0			; DATA XREF: sub_10C2E:loc_10C77r
					; sub_10E39+Fw	...
		db 2Eh,	2 dup(0FFh), 0
byte_10732	db 12h			; DATA XREF: sub_10915+1DBr
		db 7, 45h, 6Eh,	74h, 65h, 72h, 20h, 70h, 61h, 72h, 74h
		db 69h,	74h, 69h, 6Fh, 6Eh, 20h, 73h, 69h, 7Ah,	65h, 0Ch dup(2Eh)
		db 3Ah,	20h, 0FFh, 0Fh,	5Bh, 0FFh, 7, 3	dup(20h), 0, 0FFh
		db 0Fh,	5Dh, 2 dup(0FFh), 0, 12h, 7, 45h, 6Eh, 74h, 65h
		db 72h,	20h, 74h, 68h, 65h, 20h, 6Eh, 75h, 6Dh,	62h, 65h
		db 72h,	20h, 6Fh, 66h, 20h, 74h, 68h, 65h, 20h,	70h, 61h
		db 72h,	74h, 69h, 74h, 69h, 6Fh, 6Eh, 20h, 79h,	6Fh, 75h
		db 0Dh,	77h, 61h, 6Eh, 74h, 20h, 74h, 6Fh, 20h,	6Dh, 61h
		db 6Bh,	65h, 20h, 61h, 63h, 74h, 69h, 76h, 65h,	0Fh dup(2Eh)
		db 3Ah,	20h, 0FFh, 0Fh,	5Bh, 0FFh, 7, 0, 0FFh, 0Fh, 5Dh
		db 2 dup(0FFh),	0, 12h,	0Fh, 7,	57h, 61h, 72h, 6Eh, 69h
		db 6Eh,	67h, 21h, 20h, 44h, 61h, 74h, 61h, 20h,	69h, 6Eh
		db 20h,	74h, 68h, 65h, 20h, 44h, 4Fh, 53h, 20h,	70h, 61h
		db 72h,	74h, 69h, 74h, 69h, 6Fh, 6Eh, 0Dh, 63h,	6Fh, 75h
		db 6Ch,	64h, 20h, 62h, 65h, 20h, 6Ch, 6Fh, 73h,	74h, 2Eh
		db 2 dup(20h), 44h, 6Fh, 20h, 79h, 6Fh,	75h, 20h, 77h
		db 69h,	73h, 68h, 20h, 74h, 6Fh, 0Dh, 63h, 6Fh,	6Eh, 74h
		db 69h,	6Eh, 75h, 65h, 1Ah dup(2Eh), 3Fh, 20h, 0FFh, 0Fh
		db 5Bh,	0FFh, 7, 0, 0FFh, 0Fh, 5Dh, 2 dup(0FFh), 0
byte_10832	db 13h			; DATA XREF: sub_10915+209r
		db 7, 45h, 6Eh,	74h, 65h, 72h, 20h, 73h, 74h, 61h, 72h
		db 74h,	69h, 6Eh, 67h, 20h, 63h, 79h, 6Ch, 69h,	6Eh, 64h
		db 65h,	72h, 20h, 6Eh, 75h, 6Dh, 62h, 65h, 72h,	2 dup(2Eh)
		db 3Ah,	20h, 0FFh, 0Fh,	5Bh, 0FFh, 7, 3	dup(20h), 0, 0FFh
		db 0Fh,	5Dh, 2 dup(0FFh), 22h
byte_10865	db 0			; DATA XREF: sub_10915+1DEw
					; sub_10915+20Cw
; ---------------------------------------------------------------------------
		pop	es
		and	bh, bh
		jmp	word ptr [bx]
; ---------------------------------------------------------------------------
byte_1086B	db 0			; DATA XREF: sub_10915+1E1w
					; sub_10915+20Fw
		db 7, 20h, 2 dup(0FFh),	5, 31h,	32h, 33h, 34h, 0, 5, 31h
		db 32h,	33h, 34h, 35h, 4, 59h, 4Eh, 79h, 6Eh, 87h, 8, 0
		db 16h,	0Fh, 7,	0, 20h,	69h, 73h, 20h, 6Eh, 6Fh, 74h, 20h
		db 61h,	20h, 63h, 68h, 6Fh, 69h, 63h, 65h, 2Eh,	2 dup(20h)
		db 45h,	6Eh, 74h, 65h, 72h, 20h, 59h, 20h, 6Fh,	72h, 20h
		db 4Eh,	2Eh, 2 dup(0FFh), 4, 31h, 32h, 33h, 34h, 0B5h
		db 8, 0, 16h, 0Fh, 7, 0, 20h, 69h, 73h,	20h, 6Eh, 6Fh
		db 74h,	20h, 61h, 20h, 63h, 68h, 6Fh, 69h, 63h,	65h, 2Eh
		db 2 dup(20h), 45h, 6Eh, 74h, 65h, 72h,	20h, 61h, 20h
		db 63h,	68h, 6Fh, 69h, 63h, 65h, 2Eh, 2	dup(0FFh), 5, 31h
		db 32h,	33h, 34h, 35h, 0E6h, 8,	0, 16h,	0Fh, 7,	0, 20h
		db 69h,	73h, 20h, 6Eh, 6Fh, 74h, 20h, 61h, 20h,	63h, 68h
		db 6Fh,	69h, 63h, 65h, 2Eh, 2 dup(20h),	45h, 6Eh, 74h
		db 65h,	72h, 20h, 61h, 20h, 63h, 68h, 6Fh, 69h,	63h, 65h
		db 2Eh,	2 dup(0FFh)
off_1090B	dw offset sub_10915	; DATA XREF: sub_10F56+8Cr
		dw offset sub_10C2E
		dw offset sub_10D34
		dw offset sub_10DE9
		dw offset sub_11023

; =============== S U B	R O U T	I N E =======================================


sub_10915	proc near		; CODE XREF: sub_10F56+8Cp
					; DATA XREF: seg000:off_1090Bo
		mov	cx, 0
		mov	dx, word_10105
		call	sub_110E7
		mov	si, 4A3h
		call	sub_1136F
		cmp	byte_10107, 1
		jz	short loc_10932
		mov	si, 454h
		call	sub_1136F

loc_10932:				; CODE XREF: sub_10915+15j
		mov	si, 513h
		call	sub_1136F
		call	sub_11477
		cmp	ah, 0
		jz	short loc_10943
		jmp	loc_10C04
; ---------------------------------------------------------------------------

loc_10943:				; CODE XREF: sub_10915+29j
		cmp	word_119DF, 0AA55h
		jz	short loc_10951
		mov	cx, 100h
		call	sub_114D5

loc_10951:				; CODE XREF: sub_10915+34j
		mov	cx, 20h
		mov	di, 199Fh
		xor	ax, ax
		repe scasw
		cmp	cx, 0
		jz	short loc_10963
		jmp	short loc_109BE
; ---------------------------------------------------------------------------
		db 90h
; ---------------------------------------------------------------------------

loc_10963:				; CODE XREF: sub_10915+49j
		mov	si, 56Fh
		call	sub_1136F
		mov	di, 87Ch
		mov	dl, 59h
		call	sub_11164
		cmp	dl, 1Bh
		jnz	short loc_10979
		jmp	locret_10C2D
; ---------------------------------------------------------------------------

loc_10979:				; CODE XREF: sub_10915+5Fj
		cmp	dl, 59h
		jnz	short loc_109BE
		call	sub_114A3
		call	sub_114E2
		cmp	ah, 0
		jz	short loc_1098C
		jmp	loc_10C0C
; ---------------------------------------------------------------------------

loc_1098C:				; CODE XREF: sub_10915+72j
		mov	cx, 1700h
		mov	dx, word_10105
		call	sub_110E7

loc_10996::				; CODE XREF: start_0+2Ej
		mov	si, 5C1h
		call	sub_1136F
		mov	bh, 0
		mov	dx, word_1010D
		mov	ah, 2
		int	10h		; - VIDEO - SET	CURSOR POSITION
					; DH,DL	= row, column (0,0 = upper left)
					; BH = page number
		call	sub_11142
		mov	cx, 0
		mov	dx, word_10105
		call	sub_110E7
		mov	bh, 0
		mov	dx, 0
		mov	ah, 2
		int	10h		; - VIDEO - SET	CURSOR POSITION
					; DH,DL	= row, column (0,0 = upper left)
					; BH = page number
		int	19h		; DISK BOOT
					; causes reboot	of disk	system

loc_109BE:				; CODE XREF: sub_10915+4Bj
					; sub_10915+67j
		call	sub_10E39
		cmp	word_1012E, 0
		jnz	short loc_109CB
		jmp	loc_10C14
; ---------------------------------------------------------------------------

loc_109CB:				; CODE XREF: sub_10915+B1j
		mov	di, 199Fh
		mov	dh, 4

loc_109D0:				; CODE XREF: sub_10915+C9j
		cmp	byte ptr [di+4], 1
		jnz	short loc_109D9
		jmp	loc_10C1C
; ---------------------------------------------------------------------------

loc_109D9:				; CODE XREF: sub_10915+BFj
		add	di, 10h
		dec	dh
		jnz	short loc_109D0
		mov	cx, 0Ah
		xor	ax, ax
		mov	di, 110h
		push	di
		rep stosw
		pop	di
		mov	si, 199Fh
		mov	cl, 6
		mov	dh, 4

loc_109F3:				; CODE XREF: sub_10915+EBj
		mov	ax, [si+2]
		cmp	ax, 0
		jnz	short loc_10A11
		add	si, 10h
		dec	dh
		jnz	short loc_109F3
		mov	ah, byte_1010A
		mov	al, byte_10109
		shr	ah, cl
		inc	ax
		mov	[di+2],	ax
		jmp	short loc_10A6E
; ---------------------------------------------------------------------------

loc_10A11:				; CODE XREF: sub_10915+E4j
		xchg	ah, al
		shr	ah, cl
		mov	[di+2],	ax
		mov	dh, 4
		add	di, 4
		mov	si, 19CFh

loc_10A20:				; CODE XREF: sub_10915+118j
		mov	ax, [si+6]
		cmp	ax, 0
		jnz	short loc_10A2F
		sub	si, 10h
		dec	dh
		jnz	short loc_10A20

loc_10A2F:				; CODE XREF: sub_10915+111j
		xchg	ah, al
		shr	ah, cl
		mov	bh, byte_1010A
		mov	bl, byte_10109
		shr	bh, cl
		sub	bx, ax
		inc	ax
		mov	[di], ax
		mov	[di+2],	bx
		add	di, 4
		mov	si, 199Fh
		mov	dh, 3

loc_10A4D:				; CODE XREF: sub_10915+157j
		mov	ax, [si+6]
		xchg	ah, al
		shr	ah, cl
		mov	bx, [si+12h]
		xchg	bh, bl
		shr	bh, cl
		sub	bx, ax
		dec	bx
		inc	ax
		mov	[di], ax
		mov	[di+2],	bx
		add	di, 4
		add	si, 10h
		dec	dh
		jnz	short loc_10A4D

loc_10A6E:				; CODE XREF: sub_10915+FAj
		mov	cx, 5
		mov	di, 110h
		mov	si, di
		xor	ax, ax

loc_10A78:				; CODE XREF: sub_10915+170j
		cmp	[di+2],	ax
		jle	short loc_10A82
		mov	ax, [di+2]
		mov	si, di

loc_10A82:				; CODE XREF: sub_10915+166j
		add	di, 4
		loop	loc_10A78
		cmp	ax, 0
		jnz	short loc_10A8F
		jmp	loc_10C14
; ---------------------------------------------------------------------------

loc_10A8F:				; CODE XREF: sub_10915+175j
		mov	word_10124, ax
		mov	di, 6E8h
		mov	cx, 4
		call	sub_11120
		mov	ax, [si]
		mov	word_10126, ax
		mov	di, 703h
		call	sub_11120
		mov	si, 6CAh
		call	sub_1136F

loc_10AAC:				; CODE XREF: sub_10915+1D5j
					; sub_10915+27Dj
		mov	si, 731h
		call	sub_1136F
		mov	dx, word_10124
		mov	cx, 4
		call	sub_11275
		jnz	short loc_10AC1
		jmp	locret_10C2D
; ---------------------------------------------------------------------------

loc_10AC1:				; CODE XREF: sub_10915+1A7j
		cmp	dx, word_10124
		jg	short loc_10ACE
		cmp	dx, 0
		jz	short loc_10ACE
		jmp	short loc_10AEC
; ---------------------------------------------------------------------------

loc_10ACE:				; CODE XREF: sub_10915+1B0j
					; sub_10915+1B5j
		mov	byte_10104, 1
		mov	ax, dx
		mov	di, 235h
		mov	cx, 4
		call	sub_11120
		mov	si, 222h
		call	sub_1136F
		mov	si, 24Fh
		call	sub_1136F
		jmp	short loc_10AAC
; ---------------------------------------------------------------------------

loc_10AEC:				; CODE XREF: sub_10915+1B7j
		mov	word_10128, dx
		mov	al, byte_10732
		mov	byte_10865, al
		mov	byte_1086B, al
		mov	si, 864h
		call	sub_1136F
		mov	si, 86Ah
		call	sub_1136F
		mov	si, 831h
		call	sub_1136F
		mov	dx, word_10126
		mov	cx, 4
		call	sub_11275
		jnz	short loc_10B1A
		jmp	locret_10C2D
; ---------------------------------------------------------------------------

loc_10B1A:				; CODE XREF: sub_10915+200j
		mov	word_1012A, dx
		mov	al, byte_10832
		mov	byte_10865, al
		mov	byte_1086B, al
		mov	si, 864h
		call	sub_1136F
		mov	si, 86Ah
		call	sub_1136F
		mov	cx, 5
		mov	si, 110h

loc_10B39:				; CODE XREF: sub_10915+24Ej
		mov	dx, word_1012A
		cmp	word ptr [si+2], 0
		jz	short loc_10B60
		cmp	dx, [si]
		jl	short loc_10B60
		mov	ax, [si+2]
		add	ax, [si]
		dec	ax
		cmp	dx, ax
		jg	short loc_10B60
		add	dx, word_10128
		dec	dx
		cmp	dx, ax
		jle	short loc_10B95
		mov	dx, word_10128
		jmp	short loc_10B69
; ---------------------------------------------------------------------------

loc_10B60:				; CODE XREF: sub_10915+22Cj
					; sub_10915+230j ...
		add	si, 4
		loop	loc_10B39
		mov	dx, word_10128

loc_10B69:				; CODE XREF: sub_10915+249j
		mov	byte_10104, 1
		mov	ax, word_10128
		mov	di, 235h
		mov	cx, 4
		call	sub_11120
		mov	ax, word_1012A
		mov	di, 264h
		mov	cx, 4
		call	sub_11120
		mov	si, 222h
		call	sub_1136F
		mov	si, 255h
		call	sub_1136F
		jmp	loc_10AAC
; ---------------------------------------------------------------------------

loc_10B95:				; CODE XREF: sub_10915+243j
		mov	si, 199Fh
		mov	si, word_1012E
		mov	byte ptr [si+4], 1
		mov	al, byte ptr word_1012A
		mov	[si+3],	al
		mov	cx, 6
		mov	al, byte ptr word_1012A+1
		shl	al, cl
		mov	[si+2],	al
		cmp	word_1012A, 0
		jz	short loc_10BBE
		or	byte ptr [si+2], 1
		jmp	short loc_10BC2
; ---------------------------------------------------------------------------

loc_10BBE:				; CODE XREF: sub_10915+2A1j
		or	byte ptr [si+2], 2

loc_10BC2:				; CODE XREF: sub_10915+2A7j
		mov	byte ptr [si+1], 0
		mov	ax, word_1012A
		add	ax, word_10128
		dec	ax
		mov	[si+7],	al
		shl	ah, cl
		mov	dh, byte_1010A
		and	dh, 3Fh
		or	ah, dh
		mov	[si+6],	ah
		mov	ah, byte_10108
		mov	[si+5],	ah
		call	sub_11561
		call	sub_11400
		call	sub_10E39
		call	sub_114E2
		cmp	ah, 0
		jnz	short loc_10C0C
		mov	byte_10131, 1
		mov	si, 2E7h
		call	sub_1136F
		jmp	short loc_10C24
; ---------------------------------------------------------------------------

loc_10C04:				; CODE XREF: sub_10915+2Bj
		mov	si, 150h
		call	sub_1136F
		jmp	short loc_10C24
; ---------------------------------------------------------------------------

loc_10C0C:				; CODE XREF: sub_10915+74j
					; sub_10915+2E0j
		mov	si, 16Fh
		call	sub_1136F
		jmp	short loc_10C24
; ---------------------------------------------------------------------------

loc_10C14:				; CODE XREF: sub_10915+B3j
					; sub_10915+177j
		mov	si, 1F9h
		call	sub_1136F
		jmp	short loc_10C24
; ---------------------------------------------------------------------------

loc_10C1C:				; CODE XREF: sub_10915+C1j
		mov	si, 1CCh
		call	sub_1136F
		jmp	short $+2
; ---------------------------------------------------------------------------

loc_10C24:				; CODE XREF: sub_10915+2EDj
					; sub_10915+2F5j ...
		mov	si, 540h
		call	sub_1136F
		call	sub_113C8

locret_10C2D:				; CODE XREF: sub_10915+61j
					; sub_10915+1A9j ...
		retn
sub_10915	endp


; =============== S U B	R O U T	I N E =======================================


sub_10C2E	proc near		; CODE XREF: sub_10F56+8Cp
					; DATA XREF: seg000:090Do
		mov	cx, 0
		mov	dx, word_10105
		call	sub_110E7
		mov	si, 4BCh
		call	sub_1136F
		cmp	byte_10107, 1
		jz	short loc_10C4B
		mov	si, 454h
		call	sub_1136F

loc_10C4B:				; CODE XREF: sub_10C2E+15j
		mov	si, 513h
		call	sub_1136F
		call	sub_11477
		cmp	ah, 0
		jz	short loc_10C5C
		jmp	loc_10D0A
; ---------------------------------------------------------------------------

loc_10C5C:				; CODE XREF: sub_10C2E+29j
		cmp	word_119DF, 0AA55h
		jz	short loc_10C67
		call	sub_114D5

loc_10C67:				; CODE XREF: sub_10C2E+34j
		call	sub_11561
		call	sub_10E39
		cmp	byte_10130, 30h
		jnz	short loc_10C77
		jmp	loc_10D1A
; ---------------------------------------------------------------------------

loc_10C77:				; CODE XREF: sub_10C2E+44j
		cmp	byte_1072D, 30h
		jnz	short loc_10C81
		jmp	short loc_10C91
; ---------------------------------------------------------------------------
		db 90h
; ---------------------------------------------------------------------------

loc_10C81:				; CODE XREF: sub_10C2E+4Ej
		cmp	byte_10130, 31h
		jnz	short loc_10C8B
		jmp	loc_10D22
; ---------------------------------------------------------------------------

loc_10C8B:				; CODE XREF: sub_10C2E+58j
		mov	si, 70Ah
		call	sub_1136F

loc_10C91:				; CODE XREF: sub_10C2E+50j
		mov	cx, 4
		mov	di, 8ABh
		xor	al, al
		rep stosb
		mov	di, 8ABh
		mov	dl, 31h

loc_10CA0:				; CODE XREF: sub_10C2E+7Dj
		mov	[di], dl
		cmp	dl, byte_10130
		jz	short loc_10CAD
		inc	di
		inc	dl
		jmp	short loc_10CA0
; ---------------------------------------------------------------------------

loc_10CAD:				; CODE XREF: sub_10C2E+78j
		mov	si, 764h
		call	sub_1136F
		mov	di, 8AAh
		mov	dl, 20h
		call	sub_11164
		cmp	dl, 1Bh
		jz	short locret_10D33
		mov	byte_102D8, dl
		mov	di, word_1012C
		mov	al, 31h

loc_10CCA:				; CODE XREF: sub_10C2E+AAj
		mov	byte ptr [di], 0
		cmp	byte_10130, al
		jz	short loc_10CDA
		inc	al
		add	di, 10h
		jmp	short loc_10CCA
; ---------------------------------------------------------------------------

loc_10CDA:				; CODE XREF: sub_10C2E+A3j
		mov	di, word_1012C
		mov	bl, dl
		sub	bl, 31h
		xor	bh, bh
		mov	cl, 4
		shl	bx, cl
		add	di, bx
		mov	byte ptr [di], 80h
		call	sub_10E39
		call	sub_114E2
		cmp	ah, 0
		jnz	short loc_10D12
		mov	cx, 1200h
		mov	dx, 1727h
		call	sub_110E7
		mov	si, 2CBh
		call	sub_1136F
		jmp	short loc_10D2A
; ---------------------------------------------------------------------------

loc_10D0A:				; CODE XREF: sub_10C2E+2Bj
		mov	si, 150h
		call	sub_1136F
		jmp	short loc_10D2A
; ---------------------------------------------------------------------------

loc_10D12:				; CODE XREF: sub_10C2E+C9j
		mov	si, 16Fh
		call	sub_1136F
		jmp	short loc_10D2A
; ---------------------------------------------------------------------------

loc_10D1A:				; CODE XREF: sub_10C2E+46j
		mov	si, 28Eh
		call	sub_1136F
		jmp	short loc_10D2A
; ---------------------------------------------------------------------------

loc_10D22:				; CODE XREF: sub_10C2E+5Aj
		mov	si, 26Bh
		call	sub_1136F
		jmp	short $+2
; ---------------------------------------------------------------------------

loc_10D2A:				; CODE XREF: sub_10C2E+DAj
					; sub_10C2E+E2j ...
		mov	si, 540h
		call	sub_1136F
		call	sub_113C8

locret_10D33:				; CODE XREF: sub_10C2E+90j
		retn
sub_10C2E	endp


; =============== S U B	R O U T	I N E =======================================


sub_10D34	proc near		; CODE XREF: sub_10F56+8Cp
					; DATA XREF: seg000:090Fo
		mov	cx, 0
		mov	dx, word_10105
		call	sub_110E7
		mov	si, 4D8h
		call	sub_1136F
		cmp	byte_10107, 1
		jz	short loc_10D51
		mov	si, 454h
		call	sub_1136F

loc_10D51:				; CODE XREF: sub_10D34+15j
		mov	si, 513h
		call	sub_1136F
		call	sub_11477
		cmp	ah, 0
		jz	short loc_10D62
		jmp	short loc_10DC7
; ---------------------------------------------------------------------------
		align 2

loc_10D62:				; CODE XREF: sub_10D34+29j
		cmp	word_119DF, 0AA55h
		jz	short loc_10D6D
		call	sub_114D5

loc_10D6D:				; CODE XREF: sub_10D34+34j
		call	sub_11561
		call	sub_10E39
		mov	dh, 4
		mov	di, 199Fh

loc_10D78:				; CODE XREF: sub_10D34+4Fj
		cmp	byte ptr [di+4], 1
		jz	short loc_10D87
		add	di, 10h
		dec	dh
		jnz	short loc_10D78
		jmp	short loc_10DD7
; ---------------------------------------------------------------------------

loc_10D87:				; CODE XREF: sub_10D34+48j
		push	di
		mov	si, 7BCh
		call	sub_1136F
		mov	di, 87Ch
		mov	dl, 4Eh
		call	sub_11164
		pop	di
		cmp	dl, 59h
		jnz	short locret_10DE8
		xor	al, al
		mov	cx, 10h
		rep stosb
		call	sub_11561
		call	sub_10E39
		mov	cx, 1200h
		mov	dx, 1727h
		call	sub_110E7
		call	sub_114E2
		cmp	ah, 0
		jnz	short loc_10DCF
		mov	byte_10131, 1
		mov	si, 2B1h
		call	sub_1136F
		jmp	short loc_10DDF
; ---------------------------------------------------------------------------

loc_10DC7:				; CODE XREF: sub_10D34+2Bj
		mov	si, 150h
		call	sub_1136F
		jmp	short loc_10DDF
; ---------------------------------------------------------------------------

loc_10DCF:				; CODE XREF: sub_10D34+84j
		mov	si, 16Fh
		call	sub_1136F
		jmp	short loc_10DDF
; ---------------------------------------------------------------------------

loc_10DD7:				; CODE XREF: sub_10D34+51j
		mov	si, 1ABh
		call	sub_1136F
		jmp	short $+2
; ---------------------------------------------------------------------------

loc_10DDF:				; CODE XREF: sub_10D34+91j
					; sub_10D34+99j ...
		mov	si, 540h
		call	sub_1136F
		call	sub_113C8

locret_10DE8:				; CODE XREF: sub_10D34+66j
		retn
sub_10D34	endp


; =============== S U B	R O U T	I N E =======================================


sub_10DE9	proc near		; CODE XREF: sub_10F56+8Cp
					; DATA XREF: seg000:0911o
		mov	cx, 0
		mov	dx, word_10105
		call	sub_110E7
		mov	si, 4F1h
		call	sub_1136F
		cmp	byte_10107, 1
		jz	short loc_10E06
		mov	si, 454h
		call	sub_1136F

loc_10E06:				; CODE XREF: sub_10DE9+15j
		mov	si, 513h
		call	sub_1136F
		call	sub_11477
		cmp	ah, 0
		jnz	short loc_10E27
		cmp	word_119DF, 0AA55h
		jz	short loc_10E1F
		call	sub_114D5

loc_10E1F:				; CODE XREF: sub_10DE9+31j
		call	sub_11561
		call	sub_10E39
		jmp	short loc_10E2F
; ---------------------------------------------------------------------------

loc_10E27:				; CODE XREF: sub_10DE9+29j
		mov	si, 150h
		call	sub_1136F
		jmp	short $+2
; ---------------------------------------------------------------------------

loc_10E2F:				; CODE XREF: sub_10DE9+3Cj
					; sub_10DE9+44j
		mov	si, 540h
		call	sub_1136F
		call	sub_113C8
		retn
sub_10DE9	endp


; =============== S U B	R O U T	I N E =======================================


sub_10E39	proc near		; CODE XREF: sub_10915:loc_109BEp
					; sub_10915+2D7p ...
		push	ax
		push	bx
		push	cx
		push	dx
		push	di
		push	si
		mov	cx, 800h
		mov	dx, 1027h
		call	sub_110E7
		mov	byte_1072D, 30h
		mov	byte_10668, 9
		mov	dl, 31h
		cmp	word_119DF, 0AA55h
		jz	short loc_10E5F
		jmp	loc_10F09
; ---------------------------------------------------------------------------

loc_10E5F:				; CODE XREF: sub_10E39+21j
		mov	di, 199Fh
		mov	dh, 4

loc_10E64:				; CODE XREF: sub_10E39+CDj
		push	di
		mov	cx, 10h
		mov	al, 0
		repe scasb
		pop	di
		cmp	cx, 0
		jnz	short loc_10E79
		mov	word_1012E, di
		jmp	loc_10EFF
; ---------------------------------------------------------------------------

loc_10E79:				; CODE XREF: sub_10E39+37j
		cmp	dl, 31h
		jnz	short loc_10E82
		mov	word_1012C, di

loc_10E82:				; CODE XREF: sub_10E39+43j
		mov	byte_1066E, dl
		cmp	byte ptr [di+4], 1
		jz	short loc_10E9B
		push	di
		mov	di, 67Bh
		mov	si, 69Bh
		mov	cx, 7
		rep movsb
		pop	di
		jmp	short loc_10EA8
; ---------------------------------------------------------------------------

loc_10E9B:				; CODE XREF: sub_10E39+51j
		push	di
		mov	di, 67Bh
		mov	si, 694h
		mov	cx, 7
		rep movsb
		pop	di

loc_10EA8:				; CODE XREF: sub_10E39+60j
		mov	byte_10677, 4Eh
		cmp	byte ptr [di], 80h
		jnz	short loc_10EBB
		mov	byte_10677, 41h
		mov	byte_1072D, dl

loc_10EBB:				; CODE XREF: sub_10E39+77j
		mov	ax, [di+2]
		xchg	ah, al
		mov	cl, 6
		shr	ah, cl
		mov	cx, 4
		push	di
		mov	di, 684h
		call	sub_11120
		pop	di
		mov	bx, ax
		mov	ax, [di+6]
		xchg	ah, al
		mov	cl, 6
		shr	ah, cl
		mov	cx, 4
		push	di
		mov	di, 689h
		call	sub_11120
		pop	di
		sub	ax, bx
		inc	ax
		mov	cx, 4
		push	di
		mov	di, 68Eh
		call	sub_11120
		pop	di
		mov	si, 667h
		call	sub_1136F
		inc	dl
		inc	byte_10668

loc_10EFF:				; CODE XREF: sub_10E39+3Dj
		add	di, 10h
		dec	dh
		jz	short loc_10F09
		jmp	loc_10E64
; ---------------------------------------------------------------------------

loc_10F09:				; CODE XREF: sub_10E39+23j
					; sub_10E39+CBj
		mov	byte_10130, 30h
		cmp	dl, 31h
		jz	short loc_10F2E
		cmp	dl, 35h
		jnz	short loc_10F1E
		mov	word_1012E, 0

loc_10F1E:				; CODE XREF: sub_10E39+DDj
		mov	si, 61Fh
		call	sub_1136F
		mov	byte_10130, dl
		dec	byte_10130
		jmp	short loc_10F34
; ---------------------------------------------------------------------------

loc_10F2E:				; CODE XREF: sub_10E39+D8j
		mov	si, 64Ch
		call	sub_1136F

loc_10F34:				; CODE XREF: sub_10E39+F3j
		mov	al, byte_10109
		mov	ah, byte_1010A
		mov	cl, 6
		shr	ah, cl
		inc	ax
		mov	di, 6B9h
		mov	cx, 4
		call	sub_11120
		mov	si, 6A2h
		call	sub_1136F
		pop	si
		pop	di
		pop	dx
		pop	cx
		pop	bx
		pop	ax
		retn
sub_10E39	endp


; =============== S U B	R O U T	I N E =======================================


sub_10F56	proc near		; CODE XREF: start_0+1Ap
		push	cx
		push	dx
		push	si
		push	di
		cmp	byte_10107, 1
		jz	short loc_10F6E
		mov	si, 876h
		mov	di, 8DAh
		mov	cx, 6
		rep movsb
		jmp	short loc_10F79
; ---------------------------------------------------------------------------

loc_10F6E:				; CODE XREF: sub_10F56+9j
		mov	si, 870h
		mov	di, 8DAh
		mov	cx, 6
		rep movsb

loc_10F79:				; CODE XREF: sub_10F56+16j
					; sub_10F56+90j
		mov	cx, 0
		mov	dx, word_10105
		call	sub_110E7
		cmp	byte_1010F, 0
		jz	short loc_10F95
		mov	si, 150h
		call	sub_1136F
		mov	byte_10104, 1

loc_10F95:				; CODE XREF: sub_10F56+32j
		cmp	byte_10132, 0
		jnz	short loc_10FA6
		inc	byte_10132
		mov	si, 301h
		call	sub_1136F

loc_10FA6:				; CODE XREF: sub_10F56+44j
		mov	si, 35Dh
		call	sub_1136F
		mov	si, 431h
		call	sub_1136F
		cmp	byte_10107, 1
		jz	short loc_10FCC
		cmp	byte_10107, 1
		jz	short loc_10FC6
		mov	si, 454h
		call	sub_1136F

loc_10FC6:				; CODE XREF: sub_10F56+68j
		mov	si, 476h
		call	sub_1136F

loc_10FCC:				; CODE XREF: sub_10F56+61j
		mov	di, 8DAh
		mov	dl, 31h
		call	sub_11164
		cmp	dl, 1Bh
		jz	short loc_10FE8
		sub	dl, 31h
		xor	dh, dh
		shl	dl, 1
		mov	si, dx
		call	off_1090B[si]
		jmp	short loc_10F79
; ---------------------------------------------------------------------------

loc_10FE8:				; CODE XREF: sub_10F56+81j
		pop	di
		pop	si
		pop	bx
		pop	cx
		retn
sub_10F56	endp


; =============== S U B	R O U T	I N E =======================================


sub_10FED	proc near		; CODE XREF: start_0p
		push	ax
		mov	ah, 0Fh
		int	10h		; - VIDEO - GET	CURRENT	VIDEO MODE
					; Return: AH = number of columns on screen
					; AL = current video mode
					; BH = current active display page
		cmp	al, 4
		jl	short loc_10FFF
		cmp	al, 6
		jg	short loc_10FFF
		mov	ax, 0
		int	10h		; - VIDEO - SET	VIDEO MODE
					; AL = mode

loc_10FFF:				; CODE XREF: sub_10FED+7j sub_10FED+Bj
		cmp	al, 1
		jg	short loc_1100C
		mov	word_10105, 1827h
		jmp	short loc_11012
; ---------------------------------------------------------------------------
		align 2

loc_1100C:				; CODE XREF: sub_10FED+14j
		mov	word_10105, 184Fh

loc_11012:				; CODE XREF: sub_10FED+1Cj
		mov	ax, 500h
		int	10h		; - VIDEO - SELECT DISPLAY PAGE
					; AL = display page, 0-7  for modes 0 &	1, 0-3	for modes 2 & 3
		mov	cx, 0
		mov	dx, word_10105
		call	sub_110E7
		pop	ax
		retn
sub_10FED	endp


; =============== S U B	R O U T	I N E =======================================


sub_11023	proc near		; CODE XREF: sub_10F56+8Cp
					; DATA XREF: seg000:0913o
		push	ax
		push	cx
		mov	byte_1010F, 0
		mov	bl, byte_10103
		mov	al, byte_10107
		cmp	byte_10103, al
		jz	short loc_1103D
		inc	byte_10103
		jmp	short loc_11042
; ---------------------------------------------------------------------------

loc_1103D:				; CODE XREF: sub_11023+12j
		mov	byte_10103, 1

loc_11042:				; CODE XREF: sub_11023+18j
		call	sub_11514
		cmp	ah, 0
		jz	short loc_1104F
		mov	byte_1010F, 1

loc_1104F:				; CODE XREF: sub_11023+25j
		mov	cl, byte_10103
		add	cl, 30h
		mov	byte_10473, cl
		pop	cx
		pop	ax
		retn
sub_11023	endp


; =============== S U B	R O U T	I N E =======================================


start_0		proc near		; CODE XREF: startj
		call	sub_10FED
		mov	ah, 30h
		int	21h		; DOS -	GET DOS	VERSION
					; Return: AL = major version number (00h for DOS 1.x)
		cmp	al, 0
		jz	short loc_1109E
		call	sub_11514
		cmp	ah, 0
		jnz	short loc_1108E
		cmp	byte_10107, 0
		jz	short loc_11096
		call	sub_10F56
		mov	cx, 0
		mov	dx, word_10105
		call	sub_110E7
		cmp	byte_10131, 1
		jnz	short loc_110A4
		jmp	loc_10996
; ---------------------------------------------------------------------------

loc_1108E:				; CODE XREF: start_0+11j
		mov	si, 150h
		call	sub_1136F
		jmp	short loc_110A4
; ---------------------------------------------------------------------------

loc_11096:				; CODE XREF: start_0+18j
		mov	si, 133h
		call	sub_1136F
		jmp	short loc_110A4
; ---------------------------------------------------------------------------

loc_1109E:				; CODE XREF: start_0+9j
		mov	si, 18Eh
		call	sub_1136F

loc_110A4:				; CODE XREF: start_0+2Cj start_0+37j ...
		int	20h		; DOS -	PROGRAM	TERMINATION
start_0		endp			; returns to DOS--identical to INT 21/AH=00h

; ---------------------------------------------------------------------------
		align 10h
byte_110B0	db 0			; DATA XREF: sub_11164+15w
					; sub_11164+52w ...
		db 1, 0
word_110B3	dw 0Ah			; DATA XREF: sub_11120+Er
		db 64h,	0, 0E8h, 3
word_110B9	dw 0			; DATA XREF: sub_11275+5w
					; sub_11275:loc_1127Er
word_110BB	dw 0			; DATA XREF: sub_11275+15w
		db 7
word_110BE	dw 0			; DATA XREF: sub_11275+4Cw
					; sub_11275+B5w
word_110C0	dw 0			; DATA XREF: sub_11275+4Fw
					; sub_11275+81w
		db 2 dup(0FFh),	0, 16h,	0Fh, 7,	45h, 6Eh, 74h, 65h, 72h
		db 20h,	61h, 20h, 6Eh, 75h, 6Dh, 62h, 65h, 72h,	2Eh, 2 dup(0FFh)

; =============== S U B	R O U T	I N E =======================================


sub_110D9	proc near		; CODE XREF: sub_11164:loc_111D0p
					; sub_11164:loc_111D5p	...
		push	ax
		push	bx
		mov	al, 7
		mov	bx, 0
		mov	ah, 0Eh
		int	10h		; - VIDEO - WRITE CHARACTER AND	ADVANCE	CURSOR (TTY WRITE)
					; AL = character, BH = display page (alpha modes)
					; BL = foreground color	(graphics modes)
		pop	bx
		pop	ax
		retn
sub_110D9	endp


; =============== S U B	R O U T	I N E =======================================


sub_110E7	proc near		; CODE XREF: sub_10915+7p
					; sub_10915+7Ep ...
		push	ax
		push	bx
		mov	ax, 600h
		mov	bh, 7
		int	10h		; - VIDEO - SCROLL PAGE	UP
					; AL = number of lines to scroll window	(0 = blank whole window)
					; BH = attributes to be	used on	blanked	lines
					; CH,CL	= row,column of	upper left corner of window to scroll
					; DH,DL	= row,column of	lower right corner of window
		pop	bx
		pop	ax
		retn
sub_110E7	endp


; =============== S U B	R O U T	I N E =======================================


sub_110F3	proc near		; CODE XREF: sub_11275+E5p
		push	bx
		push	cx
		push	dx
		push	si
		push	di
		xor	bx, bx
		add	di, cx
		dec	di
		mov	si, 10B1h

loc_11100:				; CODE XREF: sub_110F3+23j
		mov	al, [di]
		cmp	al, 20h
		jz	short loc_1110D
		sub	al, 30h
		cbw
		mul	word ptr [si]
		jmp	short loc_11110
; ---------------------------------------------------------------------------

loc_1110D:				; CODE XREF: sub_110F3+11j
		mov	ax, 0

loc_11110:				; CODE XREF: sub_110F3+18j
		add	bx, ax
		add	si, 2
		dec	di
		loop	loc_11100
		mov	ax, bx
		pop	di
		pop	si
		pop	dx
		pop	cx
		pop	bx
		retn
sub_110F3	endp


; =============== S U B	R O U T	I N E =======================================


sub_11120	proc near		; CODE XREF: sub_10915+183p
					; sub_10915+18Ep ...
		push	ax
		push	cx
		push	dx
		push	di
		push	ax
		push	cx
		mov	al, 20h
		rep stosb
		pop	cx
		pop	ax
		dec	di

loc_1112D:				; CODE XREF: sub_11120+1Bj
		cwd
		div	word_110B3
		add	dl, 30h
		mov	[di], dl
		dec	di
		cmp	ax, 0
		jnz	short loc_1112D
		pop	di
		pop	dx
		pop	cx
		pop	ax
		retn
sub_11120	endp


; =============== S U B	R O U T	I N E =======================================


sub_11142	proc near		; CODE XREF: sub_10915+91p
					; sub_11164:loc_11190p	...
		push	cx
		push	dx
		mov	ah, 6
		mov	dl, 0FFh

loc_11148:				; CODE XREF: sub_11142+8j
		int	21h		; DOS -	DIRECT CONSOLE I/O CHARACTER OUTPUT
					; DL = character <> FFh
					;  Return: ZF set = no character
					;   ZF clear = character recieved, AL =	character
		jz	short loc_11148
		cmp	byte_10104, 1
		jnz	short loc_11161
		mov	cx, 1500h
		mov	dx, 1727h
		call	sub_110E7
		mov	byte_10104, 0

loc_11161:				; CODE XREF: sub_11142+Fj
		pop	dx
		pop	cx
		retn
sub_11142	endp


; =============== S U B	R O U T	I N E =======================================


sub_11164	proc near		; CODE XREF: sub_10915+59p
					; sub_10C2E+8Ap ...
		push	ax
		push	bx
		push	cx
		push	si

loc_11168:				; CODE XREF: sub_11164+C8j
		push	dx
		mov	bh, 0
		mov	dx, word_1010D
		mov	ah, 2
		int	10h		; - VIDEO - SET	CURSOR POSITION
					; DH,DL	= row, column (0,0 = upper left)
					; BH = page number
		pop	dx
		xor	dh, dh
		push	dx
		mov	al, dl
		mov	byte_110B0, 1
		push	dx
		mov	cx, 1
		mov	bl, 7
		mov	ah, 9
		mov	dx, word_1010D
		int	10h		; - VIDEO - WRITE ATTRIBUTES/CHARACTERS	AT CURSOR POSITION
					; AL = character, BH = display page
					; BL = attributes of character (alpha modes) or	color (graphics	modes)
					; CX = number of times to write	character
		pop	dx
		mov	cx, 0

loc_11190:				; CODE XREF: sub_11164+6Aj
					; sub_11164+6Fj ...
		call	sub_11142
		cmp	al, 1Bh
		jnz	short loc_1119A
		jmp	loc_11238
; ---------------------------------------------------------------------------

loc_1119A:				; CODE XREF: sub_11164+31j
		cmp	al, 0
		jz	short loc_111DA
		cmp	al, 0Dh
		jz	short loc_11202
		cmp	al, 8
		jz	short loc_111EA
		cmp	al, 20h
		jl	short loc_111D5
		cmp	al, 7Eh
		jg	short loc_111D5
		cmp	cx, 1
		jz	short loc_111D0
		mov	cx, 1
		mov	byte_110B0, 0
		mov	dl, al
		push	cx
		push	dx
		mov	cx, 1
		mov	dx, word_1010D
		mov	bl, 7
		mov	ah, 9
		int	10h		; - VIDEO - WRITE ATTRIBUTES/CHARACTERS	AT CURSOR POSITION
					; AL = character, BH = display page
					; BL = attributes of character (alpha modes) or	color (graphics	modes)
					; CX = number of times to write	character
		pop	dx
		pop	cx
		jmp	short loc_11190
; ---------------------------------------------------------------------------

loc_111D0:				; CODE XREF: sub_11164+4Dj
		call	sub_110D9
		jmp	short loc_11190
; ---------------------------------------------------------------------------

loc_111D5:				; CODE XREF: sub_11164+44j
					; sub_11164+48j
		call	sub_110D9
		jmp	short loc_11190
; ---------------------------------------------------------------------------

loc_111DA:				; CODE XREF: sub_11164+38j
		call	sub_11142
		cmp	al, 53h
		jz	short loc_111EA
		cmp	al, 4Bh
		jz	short loc_111EA
		call	sub_110D9
		jmp	short loc_11190
; ---------------------------------------------------------------------------

loc_111EA:				; CODE XREF: sub_11164+40j
					; sub_11164+7Bj ...
		push	dx
		mov	cx, 1
		mov	bl, 7
		mov	ax, 920h
		int	10h		; - VIDEO - WRITE ATTRIBUTES/CHARACTERS	AT CURSOR POSITION
					; AL = character, BH = display page
					; BL = attributes of character (alpha modes) or	color (graphics	modes)
					; CX = number of times to write	character
		pop	dx
		mov	cx, 0
		mov	byte_110B0, 0
		mov	dl, 20h
		jmp	short loc_11190
; ---------------------------------------------------------------------------

loc_11202:				; CODE XREF: sub_11164+3Cj
		cmp	byte_110B0, 1
		jz	short loc_1122F

loc_11209:				; CODE XREF: sub_11164+D2j
		push	di
		xor	ch, ch
		mov	cl, [di]
		inc	di
		mov	al, dl
		cld
		repne scasb
		jnz	short loc_11219
		pop	di
		jmp	short loc_1123A
; ---------------------------------------------------------------------------

loc_11219:				; CODE XREF: sub_11164+B0j
		mov	si, [di]
		mov	[si], al
		add	di, 2
		mov	byte_10104, 1
		mov	si, di
		call	sub_1136F
		pop	di
		pop	dx
		jmp	loc_11168
; ---------------------------------------------------------------------------

loc_1122F:				; CODE XREF: sub_11164+A3j
		mov	bp, sp
		mov	si, [bp+0]
		mov	dx, si
		jmp	short loc_11209
; ---------------------------------------------------------------------------

loc_11238:				; CODE XREF: sub_11164+33j
		mov	dl, 1Bh

loc_1123A:				; CODE XREF: sub_11164+B3j
		add	sp, 2
		push	dx
		mov	cx, 1
		mov	bx, 7
		mov	dx, word_1010D
		dec	dl
		mov	ah, 2
		int	10h		; - VIDEO - SET	CURSOR POSITION
					; DH,DL	= row, column (0,0 = upper left)
					; BH = page number
		mov	ax, 920h
		int	10h		; - VIDEO - WRITE ATTRIBUTES/CHARACTERS	AT CURSOR POSITION
					; AL = character, BH = display page
					; BL = attributes of character (alpha modes) or	color (graphics	modes)
					; CX = number of times to write	character
		mov	dx, word_1010D
		inc	dl
		mov	ah, 2
		int	10h		; - VIDEO - SET	CURSOR POSITION
					; DH,DL	= row, column (0,0 = upper left)
					; BH = page number
		mov	ax, 920h
		int	10h		; - VIDEO - WRITE ATTRIBUTES/CHARACTERS	AT CURSOR POSITION
					; AL = character, BH = display page
					; BL = attributes of character (alpha modes) or	color (graphics	modes)
					; CX = number of times to write	character
		pop	dx
		cmp	dl, 61h
		jl	short loc_11270
		cmp	dl, 7Ah
		jg	short loc_11270
		sub	dl, 20h

loc_11270:				; CODE XREF: sub_11164+102j
					; sub_11164+107j
		pop	si
		pop	cx
		pop	bx
		pop	ax
		retn
sub_11164	endp


; =============== S U B	R O U T	I N E =======================================


sub_11275	proc near		; CODE XREF: sub_10915+1A4p
					; sub_10915+1FDp
		push	ax
		push	bx
		push	cx
		push	di
		push	si
		mov	word_110B9, cx

loc_1127E:				; CODE XREF: sub_11275+DCj
		mov	cx, word_110B9
		mov	bx, word_1010D
		sub	bl, cl
		inc	bl
		mov	word_110BB, bx
		mov	di, 10BEh
		mov	cx, 4
		mov	ax, dx
		call	sub_11120
		mov	si, 10BBh
		call	sub_1136F
		mov	byte_110B0, 1
		mov	cx, 0

loc_112A7:				; CODE XREF: sub_11275+8Aj
					; sub_11275+8Fj ...
		call	sub_11142
		cmp	al, 1Bh
		jnz	short loc_112B1
		jmp	loc_11367
; ---------------------------------------------------------------------------

loc_112B1:				; CODE XREF: sub_11275+37j
		cmp	al, 0Dh
		jnz	short loc_112B8
		jmp	loc_1133A
; ---------------------------------------------------------------------------

loc_112B8:				; CODE XREF: sub_11275+3Ej
		cmp	cx, 0
		jnz	short loc_112D3
		push	ax
		mov	ax, 2020h
		mov	word_110BE, ax
		mov	word_110C0, ax
		pop	ax
		mov	si, 10BBh
		call	sub_1136F
		mov	byte_110B0, 0

loc_112D3:				; CODE XREF: sub_11275+46j
		cmp	al, 0
		jz	short loc_1130B
		cmp	al, 8
		jz	short loc_11317
		cmp	al, 30h
		jl	short loc_11306
		cmp	al, 39h
		jg	short loc_11306
		cmp	cx, 4
		jz	short loc_11301
		inc	cx
		push	cx
		mov	si, 10BFh
		mov	di, 10BEh
		mov	cx, 3
		rep movsb
		pop	cx
		mov	byte ptr word_110C0+1, al
		mov	si, 10BBh
		call	sub_1136F
		jmp	short loc_112A7
; ---------------------------------------------------------------------------

loc_11301:				; CODE XREF: sub_11275+71j
		call	sub_110D9
		jmp	short loc_112A7
; ---------------------------------------------------------------------------

loc_11306:				; CODE XREF: sub_11275+68j
					; sub_11275+6Cj
		call	sub_110D9
		jmp	short loc_112A7
; ---------------------------------------------------------------------------

loc_1130B:				; CODE XREF: sub_11275+60j
		call	sub_11142
		cmp	al, 53h
		jz	short loc_11317
		call	sub_110D9
		jmp	short loc_112A7
; ---------------------------------------------------------------------------

loc_11317:				; CODE XREF: sub_11275+64j
					; sub_11275+9Bj
		cmp	cx, 0
		jz	short loc_11337
		push	cx
		std
		mov	di, 10C1h
		mov	si, 10C0h
		mov	cx, 3
		rep movsb
		cld
		mov	byte ptr word_110BE, 20h
		pop	cx
		mov	si, 10BBh
		call	sub_1136F
		dec	cx

loc_11337:				; CODE XREF: sub_11275+A5j
		jmp	loc_112A7
; ---------------------------------------------------------------------------

loc_1133A:				; CODE XREF: sub_11275+40j
		cmp	byte_110B0, 1
		jz	short loc_11354
		cmp	cx, 0
		jnz	short loc_11354
		mov	byte_10104, 1
		mov	si, 10C4h
		call	sub_1136F
		jmp	loc_1127E
; ---------------------------------------------------------------------------

loc_11354:				; CODE XREF: sub_11275+CAj
					; sub_11275+CFj
		mov	di, 10BEh
		mov	cx, 4
		call	sub_110F3
		mov	dx, ax
		mov	ax, 1
		cmp	ax, 0
		jmp	short loc_11369
; ---------------------------------------------------------------------------

loc_11367:				; CODE XREF: sub_11275+39j
		cmp	ax, ax

loc_11369:				; CODE XREF: sub_11275+F0j
		pop	si
		pop	di
		pop	cx
		pop	bx
		pop	ax
		retn
sub_11275	endp


; =============== S U B	R O U T	I N E =======================================


sub_1136F	proc near		; CODE XREF: sub_10915+Dp
					; sub_10915+1Ap ...
		push	ax
		push	bx
		push	cx
		push	dx
		push	si
		mov	dx, [si]
		add	si, 2

loc_11379:				; CODE XREF: sub_1136F+51j
		cmp	byte ptr [si], 0FFh
		jz	short loc_113C2
		mov	bl, [si]
		mov	bh, 0
		mov	cx, 1
		inc	si

loc_11386:				; CODE XREF: sub_1136F+38j
					; sub_1136F+3Ej ...
		cmp	byte ptr [si], 0FFh
		jz	short loc_113BF
		cmp	byte ptr [si], 7
		jz	short loc_113A9
		cmp	byte ptr [si], 0Dh
		jz	short loc_113AF
		cmp	byte ptr [si], 0
		jz	short loc_113B6
		mov	ah, 2
		int	10h		; - VIDEO - SET	CURSOR POSITION
					; DH,DL	= row, column (0,0 = upper left)
					; BH = page number
		mov	ah, 9
		mov	al, [si]
		int	10h		; - VIDEO - WRITE ATTRIBUTES/CHARACTERS	AT CURSOR POSITION
					; AL = character, BH = display page
					; BL = attributes of character (alpha modes) or	color (graphics	modes)
					; CX = number of times to write	character
		inc	dl
		inc	si
		jmp	short loc_11386
; ---------------------------------------------------------------------------

loc_113A9:				; CODE XREF: sub_1136F+1Fj
		call	sub_110D9
		inc	si
		jmp	short loc_11386
; ---------------------------------------------------------------------------

loc_113AF:				; CODE XREF: sub_1136F+24j
		xor	dl, dl
		inc	dh
		inc	si
		jmp	short loc_11386
; ---------------------------------------------------------------------------

loc_113B6:				; CODE XREF: sub_1136F+29j
		mov	word_1010D, dx
		inc	dl
		inc	si
		jmp	short loc_11386
; ---------------------------------------------------------------------------

loc_113BF:				; CODE XREF: sub_1136F+1Aj
		inc	si
		jmp	short loc_11379
; ---------------------------------------------------------------------------

loc_113C2:				; CODE XREF: sub_1136F+Dj
		pop	si
		pop	dx
		pop	cx
		pop	bx
		pop	ax
		retn
sub_1136F	endp


; =============== S U B	R O U T	I N E =======================================


sub_113C8	proc near		; CODE XREF: sub_10915+315p
					; sub_10C2E+102p ...
		mov	dx, word_1010D
		mov	bh, 0
		mov	ah, 2
		int	10h		; - VIDEO - SET	CURSOR POSITION
					; DH,DL	= row, column (0,0 = upper left)
					; BH = page number
		call	sub_11142
		cmp	al, 0
		jnz	short loc_113DE
		call	sub_11142
		jmp	short loc_113E2
; ---------------------------------------------------------------------------

loc_113DE:				; CODE XREF: sub_113C8+Fj
		cmp	al, 1Bh
		jz	short locret_113E7

loc_113E2:				; CODE XREF: sub_113C8+14j
		call	sub_110D9
		jmp	short sub_113C8
; ---------------------------------------------------------------------------

locret_113E7:				; CODE XREF: sub_113C8+18j
		retn
sub_113C8	endp

; ---------------------------------------------------------------------------
		align 20h

; =============== S U B	R O U T	I N E =======================================


sub_11400	proc near		; CODE XREF: sub_10915+2D4p
					; sub_114A3+2Ep
		push	ax
		push	bx
		push	cx
		push	dx
		push	di
		push	si
		mov	di, 199Fh
		mov	si, 4

loc_1140C:				; CODE XREF: sub_11400+6Ej
		push	di
		xor	ax, ax
		mov	cx, 8
		repe scasw
		pop	di
		cmp	cx, 0
		jz	short loc_1146A
		mov	cl, 6
		mov	ax, [di+6]
		xchg	ah, al
		shr	ah, cl
		mov	bx, [di+2]
		xchg	bh, bl
		shr	bh, cl
		push	bx
		sub	ax, bx
		inc	ax
		mul	word_1010B
		mov	bl, byte_10108
		xor	bh, bh
		inc	bl
		mul	bx
		mov	[di+0Eh], dx
		mov	[di+0Ch], ax
		pop	ax
		cmp	ax, 0
		jz	short loc_11458
		mul	word_1010B
		mov	bl, byte_10108
		xor	bh, bh
		inc	bl
		mul	bx
		jmp	short loc_11464
; ---------------------------------------------------------------------------

loc_11458:				; CODE XREF: sub_11400+46j
		mov	ax, 1
		xor	dx, dx
		dec	word ptr [di+0Ch]
		sbb	word ptr [di+0Eh], 0

loc_11464:				; CODE XREF: sub_11400+56j
		mov	[di+0Ah], dx
		mov	[di+8],	ax

loc_1146A:				; CODE XREF: sub_11400+18j
		add	di, 10h
		dec	si
		jnz	short loc_1140C
		pop	si
		pop	di
		pop	dx
		pop	cx
		pop	bx
		pop	ax
		retn
sub_11400	endp


; =============== S U B	R O U T	I N E =======================================


sub_11477	proc near		; CODE XREF: sub_10915+23p
					; sub_10C2E+23p ...
		push	bx
		push	cx
		push	dx
		mov	cx, 5

loc_1147D:				; CODE XREF: sub_11477+26j
		push	cx
		mov	ax, 201h
		mov	bx, 17E1h
		mov	cx, 1
		mov	dl, byte_10103
		dec	dl
		or	dl, 80h
		xor	dh, dh
		int	13h		; DISK - READ SECTORS INTO MEMORY
					; AL = number of sectors to read, CH = track, CL = sector
					; DH = head, DL	= drive, ES:BX -> buffer to fill
					; Return: CF set on error, AH =	status,	AL = number of sectors read
		pop	cx
		jnb	short loc_1149F
		push	ax
		xor	ax, ax
		int	13h		; DISK - RESET DISK SYSTEM
					; DL = drive (if bit 7 is set both hard	disks and floppy disks reset)
		pop	ax
		loop	loc_1147D

loc_1149F:				; CODE XREF: sub_11477+1Ej
		pop	dx
		pop	cx
		pop	bx
		retn
sub_11477	endp


; =============== S U B	R O U T	I N E =======================================


sub_114A3	proc near		; CODE XREF: sub_10915+69p
		xor	ax, ax
		mov	di, 199Fh
		mov	cx, 20h
		rep stosw
		mov	byte_1199F, 80h
		mov	byte_119A3, 1
		mov	byte_119A1, 2
		mov	al, byte_10109
		mov	byte_119A6, al
		mov	al, byte_10108
		mov	byte_119A4, al
		mov	al, byte_1010A
		mov	byte_119A5, al
		call	sub_11561
		call	sub_11400
		retn
sub_114A3	endp


; =============== S U B	R O U T	I N E =======================================


sub_114D5	proc near		; CODE XREF: sub_10915+39p
					; sub_10C2E+36p ...
		push	si
		push	di
		mov	si, 15E1h
		mov	di, 17E1h
		rep movsw
		pop	di
		pop	si
		retn
sub_114D5	endp


; =============== S U B	R O U T	I N E =======================================


sub_114E2	proc near		; CODE XREF: sub_10915+6Cp
					; sub_10915+2DAp ...
		push	bx
		push	cx
		push	dx
		mov	cx, 0DFh
		call	sub_114D5
		mov	cx, 5

loc_114EE:				; CODE XREF: sub_114E2+2Cj
		push	cx
		mov	ax, 301h
		mov	bx, 17E1h
		mov	cx, 1
		mov	dl, byte_10103
		dec	dl
		or	dl, 80h
		xor	dh, dh
		int	13h		; DISK - WRITE SECTORS FROM MEMORY
					; AL = number of sectors to write, CH =	track, CL = sector
					; DH = head, DL	= drive, ES:BX -> buffer
					; Return: CF set on error, AH =	status,	AL = number of sectors written
		pop	cx
		jnb	short loc_11510
		push	ax
		xor	ax, ax
		int	13h		; DISK - RESET DISK SYSTEM
					; DL = drive (if bit 7 is set both hard	disks and floppy disks reset)
		pop	ax
		loop	loc_114EE

loc_11510:				; CODE XREF: sub_114E2+24j
		pop	dx
		pop	cx
		pop	bx
		retn
sub_114E2	endp


; =============== S U B	R O U T	I N E =======================================


sub_11514	proc near		; CODE XREF: sub_11023:loc_11042p
					; start_0+Bp
		push	cx
		push	dx
		mov	cx, 5

loc_11519:				; CODE XREF: sub_11514+2Fj
		push	cx
		mov	ah, 8
		mov	dl, byte_10103
		dec	dl
		or	dl, 80h
		int	13h		; DISK - DISK -	GET CURRENT DRIVE PARAMETERS (XT,AT,XT286,CONV,PS)
					; DL = drive number
					; Return: CF set on error, AH =	status code, BL	= drive	type
					; DL = number of consecutive drives
					; DH = maximum value for head number, ES:DI -> drive parameter
		mov	byte_10107, dl
		mov	byte_10108, dh
		mov	byte_10109, ch
		mov	byte_1010A, cl
		pop	cx
		cmp	ah, 0
		jz	short loc_11551
		push	ax
		xor	ax, ax
		int	13h		; DISK - RESET DISK SYSTEM
					; DL = drive (if bit 7 is set both hard	disks and floppy disks reset)
		pop	ax
		loop	loc_11519
		cmp	ah, 1
		jnz	short loc_11551
		mov	ah, 0
		mov	byte_10107, 0

loc_11551:				; CODE XREF: sub_11514+27j
					; sub_11514+34j
		mov	dl, byte_1010A
		xor	dh, dh
		and	dl, 3Fh
		mov	word_1010B, dx
		pop	dx
		pop	cx
		retn
sub_11514	endp


; =============== S U B	R O U T	I N E =======================================


sub_11561	proc near		; CODE XREF: sub_10915+2D1p
					; sub_10C2E:loc_10C67p	...
		push	ax
		push	bx
		push	cx
		push	dx
		push	di
		push	si
		mov	si, 199Fh
		mov	dh, 3

loc_1156C:				; CODE XREF: sub_11561+77j
		mov	bx, si
		mov	di, si
		add	di, 10h
		mov	dl, dh

loc_11575:				; CODE XREF: sub_11561+47j
		push	di
		mov	cx, 8
		xor	ax, ax
		repe scasw
		pop	di
		cmp	cx, 0
		jnz	short loc_11587
		mov	bx, di
		jmp	short loc_115A1
; ---------------------------------------------------------------------------

loc_11587:				; CODE XREF: sub_11561+20j
		push	dx
		mov	ax, [si+2]
		xchg	ah, al
		mov	cl, 6
		shr	ah, cl
		mov	dx, [di+2]
		xchg	dh, dl
		mov	cl, 6
		shr	dh, cl
		cmp	dx, ax
		jge	short loc_115A0
		mov	bx, di

loc_115A0:				; CODE XREF: sub_11561+3Bj
		pop	dx

loc_115A1:				; CODE XREF: sub_11561+24j
		add	di, 10h
		dec	dl
		jz	short loc_115AA
		jmp	short loc_11575
; ---------------------------------------------------------------------------

loc_115AA:				; CODE XREF: sub_11561+45j
		push	si
		push	di
		mov	di, 13F0h
		mov	cx, 8
		rep movsw
		pop	di
		pop	si
		push	si
		push	di
		mov	di, si
		mov	si, bx
		mov	cx, 8
		rep movsw
		pop	di
		pop	si
		push	si
		push	di
		mov	si, 13F0h
		mov	di, bx
		mov	cx, 8
		rep movsw
		pop	di
		pop	si
		add	si, 10h
		dec	dh
		jz	short loc_115DA
		jmp	short loc_1156C
; ---------------------------------------------------------------------------

loc_115DA:				; CODE XREF: sub_11561+75j
		pop	si
		pop	di
		pop	dx
		pop	cx
		pop	bx
		pop	ax
		retn
sub_11561	endp

; ---------------------------------------------------------------------------
		db 0FAh, 33h, 0C0h, 8Eh, 0D0h, 0BCh, 0,	7Ch, 8Bh, 0F4h
		db 50h,	7, 50h,	1Fh, 0FBh, 0FCh, 0BFh, 0, 6, 0B9h, 0, 1
		db 0F3h, 0A5h, 0EAh, 1Dh, 6, 2 dup(0), 2 dup(0BEh), 7
		db 0B3h, 4, 80h, 3Ch, 80h, 74h,	0Eh, 82h, 3Ch, 0, 75h
		db 1Ch,	83h, 0C6h, 10h,	0FEh, 0CBh, 75h, 0EFh, 0CDh, 18h
		db 8Bh,	14h, 8Bh, 4Ch, 2, 8Bh, 0EEh, 83h, 0C6h,	10h, 0FEh
		db 0CBh, 74h, 1Bh, 82h,	3Ch, 0,	74h, 0F4h, 0BEh, 8Bh, 6
		db 32h,	0EDh, 0ACh, 8Ah, 0C8h, 0ACh, 56h, 0BBh,	7, 0, 0B4h
		db 0Eh,	0CDh, 10h, 5Eh,	0E2h, 0F4h, 0EBh, 0FEh,	0BFh, 5
		db 0, 0BBh, 0, 7Ch, 0B8h, 1, 2,	57h, 0CDh, 13h,	5Fh, 73h
		db 0Ch,	33h, 0C0h, 0CDh, 13h, 4Fh, 75h,	0EDh, 0BEh, 0A3h
		db 6, 0EBh, 0D2h, 0BEh,	0C2h, 6, 81h, 3Eh, 0FEh, 7Dh, 55h
		db 0AAh, 75h, 0C7h, 8Bh, 0F5h, 0EAh, 0,	7Ch, 2 dup(0)
		db 17h,	49h, 6Eh, 76h, 61h, 6Ch, 69h, 64h, 20h,	70h, 61h
		db 72h,	74h, 69h, 74h, 69h, 6Fh, 6Eh, 20h, 74h,	61h, 62h
		db 6Ch,	65h, 1Eh, 45h, 2 dup(72h), 6Fh,	72h, 20h, 6Ch
		db 6Fh,	61h, 64h, 69h, 6Eh, 67h, 20h, 6Fh, 70h,	65h, 72h
		db 61h,	74h, 69h, 6Eh, 67h, 20h, 73h, 79h, 73h,	74h, 65h
		db 6Dh,	18h
aMissingOperati	db 'Missing operating systemAuthor - David Litton',0
		db 10Dh	dup(0),	55h, 0AAh, 1BEh	dup(0)
byte_1199F	db 0			; DATA XREF: sub_114A3+Aw
		db 0
byte_119A1	db 0			; DATA XREF: sub_114A3+14w
		db 0
byte_119A3	db 0			; DATA XREF: sub_114A3+Fw
byte_119A4	db 0			; DATA XREF: sub_114A3+22w
byte_119A5	db 0			; DATA XREF: sub_114A3+28w
byte_119A6	db 0			; DATA XREF: sub_114A3+1Cw
		db 38h dup(0)
word_119DF	dw 0			; DATA XREF: sub_10915:loc_10943r
					; sub_10C2E:loc_10C5Cr	...
seg000		ends


		end start
