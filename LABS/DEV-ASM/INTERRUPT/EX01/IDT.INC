IDTDESC	STRUCT
	BASE_LO			DW ?
	CODE_SEL		DW ?
	RESERVED		DB ?
	ATTRIBUTE		DB ?
	BASE_HI			DW ?
IDTDESC ENDS

DATASEG16 SEGMENT USE16 

	IDTR 			LABEL FWORD
	IDT_LIMIT 		DW IDT_SIZE-1
	IDT_ADDR 		DD ?
	
	IDT_START 		EQU $
	IDT_DESC_00h 	IDTDESC <OFFSET INT08h,SELCODEDESC16,0,10001110B,0>
	IDT_DESC_01h 	IDTDESC <OFFSET INT08h,SELCODEDESC16,0,10001110B,0>
	IDT_DESC_02h 	IDTDESC <OFFSET INT08h,SELCODEDESC16,0,10001110B,0>
	IDT_DESC_03h 	IDTDESC <OFFSET INT08h,SELCODEDESC16,0,10001110B,0>
	IDT_DESC_04h 	IDTDESC <OFFSET INT08h,SELCODEDESC16,0,10001110B,0>
	IDT_DESC_05h 	IDTDESC <OFFSET INT08h,SELCODEDESC16,0,10001110B,0>
	IDT_DESC_06h 	IDTDESC <OFFSET INT08h,SELCODEDESC16,0,10001110B,0>
	IDT_DESC_07h 	IDTDESC <OFFSET INT08h,SELCODEDESC16,0,10001110B,0>
	IDT_DESC_08h 	IDTDESC <OFFSET INT08h,SELCODEDESC16,0,10001110B,0>
	IDT_DESC_09h 	IDTDESC <OFFSET INT09h,SELCODEDESC16,0,10001110B,0>
	IDT_SIZE 		EQU ($-IDT_START)
	
	POLD			LABEL	FWORD
	DIDT_LIMIT		DW		?						; DOS IDT LIMIT
	DIDT_ADDR		DD		?						; DOS IDT BASE ADDRESS
	
DATASEG16 ENDS