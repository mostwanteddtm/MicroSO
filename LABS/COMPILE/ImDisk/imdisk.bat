SET DIRETORIO=C:\MicroSO\trunk\LABS\COMPILE\ImDisk\
REG QUERY HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Run /v ImDisk
IF %ERRORLEVEL% EQU 0 GOTO EXISTS
REG ADD HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Run /v ImDisk /t REG_SZ /d %DIRETORIO%install.vbs
:EXISTS
imdisk.exe -a -s 1440K -m A:
format a: /Y