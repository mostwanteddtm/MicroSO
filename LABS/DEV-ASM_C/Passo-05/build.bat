CL.EXE /AT /G2 /Gs /Gx /c /Zl *.cpp
pause

ML.EXE /AT /c boot.asm 
pause

LINK.EXE /T /NOD boot.obj bootmain.obj cdisplay.obj 
pause
