SET PATH=C:\MASM615\BIN;C:\PROGRAM FILES\WINIMAGE;C:\PROGRAM FILES\QEMU;
SET IMAGE="C:\PROGRAM FILES\QEMU\images\msdos\msdos.img"
PUSHD %cd%

ML /c *.ASM

WINIMAGE %IMAGE% /I /Q /H %cd%\MAIN.C
WINIMAGE %IMAGE% /I /Q /H %cd%\READCFG.C
WINIMAGE %IMAGE% /I /Q /H %cd%\RTL8139.C
WINIMAGE %IMAGE% /I /Q /H %cd%\RTL8139.H
WINIMAGE %IMAGE% /I /Q /H %cd%\COMMON.H
WINIMAGE %IMAGE% /I /Q /H %cd%\IODW.OBJ
WINIMAGE %IMAGE% /I /Q /H %cd%\PRINTDW.OBJ
WINIMAGE %IMAGE% /I /Q /H %cd%\MAIN.CFG
CD "C:\PROGRAM FILES\QEMU\IMAGES\MSDOS\"
MSDOS