ML /AT /c WRCOM.ASM
LINK /TINY WRCOM.OBJ, WRCOM.COM,,,,
ML /AT /c RDCOM.ASM
LINK /TINY RDCOM.OBJ, RDCOM.COM,,,,
ML /AT /c READCOM2.ASM
LINK /TINY READCOM2.OBJ, READCOM2.COM,,,,
DEL *.OBJ *.MAP
COPY /Y READCOM2.COM A:\