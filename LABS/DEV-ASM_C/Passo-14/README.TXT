##################  COMILAÇÃO ENTRE C E ASSEMBLY ########################

- O COMPILADOR DA MICROSOFT INCLUI OBRIGATÓRIAMENTE A CHAMADA A FUNÇÃO PUBLICA _acrtused 
- PARA EVITAR ERRO DURANTE O PROCESSO DE LINKAGEM, CRIEI UMA FUNCÃO PUBLICA COM O MESMO NOME
- A FUNÇÃO NÃO FAZ NADA E NÃO É CHAMADA POR PADRÃO
- DESSA FRMA FOI POSSÍVEL PASSAR A COMBINAR C E ASSEMBLY, SEM AS LIBs PADRÕES, 
USANDO O MICROSOFT VISUAL C++ 1.52c

-------------------------------------------------------------------------

################## DIRETÓRIO USEDEF #####################################

- NESSE DRETÓRIO, A COMPILAÇÃO ENTRE C E ASSEMBLY UTILIZA AS LIBs PADRÕES.

-------------------------------------------------------------------------