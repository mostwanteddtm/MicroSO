// kernel.cpp
#include "CDisplay.h"
extern "C" void BootMain()
{
    CDisplay::ClearScreen();
    for(;;);

    return;
}
