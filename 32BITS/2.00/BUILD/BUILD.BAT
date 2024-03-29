SET PATH=..\TOOLS;
SET INCLUDE=C:\MSVC20\INCLUDE;C:\MSVC20\MFC\INCLUDE
SET LIB=C:\MSVC20\LIB;C:\MSVC20\MFC\LIB
SET PATHC=C:\MSVC20\BIN\

SET PATH_BOOT=..\BOOT\
SET PATH_KERNEL=..\KERNEL\
SET PATH_DEBUG=..\DEBUG\
SET PATH_LIB=..\LIB\
SET PATH_INCLUDE=..\INCLUDE\

SET IMAGE_NAME=KERNEL32.EXE

IF NOT EXIST %PATH_LIB%MICROSO.LIB (
	MKDIR %PATH_LIB%
)

ML /AT /c %PATH_BOOT%FAT32.ASM
ML /c %PATH_KERNEL%KERNEL.ASM
ML /c %PATH_DEBUG%FUNCTION.ASM

LINK /TINY /NOD FAT32.OBJ, FAT32.BIN,,,,
LINK /NOD KERNEL.OBJ, KERNEL.SYS,,,,
REN FUNCTION.OBJ FUNCASM.OBJ

%PATHC%CL /O2 /I %PATH_INCLUDE% /D "ARCH_X86" /X /MT /Zp1 /FAs /W4 /c /Gd /Oy %PATH_KERNEL%CRT0.CPP
%PATHC%CL /O2 /I %PATH_INCLUDE% /D "ARCH_X86" /X /MT /Zp1 /FAs /W4 /c /Gd /Oy %PATH_DEBUG%FUNCTION.CPP
%PATHC%CL /O2 /I %PATH_INCLUDE% /D "ARCH_X86" /X /MT /Zp1 /FAs /W4 /c /Gd /Oy %PATH_KERNEL%MAIN.CPP

%PATHC%LIB /OUT:%PATH_LIB%MICROSO.LIB FUNCASM.OBJ FUNCTION.OBJ 

%PATHC%LINK /OUT:%IMAGE_NAME% /INCREMENTAL:NO /NODEFAULTLIB /MAP:"KERNEL.MAP" /SUBSYSTEM:NATIVE /OPT:REF /ENTRY:"mainCRTStart" /BASE:"0x100000" /ALIGN:512 %PATH_LIB%MICROSO.LIB CRT0.OBJ MAIN.OBJ

DEL *.OBJ *.ASM *.MAP
PAUSE
