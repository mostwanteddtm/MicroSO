COPY ..\C0T.OBJ C0T.OBJ
..\NASM TESTA.ASM -s -fobj
..\TCC.EXE -1 -K- -k -ms -N- -c -w- -v -y TESTC.C

