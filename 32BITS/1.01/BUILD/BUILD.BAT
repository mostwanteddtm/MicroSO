FORMAT A: /Y
SET PATH=C:\MASM615\BIN
SET BOOT_DIR=..\BOOT\
SET TOOLS_DIR=..\TOOLS\
SET KERNEL_DIR=..\KERNEL\
ML /AT /c %BOOT_DIR%FAT12.ASM
LINK /NOD /TINY FAT12.OBJ, FAT12.BIN,,,,
ML /c %KERNEL_DIR%KERNEL.ASM
LINK /NOD KERNEL.OBJ, KERNEL.SYS,,,,
%TOOLS_DIR%DD if=fat12.bin of=\\.\A: bs=512 count=1
COPY KERNEL.SYS A:
PAUSE
DEL *.OBJ *.MAP *.BIN *.SYS