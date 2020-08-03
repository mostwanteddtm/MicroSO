;https://board.flatassembler.net/topic.php?t=14914

;************************************** 
; First written for tasm 
; Converted for fasm 
; Assemble with fasm 
; C:\fasm FirstOS.asm FirstOS.com 
;************************************** 
org     100h                            ; code starts at offset 100h 
        use16                           ; use 16-bit code 
        jmp   start 
CR              EQU     13 
LF              EQU     10 
EOS             EQU     0 
; *** Macros *** 
;------------------------------------------- 
; Fade the text in and out 
;------------------------------------------- 
Macro   Text_Stuff 
{ 
        mov     dx,3C8h 
        mov     al,100                  ; Color reg 100 
        out     dx,al 
        inc     dx                      ; DX = Color data 
        xor     al,al 
        out     dx,al                   ; R = 0 
        mov     ah,Byte[ds:Text_Color] 
        mov     al,ah 
        shr     al,2                    ; Color / 4 
        out     dx,al                   ; G 
        mov     al,ah 
        out     dx,al                   ; B 

        cmp     Byte[ds:Fade_Dir],1 
        je      @@800 

; Fade up (INC) 
        inc     al 
        cmp     al,62 
        jne     @@990 
        inc     Byte[ds:Fade_Dir]      ; Set fade down flag (1) 
        jmp     @@990 


; Fade down (DEC) 
@@800:  sub     al,2 
        jnz     @@990 
        dec     Byte[ds:Fade_Dir] 

@@990:  mov     Byte[ds:Text_Color],al 
} 
;------------------------------------------- 
; Draw the frame buffer to the screen 
;------------------------------------------- 
Macro   Draw_Flame 
{ 
        mov     al,Byte[ds:Y_Len] 
        cmp     al,94 
        je      @@105 
        inc     al 
        cmp     al,1 
        mov     Byte[ds:Y_Len],al 
        jge     @@105 
        jmp     Return 


@@105:  cmp     Word[ds:Flame_Ofs],320 * (200-94) + 4 
        je      @@205 
        sub     Word[ds:Flame_Ofs],320 

@@205:  mov     Word[ds:Temp],Frame + 104 
        mov     di,Word[ds:Flame_Ofs] 
        mov     bl,Byte[ds:Y_Len] 
        xor     eax,eax 

Line_Loop: 
        mov     cx,3                    ; Draw 3 copies 

@@305:  push    cx 
        mov     si,Word[ds:Temp]       ; Display First image 
        mov     cx,104/4 
        rep     movsd 
        pop     cx 
        loop    @@305 

        xor     eax,eax 
        stosd 
        stosd 
        add     Word[ds:Temp],104      ; Next line 
        dec     bl 
        jnz     Line_Loop 
Return: 
} 
;------------------------------------------- 
; Calculate the next frame buffer 
;------------------------------------------- 
Macro   Calc_Flame 
{ 
        mov     si,Frame + 104 - 3 
        mov     cx,104 * (94+9-2) 

@@101:  mov     al,Byte[ds:si+2*104]   ; Each point is set as the average of 
        mov     bl,Byte[ds:si]         ; four pixels to the left below it. 
        add     ax,bx 
        mov     bl,Byte[ds:si+1] 
        sub     ax,3 
        add     ax,bx 
        mov     bl,Byte[ds:si+104] 
        add     ax,bx 

        sar     ax,2 
        jge     @@201 
        xor     ax,ax 

@@201:  mov     Byte[ds:si-104 + 3],al 
        inc     si 
        loop    @@101 


; Setup botom line with random numbers 
        mov     si,Frame+104*(94+9-2) 
        mov     cx,104 
        xor     dx,dx 

@@301:  call    Random 
        or      ax,ax 
        js      @@401 
        call    Random 

@@401:  sub     al,35   
        mov     Byte[ds:si+104+3],al 
        and     al,07fh 
        mov     Byte[ds:si],al 
        add     si,2 
        loop    @@301 
} 
;------------------------------ 
; Wait for the start of VR 
;------------------------------ 
Macro   Wait_VR 
{ 
        mov     dx,3DAh 
@@100:  in      al,dx 
        test    al,8 
        je      @@100 
@@110:  in      al,dx 
        test    al,8 
        jne     @@110 
} 
;************************ 
; Main loop starts here * 
;************************ 

start:  push    cs                      ; DS = ES = Data in code seg 
        pop     ds 
        push    cs 
        pop     es 
        mov     ax,13h                  ; 320 X 200 , 256 colors 
        int     10h 
        cld 


; Clear variables 
        mov     di,Frame 
        mov     cx,(104*104*2) / 4 
        xor     eax,eax 
        rep     stosd 


; Create fire palette 
        mov     di,Palette 
        xor     al,al 

        mov     cx,6                    ; Black to blue  (CH = ZERO!) 
        mov     bx,0102h 
        mov     dx,0002h 
        call    Make_Pal 


; Darkblue to midblue 
        mov     cl,10 
        xor     ah,ah                   ; I = 0 

@@10:   stosb                           ; R 
        stosb                           ; G 
        mov     bl,14 
        sub     bl,ah                   ; B = 14 - I 
        mov     Byte [ds:di],bl         ; Store I (B) 
        inc     di 
        inc     ah                      ; I = I+1 
        loop    @@10 
         
         
        mov     cl,24                   ; Midblue to brightblue 
        mov     bx,182Fh 
        mov     dx,0010h 
        call    Make_Pal 


        mov     cl,32                   ; Brightblue to lightblue/cyan 
        mov     bx,101Fh 
        mov     dx,0100h 
        call    Make_Pal 


; Setup palette 
        mov     si,Palette 
        mov     cl,72*3 
        mov     dx,3C8h 
        xor     al,al 
        out     dx,al 
        inc     dx 
        rep     outsb 


; Write string 
        mov     ax,1300h 
        mov     bx,0064h 
        mov     cl,Byte[ds:Len_String] 
        mov     dl,Byte[ds:String_Start] 
        mov     dh,0Ah 
        mov     bp,String 
        int     10h 

        push    0A000h                  ; ES = Video RAM 
        pop     es 

        mov   cx,350 ;1000                   ; time lenth 
Main_Loop: 
        push  cx 
        Wait_VR 
        Text_Stuff 
        Draw_Flame 
        Calc_Flame 
        pop  cx 
        dec  cx 
        cmp  cx,0 
        jne  Main_Loop 
  
; Exit         
        mov     ax,03h                  ; Set text mode 
        int     10h 
        mov     ax,04C00h 
        int     21h 


;------------------------------ 
; Make one shade 
;------------------------------ 
; In :  CX = Number of colors 
;       BL = * 
;       BH = / 
;       DH = 0 or 1 
;       AL Must be zero 
;------------------------------ 
Make_Pal: 
        xor     ah,ah                   ; AH = I 

@@10a:  push    ax 
        stosb                           ; Red 
        stosb                           ; Green 
        mov     al,ah                   ; AL = I 
        mul     bl                      ; AX = AL * BL (I*BL) 
        div     bh                      ; AL = AX / BH (I/BH) 
        add     al,dl                   ; AL = I + DL 

        or      dh,dh 
        jz      @@20 
        dec     di                      ; Write Green innsted 
        stosb 
        mov     al,63                   ; B = 63 

@@20:   stosb 
        pop     ax 
        inc     ah                      ; I = I+1  
        loop    @@10a 

        ret 

;------------------------------ 
; AX = "Random" number 
;------------------------------ 
Random: 
        mov     ax,Word[ds:Seed] 
        imul    ax,8905h 
        inc     ax 
        mov     Word[ds:Seed],ax 

        ret 


;------------------------------ 
; Boot program data 
;------------------------------ 
       
Seed            dw      4321h           ; Random seed 
Flame_Ofs       dw      320*200 + 4 


String           db       '         WELCOME TO MiniDOS!          ' 
                        
Len_String      dw      38 
String_Start    db      1 


; The rest of memory is unused so we can use it for our buffers 
Frame           =       $               ; 104*(94+9) Words 
Temp            =       $ + (104*103)*2 ; Word 
Y_Len           =       Temp + 2        ; Byte 
Text_Color      =       Y_Len + 1       ; Byte 
Fade_Dir        =       Text_Color + 1  ; Byte 
Palette         =       Fade_Dir + 1    ; 72 * 3 Bytes 
;------------------------------ 
; Boot program End 
;------------------------------ 