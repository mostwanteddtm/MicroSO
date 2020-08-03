.286
.MODEL TINY 
.STACK
.CODE 

    ORG 100h
    
.STARTUP
     	        call    cls
                call    PS2SET
                call    ACTMOUS 
                
                mov     ch, 32
     	        mov     ah, 1
     	        int     10h
                
                mov     word ptr [offset pos_x], 305
                mov     word ptr [offset pos_y], 99
                call    show_mouse
				  		
getdata:     
                call    new_isr
                xor     ax, ax
                mov     ah, 11h
                int     16h
                jnz     quit
                
                jmp     getdata
                         
quit:           mov     ch, 6
             	mov     cl, 7
             	mov     ah, 1
             	int     10h
             	
             	call    cls
             	
                int     20h  
                
;##################################################################################################################################

new_isr:
                mov     word ptr [temp_mask], 0
        
                mov     cx, word ptr [offset pos_x]
                mov     dx, word ptr [offset pos_y]
        
                call    keyboard_read
                cmp     byte ptr [temp_data], 1
                je      has_data1
                ret
has_data1:
                mov     byte ptr [temp_data], 0  
                and     al, 7 ;3
                mov     ah, [buttons]
                mov     [buttons], al
                cmp     al, ah
                je      no_button_change
                and     al, 3
                and     ah, 3
                xor     al, ah
                xor     bx, bx
        
                push    ax
                test    al, 2
                jz      no_right_button_change
                and     ah, 2
                jz      right_button_pressed
                or      bx, 16
                jmp     no_right_button_change  
                
right_button_pressed:
                or      bx, 8
no_right_button_change:

                pop     ax
        
                test    al, 1
                jz      no_left_button_change
                and     ah, 1
                jz      left_button_pressed
                or      bx, 4
                jmp     no_left_button_change
                
left_button_pressed:
                or      bx, 2
no_left_button_change:

                mov     [temp_mask], bx

no_button_change: 

                call    keyboard_read
                cmp     byte ptr [temp_data], 1
                je      has_data2
                ret
has_data2:      
                mov     byte ptr [temp_data], 0             
                cbw
                add     word ptr [pos_x], ax
                add     word ptr [x_move], ax
                mov     ax, [x_min]
                cmp     word ptr [pos_x], ax
                jg      good_hor1
                mov     word ptr [pos_x], ax
good_hor1:
                mov     ax, [x_max]
                cmp     word ptr [pos_x], ax
                jle     good_hor2
                mov     word ptr [pos_x], ax
good_hor2:

                call    keyboard_read
                cmp     byte ptr [temp_data], 1
                je      has_data3
                ret
has_data3:      
                mov     byte ptr [temp_data], 0
                neg     al
                cbw
                add     word ptr [pos_y], ax
                add     word ptr [y_move], ax
                mov     ax, [y_min]
                cmp     word ptr [pos_y], ax
                jg      good_ver1
                mov     word ptr [pos_y], ax
good_ver1:
                mov     ax, [y_max]
                cmp     word ptr [pos_y], ax
                jle     good_ver2
                mov     word ptr [pos_y], ax
good_ver2:
                mov     ax, [x_move]
                or      ax, [y_move]
                or      ax, ax
                jz      no_change_position
                or      word ptr [temp_mask], 1

no_change_position:
                mov     ax, [temp_mask]
no_call_user:

                cmp     byte ptr [sm_flag], 1
                jne     no_show
        
                shr     cx, 3
                shr     dx, 3
                mov     ax, 80
                mul     dl
                add     ax, cx
                shl     ax, 1
                mov     di, ax
                mov     ax, 0B800h
                mov     es, ax
                mov     ax, word ptr [offset save_char]
                stosw

show_mouse:        
                mov     cx, word ptr [offset pos_x]
                mov     dx, word ptr [offset pos_y]
                shr     cx, 3
                shr     dx, 3
                mov     ax, 80
                mul     dl
                add     ax, cx
                shl     ax, 1
                mov     di, ax
                mov     ax, 0B800h
                mov     es, ax
                mov     ax, word ptr es:[di]
                mov     word ptr [save_char], ax
                not     ah
                and     ah, 7fh
                stosw
no_show:
        
                ret

;##################################################################################################################################				
				
keyboard_read:
                push    cx
                push    dx
                xor     cx,cx
key_read_loop:
                in      al, 64h
                jmp     $+2
                jmp     $+2
                test    al, 1
                jnz     key_read_ready
                loop    key_read_loop
                mov     ah, 1
                jmp     key_read_exit
key_read_ready:
                push    cx
                mov     cx, 32
key_read_delay:
                jmp     $+2
                jmp     $+2
                loop    key_read_delay
        
                pop     cx
        
                in      al, 60h
                jmp     $+2
                jmp     $+2 
                mov     byte ptr [temp_data], 1
                xor     ah,ah
key_read_exit:
                pop     dx
                pop     cx
                ret 
                
cls:
                mov     ah, 00h
                mov     al, 03h
                int     10h
                ret
                
;##################################################################################################################################

;***********************************************************************
;Activate mouse port (PS/2)
;***********************************************************************
PS2SET:
  mov  al, 0A8h		; enable mouse port
  out  64h, al		; write to keyboardcontroller
  call CHKPRT		; check if command is progressed (demand!)
ret

;***********************************************************************
;Check if command is accepted. (not got stuck in inputbuffer)
;***********************************************************************
CHKPRT:
  xor  cx, cx		
 .again:
  in   al, 64h		; read from keyboardcontroller
  test al, 2		; Check if input buffer is empty
  jz  continue
  jmp .again		; (demand!) This may couse hanging, use only when sure.
 continue:
ret

;***********************************************************************
;Write to mouse
;***********************************************************************
WMOUS:
  mov  al, 0D4h		; write to mouse device instead of to keyboard
  out  64h, al		; write to keyboardcontroller
  call CHKPRT		; check if command is progressed (demand!)
ret

;***********************************************************************
;mouse output buffer full
;***********************************************************************
MBUFFUL:
  xor  cx, cx
 .mn:
  in   al, 64h		; read from keyboardcontroller
  test al, 20h		; check if mouse output buffer is full
  jz  continue2
  loop .mn
 continue2:
ret


;***********************************************************************
;Write activate Mouse HardWare
;***********************************************************************
ACTMOUS:
  call WMOUS
  mov  al, 0F4h 	; Command to activate mouse itselve (Stream mode)
  out  60h, al		; write ps/2 controller output port (activate mouse)
  call CHKPRT		; check if command is progressed (demand!)
  call CHKMOUS		; check if a BYTE PTR is available
ret

;***********************************************************************
;Check if mouse has info for us
;***********************************************************************
CHKMOUS:
  mov  bl, 0
  xor  cx, cx
 .vrd:
  in   al, 64h		; read from keyboardcontroller
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
  mov  al, 0ADh		; Disable Keyboard
  out  64h, al		; write to keyboardcontroller
  call CHKPRT		; check if command is progressed (demand!)
ret

;***********************************************************************
;Enable Keyboard
;***********************************************************************
EKEYB:
  mov  al, 0AEh		; Enable Keyboard
  out  64h, al		; write to keyboardcontroller
  call CHKPRT		; check if command is progressed (demand!)
ret

;##################################################################################################################################

first_time      db      0
buttons         db      0
pos_x           dw      0
pos_y           dw      0
sm_flag         dw      1
save_char       dw      0
x_move          dw      0
y_move          dw      0
x_max           dw      639
x_min           dw      0
y_max           dw      199
y_min           dw      0
user_subroutine dw      0,0
user_mask       dw      0
temp_mask       dw      0
temp_data       db      0

END
