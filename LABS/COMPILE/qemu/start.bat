pushd %~dp0
set script_dir=%CD%
%CD%\qemu.exe -L . -boot c -m 32 -drive file=\\.\PhysicalDrive1,if=ide,index=0,media=disk