.MODEL MEDIUM
.386


ARG1	EQU	6

PUBLIC _seteax
PUBLIC _gethigh
PUBLIC _getlow
PUBLIC _value

.DATA
	_value	DD	0

.CODE

_seteax proc far

	push    bp              ; Save the stack frame pointer
	mov     bp, sp          ; Set up a new stack frame pointer
	;mov     dx, word ptr [bp+ARG1]          ; Get the port
	;mov     eax, dword ptr [bp+ARG1+2]      ; Get the vlaue
	;out     dx, eax         ; Out port
	mov		eax, 813910ECh
	mov		si, OFFSET _value
	mov		[si], eax
	mov     sp, bp          ; Restore the stack frame
	pop     bp              ; Restore registers
	ret

_seteax endp

_gethigh proc far

	push    bp              ; Save the stack frame pointer
	mov     bp, sp          ; Set up a new stack frame pointer
	mov     sp, bp          ; Restore the stack frame
	mov		eax, _value
	pop     bp              ; Restore registers
	ret

_gethigh endp

_getlow proc far

	push    bp              ; Save the stack frame pointer
	mov     bp, sp          ; Set up a new stack frame pointer
	mov		eax, _value
	shr		eax, 16
	mov     sp, bp          ; Restore the stack frame
	pop     bp              ; Restore registers
	ret

_getlow endp

end
