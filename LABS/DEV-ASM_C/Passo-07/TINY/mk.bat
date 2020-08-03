@ECHO OFF
rem compiles startup module

if exist ..\c0s.obj del ..\c0s.obj
if exist ..\c0t.obj del ..\c0t.obj

nasm c0.asm -fobj -o..\c0s.obj
nasm c0.asm -D__TINY__ -fobj -o..\c0t.obj
