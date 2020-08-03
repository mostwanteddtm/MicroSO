rem --usando Masm 6.15
ml /c /AT function.asm
ml /c /AT main.asm
lib main.lib +main.obj +function.obj,,
link /TINY main.lib,main.com,,,,