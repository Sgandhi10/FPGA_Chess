/*******************************************************************************
* File: check_rook.sv
* Author: Aniruddh Chauhan
* Date: 2025-04-27
* Description: 
*   Rook move checker module for chess game.
*   
*******************************************************************************/

module check_rook (
    input logic clk,
    input logic reset_n,
    input logic [2:0] old_x, old_y,      // Old coordinates (starting position)
    input logic [2:0] new_x, new_y,      // New coordinates (destination position)
    input logic [2:0] h_delta, v_delta,  // Deltas between positions
    input logic [3:0] piece_type,        // Type of moving piece (rook = 0/6)
    input logic [3:0] board_in [8][8],   // Current board state
    input logic       valid_input,


    output logic cr_valid_move,          // Move validity output (1 = legal move)
    output logic cr_valid_output         // Output ready signal (1 = check complete)
);

// FSM States
typedef enum logic [1:0] {
    CR_IDLE,
    CR_CHECK_PATH,
    CR_DONE
} cr_state_t;

cr_state_t cr_current_state, cr_next_state;

// Internal signal to track if the path is clear
logic path_clear;

// FSM sequential block
always_ff @(posedge clk or negedge reset_n) begin
    if (!reset_n)
        cr_current_state <= CR_IDLE;
    else
        cr_current_state <= cr_next_state;
end

// FSM combinational logic
always_comb begin
    // Default assignments
    cr_valid_move = 1'b0;
    cr_valid_output = 1'b0;
    path_clear = 1'b1; // Assume path is clear unless found otherwise
    cr_next_state = cr_current_state;

    case (cr_current_state)

        // IDLE: Just transition to check path
        CR_IDLE: begin
            cr_next_state = CR_CHECK_PATH;
        end

        // CHECK_PATH: Validate rook move legality
        CR_CHECK_PATH: begin
            // Check if move is strictly vertical
            if (h_delta == 0) begin
                if (old_y < new_y) begin
                    for (int y = old_y + 1; y < new_y; y++) begin
                        if (board_in[y][old_x] != 4'd15)
                            path_clear = 1'b0;
                    end
                end else begin
                    for (int y = new_y + 1; y < old_y; y++) begin
                        if (board_in[y][old_x] != 4'd15)
                            path_clear = 1'b0;
                    end
                end
            end 
            // Check if move is strictly horizontal
            else if (v_delta == 0) begin
                if (old_x < new_x) begin //left
                    for (int x = old_x + 1; x < new_x; x++) begin
                        if (board_in[old_y][x] != 4'd15)
                            path_clear = 1'b0;
                    end
                end else begin
                    for (int x = new_x + 1; x < old_x; x++) begin
                        if (board_in[old_y][x] != 4'd15)
                            path_clear = 1'b0;
                    end
                end
            end 
            else begin
                path_clear = 1'b0; // Neither vertical nor horizontal
            end

            
            if (path_clear) begin
                // Move is valid if destination is empty OR destination is enemy
                if (board_in[new_y][new_x] == 4'd15)//CHECK THIS CONDITION, need to underdtad the enemy vs friend logic
                    cr_valid_move = 1'b1;
            end

            cr_next_state = CR_DONE;
        end

        // DONE: Assert output valid
        CR_DONE: begin
            cr_valid_output = 1'b1;
            cr_next_state = CR_IDLE; // Reset FSM to IDLE
        end

    endcase
end

endmodule
