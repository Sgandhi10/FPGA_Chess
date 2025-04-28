/*******************************************************************************
* File: board.sv
* Author: Soham Gandhi
* Date: 2025-04-27
* Description: Controls the game board
* Version: 1.1
*******************************************************************************/
import common_enums::*;

module board (
    input logic             CLOCK_50,
    input logic             reset_n,
    input logic             player,
    input logic             curr_player,
    input logic             dir,
    input screen_state_t    state,       

    input logic         key1out, // + dir
    input logic         key2out, // - dir
    input logic         key3out, // + enter

    input logic [3:0]   board_in [8][8], // 8x8 board input

    output logic [3:0]  board_out [8][8],
    output logic        square_highlight [8][8] // 8x8 board output
);

    always_ff @(posedge CLOCK_50 or negedge reset_n) begin
        if (!reset_n) begin
            // Initialize board_out on reset
            board_out[0] <= '{6, 7, 8, 9, 10, 8, 7, 6};
            board_out[1] <= '{default: 11};
            board_out[6] <= '{default: 5};
            board_out[7] <= '{0, 1, 2, 3, 4, 2, 1, 0};

            // Set middle rows to default (15)
            for (int i = 2; i <= 5; i++) begin
                board_out[i] <= '{default: 15};
            end
        end else if (state == SETUP_SCREEN) begin
            // Setup screen based on player
            if (player) begin
                board_out[0] <= '{6, 7, 8, 9, 10, 8, 7, 6};
                board_out[1] <= '{default: 11};
                board_out[6] <= '{default: 5};
                board_out[7] <= '{0, 1, 2, 3, 4, 2, 1, 0};
            end else begin
                board_out[0] <= '{0, 1, 2, 3, 4, 2, 1, 0};
                board_out[1] <= '{default: 5};
                board_out[6] <= '{default: 11};
                board_out[7] <= '{6, 7, 8, 9, 10, 8, 7, 6};
            end

            // Always initialize middle rows
            for (int i = 2; i <= 5; i++) begin
                board_out[i] <= '{default: 15};
            end
        end
    end


endmodule
