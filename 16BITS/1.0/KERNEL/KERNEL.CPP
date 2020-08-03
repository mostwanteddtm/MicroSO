#include "system.h"
extern "C" void KernelMain()
{
	char charValue = 0;
	
	if (VerificaRetorno() == 0)
	{
		Welcome();
	}
	
	ShowPrompt();
	
	for(;;)
	{
		char charValue = GetChr();
		
		if (charValue == 13)
		{
			DefinirPrograma();
			//Printf();
			ExecutarPrograma();
			ShowPrompt();
		}
	}
	return;
}