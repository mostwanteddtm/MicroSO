ORG 100H
	; Ports for normal IDE/ATA are
	; 0x1F0 Primary 	Irq 14
	; 0x170 Secondary	Irq 15
	; 0x1E8 Tertiary	Irq 11
	; 0x168 Quaternary	Irq 10

	; Secondary status register at Base+0x206 not used
	; because register not present on many ISA add-in 
	; cards and not part of current specs at all.

	; For the meaning of the remainder of the ID block
	; sent by devices in responce to the command please goto
	; http://www.t13.org and look up ATAPI4 or later.

        MOV DX,0168H		;BASE PORT
	MOV [BASE],DX
	ADD DX,0
	MOV [DATAREG],DX	;DATA PORT
	MOV DX,[BASE]
	ADD DX,06
	MOV [DRIVEHEAD],DX	;DRIVEHEAD PORT
	MOV DX,[BASE]
	ADD DX,07
	MOV [COMMAND],DX	;COMMAND PORT (ON WRITE)
	MOV [STATUS],DX		;STATUS PORT (ON READ)

        MOV DX,BEGINING 
	CALL PRN_DX             ; print out begin
	
BSYCLR1	MOV DX,[STATUS]         ;bsy clr loop1 ; Is Drive Busy?
	IN  AL,DX
        IN  AL,DX
        IN  AL,DX
        IN  AL,DX
        IN  AL,DX
        MOV [STATBYTE],AL
        AND AL,080H
        CMP AL,00H
        JNE BSYCLR1

        MOV DX,STEPONE
	CALL PRN_DX             ; print out step one done

        MOV DX,[DRIVEHEAD]
        IN  AL,DX
        AND AL,0EFH		; AND AL,0EFH FOR Master
        OUT DX,AL		; OR  AL,010H FOR SLAVE

BSYCLR2 MOV DX,[STATUS]           ;bsy clr loop2 ;Is Select valid now?
	IN  AL,DX
        IN  AL,DX
        IN  AL,DX
        IN  AL,DX
        IN  AL,DX
        MOV [STATBYTE],AL
        AND AL,80H
        CMP AL,00H
        JNE BSYCLR2

DVRDY   MOV DX,[STATUS]           ;Is Drive Ready for more Information
	IN  AL,DX
	MOV [STATBYTE],AL
        IN  AL,DX
        IN  AL,DX
        IN  AL,DX
        IN  AL,DX
        IN  AL,DX
        MOV [STATBYTE],AL
        AND AL,40H
        CMP AL,40H
        JNE DVRDY

        MOV DX,DRVSEL
	CALL PRN_DX             ; print out drive selected

        MOV DX,[COMMAND]
        MOV AL,0ECH		; Identify Drive Command
        OUT DX,AL		; Use 0A1H for Atapi Devices (Cdrom Etc.)

BSYDRQ1 MOV DX,[STATUS]          ;bsy clr loop1 ;Is drive busy with data ready?
	IN  AL,DX
	MOV [STATBYTE],AL
        IN  AL,DX
        IN  AL,DX
        IN  AL,DX
        IN  AL,DX
        IN  AL,DX
        MOV [STATBYTE],AL
        AND AL,88H
        CMP AL,08H
        JNE BSYDRQ1

        MOV DX,DATARDY
	CALL PRN_DX

        MOV SI,00H		;This is a read loop
        MOV DX,[DATAREG]
RDLOOP  MOV BX,MYBUFFER
	IN  AX,DX
        MOV [BX+SI],AX
        INC SI
        INC SI
        CMP SI,200H
        JL  RDLOOP		; At 0x200 the whoe block has been read.

        MOV DX,HAVERD
	CALL PRN_DX
        CALL LF

        MOV SI,MYBUFFER
        MOV DI,27
MDLLOOP MOV BX,DI
        SHL BX,1
        MOV CX,[SI+BX]
        MOV AH,2
        MOV DL,CH
        INT 21H
        MOV AH,2
        MOV DL,CL
        INT 21H
        INC DI
        CMP DI,46
        JLE MDLLOOP

        CALL LF

        MOV SI,MYBUFFER
        MOV DI,10
SERLOOP MOV BX,DI
        SHL BX,1
        MOV CX,[SI+BX]
        MOV AH,2
        MOV DL,CH
        INT 21H
        MOV AH,2
        MOV DL,CL
        INT 21H
        INC DI
        CMP DI,19
        JLE SERLOOP

        CALL LF

        MOV SI,MYBUFFER
        MOV DI,23
FRMLOOP MOV BX,DI
        SHL BX,1
        MOV CX,[SI+BX]
        MOV AH,2
        MOV DL,CH
        INT 21H
        MOV AH,2
        MOV DL,CL
        INT 21H
        INC DI
        CMP DI,26
        JLE FRMLOOP

        CALL LF

        MOV AX,04C00H
        INT 21H
        NOP

PRN_DX  MOV AH,09
        INT 21H                 ;Print Out DX$
	RET

LF      MOV AH,9
        MOV DX,LFSTR
        INT 21H
	RET

BEGINING:	DB	'BSY CLR?',0AH,0DH,'$'
STEPONE:        DB      'BSY CLR',0AH,0DH,'$'
DRVSEL:         DB      'DRV SELECTED',0AH,0DH,'$'
DATARDY:        DB      'DATA READY',0AH,0DH,'$'
HAVERD:         DB      'DATA READ',0AH,0DH,'$'
STATBYTE:	DB	020H
BASE:		DW	030H	
DATAREG:	DW	030H
ERRORREG:	DW	031H
SECTORCOUNT:	DW	032H
SECTORNUMBER:	DW	033H
CYLINDERLOW:	DW	034H
CYLINDERHIGH:	DW	035H
DRIVEHEAD:	DW	036H
COMMAND:	DW	037H
STATUS:		DW	037H
LFSTR:		DB	0AH,0DH,'$'
ENDSTUFF:       DB      'END DATA',0AH,0DH,'$'
MYBUFFER	DW 	0xFFFF
