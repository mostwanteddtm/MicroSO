SET PATH=C:\MASM300
for %%a in (*.asm) do masm %%a;
link @xt286lnk
COPY XT286.EXE A:
pause