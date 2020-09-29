cwsdpmi
nasm c0s.asm -f obj
nasm CONIO!.ASM -f obj
TCC -1 -K -k -ms -N- -c -w- -v- -y- conio.c
TCC -1 -K -k -ms -N- -c -w- -v- -y- main.c
TLINK /c main c0s CONIO! conio, main.exe,,