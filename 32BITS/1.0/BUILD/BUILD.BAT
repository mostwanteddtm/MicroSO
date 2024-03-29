FORMAT A: /Y /q
DEL FAT12.BIN KRNLDR.SYS
SET PATH=..\TOOLS;
SET INCLUDE=C:\MSVC20\INCLUDE;C:\MSVC20\MFC\INCLUDE
SET LIB=C:\MSVC20\LIB;C:\MSVC20\MFC\LIB
SET PATHC=C:\MSVC20\BIN\
SET DEBUGKERNEL=0

SET PATH_BOOT=..\BOOT\
SET PATH_KERNEL=..\KERNEL\
SET PATH_DEBUG=..\DEBUG\
SET PATH_LIB=..\LIB\
SET PATH_INCLUDE=..\INCLUDE\

SET IMAGE_NAME=KRNL32.EXE

ML /AT %PATH_BOOT%FAT12.ASM
ML %PATH_KERNEL%KRNLDR.ASM
ML /c %PATH_DEBUG%FUNCTION.ASM

REN FUNCTION.OBJ FUNCASM.OBJ
REN FAT12.COM FAT12.BIN
REN KRNLDR.EXE KRNLDR.SYS

IF %DEBUGKERNEL% == 0 (

	%PATHC%CL /O2 /I %PATH_INCLUDE% /D "ARCH_X86" /X /MT /Zp1 /FAs /W4 /c /Gd /Oy %PATH_KERNEL%CRT0.CPP
	%PATHC%CL /O2 /I %PATH_INCLUDE% /D "ARCH_X86" /X /MT /Zp1 /FAs /W4 /c /Gd /Oy %PATH_DEBUG%FUNCTION.CPP
	%PATHC%CL /O2 /I %PATH_INCLUDE% /D "ARCH_X86" /X /MT /Zp1 /FAs /W4 /c /Gd /Oy %PATH_KERNEL%MAIN.CPP
	
	%PATHC%LIB /OUT:%PATH_LIB%MICROSO.LIB FUNCASM.OBJ FUNCTION.OBJ 

	%PATHC%LINK /OUT:%IMAGE_NAME% /INCREMENTAL:NO /NODEFAULTLIB /MAP:"KERNEL.MAP" /SUBSYSTEM:NATIVE /OPT:REF /ENTRY:"mainCRTStart" /BASE:"0x100000" /ALIGN:512 %PATH_LIB%MICROSO.LIB CRT0.OBJ MAIN.OBJ

) ELSE (
	ML ..\KERNEL\KRNL32.ASM
)

IF "%PROCESSOR_ARCHITECTURE%" == "x86" (
	PARTCOPY FAT12.BIN 0 200 -f0
) ELSE (
	DD if=fat12.bin of=\\.\A: bs=512 count=1
)

COPY KRNLDR.SYS A:\
COPY KRNL32.EXE A:\
PAUSE
DEL *.OBJ *.ASM *.SYS *.BIN *.EXE *.MAP