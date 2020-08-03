/*******************************************************************************
* NAME: EmbedAssembly.cpp
* DATE: June 30, 2003
* PGMR: Y. Bai - Copyright 2003-2007
* DESC: Serial communication test program using embedded assembly language
* This program uses 8250 controller to loop-test a serial port.
*******************************************************************************/
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <conio.h>
#include <ctype.h>
#include <math.h>
#include <dos.h>  

#define MAX 5000  
  
#define COM1 3f8h // COM1 base address
#define COM2 2f8h // COM2 base address
#define IER 3f9h // COM1 Interrupt Enable Register
#define MCR 3fch // COM1 Modem Control Register
#define LCR 3fbh // COM1 Line Control Register
#define LSR 3fdh // COM1 Line Status Register
#define MSR 3feh // COM1 Modem Status Register 

void c_inial(); // Assembly subroutine used to initialize the UART 
char reces(); // Assembly subroutine used to receive a byte (uchar)
char sends(char c); // Assembly subroutine used to send out a byte
void delay(int num); // Delay subroutine used to delay a period of time
void TestSerial(); // C-code subroutine used to test the serial port
void main(void)     

{
	char cc;
	printf("\n********* WELCOME TO SERIAL LOOP TESTING ***********\n\n");
	printf("Do you want to begin the testing? y/n\n");
	scanf("%c", &cc);
	if (cc == 'y' || cc == 'Y')
		TestSerial();
	printf("************* TESTING END ****************\n");
	return;
}  
   
   
/********************************************************************************
* Subroutine to loop testing for the RS232C port. *
********************************************************************************/
void TestSerial()
{
	char sChar[] = {"ABCDEFGHIJKLMNOPQRSTUVWXYZ"};
	char rc, rChar = 0;
	int index = 0;
	
	c_inial();
	
	for(index=0;index<=26;index++)
	{
		rc = sends(sChar[index]);
	}	
	
	while((rChar = reces()) == 0) {} 
	
	printf("Receiving data is %c\n", rChar);
	
	return;
}  

/***********************************************************************************
* Initialization the 8250 communication port
**********************************************************************************/
void c_inial()
{
	_asm
	{
		mov dx, LCR 	// Select the Line Control Register to set up the comm. parameters.
		mov al, 80h 	// Bit7 = 1, 3f8h & 3f9h registers can access the baud rate divisor.
		out dx, al 		// Nominal baud rate = 1843200/(baud rate*16).
		
		mov dx, COM1 	//
		mov al, 0Ch 	// b7 - b0 = (60h) = (01100000b) -> 3f8h (baud rate low-byte)
		out dx, al 		// 
		
		mov dx, IER 	//
		mov al, 00h 	// b7 - b0 = (00h) = (00000000b) -> 3f 9h (baud rate high-byte)
		out dx, al 		// Set up the baud rate high & low bytes (000Ch -> 9600 baud rate).
		
		mov dx, LCR 	// Finish set up the Line Controller Register.
		mov al, 0bh 	// b7 - b0 = 0bh = (00001011b) -> odd parity, 1 stop bit, 8 data bits.
		out dx, al 		// Set up LCR based on the above control parameters.
		
		mov dx, MCR 	// Set up Modem Control Register to set DTR & RTS to 1 (space or active).
		mov al, 03h 	// Self-test sub. if this line becomes "mov al,13h".
		out dx, al 		// Finish set up the MCR.
		
		mov dx, IER 	// Set up the Interrupt Enable Register.
		mov al, 0 		// No interrupt utilized.
		out dx, al 		//
	}
} 


/****************************************************************************
* Send Data to the THR in the UART *
****************************************************************************/
char sends(char c)
{
	char feedback;
	_asm
	{
		done: mov dx, LSR 	// Check the Line Status Register.
		in al, dx 			// Inspect the state word.
		test al, 20h 		// THR is empty? (when b5 = 1: THR is empty).
		jz done 			// No, continuing to check it and waiting.
		mov dx, COM1 		// THR is empty & ready to send the next character.
		mov al, c 			// Assign character c to lower-byte in A register.
		mov feedback, al 	// Return the sent-out character as a feedback.
		out dx, al 			// Send the character to the 8250.
		jmp end
		mov al, '?' 		// Error occurs, send '?' as a feedback.
		mov feedback, al 	// Return the error information.
		end: nop
	}
	return feedback;
}

 
/******************************************************************************
* Receiving the character from the 8250 controller. *
*******************************************************************************/
char reces()
{
	char dd;
	_asm
	{ 						// Line Status Register Bit Definition
		done: mov dx, LSR 	// Check the Line Status Register b0 = 1: Receive data is ready
		in al, dx 			// b1 = 1: Overrun error
		//test al, 1eh 		// Detect any error happend? b2 = 1: Parity error
		//jnz error 		// Yes, go to error processing. b3 = 1: Framing error
		test al, 01h 		// The data is ready? (b0 = 1?) b4 = 1: Break interrupt
		jz done 			// No, continuing to check. b5 = 1: THR is empty
							// (ready to send data)
		mov dx, COM1		// Data is ready b6 = 1: Transmit Shift Register
							// is empty
		in al, dx 			// Get the character from the b7 is always zero
							// receiver reg (3f8h_COM1).
		mov dd, al 			// Returning the character received.
		jmp end 			// RHR: Receiver Holding Register
		//error: mov dx, COM1 // Error occurs.
		//in al, dx 
		//mov al, '?' 		// Return a '?' as an indicator of the error
		//mov dd, al
		end: nop
	}
	return dd;
} 
 
/*****************************************************************************
* Delay subroutine to delay certain period of time *
****************************************************************************/
void Delay(int num)
{
	int m, n, cycle = MAX;
	for (m = 0; m <= num * cycle; m++)
		n = m - 1;
	return;
}
/******************************* End of Code *********************************/