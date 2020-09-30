del *.lib
cwsdpmi
nasm c0s.asm -f obj
nasm CONIOA.ASM -f obj
lib conio.lib +conio.obj +CONIOA.obj, conio.lib
rem TCC -ms -c -w- conio.c
rem TCC -ms -c -w- main.c
CL /G2 /Gs /c /Zl conio.c
CL /G2 /Gs /c /Zl main.c /link conio/NOD
rem TLINK /c main c0s, main.exe,,
LINK /NOD main c0s CONIO! conio, main.exe,,,,
