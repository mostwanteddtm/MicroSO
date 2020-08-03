@echo off
rem tested with TASM 3.2 and TASM 5.0
cls
tasm /m2 /mx /o /t kernel.asm
tlink /3 /x kernel.obj
