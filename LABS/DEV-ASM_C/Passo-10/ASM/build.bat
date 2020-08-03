..\ml.exe /c /AT function.asm
..\ml.exe /c /AT main.asm
..\link16.exe /TINY main.obj function.obj, MAIN.COM,,,,
DEL *.OBJ *.MAP
PAUSE