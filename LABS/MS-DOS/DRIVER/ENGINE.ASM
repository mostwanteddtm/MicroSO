                TITLE       engine
                
CODE            SEGMENT     PUBLIC 'CODE'
    
                ASSUME      CS:CODE, DS:CODE, Es:CODE, SS:CODE
                
                ORG         100h
                
START:          Mov         Dx, Offset Devnum                       ; open named device (ASY1)
                Mov         Ax, 3d02h
                Int         21h
                Mov         Handle, Ax
                jc          Quit
Alltim:         Call        Getmdm                                  ; main engine loop
                Call        Putcrt
                Call        Getkbd
                Call        Putmdm
                Jmp         Alltim
Quit:           mov         Ah, 4Ch                                 ; come here to quit
                Int         21h
                
Getmdm          Proc                                                ; get input from modem
                Mov         Cx, 256
                Mov         Bx, Handle
                Mov         Dx, Offset Mbufr
                Mov         Ax, 3F00h
                Int         21h
                Jc          Quit
                Mov         Mdlen, Ax
                Ret
Getmdm          Endp

GetKbd          Proc                                                ; get input from keyboard
                Mov         Kblen, 0                                ; first zero the count
                Mov         Ah, 11                                  ; key pressed?
                Int         21h
                Inc         Al
                Jnz         Nogk                                    ; no
                mov         Ah, 7                                   ; yes, get it
                Int         21h
                Cmp         Al, 3                                   ; was it Ctrl-C?
                Je          Quit                                    ; yes get out
                Mov         Kbufr, Al                               ; no, save it
                Inc         Kblen
                Cmp         Al, 13                                  ; was it Enter?
                Jne         Nogk                                    ; no
                Mov         Byte Ptr Kbufr+1, 10                    ; yes, add LF
                Inc         Kblen
Nogk:           Ret
Getkbd          Endp

Putmdm          Proc                                                ; put output to modem
                Mov         Cx, Kblen
                Jcxz        Nopm
                Mov         Bx, Handle
                Mov         Dx, Offset Kbufr
                Mov         Ax, 4000h
                Int         21h
                Jc          Quit
Nopm:           Ret
Putmdm          Endp

Putcrt          Proc                                                ; put output to CRT
                Mov         Cx, Mdlen
                Jcxz        Nopc
                Mov         Bx, 1
                Mov         Dx, Offset Mbufr
                Mov         Ah, 40h
                Int         21h
                Jc          Quit
Nopc:           Ret
Putcrt          Endp

Devnum          Db          'ASY1', 0                               ; miscellaneous data and buffers
Handle          Dw          0
Kblen           Dw          0
Mdlen           Dw          0
Mbufr           Db          256 DUP (0)
Kbufr           Db           80 DUP (0)

CODE            ENDS
                END         START