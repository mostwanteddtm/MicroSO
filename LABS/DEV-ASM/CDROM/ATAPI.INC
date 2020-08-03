;=========================================================; 
; ATAPI Information Block                        11/12/01 ; 
;---------------------------------------------------------; 
; DOS EXTREME OS V0.01                                    ; 
; by Craig Bamford.                                       ; 
;                                                         ; 
;  * M = mandatory                                        ;  
;  * O = optional                                         ;  
;                                                         ;          
;=========================================================; 
 
R_Date         = 0    ; date reg 
W_Date         = 0    ; date reg 
R_Error        = 1    ; error reg 
W_Feature      = 1    ; feature reg 
R_SectCount    = 2    ; sector count reg 
W_SectCount    = 2    ; sector count reg 
R_Sector       = 3    ; sector number or lba bits 0-7 
W_Sector       = 3    ; sector number or lba bits 0-7 
R_Cylinder0    = 4    ; cylinder bits 0-7 or lba bits 8-15 
W_Cylinder0    = 4    ; cylinder bits 0-7 or lba bits 8-15 
R_Cylinder1    = 5    ; cylinder bits 8-15 or lba bits 16-23 
W_Cylinder1    = 5    ; cylinder bits 8-15 or lba bits 16-23 
R_DriveHead    = 6    ; drive & head bits or lba bits 24-27 
W_Drivehead    = 6    ; drive & head bits or lba bits 24-27 
R_Status       = 7    ; status reg 
W_Command      = 7    ; command reg 
 
R_Status_BSY   = 0x80 ; bit 7 
R_Status_DRDY  = 0x40 ; bit 6 
R_Status_DWF   = 0x20 ; bit 5 
R_Status_DSC   = 0x10 ; bit 4 
R_Status_DRQ   = 0x08 ; bit 3 
R_Status_CORR  = 0x04 ; bit 2 
R_Status_IDX   = 0x02 ; bit 1 
R_Status_ERR   = 0x01 ; bit 0 
 
Atapi_Packet_Command  = 0xA0 ; *M 
Atapi_Identify_Drive  = 0xA1 ; *M 
Atapi_Soft_Reset      = 0x08 ; *M 
Atapi_Service         = 0xA2 ; *O 
 
Atapi_StartStop_Group = 0x1B ; *O 
 
 
 
 
 
;================================== ATAPI MODE INFORMATION END ================================= 