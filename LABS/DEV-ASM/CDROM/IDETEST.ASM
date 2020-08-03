;========= IDE test ================= 
;=========== time: 2008.08.20  
;writed by vincent_wu 
 
;  ====  output strings 
PRINTSTR    MACRO X 
	LEA	DX,X 
	MOV	AH,09H 
	INT	21H 
	    ENDM 
 
.model small 
.586 
.stack 	 100  
 
.data   	 
        no1             equ     512 
        no2             equ     256	 
	pri_cntl        equ     03f6h 
	sec_cntl        equ     0376h 
	pri_dev         equ     1f6h 
	pri_cmdsta      equ     1f7h 
	sec_dev         equ     176h 
	sec_cmdsta      equ     177h 
	pri_data        equ     1f0h 
	sec_data        equ     170h 
	 
	IdenData        dw      256 dup(0) 
	FirSecData      dw      256 dup(0) 
	 
	 
	 
	 
	;show the choose info 
	EnterS	DB	10,13,'$' 
	ChooseMenu      db      'press 1 to choose ATA or press 2 to choose ATAPI$' 
	serialinfo      db      'Serial number:  $' 
	Modelinfo       db      'Model number:  $' 
	secsize         db      'Sector size:  $' 
	info_ide        db      'show the first sector of HD: $' 
	info_audio      db      'begin to listen music ~~~~~~~~~~$' 
	error1          db      'No HD found!!!$' 
	error2          db      'No CD-ROM found!!!$' 
	memusting       db      'choose: 1.ata, 2.atapi, 3.exit $' 
	reinput         db      'your input is error, please input again!!!$' 
	space1          db      ' $' 
.code 
.startup 
 
                printstr        memusting 
                printstr        enters 
input1:         mov     ah,07h 
                int     21h 
                cmp     al,'1' 
                jz      ata 
                cmp     al,'2' 
                jz      atapi 
                cmp     al,'3' 
                jz      exit3 
                printstr        reinput 
                printstr        enters 
                jmp     input1 
                 
ata:             
                call    checkIDE 
                ;============ read first sector ========================== 
                call    readfirstsector 
                call    showfirstsector 
                ;============== check the cd-rom ================== 
                jmp     input1 
atapi:          call    checkATAPI 
                jmp     input1 
exit3:          nop 
                 
.exit    
 
checkIDE        proc    far     public 
                 
                push    dx 
                push    ax 
                push    si 
                push    di 
                 
                lea     si,IdenData             ; 
                lea     di,FirSecData           ; 
 
pri_master:     mov     dx,pri_cntl     ; 
                mov     al,04h          ;reset channel 
                out     dx,al 
                out     0ebh,al 
                mov     al,00h 
                out     dx,al           ;reset complete 
                mov     dx,pri_dev 
                mov     al,0a0h         ;master 
                out     dx,al 
                mov     dx,pri_cmdsta 
                in      al,dx 
                test    al,40h          ;test bit6 = 1 
                jz      exit1 
                call    storeidendata 
                call    showiden                 
                pop     di 
                pop     si 
                pop     ax 
                pop     dx 
                ret 
 
exit1:          printstr        error1  
                printstr        enters 
                pop     di 
                pop     si 
                pop     ax 
                pop     dx 
                ret 
checkIDE        endp    
 
storeidendata   proc    far     public 
                 
                push    cx 
                push    bx 
                                 
                mov     dx,pri_cmdsta 
@@:             in      al,dx 
                test    al,88h           ;device busy and data req? 
                jnz      @b 
 
                mov     al,0ech 
                out     dx,al           ;identify cmd 
@@:             in      al,dx 
                test    al,08h          ;data req? 
                jz      @b 
                 
                ;start transfor data 
                mov     cx,no2          ;256 
                mov     dx,pri_data 
                mov     bx,0 
@@:             in      ax,dx 
                mov     [si+bx],ax 
                add     bx,2 
                loop    @b 
                 
                pop    bx 
                pop    cx 
                ret 
storeidendata  endp 
 
readfirstsector proc    far     public 
 
                push    bx 
                push    cx 
                push    di 
                 
                lea     di,firsecdata 
                mov     bx,0 
                 
                mov     dx,pri_cntl     ; 
                mov     al,04h          ;reset channel 
                out     dx,al 
                out     0ebh,al 
                mov     al,00h 
                out     dx,al           ;reset complete 
                mov     dx,pri_dev 
                mov     al,0a0h         ;master 
                out     dx,al 
 
@@:	        mov	dx,1f7h 
	        in	al,dx 
	        cmp	al,50h 
	        jnz	@b 
 
	        mov	dx,1f2h 
	        mov	al,1	;READ	1	SECTOR	 
	        out	dx,al 
	        inc	dx 
	        mov	al,0 
	        out	dx,al	;1f3 
	        inc	dx 
	        out	dx,al	;1f4 
	        inc	dx 
	        out	dx,al	;1f5 
	        inc	dx 
	        mov	al,0e0h 
	        out	dx,al	;1f6 
	        inc	dx 
	        mov	al,20h 
	        out	dx,al	;1f7 
	        in	al,dx			;ready 
	 
@@:	        mov	dx,1f7h 
	        in	al,dx 
	        cmp	al,58h 
	        jnz	@b 
 
          ;read data    
                mov     cx,no2     
                mov     dx,pri_data                 
@@:             in      ax,dx 
                mov     [di+bx],ax 
                add     bx,2 
                loop    @b 
                 
                pop     di 
                pop     cx 
                pop     bx                         
                ret                 
readfirstsector endp                 
                 
showfirstsector proc    far     public 
 
                push    si 
                push    cx 
     
                printstr        enters 
                printstr        info_ide 
                printstr        enters 
                lea     si,FirSecData 
                mov     cx,no2 
@@:             mov     al,[si] 
                call    show_al 
                inc     si 
                mov     al,[si] 
                call    show_al 
                inc     si 
                printstr        space1 
                loop    @b 
                printstr        enters 
                pop     cx 
                pop     si 
                ret             
 
 
showfirstsector endp 
 
 
showiden        proc    far     public 
 
                push    bx 
                push    cx 
                PRINTSTR        serialinfo 
                mov     cx,10       
                mov     bx,20 
@@:             mov     dl,[si+bx+1] 
                mov     ah,2 
                int     21h 
                mov     dl,[si+bx] 
                mov     ah,2 
                int     21h 
                add     bx,2 
                loop    @b 
                PRINTSTR        EnterS 
                PRINTSTR        Modelinfo 
                mov     cx,20 
                mov     bx,54 
@@:             mov     dl,[si+bx+1] 
                mov     ah,2 
                int     21h 
                mov     dl,[si+bx] 
                mov     ah,2 
                int     21h 
                add     bx,2 
                loop    @b    
                PRINTSTR        EnterS 
                PRINTSTR        Secsize 
                mov     al,[si+123] 
                call    show_al 
                mov     al,[si+122] 
                call    show_al 
                mov     al,[si+121] 
                call    show_al 
                mov     al,[si+120] 
                call    show_al                               
                PRINTSTR        Enters                 
                pop     cx 
                pop     bx 
showiden        endp 
 
show_al         proc    far     public 
 
                push    ax 
                push    dx 
                mov     dh,al 
                and     al,0f0h 
                shr     al,4 
                add     al,30h 
                cmp     al,3ah 
                jb      doing 
                add     al,7 
doing:          mov     dl,al 
                mov     ah,2 
                int     21h                                    
	 
	        mov     al,dh 
                and     al,0fh 
                add     al,30h 
                cmp     al,3ah 
                jb      doing1 
                add     al,7 
doing1:         mov     dl,al 
                mov     ah,2 
                int     21h  	 
                pop     dx 
                pop     ax 
                ret 
show_al		endp 
 
checkATAPI      proc    far     public 
 
                mov     dx,pri_cntl     ; 
                mov     al,04h          ;reset channel 
                out     dx,al 
                out     0ebh,al 
                mov     al,00h 
                out     dx,al           ;reset complete 
                mov     dx,pri_dev 
                mov     al,0b0h         ;slave for cd - rom 
                out     dx,al 
                mov     dx,1f5h 
                in      al,dx 
                cmp     al,0ebh 
                jnz     exit2 
                mov     dx,1f4h 
                in      al,dx 
                cmp     al,14h 
                jnz     exit2 
                printstr        enters 
                printstr        info_audio 
                call    TestUnitRdy  
                call    PlayAudio 
                ret 
exit2:          printstr        enters 
                printstr        error2 
                ret                 
checkATAPI      endp 
 
TestUnitRdy     proc    far     public 
 
                mov     dx,pri_cntl     ; 
                mov     al,04h          ;reset channel 
                out     dx,al 
                out     0ebh,al 
                mov     al,00h 
                out     dx,al           ;reset complete 
                mov     dx,pri_dev 
                mov     al,0b0h         ;slave for cd - rom 
                out     dx,al 
resend1: 
                mov     dx,1f7h 
@@:             in      al,dx 
                test    al,88h           ;busy and data? 
                jnz      @b 
 
 
                mov     dx,1f7h 
                mov     al,0a0h 
                out     dx,al 
                
@@:             in      al,dx           ;wait for data req 
                test    al,08h 
                jz      @b      
 
                 
    ;============  test =============== 
                mov     ax,0abcdh 
                out     80h,ax 
                mov     dx,1f0h 
                mov     ax,00 
                out     dx,ax 
                out     dx,ax 
                out     dx,ax 
                out     dx,ax 
                out     dx,ax 
                out     dx,ax 
 
                mov     dx,1f7h 
                in      al,dx 
                test    al,01h          ;check error??? 
                jnz     resend1 
 
                mov     dx,1f7h 
@@:             in      al,dx 
                test    al,84h           ;busy and data? 
                jnz      @b 
 
                 
resend2:                 
                mov     dx,1f7h         ;second send  
                mov     al,0a0h 
                out     dx,al 
                 
@@:             in      al,dx 
                test    al,08h 
                jz      @b                 
         ;===============================test  
                mov     ax,1234h 
                out     80h,ax 
                 
                 
                mov     dx,1f0h 
                mov     ax,0045h 
                out     dx,ax               
                mov     ax,0ffffh 
                out     dx,ax 
                mov     ax,0ffffh 
                out     dx,ax 
                mov     ax,0ff00h 
                out     dx,ax 
                mov     ax,00ffh 
                out     dx,ax 
                mov     ax,0000h 
                out     dx,ax 
 
                mov     dx,1f7h 
                in      al,dx 
                test    al,01h          ;check error??? 
                jnz     resend2                 
 
                ret 
TestUnitRdy     endp 
 
PlayAudio       proc    far     public 
 
                ret 
PlayAudio       endp 
end  