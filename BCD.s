;-----------------------------------------------------------------------
;    Module: BCD programme
;    Author: Jiaying Huang 
;    Version: 1.0
;    1st Mar 2023
;
;    Description:
;		This programme provedes several functions to perform an ADD arithmetic and print it out.
;
;------------------------------------------------------------------------ 

test_least_significant_four_bits    EQU :00001111
clear_least_significant_four_bits   EQU :00001111
test_most_significant_four_bits     EQU :11110000
clear_most_significant_four_bits    EQU :11110000

;------------------------
;    Procedure: BCD_one_byte_half_adder
;
;    Description:
;         Add carry in input to a one-byte BCD, considering least significant 8 bits in a 32-bit word.
;   
;    Parameter:
;       R0 -> a pointer to a one-byte BCD
;       R1 -> carry in
;    
;    Return:
;       R0 -> the input incremented by 1
;       R1 -> carry out
;       
;------------------------
BCD_one_byte_half_adder 
                        CMP R1, #0 ; Exit if the carry in param is zero
                        BEQ BCD_one_byte_half_adder1
                        LDRB R2, [R0]; Load the BCD param into R0
                        ADD R2, R2, #1 ; Add 1 to least significant 4 bits 
                        ANDS R3, R2, #test_least_significant_four_bits
                        CMP R3, #10
                        BNE BCD_one_byte_half_adder1
                        BIC R2, R2, #clear_least_significant_four_bits
                        ADD R2, R2, #&10
                        ANDS R3, R2, #test_most_significant_four_bits
                        CMP R3, #&A0
                        BICEQ R2, R2, #clear_most_significant_four_bits
                        
BCD_one_byte_half_adder1 MOVNE R1, #0
                        STRB R2, [R0], #1
                        MOV PC, LR

;------------------------
;    Procedure: 
;
;    Description:
;          
;   
;    Parameter:
;        
;------------------------
BCD_printHex8   STMFD SP!, {R4, LR}
            ROR R4, R4, #4 
            BL BCD_printHex4 
            ROR R4, R4, #28
            BL BCD_printHex4
            LDMFD SP!, {R4, PC}

;------------------------
;    Procedure: 
;
;    Description:
;          
;   
;    Parameter:
;        
;------------------------
BCD_printHex4   STMFD SP!, {R0, R4, LR} 
            LDR R4, [SP, #4]  
            ANDS R4, R4, #test_least_significant_four_bits
            ADD R0, R4, #'0'
            CMP R4, #9
            ADDHI R0, R0, #('A' - 10 - '0')
            SVC 0
            LDMFD SP!, {R0, R4, PC}