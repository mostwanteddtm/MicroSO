.286
.model tiny,c
.stack 100						   
 _Text SEGMENT PUBLIC USE16 
    Power2 PROTO C factor:SWORD,power:SWORD
.code 
Power2 PROC C factor:SWORD,power:SWORD
  mov ax, factor
  mov cx, power
  shl ax, cl	
  ret
     
Power2 ENDP

END