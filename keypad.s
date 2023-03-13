;-----------------------------------------------------------------------
;    Module: keypad programme
;    Author: Jiaying Huang 
;    Version: 1.0
;    2st Mar 2023
;
;    Description:
;			includes functions to manipulate the keypad
;
;    Key states:  PRESSED and RELEASED
;
;------------------------------------------------------------------------

PRESSED             EQU 1
RELEASED            EQU 0
scan_first_row      EQU &2F
scan_second_row     EQU &4F
scan_thrid_row      EQU &8F
key_state_table_size EQU 12
key_count_table_size EQU 12
max_debounce_count   EQU 8
min_debounce_count   EQU 0

test_code                  BL debounce
                            B test_code


; A keypad map reading the device as follows: 
; |3|  |6|  |9|  |#|
;
; |2|  |5|  |8|  |0|
;
; |1|  |4|  |7|  |*|
;
;Key state table indecating if a key is pressed
key_state_table DEFB 0, 0
;key count table
;Incrementing it if the key is pressed and decrementing it if it is not
key_count_table DEFB 0, 0, 0, 0
                DEFB 0, 0, 0, 0
                DEFB 0, 0, 0, 0
                ALIGN
;------------------------
;    Procedure: debounce
;
;    Description:
;          increment or decrement the count of each key depending on the corresponding state in the keypad map.
;          If reach the max, change the key state to PRESSED, else if reach the 0, RELEASED, else unchange
;   
;    No parameter required
;------------------------
debounce        STMFD SP!, {R0-R8}
                MOV R8, #FPGA_io_base_addr
                ; Loop Unrolling
                MOV R0, #scan_first_row
                STRB R0, [R8, #S0_upper_control_register]
                LDRB R1, [R8, #S0_upper_data_register]
                LSL R1, R1, #4

                MOV R0, #scan_second_row
                STRB R0, [R8, #S0_upper_control_register]
                LDRB R2, [R8, #S0_upper_data_register]
                ORR R1, R1, R2
                LSL R1, R1, #4 

                MOV R0, #scan_third_row
                STRB R0, [R8, #S0_upper_control_register]
                LDRB R2, [R8, #S0_upper_data_register]
                ORR R1, R1, R2

                ; keymap in the least significant 12 bits in R1
                ; |#|  |9|  |6|  |3|  |0|  |8|  |5|  |2|  |*|  |7|  |4|  |1|  

                ; increment or decrement the count for each key iteratively 
                ; from the end of the key_count_table to the beginning.
                ; Since it depends on the key state stored in R1, I chose to
                ; initialize R4 to 1 and TST R1 with it to test if corresponding bit is set, 
                ; logical shfit left R4 and repeat testing each bit in the first 12 bits of R1.
                ; In the loop, if the key state is 1, increment the count. otherwise, decrement it.
                ; If the count reach the max, set the corresponding bit in the key state table as pressed.
                ; R4 = 1
                ; for R5=size-1; R5 >= 0; R5--{
                ;     if(TST R1, R4 == 0){
                ;         R3 -= 1
                ;         if reach the min, R0 = 0
                ;     }else{
                ;         R3 += 1
                ;         if reach the max, R0 = 1
                ;     }   
                ;     R4 = R4 << 1    
                ; }
                ADR R8, key_count_table 
                ADR R6, key_state_table ; 2 bytes but only 12 bits used 
                LDRH R0, [R6] 
                MOV R5, #key_count_table_size-1 ; the index of the end of the count table 
                MOV R4, #1

debounce1       LDRB R3, [R8, R5] ; load key count
                TST R1, R4 ; test each bit in the first 12 bits of R1 is set
                BNE debounce2 ; if the bit is set, dump to deobunce2
                
                CMP R3, #min_debounce_count ; the case not set, decrement the count, first check if it already reached the min
                BLE debounce5 ; if it reached the min, do not decrement and go to the next iteration
                SUB R3, R3, #1 
                BAL debounce3

debounce2       CMP R3, #max_debounce_count ; do the same check as above
                BHS debounce5
                ADD R3, R3, #1                 
                CMP R3, #max_debounce_count
                ORRGE R0, R0, R4
                BAL debounce4

debounce3       CMP R3, #min_debounce_count
                BICLS R0, R0, R4

debounce4       STRB R3, [R8, R5]
debounce5       SUBS R5, R5, #1
                LSLGE R4, R4, #1
                BGE debounce1
                STRH R0, [R6]
                LDMFD SP!, {R0-R8}
                MOV PC, LR



