name "psmouse"

ORG 100h 

        jmp start

        PS2SET:
          mov  al, 0xa8		; enable mouse port
          out  0x64, al		; write to keyboardcontroller
          call CHKPRT		; check if command is progressed (demand!)
        ret
        
        ;***********************************************************************
        ;Check if command is accepted. (not got stuck in inputbuffer)
        ;***********************************************************************
        CHKPRT:
          xor  cx, cx		
         .again:
          in   al, 0x64		; read from keyboardcontroller
          test al, 2		; Check if input buffer is empty
          jz  continue
          jmp .again		; (demand!) This may couse hanging, use only when sure.
         continue:
         ret
        ;***********************************************************************
        ;Write activate Mouse HardWare
        ;***********************************************************************
        ACTMOUS:
          call WMOUS
          mov  al, 0xf4 	; Command to activate mouse itselve (Stream mode)
          out  0x60, al		; write ps/2 controller output port (activate mouse)
          call CHKPRT		; check if command is progressed (demand!)
          call CHKMOUS		; check if a BYTE PTR is available
        ret
        ;***********************************************************************
        ;Write to mouse
        ;***********************************************************************
        WMOUS:
          mov  al, 0xd4		; write to mouse device instead of to keyboard
          out  0x64, al		; write to keyboardcontroller
          call CHKPRT		; check if command is progressed (demand!)
        ret
        
        ;***********************************************************************
        ;Check if mouse has info for us
        ;***********************************************************************
        CHKMOUS:
          mov  bl, 0
          xor  cx, cx
         .vrd:
          in   al, 0x64		; read from keyboardcontroller 
          test al, 1		; check if controller buffer (60h) has data
          jnz .yy
          loop .vrd
          mov  bl, 1
         .yy:
        ret 
        
        ;***********************************************************************
        ;Disable Keyboard
        ;***********************************************************************
        DKEYB:
          mov  al, 0xad		; Disable Keyboard
          out  0x64, al		; write to keyboardcontroller
          call CHKPRT		; check if command is progressed (demand!)
        ret
        
        ;***********************************************************************
        ;Enable Keyboard
        ;***********************************************************************
        EKEYB:
          mov  al, 0xae		; Enable Keyboard
          out  0x64, al		; write to keyboardcontroller
          call CHKPRT		; check if command is progressed (demand!)
        ret
        
        ;***********************************************************************
        ;Get Mouse BYTE PTR
        ;***********************************************************************
        GETB:
         cagain:
          call CHKMOUS		; check if a BYTE PTR is available
          or   bl, bl
          jnz cagain
          call DKEYB		; disable keyboard to read mouse BYTE PTR
          xor  ax, ax
          in   al, 0x60		; read ps/2 controller output port (mouseBYTE PTR)
          mov  dl, al
          call print 
          call EKEYB		; enable keyboard
          mov  al, dl
        ret
        
start:   
         call PS2SET
         call ACTMOUS
         
         
get:     call GETB
         
         xor  ax, ax
         mov  ah, 11h
         int  16h
         jnz quit
    
         jmp get
         
quit:    int 20h 

print: 
        push    ax
        cmp     al, dados
        je      return
        mov     dados, al
        mov     cx, 8
        mov     bl, al
cont:   xor     ax, ax
        rcl     bl, 1
        adc     al, 30h
        mov     ah, 0eh
        int     10h
        loop    cont
        
        mov     ah, 0Eh
        mov     al, ' '
        int     10h
        
return: pop     ax
        ret 
        
dados   db 0