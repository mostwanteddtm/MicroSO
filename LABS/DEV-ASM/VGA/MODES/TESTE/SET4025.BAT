SET ISC=1

IF %ISC% == 1 (

	SET PATH=C:\TC101\BIN
	SET INCLUDE=C:\TC101\INCLUDE
	SET LIB=C:\TC101\LIB

	TCC SET4025.C
	PAUSE
	
	GOTO END

)

SET PATH=C:\MASM615\BIN

ML SET4025.ASM

PAUSE

:END
COPY SET4025.EXE A:
PAUSE