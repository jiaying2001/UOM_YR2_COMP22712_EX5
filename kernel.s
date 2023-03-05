;-----------------------------------------------------------------------
;    Module: Kernel programme
;    Author: Jiaying Huang 
;    Version: 1.0
;    2st Mar 2023
;
;    Description:
;			includes the system code accessing the hardware devices, SVC handlers and reset
;
;------------------------------------------------------------------------ 
; Labels declaration
GET size.s
GET mode.s
GET io_port_map.s

Reset 			B reset_handler 	; Reset (address 0)
				NOP 	; Undefined instruction
				B SVC_entry 		; SVC call
				NOP 	; Page fault
				NOP		; Page fault
				NOP 				; Unused ‘vector’
				NOP 		; Interrupt
				NOP 		; Fast interrupt
; dispatch SVC call to its corresponding procedure
SVC_entry		STMFD SP!, {R0, R2, LR}

				LDR R0, [LR, #-4] ; Read SVC instruction
				BIC R0, R0, #&FF000000 ; Get the integer parameter

				CMP R0, #Max_SVC ; Check upper limit
				BHS SVC_unknown

				ADR R2, SVC_table
				ADR LR, SVC_exit ; All SVC share the same exit procedure
				LDR PC, [R2, R0, LSL #2] 

SVC_exit		LDMFD SP!, {R0, R2, LR}
				MOVS PC, LR
; SVC stabe: provides currently active SVCs.
SVC_table		DEFW SCV_0
                DEFW SVC_1
                DEFW SVC_2
                DEFW SVC_3
; SVC_0: print a character to the LCD
; @param R0 a 8-bit ASCII code
; @return None
SCV_0 			STMFD SP!, {R4, LR}

        		; Current Stack View: -> R4, LR, R0, R2, LR
				LDR R4, [SP, #(2 * 4)] ; Get the param from R0
				BL	LCD_print_char

				LDMFD SP!, {R4, PC}	
; SVC_1 : wait for a delay
; @param R0 an amount of delay in milliseconds (no more than 256)
; @return None
SVC_1   		STMFD SP!, {R4, R8, LR}

		        MOV R8, #io_base_addr
		        LDR R4, [SP, #(3 * 4)] ; Get the param from R0
		        CMP R4, #255 ; if the param exceeds the max value, then exit.
		        BLLS Timer_start_delay

		        LDMFD SP!, {R4, R8, PC}				
; SVC_2 : read the two buttons
; @param None
; @return R1 a 8-bit signal in which bit 7 for the lower button and bit 6 for the upper button
SVC_2   		STMFD SP!, {R8}

        		MOV R8, #io_base_addr
        		LDRB R1, [R8, #PIO_B] ; Read Buttons

        		LDMFD SP!, {R8}
        		MOV PC, LR
; SVC_3 : move the cursor of the LCD to the line1 beginning
; @param None
; @return None
SVC_3   		STMFD SP!, {LR}
		        BL LCD_move_cursor_to_line1_beginning
		        LDMFD SP!, {PC}
; reset_handler: Initialization
; 1. set-up for the stack in Supervisor and User modes
; 2. clear the display on the LCD
SVC_unknown B SVC_exit
				
				DEFS 512	
_stack_base 	
reset_handler 	ADR R0, _stack_base ; reset_handler here treated as stack base
				MOV SP, R0
				SUB R0, R0, #Len_SVC_Stack
				MSR CPSR, #Mode_System
				MOV SP, R0 
				MSR CPSR, #Mode_Supervisor

				BL LCD_clear
				; Switch to User mode
				MOV LR, #Mode_User ; User mode, no ints.
				MSR SPSR, LR ;
				ADR LR, User_code_start
				MOVS PC, LR ; ‘Return’ to user code
GET timer.s
GET LCD.s
GET user_code.s



