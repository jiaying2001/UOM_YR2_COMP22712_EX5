;-----------------------------------------------------------------------
;    Module: Kernel programme
;    Author: Jiaying Huang 
;    Version: 1.0
;    2st Mar 2023
;
;    Description:
;		
;
;------------------------------------------------------------------------ 

GET size.s
GET mode.s

Reset 			B reset_handler 	; Reset (address 0)
				B Undef_handler 	; Undefined instruction
				B SVC_entry 		; SVC call
				B Prefetch_abort 	; Page fault
				B Data_abort 		; Page fault
				NOP 				; Unused ‘vector’
				B IRQ_service 		; Interrupt
				B FIQ_service 		; Fast interrupt

SVC_entry		STMFD SP!, {R0, R2, LR}

				LDR R0, [LR, #-4] ; Read SVC instruction
				BIC R0, R0, #&FF000000 ; Mask off opcode

				CMP R0, #Max_SVC ; Check upper limit
				BHS SVC_unknown

				ADR R2, SVC_table
				ADR LR, SVC_exit
				LDR PC, [R2, R0, LSL #2] 

SVC_exit		LDMFD SP!, {R0, R2, LR}
				MOVS PC, LR

SVC_table		DEFW SCV_0
                DEFW SVC_1
                DEFW SVC_2
                DEFW SVC_3

SCV_0 			STMFD SP!, {R4, LR}

        		; Current Stack View: -> R4, LR, R0, R2, LR
				LDR R4, [SP, #(2 * 4)] ; Get the param from R0
				BL	LCD_print_char

				LDMFD SP!, {R4, PC}	

SVC_1   		STMFD SP!, {R4, R8, LR}

		        MOV R8, #io_base_addr
		        LDR R4, [SP, #(3 * 4)] ; Get the param from R0
		        CMP R4, #255 ; if the param exceeds the max value, then exit.
		        BLLS Timer_start_delay

		        LDMFD SP!, {R4, R8, PC}				

SVC_2   		STMFD SP!, {R8}

        		MOV R8, #io_base_addr
        		LDRB R1, [R8, #PIO_B] ; Read Buttons

        		LDMFD SP!, {R8}
        		MOV PC, LR

SVC_3   		STMFD SP!, {LR}
		        BL LCD_move_cursor_to_line1_beginning
		        LDMFD SP!, {PC}

SVC_unknown B SVC_exit

reset_handler 	LDR R0, _stack_base
				MOV SP, R0
				SUB R0, R0, #Len_SVC_Stack
				MSR CPSR, #Mode_System
				MOV SP, R0 
				MSR CPSR, #Mode_Supervisor

 				DEFS &30
_stack_base
				BL LCD_clear

				MOV LR, #Mode_User ; User mode, no ints.
				MSR SPSR, LR ;
				ADR LR, User_code_start
				MOVS PC, LR ; ‘Return’ to user code
GET timer.s
GET LCD.s



