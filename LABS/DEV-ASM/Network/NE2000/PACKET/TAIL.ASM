;   PC/FTP Packet Driver source, conforming to version 1.05 of the spec
;   Updated to version 1.08 Feb. 17, 1989.
;   Copyright 1988-1996 Russell Nelson

;   This program is free software; you can redistribute it and/or modify
;   it under the terms of the GNU General Public License as published by
;   the Free Software Foundation, version 1.
;
;   This program is distributed in the hope that it will be useful,
;   but WITHOUT ANY WARRANTY; without even the implied warranty of
;   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;   GNU General Public License for more details.
;
;   You should have received a copy of the GNU General Public License
;   along with this program; if not, write to the Free Software
;   Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA

	include	defs.asm

code	segment word public
	assume	cs:code, ds:code

	public	is_eisa
is_eisa	db	0			;=0 if ISA, =1 if EISA
	public	is_pci
is_pci	db	0			;=0 if PCI, =1 if PCI
	extrn	sys_features: byte	;bitmask of system features.
	extrn	is_186: byte		;=0 if 808[68], =1 if 80[1234]86.
	extrn	is_286: byte		;=0 if 80[1]8[68], =1 if 80[234]86.
	extrn	is_386: byte		;=0 if 80[12]8[68], =1 if 80[34]86.
	extrn	int_no: byte		;the board's interrupt level.
	extrn	hw_int_no: byte		;the 8259 interrupt level.
	extrn	driver_class: byte	;the class of this driver, per the spec.
	extrn	rcv_modes: word		;count of modes followed by mode handles.

;-> last byte of static memory used by driver-dependent code.
	extrn	end_resident: byte
	extrn	end_free_mem: byte

;-> the fixed address of the card.
	extrn	rom_address: byte

;-> the current address of the card.
	extrn	my_address: byte

	extrn	phd_dioa: byte
	extrn	phd_environ: word
	extrn	flagbyte: byte

	include	printnum.asm
	include	decout.asm
	include	digout.asm
	include	crlf.asm
	include	chrout.asm

free_mem	dw	end_resident	;allocate memory from here.
;also see memory_to_keep.

	public	malloc
malloc:
;enter with dx = amount of memory desired.
;exit with nc, dx -> that memory, or cy if there isn't enough memory.
	add	dx,free_mem		;make a pointer after that much memory.
	cmp	dx,offset end_free_mem	;is it still in the free area?
	ja	malloc_1		;no, we're in trouble.
	xchg	dx,free_mem		;get the pointer back, store ptr->end.
	clc
	ret
malloc_1:
	stc
	ret


end_tail_1	label	byte		; end of the delayed init driver

;usage_msg is of the form "usage: driver [options] <packet_int_no> <args>"
	extrn	usage_msg: byte
	;extrn	mca_usage_msg: byte

options_i_msg	label	byte
db"   -i -- Force driver to report itself as IEEE 802.3 instead of Ethernet II.",CR,LF
options_msg	label	byte
db"   -d -- Delayed initialization.  Used for diskless booting",CR,LF
db"   -n -- NetWare conversion.  Converts 802.3 packets into 8137 packets",CR,LF
db"   -w -- Windows hack, obsoleted by winpkt",CR,LF
db"   -p -- Promiscuous mode disable",CR,LF
  if M_OPTION
db"   -m -- Micronetics MSM compatibility",CR,LF
  endif
db"   -u -- Uninstall",CR,LF
db '$'

;copyright_msg is of the form:
;"Packet driver for the foobar",CR,LF
;"Portions Copyright 19xx, J. Random Hacker".
	extrn	copyright_msg: byte

copyleft_msg	label	byte
 db "Packet driver skeleton copyright 1988-96, Crynwr Software.",CR,LF
 db "This program is freely copyable; source must be available; NO WARRANTY.",CR,LF
 db "See the file COPYING.DOC for details; send FAX to +1-315-268-9201 for a copy.",CR,LF
 db CR,LF,'$'

no_resident_msg	label	byte
 db CR,LF,"*** Packet driver failed to initialize the board ***",CR,LF,'$'

;parse_args should parse the arguments.
;called with ds:si -> immediately after the entry_point.
	extrn	parse_args: near

;print_parameters should print the arguments.
	extrn	print_parameters: near

	extrn	our_isr: near, their_isr: dword
	extrn	entry_point: byte

eisa_signature	db	"EISA"

system_msg	db	"System: ",'$'
i386_msg	db	"[345]86 processor",'$'
i286_msg	db	"286 processor",'$'
i186_msg	db	"186 processor",'$'
i8088_msg	db	"8088/8086 processor",'$'
mca_msg		db	", Microchannel bus",'$'
eisa_msg	db	", EISA bus",'$'
isa_msg		db	", ISA bus",'$'
two_8259_msg	db	", Two 8259s",'$'
entry_point_name	db	"Packet driver software interrupt is ",'$'
eaddr_msg	db	"My Ethernet address is ",'$'
aaddr_msg	db	"My ARCnet address is ",'$'

already_msg	db	CR,LF,"Error: there is already a packet driver (you may uninstall it using -u) at ",'$'
no_pkint_msg	db	CR,LF,"Error: there is no packet driver at ",'$'
no_pkt_msg	db	CR,LF,"Error: no packet driver found between 0x60 and 0x80",CR,LF,'$'
two_pkts_msg	db	CR,LF,"Error: there are two packets drivers (specify the desired one after -u).",CR,LF,'$'
int_msg		db	CR,LF
		db	"Error: <hardware_irq> should be between 0 and "
int_msg_num	label	word
		db	"15 inclusive", '$'
xt_hd_warn_msg	db	CR,LF,"Warning: the hard disk on an XT usually uses IRQ 5.  Use a different interrupt",CR,LF,'$'
no_ieee_msg	db	CR,LF,"Error: this driver doesn't implement both IEEE 802.3 and Ethernet II",CR,LF,'$'
terminated_msg	db	"Uninstall completed",'$'

handle		dw	?

entry_point_fnd	db	0
bogus_type	db	0,0		;totally bogus type code.
our_recv:
	xor	di,di
	mov	es,di
	retf

	public	etopen_diagn
etopen_diagn	db	0		; errorlevel from etopen if set

;etopen should initialize the device.  If it needs to give an error, it
;can issue the error message and quit to dos.
	extrn	etopen: near

memory_to_keep	dw	end_resident	;keep at least this much memory.
;also see free_mem.

already_error:
	mov	dx,offset already_msg
already_error_1:
	mov	di,offset entry_point
	call	print_number
	mov	ax,4c05h		; give errorlevel 5
	int	21h

usage_error:
	mov	dx,offset usage_msg
	test	sys_features,SYS_MCA
	je	usage_error_1
	;mov	dx,offset mca_usage_msg
usage_error_1:
	mov	ah,9
	int	21h
	mov	dx,offset options_msg
	cmp	word ptr driver_class,BLUEBOOK + IEEE8023*256	;both present?
	jne	error
	mov	dx,offset options_i_msg
	public	error
error:
	mov	ah,9
	int	21h
	mov	ax,4c0ah		; give errorlevel 10
	int	21h

;;;	include	timeout.asm

	public	start_1
start_1:

	cld
	
	mov	is_186,1
	mov	is_286,1
	mov	is_386,1

	call	etopen			;init the driver.  If any errors,
					;this routine returns cy.
	
	;call rcv_modes+14
	;extern rcv_mode_6:proc	
	;call rcv_mode_6
		
	mov ax, 4c00h
	int 21h
	
; 			Suggested errorlevels:
;
; _____________________  0 = normal
; 			 1 = unsuitable memory address given; corrected
; In most cases every-	 2 = unsuitable IRQ level given; corrected
; thing should work as	 3 = unsuitable DMA channel given; corrected
; expected for lev 1-5	 4 = unsuitable IO addr given; corrected (only 1 card)
; _____________________	 5 = packet driver for this int # already loaded
; External errors, when	20 = general cable failure (but pkt driver is loaded)
; corrected normal	21 = network cable is open             -"-
; operation starts	22 = network cable is shorted          -"-
; _____________________ 23 = 
; Packet driver not	30 = usage message
; loaded. A new load	31 = arguments out of range
; attempt must be done	32 = unspecified device initialization error
;			33 = 
;			34 = suggested memory already occupied
;			35 = suggested IRQ already occupied
;			36 = suggested DMA channel already occupied
;			37 = could not find the network card at this IO address


	include	verifypi.asm
	include	getnum.asm
	include	getdig.asm
	include	skipblk.asm
	include	printea.asm
	include	pkterr.asm
	include	getenv.asm

	public	branding_msg
branding_msg	db	'$'

code	ends

	end
