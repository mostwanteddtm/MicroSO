rem Compilacao Combinada entre Assembly e C

CL.EXE /AT /G2 /Gs /Gx /c /Zl arquivoc.cpp
pause

ml /c arquivo.asm
pause

LINK /NOD arquivo.obj arquivoc.obj, arquivo.com
pause