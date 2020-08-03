;PCI Enumerate Tool by WuJun@amoi.com.cn  
; copy Irvine16.inc into c:\masm611\include 
; copy Irvine16.lib into c:\masm611\lib 
; compile command: ML /nologo -c -Fl pci.asm 
;    link command: LINK /nologo pci,,NUL,Irvine16;  
; History 
; 2004-11-29 v0.1   prime version to show pcicfg as bus dev func venid devid class in hex code 
; 2004-12-1  v0.1   added function to show class and subclass string instead of hex code 
; 2004-12-2  v0.2   added pci struct,improve the data struct,make program to has more readablilty 
INCLUDE Irvine16.inc 
pci struct 
   vendorID           DW ? 
   deviceID           DW ? 
   command_reg        DW ? 
   status_reg         DW ? 
   revisionID         DB ? 
   progIF             DB ? 
   classcode          DW ? 
   cacheline_size     DB ? 
   latency            DB ? 
   header_type        DB ? 
   BIST               DB ? 
   base_address0      DD ? 
   base_address1      DD ? 
   base_address2      DD ? 
   base_address3      DD ? 
   base_address4      DD ? 
   base_address5      DD ? 
   CardBus_CIS        DD ? 
   subsystem_vendorID DW ? 
   subsystem_deviceID DW ? 
   expansion_ROM      DD ? 
   cap_ptr            DB ? 
   reserved1          DB 3 DUP(?) 
   reserved2          DD ? 
   interrupt_line     DB ? 
   interrupt_pin      DB ? 
   min_grant          DB ? 
   max_latency        DB ? 
   ;device_specific     DD 48 DUP(?) 
pci ends 
.data? 
pcicfg pci <> 
.data 
InfoList DB '  Bus Dev Fun VenId DevID Class',0DH,0AH,0 
LineTag  DB '  ----------------------------------------------------------',0DH,0AH,0 
io_CF8   DD 80000000H 
Blank    DB ' ',0 
Unknown  DB 'Unknown Device',0 
;-------------------------------------------------------------------------------- 
ClassTable DB 'None definitions ',0 ;00H 
           DB 'Mass storage     ',0 ;01H 
           DB 'Network device   ',0 ;02H 
           DB 'Display device   ',0 ;03H 
           DB 'Multimedia       ',0 ;04H 
           DB 'Memory controller',0 ;05H 
           DB 'Bridge controller',0 ;06H 
           DB 'Communication    ',0 ;07H 
           DB 'System peripheral',0 ;08H 
           DB 'Input devices    ',0 ;09H 
           DB 'Docking stations ',0 ;0AH 
           DB 'Processors       ',0 ;0BH 
           DB 'Serial bus       ',0 ;0CH 
           DB 'Wireless control ',0 ;0DH 
           DB 'Intelligent I/O  ',0 ;0EH 
           DB 'Satellite device ',0 ;0FH 
           DB 'E(D)ncryption dev',0 ;10H 
           DB 'A/D Signal device',0 ;11H 
;-------------------------------------------------------------------------------- 
subclass_info  DB 00h,00h,'Except VGA',0        ;subclass,class,name string 
               DB 01h,00h,'VGA-compatible',0 
               DB 00h,01h,'SCSI',0 
               DB 01h,01h,'IDE',0 
               DB 02h,01h,'Floppy',0 
               DB 03h,01h,'IPI',0 
               DB 04h,01h,'RAID',0 
               DB 00h,02h,'Ethernet',0 
               DB 01h,02h,'TokenRing',0 
               DB 02h,02h,'FDDI',0 
               DB 03h,02h,'ATM',0 
               DB 04h,02h,'ISDN',0 
 			   DB 00h,03h,'VGA',0 
               DB 01h,03h,'XGA',0 
               DB 02h,03h,'3D control',0 
		       DB 00h,04h,'video',0 
               DB 01h,04h,'audio',0 
               DB 02h,04h,'Telephony',0 
 			   DB 00h,05h,'RAM',0 
               DB 01h,05h,'Flash',0 
               DB 00h,06h,'CPU/PCI',0 
               DB 01h,06h,'PCI/ISA',0 
               DB 02h,06h,'PCI/EISA',0 
               DB 03h,06h,'PCI/MCA',0 
               DB 04h,06h,'PCI/PCI',0 
               DB 05h,06h,'PCI/PCMCIA',0 
               DB 06h,06h,'PCI/NuBus',0 
               DB 07h,06h,'PCI/CardBus',0 
               DB 08h,06h,'PCI/RACEway',0 
               DB 00h,07h,'Serial',0 
               DB 01h,07h,'Parallel',0 
               DB 02h,07h,'Multiport',0 
               DB 03h,07h,'Generic modem',0 
               DB 00h,08h,'PIC',0 
               DB 01h,08h,'DMAC',0 
               DB 02h,08h,'Timer',0 
               DB 03h,08h,'RTC',0 
               DB 04h,08h,'Hot-Plug',0 
 			   DB 00h,09h,'Keyboard ',0 
               DB 01h,09h,'Digitizer',0 
               DB 02h,09h,'Mouse',0 
               DB 03h,09h,'Scanner',0 
               DB 04h,09h,'Gameport',0 
               DB 00h,0Ah,'Generic',0 
               DB 01h,0Bh,'386',0 
               DB 02h,0Bh,'486',0 
               DB 03h,0Bh,'Pentium',0 
               DB 04h,0Bh,'P6',0 
               DB 10h,0Bh,'Alpha',0 
               DB 20h,0Bh,'PowerPC',0 
               DB 30h,0Bh,'MIPS',0 
               DB 40h,0Bh,'Coproc',0 
               DB 00h,0Ch,'1394 Firewire',0 
               DB 01h,0Ch,'ACCESS.bus',0 
               DB 02h,0Ch,'SSA',0 
               DB 03h,0Ch,'USB',0 
               DB 04h,0Ch,'Fiber Channel',0 
               DB 05h,0Ch,'SMBus',0 
               DB 00h,0Dh,'iRDA compatible',0 
               DB 01h,0Dh,'Consumer IR',0 
               DB 10h,0Dh,'RF controller',0 
               DB 00h,0Eh,'Specification 1.0',0 
               DB 01h,0Fh,'TV',0 
               DB 02h,0Fh,'Audio',0 
               DB 03h,0Fh,'Voice',0 
               DB 04h,0Fh,'Data',0 
               DB 00h,10h,'NetWork&Compute',0 
               DB 10h,10h,'Entertainment',0 
               DB 00h,11h,'DPIO Modules',0 
 prev_device   DD 0FFFFFFFFH 
 .code 
PrintText proc uses edx,pString:ptr byte 
	mov dx,pString 
	call WriteString 
	ret 
PrintText endp 
DispClass PROC 
    pushad  
    push ax 
    lea si,ClassTable    ;si->ClassTable Header 
    movzx cx,ah 
l1: add si,lengthof ClassTable 
    loop l1 
    mov dx,si            ;dx=si->class String to Show 
    call WriteString 
    lea dx,Blank 
    call WriteString 
    lea si,subclass_info 
    pop dx 
l2: mov bx,word ptr [si] ;bx=current subclass item 
    add si,2 
    cmp bx,dx            ;dx=class 
    jne l3 
    mov dx,si 
    jmp l4 
l3: invoke Str_length,si 
    add si,ax 
    inc si 
    cmp bx,dx 
    jb l2 
    lea dx,Unknown 
l4: call WriteString 
    popad 
ret    
DispClass ENDP 
DispHex PROC uses eax ecx edx HexValue:WORD 
    LOCAL count:BYTE 
    mov cx,4 
    mov count,0 
    .if HexValue==0 
        mov ah,2 
        mov dl,' ' 
        int 21h 
        int 21h 
        int 21h 
    	mov dl,'0' 
    	int 21h 
    	ret 
    .endif 
    .while cx>0 
       mov dx,HexValue 
       dec cx 
       shl cx,2 
       shr dx,cl 
       shr cx,2 
       mov ah,2 
       and dl,0FH 
       mov ah,2 
       .if dl>9  
           add dl,37H 
           inc count 
           int 21h 
       .else 
           .if ((dl>0) || ((dl==0) && (count>0))) 
           	   add dl,30H 
           	   inc count 
           	   int 21h 
           .elseif((dl==0) && (count==0)) 
               mov dl,' ' 
               int 21h 
           .endif 
       .endif 
    .endw 
ret 
DispHex ENDP 
 
.startup   
  invoke PrintText,addr InfoList 
  invoke PrintText,addr LineTag 
  mov ecx,io_CF8 
l:.while ecx<80FFFF00H 
      mov dx,0CF8H 
      mov eax,ecx 
      out dx,eax 
      mov dx,0CFCH 
      in eax,dx 
      .if eax==prev_device 
      	  add ecx,100h 
      	  jmp l	 
      .endif 
      mov prev_device,eax 
      mov ebx,eax 
      .if eax!=0FFFFFFFFH 
          push ecx 
          push eax 
          lea di,pcicfg 
          cld 
          .while cl<0FCH 
              mov eax,ecx 
              mov dx,0CF8H 
              out dx,eax 
              mov dx,0CFCH 
              insd  
              add cl,4 
          .endw 
          pop eax 
          pop ecx 
          mov eax,ecx       
          and eax,0FF0000H 
          shr eax,16 
          invoke DispHex,ax;bus id 
          lea dx,Blank 
          call WriteString 
          mov eax,ecx       
          and eax,0F800H 
          shr eax,11 
          invoke DispHex,ax;device id 
          mov eax,ecx       
          and eax,700H 
          shr eax,8 
          invoke DispHex,ax;func id 
          lea dx,Blank 
          call WriteString 
          lea dx,Blank 
          call WriteString 
          lea di,pcicfg 
          assume di:ptr PCI 
          mov ax,[di].vendorID 
          invoke DispHex,ax;vender id 
          invoke PrintText,addr Blank 
          invoke PrintText,addr Blank 
          mov ax,[di].deviceID;device id 
          invoke DispHex,ax 
          invoke PrintText,addr Blank 
          mov ax,[di].classcode 
          call DispClass;class and subclass string 
          call Crlf 
      .endif 
      add ecx,100H 
   .endw 
.exit 
END