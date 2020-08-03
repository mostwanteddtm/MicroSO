REM Compilacao Combinada entre Assembly e C
..\BIN\ML /AT /c arquivo.asm
..\BIN\CL /c /AT arquivoc.c
..\BIN\LINK /TINY /NOE CRTCOM.LIB ARQUIVO.OBJ ARQUIVOC.OBJ, ARQUIVO.COM,,,,
DEL *.OBJ 
ARQUIVO
PAUSE