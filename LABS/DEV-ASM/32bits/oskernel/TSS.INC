;---------------------------------------;
; TSSs of main and few additional tasks ;
;---------------------------------------;

TSS_MAIN        S_TSS   <>
TSS_0           S_TSS   <>
TSS_1           S_TSS   <>

; TASK LIST
TASK_LIST       DW      TSS_MAIN_DESC, TSS_0_DESC, TSS_1_DESC, 0

; THIS INDEX VARIABLE IS USED TO CHOSE THE TASK TO SWITCH TO
TASK_INDEX      DW      2

; THIS 6-BYTE PM ADDRESS IS USED TO PERFORM FAR JUMP TO TSS
TASK_ADDR       DF      0
