SET PATH=C:\MASM615\BIN
ML /AT /c FORMAT.ASM
LINK /TINY FORMAT.OBJ, FORMAT.COM,,,,
DEL *.OBJ *.MAP
PAUSE