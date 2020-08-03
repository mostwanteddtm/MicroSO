_Text SEGMENT PUBLIC USE16
    assume CS:_Text, DS:_Text
    org 0h

EntryPoint:
    dw  OFFSET AfterData, 07C00h

   AfterData: 
        push CS
        pop  DS
    
        mov ah, 00h
        int 16h

   org 510    
                                                                                     
   dw 0AA55h  

_Text ENDS
END EntryPoint