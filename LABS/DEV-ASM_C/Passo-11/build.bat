.\VC152\ML.EXE /c /AT c0t.asm stdioa.asm
.\TC101\BIN\TCC.EXE -1 -K- -k -ms -N- -c -w- -v -y *.c
.\VC152\LINK.EXE /TINY c0t.obj main.obj stdio.obj stdioa.obj, arquivo.com,,,,
DEL *.map *.obj
PAUSE