.model tiny
.code

first:
jmp Main
Main:
cli
hlt

db (510 - ($ - first)) dup (0) 
dw 0AA55h




