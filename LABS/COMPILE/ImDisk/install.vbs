dim objShell
Set oShell = CreateObject("Shell.Application")
oShell.ShellExecute "imdisk.lnk", , "C:\MicroSO\trunk\LABS\COMPILE\ImDisk\", "runas", 0
WScript.Quit