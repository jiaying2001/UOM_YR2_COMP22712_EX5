User_code_start 
                ADR R7, state
                ADR R6, previous_state
                ADR R5, current_state

                LDRB R0, [R5]
                STRB R0, [R6]
                LDRH R1, key_state_table
                TST R1, #&0FFF
                MOV R2, #0
                STREQB R2, [R7]
                MOVNE R2, #1
                STRNE R2, [R7]

                CMP R0, R2
                BEQ User_code_start1
                CMP R2, #0
                STRNEB R2, [R7]
User_code_start1 MOV R0, #0
                STREQB R0, [R7]

                LDRB R0, [R7]
                ADR R2, state_table
                LDR PC, [R2, R0, LSL #2]


state_table        DEFW release_action
                   DEFW press_action
current_state      DEFB 0
previous_state     DEFB 0
state              DEFB 0
key_map             DEFB '1', '4', '7', '*'
                   DEFB '2', '5', '8', '0'
                   DEFB '3', '6', '9', '#'
                ALIGN
release_action   BAL User_code_start
press_action 
                ; keymap in the least significant 12 bits in R1
                ; |#|  |9|  |6|  |3|  |0|  |8|  |5|  |2|  |*|  |7|  |4|  |1| 
                ADR R8, key_map
                MOV, R3, #12
press_action1   ASRS R1, R1, #1
                LDRCSB R0, [R8], #1
                SVCCS 0
                SUBS R3, R3, #1
                BHI press_action1
                BAL User_code_start
