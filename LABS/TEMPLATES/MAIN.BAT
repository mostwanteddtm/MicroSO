SET PATH=C:\MSVC152\BIN;C:\MASM615\BIN;
SET INCLUDE=C:\MSVC152\INCLUDE
SET LIB=C:\MSVC152\LIB;C:\MSVC152\MFC\LIB
ML /AT /c *.ASM
LINK /TINY MAIN.OBJ PUBLIC.OBJ, TEMPLATEA.COM,,,,
DEL MAIN.OBJ
CL /AT /G2 /Gs /Gx /c /Zl *.C
LINK /TINY C0T.OBJ MAIN.OBJ BASE.OBJ PUBLIC.OBJ, TEMPLATEC.COM,,,,
DEL *.MAP *.OBJ
TEMPLATEA
TEMPLATEC
PAUSE