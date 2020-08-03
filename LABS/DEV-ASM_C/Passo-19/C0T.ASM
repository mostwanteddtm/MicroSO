.286
.MODEL TINY  
.CODE

ORG 100h

EXTERN      _main:NEAR  
PUBLIC 	    __acrtused		    ; trick to force in startup
	        __acrtused = 9876h	; funny value not easily matched in SYMDEB
			
PUBLIC		__fmemcpy
PUBLIC 		__fmemset
            
start 		PROC

            push    cs
            pop     ax
            mov     ds, ax
            mov     es, ax
            call    _main
	
	        int     20h
			
start 		ENDP

__fmemcpy    PROC
             
            push    bp  
            push    ax
            mov     bp, sp
            mov     si, word ptr [bp+0Ch]
            mov     cx, word ptr [bp+10h] 
            mov     ax, ds
            mov     es, ax
            mov     di, word ptr [bp]                            
            rep     movsb
            pop     ax 
            pop     bp
            ret
    
__fmemcpy    ENDP   

__fmemset    PROC 
            ret      
__fmemset    ENDP

END start