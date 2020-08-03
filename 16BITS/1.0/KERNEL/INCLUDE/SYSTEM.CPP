#include "system.h"

const char* BemVindo = "          ############### Bem Vindo ao Micro SO v 0.1 ###############";
const char* Developer = "          --- Desenvolvimento em 20/09/2014 -- By Marcos R. Costa ---";
char* ImageFile = "           ";

char VerificaRetorno()
{
	char value = 0;
	
	__asm
	{
		cmp dx, 01h
		jne fimRetorno
		mov [value], 01h
		
		fimRetorno:
	}
	
	return value;
}

void Welcome()
{
	__asm
	{
		mov ah, 00h
		mov al, 03h
		int 10h 
		
		mov si, [BemVindo]
		mov cx, 69
		whileShowPrompt01:
			lodsb
			mov ah, 0eh
			int 10h
		Loop WhileShowPrompt01
		
		mov cx, 01
		whileShowPrompt02:
			mov ah, 0eh
			mov al, 0Ah
			int 10h
			mov ah, 0eh
			mov al, 0Dh
			int 10h
		Loop WhileShowPrompt02
		
		mov si, [Developer]
		mov cx, 69
		whileShowPrompt03:
			lodsb
			mov ah, 0eh
			int 10h
		Loop WhileShowPrompt03
		
		mov ah, 0eh
		mov al, 0Ah
		int 10h
		mov ah, 0eh
		mov al, 0Dh
		int 10h
		
		mov dh, 03h
		mov dl, 00h
		mov bh, 00h
		mov ah, 02h
		int 10h
	}
}
void ShowPrompt()
{
	__asm
	{	
		mov ah, 0eh
		mov al, 0Ah
		int 10h
		
		mov ah, 0eh
		mov al, 0Dh
		int 10h
		
		mov ah, 0eh   
		mov al, 41h
		int 10h 
	   
		mov al, 3ah
		int 10h
		
		mov al, 5ch
		int 10h

		mov al, 3eh
		int 10h
		
		xor bx, bx
		WhileClean:
			cmp bx, 11
			je EndClean
			mov cs:[600h+bx], 0
			inc bx
		jmp WhileClean
		EndClean:
		
		xor ax, ax
		xor bx, bx
		xor cx, cx
		xor dx, dx
		
		push ax
		push bx
		push cx
		push dx
	}
}

char GetChr()
{
	char charValue = 0;
	char CurX = 0;
	char CurY = 0;
	
	__asm
	{
		mov ah, 3
		int 10h
		
		mov [CurX], dh
		mov [CurY], dl
		
		xor ax, ax
		int 16h
		
		cmp ah, 4Bh ; seta esquerda
		jne Seta01
		dec dl
		jmp ExecutaSeta
		Seta01:
		cmp ah, 4Dh ; seta direita
		jne ContinueSeta
		inc dl
		ExecutaSeta:
		pop bx
		dec bx
		push bx
		mov ah, 02h
		int 10h
		jmp FimGetChr
		
		ContinueSeta:
		
		cmp ah, 48h
		jne Seta02
		mov dl, [CurY]
		jmp ExecutaSeta02
		Seta02:
		cmp ah, 50h
		jne FimSeta
		mov dl, [CurY]
		
		ExecutaSeta02:
		pop bx
		push bx
		mov ah, 02h
		int 10h
		jmp FimGetChr
		
		FimSeta:
		
		mov [charValue], al
		
		cmp al, 8
		je BackSpaceKey
		cmp al, 13
		je EnterKey
		
		cmp al, 61h
        jb ContinueGetChr
        cmp al, 7Ah
        ja ContinueGetChr
        and [charValue], 11011111b
        
        ContinueGetChr:
		mov ah, 0eh
		
		pop bx
		mov dl, [charValue]
		mov cs:[0600h+bx], dl
		inc bx
		mov cs:[0600h+bx], 0
		push bx
		
		int 10h
		jmp FimGetChr
		
		BackSpaceKey:
		cmp [CurY], 4
		je FimGetChr
		jl FimGetChr
		
		pop bx
		dec bx
		mov cs:[0600h+bx], 00h
		push bx
		
		mov ah, 0eh
		int 10h
		
		mov ah, 0eh
		mov al, 20h
		int 10h
		
		mov ah, 0eh
		mov al, 8
		int 10h
		jmp FimGetChr
		
		EnterKey:
		mov ah, 03
		int 10h
		
		mov ah, 02h
		int 10h
		jmp FimGetChr
			
		FimGetChr:
		
	}
	
	return charValue;
}

void Printf()
{
	__asm
	{
	
		mov ah, 0eh
		mov al, 0ah
		int 10h
		
		mov ah, 0eh
		mov al, 0dh
		int 10h
		
		xor bx, bx
		mov si, [ImageFile]
		WhilePrintf:
			mov ah, 0eh
			lodsb
			cmp al, 00h
			je sair
			int 10h	
			inc bx
		jmp WhilePrintf
		
		sair:
		xor bx, bx
	}
}

void DefinirPrograma()
{
	int i = 0;
	int Executar = 0;
	char COMMAND = 0;
	char setImageFile[10];
	char* DIR = "DIR";
	
	__asm
	{
		mov ax, 0800h
		mov es, ax
		
		cmp cs:[600h], 0
		je NaoDefinir
		
		mov cx, 3
		mov si, 600h
		mov di, DIR
		repe cmpsb
		
		jne Comando
			mov Executar, 0
			jmp sairDefine
			
		Comando:
			mov Executar, 1
			jmp sairDefine
			
		NaoDefinir:
			mov Executar, 2
		
		sairDefine:
	}
	
	switch(Executar)
	{
		case 0:
			ImageFile = "COMMAND COM";
			break;
		
		case 1:
			for (i = 0; i <= 10; i++)
			{
				__asm
				{
					mov bx, [i]
					mov al, cs:[600h+bx]
					mov COMMAND, al
				}
				
				if (COMMAND == 0)
				{
					setImageFile[i] = ' ';
					if (i == 8 && Executar == 1)
						setImageFile[i] = 'C';
					else if (i == 9 && Executar == 1)
						setImageFile[i] = 'O';
					else if (i == 10 && Executar == 1)
						setImageFile[i] = 'M';
				}
				else
				{
					setImageFile[i] = COMMAND;
				}
				
				ImageFile = setImageFile;
			}
			break;
			
		case 2:
			ImageFile = "           ";
			__asm 
			{
				xor bx, bx
				WhileClean:
					cmp bx, 11
					je EndClean
					mov cs:[600h+bx], '$'
					inc bx
				jmp WhileClean
				EndClean:
			}
			break;
	}	
}

void ExecutarPrograma()
{	
	char* ERROR = "Comando ou programa nao encontrado!";
	
	char Trilha = 0;
	char Cabeca = 0;
	char Setor = 0;
	char bsDriveDisquete = 0;
	
	int Cluster = 0;
	
	int bpbTotalSetoresPorTrilha = 18;
	int bpbTotalCabecasNoDisco = 2;
	int bpbTotalDiretoriosArquivos = 224;
	
	__asm
	{
		mov ax, 0800h
		mov es, ax
		
		mov ah, 0eh
		mov al, 0ah
		int 10h
		
		mov ah, 0eh
		mov al, 0dh
		int 10h

		jmp start
		
		LeiaDisco:
			call ConvertLBACHS
			mov ah, 02h
			mov al, 01h
			mov ch, [Trilha]  ; C
			mov dh, [Cabeca]  ; H
			mov cl, [Setor]   ; S
			mov dl, [bsDriveDisquete]
			int 13h	
		
		ConvertLBACHS: 
			xor dx, dx                
			div [bpbTotalSetoresPorTrilha]  
			inc dl                    
			mov [Setor], dl
			xor dx, dx                
			div [bpbTotalCabecasNoDisco] 
			mov [Cabeca], dl
			mov [Trilha], al 
			ret
		
		start:
			xor ax, ax
			xor bx, bx
			xor cx, cx
			xor dx, dx
			
		;Leitura do Diretorio Raiz a procura do Kernel 
		mov al, 19 ; Endereco LBA do Diretorio Raiz
		mov bx, 650h  
		call LeiaDisco 	 
    
    mov cx, bpbTotalDiretoriosArquivos   
    mov di, 650h 
    
    while:
        mov si, [ImageFile]
        push cx 
        push di
        mov cx, 0Bh
        rep cmpsb
        je LeiaFAT
        pop di
        add di, 20h
        pop cx
        sub cx, 20h
    loop while
    
    sair:
	jmp erro
    
    LeiaFAT: 
            
        pop di
        mov dx, [di + 1Ah]
        mov [Cluster], dx 
        mov bx, 650h 
        mov ax, 1d ; Endereco LBA da Tabela FAT 
        call LeiaDisco
        
        mov ax, 0900h
        mov es, ax
        mov bx, 0100h
        push bx   
        
        LeiaArquivo:
            
            ; A regra abaixo consiste em: 
            ; Endereco LBA da area de dados dos arquivos
            ; que se inicia no Setor 33 - 2 primeiros Clusters reservados = 31 
            ; Mais Cluster indicado na tabela FAT. Entao 31 + 2 = 33 para o primeiro arquivo no disco
            ; Lembrando que cada Cluster e um Setor no Disquete  
            mov ax, 31d
            mov dx, [Cluster]
            add ax, dx 
            call LeiaDisco 
            
            mov bx, 650h
            mov ax, [Cluster] 
            mov cx, ax
            mov dx, ax
            shr dx, 1     ;calculo para leitura de endereco de memoria
            add cx, dx    ;onde estara a informacao do proximo cluster
            add bx, cx    ;cluster atual / 2 + cluster
            mov dx, [bx] 
            
            ; Apos a leitura de cada cluster, avancamos
            ; mais um setor na memoria, para armazenar 
            ; os dados do proximo cluster 
            pop bx
            add bx, 0200h
            push bx
        
            test    ax, 0001h
            jnz ClusterPar 
                  
            ClusterImpar:
                  
                and     dx, 0000111111111111b  
                jmp ValidaFimClusters
                 
            ClusterPar:
        
                shr     dx, 0004h  
                  
            ValidaFimClusters:
            
                mov [Cluster], dx 
                cmp dx, 0FF0h 
                jb LeiaArquivo
		
		push 0900h
		push 0100h
		retf
		
		erro:
			mov cx, 35
			mov si, [ERROR]
			WhileErro:
				lodsb
				mov ah, 0eh
				int 10h
			loop WhileErro		
	}
}