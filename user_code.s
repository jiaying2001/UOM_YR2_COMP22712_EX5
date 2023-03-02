;-----------------------------------------------------------------------
;    Module: BCD Counter programme
;    Author: Jiaying Huang 
;    Version: 1.0
;    2st Mar 2023
;
;    Description:
;		
;
;------------------------------------------------------------------------ 

test_if_bit_7_set				   EQU &80
test_if_bit_6_set				   EQU &40

User_code_start 
case            LDRB R0, state
                ADR R1, table 
                LDR PC, [R1, R0, LSL #2] ; table + (state * 4)

BCD             DEFB 0, 0
state			DEFB 0
                ALIGN
table           DEFW reset
				DEFW pauseState
				DEFW press_or_hold
				DEFW increment
reset_state_table 	DEFB 0, 1, 2, 3
pause_state_table 	DEFB 0, 1, 2, 3
press_or_hold_state_table 	DEFB 0, 1, 2, 3
increment_state_table 	DEFB 0, 1, 2, 3
				ALIGN

reset 	MOV R1, #0
		ADR R0, BCD
		STRH R1, [R0]
		SVC 3
		BL BCD_print_two_bytes

		ADR R0, reset_state_table
		LDRB R0, [R0, #1]
		STRB R0, state
		B case

pauseState	ADR R8, pause_state_table

		SVC 2 ; Read Buttons and R1 holds the return value
		
		TST R1, #test_if_bit_7_set
		LDRNEB R0, [R8, #3]
		STRNEB R0, state
		BNE case

		TST R1, #test_if_bit_6_set
		LDRB R0, [R8, #1]
		LDRNEB R0, [R8, #2]
		STRB R0, state
		B case


press_or_hold   ADR R8, press_or_hold_state_table

		        ; Test if it is a press or a hold
				MOV R2, #0 ; set up a counter
press_or_hold1 	CMP R2, #100
				BGE press_or_hold2
				MOV R0, #10; 10ms delay
				SVC 1 ; delay procedure
                ADD R2, R2, #1
                SVC 2 ; Read Buttons each 10ms
                TST R1, #test_if_bit_6_set
                BNE press_or_hold1
                CMP R2, #100 ; 100 * 10ms = 1s

press_or_hold2  LDRB R0, [R8]
                LDRLTB R0, [R8, #1]
                STRB R0, state
				B case

increment       ADR R8, increment_state_table
increment1		MOV R2, #0 ; set up a counter
				MOV R0, #10 ; 10ms delay
increment2		SVC 1 ; delay procedure
                SVC 2 ; Read Buttons each 10ms

                TST R1, #test_if_bit_6_set
                LDRNEB R0, [R8, #2]
                STRNEB R0, state
				BNE case ; Branch to check if it is a press or a hold

                ADD R2, R2, #1
                CMP R2, #100 ; 100 * 10ms = 1s
                BNE increment2

                ADR R0, BCD
                MOV R1, #1
                BL BCD_one_byte_half_adder
                BL BCD_one_byte_half_adder

                SVC 3
                ADR R0, BCD
				BL BCD_print_two_bytes

				B increment1

GET BCD.s




