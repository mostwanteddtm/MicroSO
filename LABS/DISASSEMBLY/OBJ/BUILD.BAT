CL /AT /c TESTE.C
LINK /NOE /TINY CRTCOM.LIB TESTE.OBJ, TESTE.COM,,,,
ML /AT /c ARQUIVO.ASM
LINK /NOE /TINY CRTCOM.LIB ARQUIVO.OBJ,ARQUIVO.COM,,SLIBCE.LIB,,
REN ARQUIVO.obj ARQUIVO.OBJ
REN TESTE.obj TESTE.OBJ
DEL *.MAP
PAUSE
