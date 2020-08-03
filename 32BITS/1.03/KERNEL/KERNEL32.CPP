#include <function.h>

static unsigned char rgb = 0x7;

void main() 
{
	char *message = "Micro SO 1.03 32 Bits!!";
	char *msgasm = "Chamando uma funcao em Assembly, compilada com o Microsoft Macro Assemby v6.15 !";
	char *msgcpp = "Criando Kernel com o Microsoft Visual C++ 2.0 !!";
	
	unsigned char* p = defineline(6);
	
	while(*message)
	{
		*p++ = message[0];
		*p = rgb;
		
		message++;
		p++;
	}

	debugprint(msgasm, 7);	
	debugprint(msgcpp, 8);
}

unsigned char *defineline(int linenumber)
{
	unsigned char* pos = (unsigned char*)(VID_MEMORY + (BASE_LINE * linenumber));
	return pos;
}
