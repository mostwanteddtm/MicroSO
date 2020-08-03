_TEXT SEGMENT PUBLIC USE16

.DATA

;FONT THIN8X8
FONT	db 8 dup(0), 7Eh, 81h, 0A5h, 81h, 0BDh,	99h, 81h, 2 dup(7Eh)
		db 0FFh, 0DBh, 0FFh, 0C3h, 0E7h, 0FFh, 7Eh, 6Ch, 3 dup(0FEh)
		db 7Ch,	38h, 10h, 0, 10h, 38h, 7Ch, 0FEh, 7Ch, 38h, 10h
		db 0, 38h, 7Ch,	38h, 2 dup(0FEh), 7Ch, 38h, 7Ch, 2 dup(10h)
		db 38h,	7Ch, 0FEh, 7Ch,	38h, 7Ch, 2 dup(0), 18h, 2 dup(3Ch)
		db 18h,	2 dup(0), 2 dup(0FFh), 0E7h, 2 dup(0C3h), 0E7h
		db 2 dup(0FFh),	0, 3Ch,	66h, 2 dup(42h), 66h, 3Ch, 0, 0FFh
		db 0C3h, 99h, 2	dup(0BDh), 99h,	0C3h, 0FFh, 0Fh, 7, 0Fh
		db 7Dh,	3 dup(0CCh), 78h, 3Ch, 3 dup(66h), 3Ch,	18h, 7Eh
		db 18h,	3Fh, 33h, 3Fh, 2 dup(30h), 70h,	0F0h, 0E0h, 7Fh
		db 63h,	7Fh, 2 dup(63h), 67h, 0E6h, 0C0h, 99h, 5Ah, 3Ch
		db 2 dup(0E7h),	3Ch, 5Ah, 99h, 80h, 0E0h, 0F8h,	0FEh, 0F8h
		db 0E0h, 80h, 0, 2, 0Eh, 3Eh, 0FEh, 3Eh, 0Eh, 2, 0, 18h
		db 3Ch,	7Eh, 2 dup(18h), 7Eh, 3Ch, 18h,	5 dup(66h), 0
		db 66h,	0, 7Fh,	2 dup(0DBh), 7Bh, 3 dup(1Bh), 0, 3Eh, 63h
		db 38h,	2 dup(6Ch), 38h, 0CCh, 78h, 4 dup(0), 3	dup(7Eh)
		db 0, 18h, 3Ch,	7Eh, 18h, 7Eh, 3Ch, 18h, 0FFh, 18h, 3Ch
		db 7Eh,	4 dup(18h), 0, 4 dup(18h), 7Eh,	3Ch, 18h, 2 dup(0)
		db 18h,	0Ch, 0FEh, 0Ch,	18h, 3 dup(0), 30h, 60h, 0FEh
		db 60h,	30h, 4 dup(0), 3 dup(0C0h), 0FEh, 3 dup(0), 24h
		db 66h,	0FFh, 66h, 24h,	3 dup(0), 18h, 3Ch, 7Eh, 2 dup(0FFh)
		db 3 dup(0), 2 dup(0FFh), 7Eh, 3Ch, 18h, 0Ah dup(0), 5 dup(40h)
		db 0, 40h, 0, 2	dup(90h), 6 dup(0), 2 dup(50h),	0F8h, 50h
		db 0F8h, 2 dup(50h), 0,	20h, 78h, 0A0h,	70h, 28h, 0F0h
		db 20h,	0, 2 dup(0C8h),	10h, 20h, 40h, 2 dup(98h), 0, 70h
		db 88h,	50h, 20h, 54h, 88h, 74h, 0, 60h, 20h, 40h, 5 dup(0)
		db 20h,	40h, 3 dup(80h), 40h, 20h, 0, 20h, 10h,	3 dup(8)
		db 10h,	20h, 2 dup(0), 20h, 0A8h, 2 dup(70h), 0A8h, 20h
		db 3 dup(0), 2 dup(20h), 0F8h, 2 dup(20h), 6 dup(0), 60h
		db 20h,	40h, 4 dup(0), 0F8h, 8 dup(0), 2 dup(60h), 0, 2
		db 4, 8, 10h, 20h, 40h,	80h, 0,	70h, 88h, 98h, 0A8h, 0C8h
		db 88h,	70h, 0,	40h, 0C0h, 4 dup(40h), 0E0h, 0,	70h, 88h
		db 8, 10h, 20h,	40h, 0F8h, 0, 70h, 88h,	8, 10h,	8, 88h
		db 70h,	0, 8, 18h, 28h,	48h, 0FCh, 2 dup(8), 0,	0F8h, 2	dup(80h)
		db 0F0h, 8, 88h, 70h, 0, 20h, 40h, 80h,	0F0h, 2	dup(88h)
		db 70h,	0, 0F8h, 8, 10h, 20h, 3	dup(40h), 0, 70h, 2 dup(88h)
		db 70h,	2 dup(88h), 70h, 0, 70h, 2 dup(88h), 78h, 2 dup(8)
		db 70h,	3 dup(0), 2 dup(60h), 0, 2 dup(60h), 3 dup(0)
		db 2 dup(60h), 0, 2 dup(60h), 20h, 10h,	20h, 40h, 80h
		db 40h,	20h, 10h, 3 dup(0), 0F8h, 0, 0F8h, 3 dup(0), 80h
		db 40h,	20h, 10h, 20h, 40h, 80h, 0, 78h, 84h, 4, 8, 10h
		db 0, 10h, 0, 70h, 2 dup(88h), 0A8h, 0B8h, 80h,	78h, 0
		db 20h,	50h, 2 dup(88h), 0F8h, 2 dup(88h), 0, 0F0h, 2 dup(88h)
		db 0F0h, 2 dup(88h), 0F0h, 0, 70h, 88h,	3 dup(80h), 88h
		db 70h,	0, 0F0h, 5 dup(88h), 0F0h, 0, 0F8h, 2 dup(80h)
		db 0E0h, 2 dup(80h), 0F8h, 0, 0F8h, 2 dup(80h),	0E0h, 3	dup(80h)
		db 0, 70h, 88h,	2 dup(80h), 98h, 88h, 78h, 0, 3	dup(88h)
		db 0F8h, 3 dup(88h), 0,	0E0h, 5	dup(40h), 0E0h,	0, 38h
		db 4 dup(10h), 90h, 60h, 0, 88h, 90h, 0A0h, 0C0h, 0A0h
		db 90h,	88h, 0,	6 dup(80h), 0F8h, 0, 82h, 0C6h,	0AAh, 92h
		db 3 dup(82h), 0, 84h, 0C4h, 0A4h, 94h,	8Ch, 2 dup(84h)
		db 0, 70h, 5 dup(88h), 70h, 0, 0F0h, 2 dup(88h), 0F0h
		db 3 dup(80h), 0, 70h, 3 dup(88h), 0A8h, 90h, 68h, 0, 0F0h
		db 2 dup(88h), 0F0h, 0A0h, 90h,	88h, 0,	70h, 88h, 80h
		db 70h,	8, 88h,	70h, 0,	0F8h, 6	dup(20h), 0, 6 dup(88h)
		db 70h,	0, 3 dup(88h), 2 dup(50h), 2 dup(20h), 0, 4 dup(82h)
		db 2 dup(92h), 6Ch, 0, 2 dup(88h), 50h,	20h, 50h, 2 dup(88h)
		db 0, 3	dup(88h), 50h, 3 dup(20h), 0, 0F8h, 8
		db 10h,	20h, 40h, 80h, 0F8h, 0,	0E0h, 5	dup(80h), 0E0h
		db 0, 80h, 40h,	20h, 10h, 8, 4,	2, 0, 0E0h, 5 dup(20h)
		db 0E0h, 0, 20h, 50h, 88h, 0Bh dup(0), 0F8h, 0,	40h, 20h
		db 8 dup(0), 70h, 8, 78h, 88h, 74h, 0, 2 dup(80h), 0B0h
		db 0C8h, 88h, 0C8h, 0B0h, 3 dup(0), 70h, 88h, 80h, 88h
		db 70h,	0, 2 dup(8), 68h, 98h, 88h, 98h, 68h, 3	dup(0)
		db 70h,	88h, 0F8h, 80h,	70h, 0,	30h, 48h, 40h, 0E0h, 3 dup(40h)
		db 3 dup(0), 34h, 2 dup(48h), 38h, 8, 30h, 2 dup(80h)
		db 0B0h, 0C8h, 3 dup(88h), 0, 20h, 0, 60h, 3 dup(20h)
		db 70h,	0, 10h,	0, 30h,	3 dup(10h), 90h, 60h, 2	dup(80h)
		db 88h,	90h, 0A0h, 0D0h, 88h, 0, 0C0h, 5 dup(40h), 0E0h
		db 3 dup(0), 0ECh, 4 dup(92h), 3 dup(0), 0B0h, 0C8h, 3 dup(88h)
		db 3 dup(0), 70h, 3 dup(88h), 70h, 3 dup(0), 0B0h, 2 dup(0C8h)
		db 0B0h, 2 dup(80h), 2 dup(0), 68h, 2 dup(98h),	68h, 2 dup(8)
		db 2 dup(0), 0B0h, 0C8h, 3 dup(80h), 3 dup(0), 78h, 80h
		db 70h,	8, 0F0h, 0, 2 dup(40h),	0E0h, 2	dup(40h), 50h
		db 20h,	3 dup(0), 3 dup(88h), 98h, 68h,	3 dup(0), 3 dup(88h)
		db 50h,	20h, 3 dup(0), 2 dup(82h), 2 dup(92h), 6Ch, 3 dup(0)
		db 88h,	50h, 20h, 50h, 88h, 3 dup(0), 2	dup(88h), 98h
		db 68h,	8, 70h,	2 dup(0), 0F8h,	10h, 20h, 40h, 0F8h, 0
		db 10h,	2 dup(20h), 40h, 2 dup(20h), 10h, 0, 3 dup(40h)
		db 0, 3	dup(40h), 0, 40h, 2 dup(20h), 10h, 2 dup(20h)
		db 40h,	0, 76h,	0DCh, 7	dup(0),	10h, 38h, 6Ch, 2 dup(0C6h)
		db 0FEh, 0, 3Eh, 60h, 0C0h, 60h, 3Eh, 8, 4, 18h, 0, 48h
		db 0, 4	dup(0CCh), 76h,	18h, 20h, 0, 78h, 0CCh,	0FCh, 0C0h
		db 78h,	10h, 28h, 0, 78h, 0Ch, 7Ch, 0CCh, 76h, 0, 48h
		db 0, 78h, 0Ch,	7Ch, 0CCh, 76h,	30h, 8,	0, 78h,	0Ch, 7Ch
		db 0CCh, 76h, 48h, 30h,	0, 78h,	0Ch, 7Ch, 0CCh,	76h, 78h
		db 0CCh, 0C0h, 0CCh, 78h, 10h, 8, 2 dup(30h), 48h, 84h
		db 78h,	0CCh, 0FCh, 0C0h, 78h, 0, 48h, 0, 78h, 0CCh, 0FCh
		db 0C0h, 78h, 30h, 8, 0, 78h, 0CCh, 0FCh, 0C0h,	78h, 0
		db 48h,	0, 6 dup(30h), 48h, 0, 5 dup(30h), 60h,	10h, 0
		db 5 dup(30h), 48h, 0, 30h, 78h, 2 dup(0CCh), 0FCh, 0CCh
		db 30h,	48h, 30h, 48h, 84h, 0FCh, 2 dup(84h), 18h, 20h
		db 0, 0F8h, 80h, 0F0h, 80h, 0F8h, 3 dup(0), 66h, 19h, 77h
		db 88h,	77h, 3 dup(0), 0Fh, 14h, 3Eh, 44h, 87h,	30h, 48h
		db 84h,	78h, 3 dup(0CCh), 78h, 0, 48h, 0, 78h, 3 dup(0CCh)
		db 78h,	60h, 10h, 0, 78h, 3 dup(0CCh), 78h, 30h, 48h, 84h
		db 0, 3	dup(0CCh), 76h,	60h, 10h, 0, 4 dup(0CCh), 76h
		db 48h,	0, 3 dup(0CCh),	7Ch, 0Ch, 0F8h,	44h, 0,	38h, 6Ch
		db 2 dup(0C6h),	6Ch, 38h, 24h, 0, 5 dup(66h), 3Ch, 0, 8
		db 1Ch,	2 dup(28h), 1Ch, 8, 0, 1Ch, 22h, 20h, 70h, 20h
		db 22h,	5Ch, 0,	44h, 28h, 2 dup(10h), 38h, 10h,	38h, 10h
		db 0F0h, 88h, 8Ah, 0F7h, 2 dup(82h), 83h, 0, 6,	2 dup(8)
		db 3Ch,	2 dup(10h), 60h, 0, 18h, 20h, 0, 78h, 0Ch, 7Ch
		db 0CCh, 76h, 18h, 20h,	0, 5 dup(30h), 18h, 20h, 0, 78h
		db 3 dup(0CCh),	78h, 18h, 20h, 0, 4 dup(0CCh), 76h, 80h
		db 78h,	4, 0F8h, 4 dup(0CCh), 80h, 7Eh,	1, 0C6h, 0E6h
		db 0D6h, 0CEh, 0C6h, 0,	78h, 0Ch, 7Ch, 0CCh, 76h, 0, 0FEh
		db 0, 78h, 3 dup(0CCh),	78h, 0,	0FCh, 2	dup(0),	2 dup(18h)
		db 30h,	60h, 66h, 3Ch, 0FFh, 3 dup(80h), 4 dup(0), 0FFh
		db 3 dup(1), 4 dup(0), 40h, 0C4h, 48h, 50h, 26h, 49h, 82h
		db 7, 40h, 0C4h, 48h, 50h, 26h,	4Ah, 9Fh, 2, 0,	30h, 0
		db 5 dup(30h), 0, 12h, 24h, 48h, 90h, 48h, 24h,	12h, 0
		db 48h,	24h, 12h, 9, 12h, 24h, 48h, 49h, 0, 92h, 0, 49h
		db 0, 92h, 0, 6Dh, 0
		db 0B6h, 0, 6Dh, 0, 0B6h, 0, 0AAh, 55h,	0AAh, 55h, 0AAh
		db 55h,	0AAh, 55h, 0Ch dup(10h), 0F0h, 6 dup(10h), 0F0h
		db 10h,	0F0h, 2	dup(10h), 4 dup(28h), 0E8h, 3 dup(28h)
		db 4 dup(0), 0F8h, 3 dup(28h), 3 dup(0), 0F0h, 10h, 0F0h
		db 2 dup(10h), 3 dup(28h), 0E8h, 8, 0E8h, 0Ah dup(28h)
		db 3 dup(0), 0F8h, 8, 0E8h, 5 dup(28h),	0E8h, 8, 0F8h
		db 2 dup(0), 4 dup(28h), 0F8h, 3 dup(0), 3 dup(10h), 0F0h
		db 10h,	0F0h, 6	dup(0),	0F0h, 7	dup(10h), 1Fh, 3 dup(0)
		db 4 dup(10h), 0FFh, 7 dup(0), 0FFh, 7 dup(10h), 1Fh, 3	dup(10h)
		db 4 dup(0), 0FFh, 3 dup(0), 4 dup(10h), 0FFh, 6 dup(10h)
		db 1Fh,	10h, 1Fh, 2 dup(10h), 4	dup(28h), 3Fh, 6 dup(28h)
		db 2Fh,	20h, 3Fh, 5 dup(0), 3Fh, 20h, 2Fh, 5 dup(28h)
		db 0EFh, 0, 0FFh, 5 dup(0), 0FFh, 0, 0EFh, 5 dup(28h)
		db 2Fh,	20h, 2Fh, 2 dup(28h), 3	dup(0),	0FFh, 0, 0FFh
		db 2 dup(0), 3 dup(28h), 0EFh, 0, 0EFh,	2 dup(28h), 3 dup(10h)
		db 0FFh, 0, 0FFh, 2 dup(0), 4 dup(28h),	0FFh, 6	dup(0)
		db 0FFh, 0, 0FFh, 2 dup(10h), 4	dup(0),	0FFh, 7	dup(28h)
		db 3Fh,	3 dup(0), 3 dup(10h), 1Fh, 10h,	1Fh, 5 dup(0)
		db 1Fh,	10h, 1Fh, 2 dup(10h), 4	dup(0),	3Fh, 7 dup(28h)
		db 0FFh, 3 dup(28h), 3 dup(10h), 0FFh, 10h, 0FFh, 6 dup(10h)
		db 0F0h, 7 dup(0), 1Fh,	3 dup(10h), 8 dup(0FFh), 4 dup(0)
		db 3 dup(0FFh),	0, 8 dup(0E0h),	8 dup(7), 4 dup(0FFh)
		db 7 dup(0), 2,	34h, 2 dup(4Ch), 32h, 0, 5Ch, 2	dup(22h)
		db 3Ch,	2 dup(44h), 78h, 7Eh, 2	dup(42h), 5 dup(40h), 2	dup(0)
		db 2, 7Ch, 0A8h, 2 dup(28h), 44h, 0, 7Eh, 61h, 30h, 18h
		db 8, 10h, 20h,	2 dup(0), 8, 7Fh, 3 dup(88h), 70h, 3 dup(0)
		db 22h,	2 dup(44h), 7Ah, 80h, 3	dup(0),	7Ch, 4 dup(10h)
		db 0, 1Ch, 8, 3Eh, 3 dup(41h), 3Eh, 2 dup(0), 38h, 2 dup(44h)
		db 7Ch,	2 dup(44h), 3Ch, 66h, 3	dup(0C3h), 66h,	24h, 66h
		db 0Ch,	10h, 8,	1Ch, 3 dup(22h), 1Ch, 4	dup(0),	6Ch, 2 dup(92h)
		db 6Ch,	0, 1, 1Ah, 26h,	2Ah, 32h, 2Ch, 40h, 0, 18h, 2 dup(20h)
		db 30h,	2 dup(20h), 18h, 0, 3Ch, 6 dup(42h), 2 dup(0)
		db 7Eh,	0, 7Eh,	0, 7Eh,	2 dup(0), 2 dup(8), 3Eh, 2 dup(8)
		db 0, 3Eh, 0, 10h, 8, 4, 8, 10h, 0, 3Eh, 0, 4, 8, 10h
		db 8, 4, 0, 3Eh, 0, 6, 2 dup(9), 3 dup(8), 3 dup(0), 3 dup(8)
		db 2 dup(48h), 30h, 2 dup(0), 8, 0, 3Eh, 0, 8, 2 dup(0)
		db 60h,	92h, 0Ch, 60h, 92h, 0Ch, 0, 60h, 90h, 60h, 8 dup(0)
		db 30h,	78h, 30h, 6 dup(0), 20h, 4 dup(0), 3, 2	dup(4)
		db 0C8h, 28h, 10h, 4 dup(0), 7Ch, 3 dup(42h), 0, 18h, 24h
		db 8, 10h, 3Ch,	6 dup(0), 4 dup(3Eh), 9	dup(0)
