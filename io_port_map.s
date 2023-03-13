;-----------------------------------------------------------------------
;    Module: Mode labels 
;    Author: Jiaying Huang 
;    Version: 1.0
;    1st Mar 2023
;
;    Description:
;		Labels for the io addresses in the komodo system.
;
;------------------------------------------------------------------------ 
io_base_addr		EQU &10000000
PIO_A				EQU &0
PIO_B				EQU &04
Timer 				EQU &08
Timer_compare		EQU &0C
Serial_RxD			EQU &10
Serial_TxD			EQU &10
Serial_status		EQU &14
Interrupt_requests	EQU	&18
Interrupt_enables   EQU &1C
Halt_port			EQU &20
FPGA_io_base_addr   EQU &20000000
S0_upper_data_register    EQU 2
S0_upper_control_register EQU 3