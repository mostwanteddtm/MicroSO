SET PATH="C:\PROGRAM FILES\WINIMAGE";"C:\PROGRAM FILES\QEMU";"C:\MASM615\BIN"
SET IMAGE="C:\PROGRAM FILES\QEMU\IMAGES\PACKETDRV.IMG"
SET CURRENT=.\
SET EXECUTE="C:\PROGRAM FILES\QEMU\IMAGES"
PUSHD %cd%
WINIMAGE %IMAGE% /I /Q /H NE2000.COM
CD %EXECUTE%
PACKETDRV