CL.EXE /AT /G2 /Gs /Gx /c /Zl *.cpp
pause

ML.EXE /AT /c kernel.asm 
pause

LINK.EXE /T /NOD kernel.obj bootmain.obj cdisplay.obj 
pause
