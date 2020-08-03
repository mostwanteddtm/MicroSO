rem --usando masm32
ml.exe /c /AT function.asm
ml.exe /c /AT main.asm
link /TINY main.obj function.obj, program.com,,,,