;-----------;
; GDT Table ;
;-----------;

GDT_BEGIN       =       $
GDT     LABEL           WORD
        GDT_0           S_DESC <0,0,0,0,0,0>                                            ; 00
        GDT_GDT         S_DESC <GDT_SIZE-1,,,ACS_DATA,0,>                               ; 08
        GDT_CS16        S_DESC <SIZE_CSEG16-1,,,ACS_CODE,0,>                            ; 10
        GDT_DS          S_DESC <SIZE_DSEG-1,,,ACS_DATA+ACS_DPL_3,0,>                    ; 18
        GDT_SS          S_DESC <SIZE_STACK-1,,,ACS_DATA,0,>                             ; 20
        GDT_BIOS        S_DESC <SIZE_BIOS-1,LOW_BIOS,HIGH_BIOS,ACS_DATA+ACS_DPL_3,0,0>  ; 28
        GDT_TEXT        S_DESC <SIZE_TEXT-1,LOW_TEXT,HIGH_TEXT,ACS_DATA+ACS_DPL_3,0,0>  ; 30
        GDT_GRAPH       S_DESC <SIZE_GRAPH-1,LOW_GRAPH,HIGH_GRAPH,ACS_DATA+ACS_DPL_3,0,0>;38
        GDT_FLAT        S_DESC <0FFFFH,0,0,ACS_DATA,08FH,0>    ; 4 GB SEGMENT ;))       ; 40
        GDT_CS32        S_DESC <SIZE_CSEG32-1,,,ACS_CODE+ACS_READ,0,>                   ; 48
        GDT_IDT         S_DESC <SIZE_IDT-1,,,ACS_IDT,0,>                                ; 50

        GDT_CS_0        S_DESC <SIZE_CS_0-1,,,ACS_CODE+ACS_DPL_3,0,>                    ; 58
        GDT_CS_1        S_DESC <SIZE_CS_1-1,,,ACS_CODE+ACS_DPL_3,0,>                    ; 60
        GDT_SS_0        S_DESC <SIZE_STACK-1,,,ACS_DATA+ACS_DPL_3,0,>                   ; 68
        GDT_SS_1        S_DESC <SIZE_STACK-1,,,ACS_DATA+ACS_DPL_3,0,>                   ; 70

        GDT_TSS_MAIN    S_DESC <SIZE_TSS-1,,,ACS_TSS,0,>                                ; 78
        GDT_TSS_0       S_DESC <SIZE_TSS-1,,,ACS_TSS,0,>                                ; 80
        GDT_TSS_1       S_DESC <SIZE_TSS-1,,,ACS_TSS,0,>                                ; 88
GDT_SIZE        =       ($ - GDT_BEGIN)

CS16_DESC       =               (GDT_CS16 - GDT_0)
DS_DESC         =               (GDT_DS - GDT_0)        + RPL_3
SS_DESC         =               (GDT_SS - GDT_0)
BIOS_DESC       =               (GDT_BIOS - GDT_0)      + RPL_3
TEXT_DESC       =               (GDT_TEXT - GDT_0)      + RPL_3
GRAPH_DESC      =               (GDT_GRAPH - GDT_0)     + RPL_3
FLAT_DESC       =               (GDT_FLAT - GDT_0)
CS32_DESC       =               (GDT_CS32 - GDT_0)
IDT_DESC        =               (GDT_IDT - GDT_0)
CS_0_DESC       =               (GDT_CS_0 - GDT_0)      + RPL_3
CS_1_DESC       =               (GDT_CS_1 - GDT_0)      + RPL_3
SS_0_DESC       =               (GDT_SS_0 - GDT_0)      + RPL_3
SS_1_DESC       =               (GDT_SS_1 - GDT_0)      + RPL_3
TSS_MAIN_DESC   =               (GDT_TSS_MAIN - GDT_0)
TSS_0_DESC      =               (GDT_TSS_0 - GDT_0)
TSS_1_DESC      =               (GDT_TSS_1 - GDT_0)
