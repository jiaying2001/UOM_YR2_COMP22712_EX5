;-----------------------------------------------------------------------
;    Module: BCD programme
;    Author: Jiaying Huang 
;    Version: 1.0
;    1st Mar 2023
;
;    Description:
;		This programme provedes several functions to perform an ADD BCD arithmetic and print it out.
;
;------------------------------------------------------------------------ 

test_least_significant_four_bits    EQU :00001111   ; mask other bits and evaluate least sig four bits if it exceeds or euqal to 10
clear_least_significant_four_bits   EQU :00001111   ; clear the least sig four bits if it exceeds 9
test_most_significant_four_bits     EQU :11110000   ; similar to ones above
clear_most_significant_four_bits    EQU :11110000

;------------------------
;    Procedure: BCD_print_two_bytes
;
;    Description:
;          Print out a two-byte BCD on the LCD
;   
;    Parameter:
;        R0 -> a pointer to a two-byte BCD
;------------------------
BCD_print_two_bytes STMFD SP!, {R4, LR}
                    LDRB R4, [R0, #1] ; Load the most significant eight bits and print it out
                    BL BCD_printHex8
                    LDRB R4, [R0] ; Load the least significant eight bits and print it out
                    BL BCD_printHex8
                    LDMFD SP!, {R4, PC}


;------------------------
;    Procedure: BCD_one_byte_half_adder
;
;    Description:
;         Add one to a one-byte BCD if the carry in input is set.
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
BCD_one_byte_half_adder     STMFD SP!, {R3}
                            CMP R1, #0  ; Exit if the carry in param is not set
                            BEQ BCD_one_byte_half_adder2

                            LDRB R2, [R0]; Load the BCD param into R0
                            ADD R2, R2, #1 ; Add 1 to least significant 4 bits 
                            ANDS R3, R2, #test_least_significant_four_bits
                            CMP R3, #10 ; if ls 4 bits greater than or equal to 10, add 1 to the next four bits and clear the ls 4 bits
                            BLT BCD_one_byte_half_adder1
                            BIC R2, R2, #clear_least_significant_four_bits
                            ADD R2, R2, #&10

                            ANDS R3, R2, #test_most_significant_four_bits ; After addition of ms four bits, we check if it is greater than or equal to 10 (&A0)
                            CMP R3, #&A0 ; if so, clear the ms four bits and output a carry out
                            BICGE R2, R2, #clear_most_significant_four_bits 
                        
BCD_one_byte_half_adder1    MOVLT R1, #0 ; Since R1 should be 1 if reaching this command, if ms four bits less than 10 then output 0 as carry out
                            STRB R2, [R0], #1 ; post-increment it, then it is ready for the addition of a next byte in a BCD
BCD_one_byte_half_adder2    LDMFD SP!, {R3}
                            MOV PC, LR

;------------------------
;    Procedure: BCD_printHex8
;
;    Description:
;          Print out two hex number in a byte 
;   
;    Parameter:
;        R4 -> A byte to be printed
;------------------------
BCD_printHex8   STMFD SP!, {R4, LR}
            ROR R4, R4, #4 
            BL BCD_printHex4 
            ROR R4, R4, #28
            BL BCD_printHex4
            LDMFD SP!, {R4, PC}

;------------------------
;    Procedure: BCD_printHex4
;
;    Description:
;          Print a hex number in a half byte 
;   
;    Parameter:
;        R4 -> a hex number stored in the least significant four bits
;------------------------
BCD_printHex4   STMFD SP!, {R0, R4, LR}  
            ANDS R4, R4, #test_least_significant_four_bits
            ADD R0, R4, #'0'
            CMP R4, #9
            ADDHI R0, R0, #('A' - 10 - '0')
            SVC 0
            LDMFD SP!, {R0, R4, PC}