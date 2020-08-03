COMMENT ^
	
	typedef struct _IMAGE_DOS_HEADER 
	{  							// DOS .EXE header
		USHORT e_magic;         // Magic number (Should be MZ
		USHORT e_cblp;          // Bytes on last page of file
		USHORT e_cp;            // Pages in file
		USHORT e_crlc;          // Relocations
		USHORT e_cparhdr;       // Size of header in paragraphs
		USHORT e_minalloc;      // Minimum extra paragraphs needed
		USHORT e_maxalloc;      // Maximum extra paragraphs needed
		USHORT e_ss;            // Initial (relative) SS value
		USHORT e_sp;            // Initial SP value
		USHORT e_csum;          // Checksum
		USHORT e_ip;            // Initial IP value
		USHORT e_cs;            // Initial (relative) CS value
		USHORT e_lfarlc;        // File address of relocation table
		USHORT e_ovno;          // Overlay number
		USHORT e_res[4];        // Reserved words
		USHORT e_oemid;         // OEM identifier (for e_oeminfo)
		USHORT e_oeminfo;       // OEM information; e_oemid specific
		USHORT e_res2[10];      // Reserved words
		LONG   e_lfanew;        // File address of new exe header
	} IMAGE_DOS_HEADER, *PIMAGE_DOS_HEADER;
	
		^
	
CODESEG32 SEGMENT USE32

	GOTOKERNEL32 PROC
	
		MOV		AX, SELDATADESC32
		MOV		DS, AX
	
		XOR		EAX, EAX
		XOR		ECX, ECX
		XOR		ESI, ESI
		MOV		SI, DATASEG32
		SHL		ESI, 4
		ADD  	ESI, OFFSET TOTALSECTORS			
		LODSB
		
		MOV		CL, [ESI]							; TOTAL SECTORS
		MOV		EAX, 80H							; 512d BYTES PER SECTOR | 200h BYTES PER SECTOR | 80h DWORD (4 BYTES) PER SECTOR (80h * 4) = 200h OR 512d 
		MUL		ECX
		XCHG	EAX, ECX

		MOV 	AX, SELKERNELDESC16
		MOV 	DS, AX
		MOV 	AX, SELKERNELDESC32
		MOV 	ES, AX
		
		XOR		ESI, ESI
		XOR		EDI, EDI
		REP 	MOVSD								; MOV DWORD
		
		MOV		AX, SELDATADESC32
		MOV		DS, AX
		
		XOR		EAX, EAX
		XOR		ESI, ESI
		MOV		SI, DATASEG32
		SHL		ESI, 4
		ADD  	ESI, OFFSET IMAGESIG				; 'PE'
		MOV		EDI, 3Ch							; 3Ch (60d) OFFSET IN KERNEL32.EXE, THAT CONTAINS ADDRESS OF SIGNATURE 'PE'
		XOR		EBX, EBX
		MOV		EBX, ES:[EDI]
		XOR		EDI, EDI
		MOV		EDI, EBX
		CMPSW
		
		JNE		ERROREXECUTE	
	
		ADD		EBX, 24								; _IMAGE_FILE_HEADER IS 20 BYTES + SIZE OF SIG (4 BYTES)
		ADD		EBX, 20-4							; ADDRESS OF ENTRY POINT
		
		MOV		EDI, EBX
		MOV		EBP, ES:[EDI]						; GET ENTRY POINT OFFSET IN CODE SECTION						
		ADD		EBX, 12								; IMAGE BASE IS OFFSET 8 BYTES FROM ENTRY POINT
		MOV		EDI, EBX
		MOV		EAX, ES:[EDI]					
		ADD		EBP, EAX							; ADD IMAGE BASE

		CALL	EBP									; EXECUTE KERNEL
		
	ERROREXECUTE:
		RET
		
	GOTOKERNEL32 ENDP

CODESEG32 ENDS