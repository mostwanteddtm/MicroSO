// CPBIN.cpp : Defines the entry point for the console application.
//

/*
	30-11-18
	
	CODIGO UTILIZADO PARA TESTAR O BOOT DESENVOLVIDO PARA FAT32
	PASSOS PARA O TESTE:

	1) CRIAR UMA IMAGEM COM O BXIMAGE [C.IMG] (BOCHS 2.6.9)
	2) DEFINIR O CAMINHO DO BINARIO DE BOOT (EX01.BIN) FASE 01 DE ANALISE ATE O MOMENTO
	3) NO BOCHS, DEFINIR COMO ATA0-MASTER O ARQUIVO C.IMG
	4) NO BOCHS DEFINIR COMO BOOT: DISK
*/

#include "stdafx.h"
#include <fstream>

using namespace std;

int _tmain(int argc, _TCHAR* argv[])
{
	char *filename = "C:\\PROGRA~1\\BOCHS-~1.9\\C.IMG";
	char *boot = "..\\..\\EX01.BIN";
	char ch[0x200] = {};
	char *chr = ch;

	streampos pos;
	ifstream infile;

	infile.open(boot, ios::binary | ios::in);
	infile.read(chr, 0x200);
	infile.close();

	fstream fout(filename, fstream::in | fstream::out | fstream::binary);
	fout.seekg(0x7E00);					// start position
	fout.write(chr, 0x200);
	fout.close();

	return 0;
}

