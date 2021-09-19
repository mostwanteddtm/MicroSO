#include <stdio.h>
#include <conio.h>

#define CMOS_PORT 0x70
#define TEST_CPP 1

void pbin(unsigned char value);

void testcpp();
void testasm();

void main(int argc, char *argv[])
{
	TEST_CPP ? testcpp() : testasm();
}

void testcpp()
{
	int i = 600;

	outp(CMOS_PORT, 0xA);

	do {
		if (inp(CMOS_PORT+1) & 0x80) break;
	} while (i <= 0);
	
	if (i == 0) {
		printf("logic error");
		return;
	}

	outp(CMOS_PORT, 0x2);
	printf("%x", inp(CMOS_PORT+1));
}

void testasm()
{
	int minutes = 0;
	_asm {

		CALL 		UPD_IN_PR ;CHECK FOR UPDATE IN PROCESS
		MOV         DL, 0
		CALL 		PORT_INC_2 ;SET ADDRESS OF MINUTES
		IN 			AL,CMOS_PORT+1 ;Get BCD value returned
		XOR			AH, AH
		MOV			minutes, AX
		MOV 		CL,AL ;SAVE IN CL

		CALL 		DisplayTime

	UPD_IN_PR:      ;Check we are ready to read clock
	
		PUSH 		CX
		MOV 		CX,600 ;SET LOOP COUNT
		
	UPDATE:
		MOV 		AL,0AH ;ADDRESS OF [A] REGISTER
		OUT 		CMOS_PORT,AL
		IN 			AL,CMOS_PORT+1 ;READ IN REGISTER [A]
		TEST 		AL,80H ;IF 8XH--> UIP BIT IS ON (CANNOT READ TIME)
		JZ 			UPD_IN_PREND
		LOOP 		UPDATE ;Try again
		XOR 		AX,AX ;
		STC 		;SET CARRY FOR ERROR
		UPD_IN_PREND:
		POP 		CX
		RET 		;RETURN 
	
	PORT_INC_2:
		ADD 		DL,2 ;INCREMENT ADDRESS
		MOV 		AL,DL
		OUT 		CMOS_PORT,AL
		RET	

	DisplayTime:
		MOV 		AL,CL
		CALL 		PRINT_REG ;Minutes. Convert BCD to ASCII
		RET

	CO: ;Character in CL
		PUSH 		DX
		MOV 		DL,CL
		MOV 		AH,02H
		INT 		21H
		POP 		DX
		RET 

	PRINT_REG: ;Print BCD in [AL]
		PUSH 		AX
		MOV 		CL,4
		RCR 		AX,CL
		AND 		AL,0FH
		ADD 		AL,30H
		MOV 		CL,AL ;Write high byte mins to CRT
		CALL 		CO
		POP 		AX
		AND 		AL,0FH
		ADD 		AL,30H
		MOV 		CL,AL
		CALL 		CO	
	}

	printf("\n%x", minutes);
}

void pbin(unsigned char value)
{
	int i = 7;
	for (i = 7; i >= 0; i--)
	{
		printf((value >> i & 0x1) == 1 ? "1" : "0");
	}
}