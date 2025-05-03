/*******************************************************************************
* File: screen_fsm.sv
* Author: Soham Gandhi and Aniruddh Chauhan
* Date: 2025-04-22
* Description: Screen transitions for game play
* Version: 1.0
*******************************************************************************/
import common_enums::*;

module screen_fsm #(
    parameter int CLK_FREQ_HZ = 50_000_000
) (
    input  logic        clk,
    input  logic        reset_n,
    input  logic        enter,
    input  logic        override,

    output screen_state_t  state,
    output logic        setup_complete
);

    screen_state_t next_state;
    logic [26:0] counter;

    always_ff @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            counter       <= 0;
            state         <= TITLE_SCREEN;
        end else begin
            state <= next_state;

            // Update counter
            if (state == PLAYER_SCREEN)
                counter <= counter + 27'd1;
            else
                counter <= 0;
        end
    end
    
    always_comb begin
        // Next state logic
        setup_complete = 0;
        case (state)
            TITLE_SCREEN: begin
                next_state = enter ? PLAYER_SCREEN : TITLE_SCREEN;
                if (override)
                    next_state = CHESS_SCREEN;
            end
            PLAYER_SCREEN: begin
                next_state = (counter >= (CLK_FREQ_HZ * 2)) ? SETUP_SCREEN : PLAYER_SCREEN;
                if (override)
                    next_state = CHESS_SCREEN;
            end
            SETUP_SCREEN: begin
                next_state = SETUP_SCREEN;
                if (enter) begin
                    setup_complete = 1;
                    next_state = CHESS_SCREEN;
                end 
                if (override)
                    next_state = CHESS_SCREEN;
            end
            CHESS_SCREEN:
                next_state = CHESS_SCREEN;
            default:
                next_state = TITLE_SCREEN;
        endcase
    end
endmodule
