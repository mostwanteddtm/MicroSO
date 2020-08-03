rem Compilacao Combinada entre Assembly e C

ml /AT /c arquivo.asm
pause

CL /I ..\MSVC15\include /c /AT arquivoc.c
pause

LINK /TINY /NOE CRTCOM.LIB arquivo.obj arquivoc.obj, arquivo.com
pause