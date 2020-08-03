Set oShell = CreateObject ("Wscript.Shell") 
Dim strArgs
strArgs = "cmd /c C:\MicroSO\trunk\LABS\COMPILE\vfd21-080206\vfd.bat"
oShell.Run strArgs, 0, FALSE