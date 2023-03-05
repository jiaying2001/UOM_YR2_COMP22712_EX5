;-----------------------------------------------------------------------
;    Module: BCD Counter programme
;    Author: Jiaying Huang 
;    Version: 1.0
;    2st Mar 2023
;
;    Description:
;		a program to increment a BCD counter and display it on the screen
;
;    Implementation:
;        Using the data-driven algorithm to handle the states, each state does a particular task.
;            reset state (0): reset the BCD to 0 and switch to the pause state (1)
;            pause state (1): read the button signals, if upper button signal is set, then switch to the press_or_hold state (2), 
;                             else if lower button signal is set, switch to the increment state (3), else pause state (1).
;            press_or_hold state (2): first check if it is a press or hold, if a press, then switch to the pause state (1),
;                                     else switch to the reset state (0)
;            increment state (3): increment the BCD per second and display it on the screen, 
;                                 when the upper button pressed, then switch to the press_or_hold state (2)
;------------------------------------------------------------------------ 

test_if_bit_7_set				   EQU &80 ; test if lower button is set
test_if_bit_6_set				   EQU &40 ; test if upper button is set
reset_state 					   EQU 0
pause_state						   EQU 1
press_or_hold_state 			   EQU 2
increment_state         		   EQU 3

User_code_start 
case            			LDRB R0, state ; jump to the corresponding precodure 
							ADR R1, table 
							LDR PC, [R1, R0, LSL #2] ; table + (state * 4)

BCD             			DEFB 0, 0
state						DEFB reset_state

table           			DEFW reset_state
							DEFW pause_state
							DEFW press_or_hold_state
							DEFW increment_state

reset_state_table 			DEFB 0, 1, 2, 3
pause_state_table 			DEFB 0, 1, 2, 3
press_or_hold_state_table 	DEFB 0, 1, 2, 3
increment_state_table 		DEFB 0, 1, 2, 3
							ALIGN

reset_state 	; Reset and print it out
				MOV R1, #0
				ADR R0, BCD
				STRH R1, [R0]
				SVC 3 ; move the cursor to the start
				BL BCD_print_two_bytes
				; Switch to the pause state
				ADR R0, reset_state_table
				LDRB R0, [R0, #pause_state]
				STRB R0, state
				B case

pause_state		ADR R8, pause_state_table

				SVC 2 ; Read Buttons and R1 holds the return value
		
				TST R1, #test_if_bit_7_set ; if lower button is pressed, switch to the increment state
				LDRNEB R0, [R8, #increment_state]
				STRNEB R0, state
				BNE case

				TST R1, #test_if_bit_6_set ; if upper button is pressed, switch to the press_or_hold state
				LDRB R0, [R8, #pause_state]
				LDRNEB R0, [R8, #press_or_hold_state]
				STRB R0, state
				B case

; Test if it is a press or hold
; Impl: Once the upper button is pressed, set up a counter. When released,
; if the counter is greater than one second, then it is a hold.
press_or_hold_state  	ADR R8, press_or_hold_state_table
		        		; Test if it is a press or a hold
						MOV R2, #0 ; set up a counter
press_or_hold_state1 	CMP R2, #100 ; if have pressed for more than a second, switch to the reset state
						BGT press_or_hold_state2
						MOV R0, #10; 10ms delay
						SVC 1 ; delay procedure
						ADD R2, R2, #1
						SVC 2 ; Read Buttons each 10ms
						TST R1, #test_if_bit_6_set
						BNE press_or_hold_state1 ; if not branch, meanning that it is a press

press_or_hold_state2  	LDRB R0, [R8, #reset_state]
						LDRLEB R0, [R8, #pause_state]
						STRB R0, state
						B case

increment_state      	ADR R8, increment_state_table
increment_state1		MOV R2, #0 ; set up a counter
						MOV R0, #10 ; 10ms delay
increment_state2		SVC 1 ; delay procedure

               			SVC 2 ; Read Buttons each 10ms
						TST R1, #test_if_bit_6_set ; if upper button is pressed, switch to press_or_hold_state
						LDRNEB R0, [R8, #press_or_hold_state]
						STRNEB R0, state
						BNE case ; Branch to check if it is a press or a hold

						ADD R2, R2, #1 ; increment the counter
						CMP R2, #100 ; 100 * 10ms = 1s
						BNE increment_state2
						; increment the BCD per second
						ADR R0, BCD
						MOV R1, #1
						BL BCD_one_byte_half_adder
						BL BCD_one_byte_half_adder
						; print the BCD
						SVC 3
						ADR R0, BCD
						BL BCD_print_two_bytes
						; switch to increment_state
						LDRB R0, [R8, #increment_state]
						STRB R0, state
						B case
GET BCD.s




