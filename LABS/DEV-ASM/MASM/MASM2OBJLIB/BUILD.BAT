rem --usando masm32
.\BUILD\ML.EXE /c /AT function.asm
.\BUILD\ML.EXE /c /AT main.asm
.\BUILD\LIB.EXE -c main.lib main.obj function.obj
.\BUILD\LINK16.EXE /TINY main.lib