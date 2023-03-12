;-----------------------------------------------------------------------
;    Module: LCD programme
;    Author: Jiaying Huang 
;    Version: 1.0
;    1st Mar 2023
;
;    Description:
;		This programme provedes several functions to manipulate the LCD.
;
;    Specific to HD44780 LCD 
;------------------------------------------------------------------------   

read_control_signal 		       EQU 4 ; the signal for reading the control register in the LCD
write_to_control_signal 		   EQU 0 ; the signal for writing to the control register in the LCD
write_to_data_signal   		       EQU 2 ; the signal for writing to the data register in the LCD
enable 						       EQU 1 ; enable the LCD operation
disable 					       EQU 1 ; disable the LCD operation
if_busy   					       EQU &80 ; signal to sheck if the LCD is busy
busy 						       EQU &80 ; a bit which is set for busy 
DELAY_LOOP_TIMES 			       EQU &8000
clear_display_command 		       EQU &01
move_cursor_to_line1_beginning_command     EQU &80

;------------------------
;    Procedure: LCD_print_char
;
;    Description:
;        Print a character onto the LCD display.  
;   
;    Parameter:
;       R4: a character to be printed 
;------------------------

LCD_print_char      STMFD SP!, {R0, R1, LR}             
            
                    MOV R0, #write_to_data_signal ; write to data register in LCD 
                    MOV R1, R4 ; Get the parameter (a char) from  cotent of R4 
                    BL LCD_write

                    LDMFD SP!, {R0, R1, PC}

;------------------------
;    Procedure: LCD_move_cursor_to_line1_beginning
;
;    Description:
;        As described in the name.  
;   
;    No parameter required 
;------------------------
LCD_move_cursor_to_line1_beginning  STMFD SP!, {R0, R1, LR}

                                    MOV R0, #write_to_control_signal       ; Write to control register in LCD 
                                    MOV R1, #move_cursor_to_line1_beginning_command
                                    BL LCD_write

                                    LDMFD SP!, {R0, R1, PC}

;------------------------
;    Procedure: LCD_clear
;
;    Description:
;        Clear LCD display.  
;   
;    No parameter required 
;------------------------
LCD_clear           STMFD SP!, {R0, R1, LR}

                    MOV R0, #write_to_control_signal       ; Write to control register in LCD 
                    MOV R1, #clear_display_command            ; clear command (&01) for LCD
                    BL LCD_write  
                    BL delay

                    LDMFD SP!, {R0, R1, PC}

;----------------------------------------------------------------
;    Procedure: LCD_write
;
;    Description:
;              This function writes data to the one of two registers in the LCD.
;
;    Parameters: 
;               R0: signals to select to which register (control or data) to write. 
;               R1: data to be sent to the LCD.
;----------------------------------------------------------------
LCD_write       STMFD SP!, {R0-R2, LR}
				
				MOV R2, #io_base_addr

LCD_write1 		MOV R0, #read_control_signal   	; Set signals {RW = 1, RS = 0, E = 0}
                STRB R0, [R2, #PIO_B]		; At Port B    

                EOR R0, R0, #enable			; Validate the action above by enable the LCD
				STRB R0, [R2, #PIO_B]

                LDRB R1, [R2, #PIO_A]       ; Load contents in Control register from LCD

                EOR R0, R0, #disable        ; Disable the LCD
                STRB R0, [R2, #PIO_B]

                TST R1, #if_busy            ; Check bit 7 or busy 
                BNE LCD_write1           ; if busy, repeat the steps above

                ; Load parameters
                LDRB R0, [SP] ; Signals 
                LDRB R1, [SP, #4] ; Data

                STRB R0, [R2, #PIO_B]      ; write signals to PortB
                STRB R1, [R2, #PIO_A]      ; write data to PortA

                EOR R0, R0, #enable         ; Enable write action
				STRB R0, [R2, #PIO_B]

                EOR R0, R0, #disable   		; Disable the action
				STRB R0, [R2, #PIO_B]

                LDMFD SP!, {R0-R2, PC}

;---------------------------------------------------------
;    Stupid delay 
;    Description:
;		Repeat substracting a value to zero and then exit 
;---------------------------------------------------------
delay	            STMFD SP!, {R0}

		            MOV R0, #DELAY_LOOP_TIMES
delay1	            SUBS R0, R0, #1
                    BNE delay1

                    LDMFD SP!, {R0}
                    MOV PC, LR