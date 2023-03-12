;-----------------------------------------------------------------------
;    Module: Timer programme
;    Author: Jiaying Huang 
;    Version: 1.0
;    1st Mar 2023
;
;    Description:
;		This programme provedes a function to manipulate the timer generating a delay.
;
;------------------------------------------------------------------------ 

;------------------------
;    Procedure: Timer_start_delay
;
;    Description:
;        Exit when the input time passes.  
;   
;    Parameter:
;        R4: a amount of time to wait.
;
;    Implementation:
;	     Initially reset the timer to zero, repeatedly polling from timer and compare it with the input, exit when they are equal.
;
;    Limitation:
;	     This function can only serve the input between 0ms to 255ms.
;------------------------
Timer_start_delay   STMFD SP!, {R0, R4, R8}
			        CMP R4, #255 ; the max value a 8-bit value can reach
			        BHI Timer_start_delay2

			        MOV R8, #io_base_addr

			        MOV R0, #0
			        STRB R0, [R8, #Timer] ; Reset the timer to 0

Timer_start_delay1  LDRB R0, [R8, #Timer]  ; Polling time from the time 
			        CMP R0, R4 				; cmpare it with inpu value R4
			        BLS Timer_start_delay1	; Loop until they are euqal

Timer_start_delay2  LDMFD SP!, {R0, R4, R8}
			        MOV PC, LR