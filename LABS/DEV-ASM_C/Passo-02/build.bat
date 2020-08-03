ML /c /AT function.asm
ML /c /AT main.asm
.\BUILD\lib.exe -c main.lib main.obj function.obj
.\BUILD\link16.exe /TINY main.lib, main.com,,,,
DEL *.MAP *.OBJ *.BAK
MAIN
PAUSE
