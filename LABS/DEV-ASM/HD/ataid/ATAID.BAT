SET PATH=C:\MASM615\BIN\
ML /AT /c ATAID.ASM
LINK /NOD /TINY ATAID.OBJ, ATAID.COM,,,,
DEL *.OBJ *.MAP
PAUSE