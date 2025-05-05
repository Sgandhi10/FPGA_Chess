/*******************************************************************************
* File: check_bishop.sv
* Author: Aniruddh Chauhan
* Date: 2025-04-27
* Description: Bishop move checker module with diagonal path clearance checking
*******************************************************************************/

module check_bishop (
    input logic clk,
    input logic reset_n,
    input logic [2:0] old_x, old_y,
    input logic [2:0] new_x, new_y,
    input logic [2:0] h_delta, v_delta,
    input logic [3:0] piece_type,
    input logic [3:0] board_in [8][8],
    input logic       valid_input,


    output logic cb_valid_move,
    output logic cb_valid_output
);

typedef enum logic [1:0] {
    CB_IDLE,
    CB_CHECK_PATH,
    CB_DONE
} cb_state_t;

cb_state_t cb_current_state, cb_next_state;

// Internal signals
logic path_clear;
logic [2:0] temp_x, temp_y;
logic signed [2:0] dir_x, dir_y;

always_ff @(posedge clk or negedge reset_n) begin
    if (!reset_n)
        cb_current_state <= CB_IDLE;
    else
        cb_current_state <= cb_next_state;
end

always_comb begin
    cb_valid_move = 0;
    cb_valid_output = 0;
    cb_next_state = cb_current_state;

    case (cb_current_state)
        CB_IDLE: begin
            if (h_delta == v_delta) begin
                cb_next_state = CB_CHECK_PATH;
            end else begin
                cb_next_state = CB_DONE; // Not diagonal => immediately done
            end
        end

        CB_CHECK_PATH: begin
            path_clear = 1;

            // Determine directions
            dir_x = (new_x > old_x) ? 1 : -1;
            dir_y = (new_y > old_y) ? 1 : -1;

            temp_x = old_x + dir_x;
            temp_y = old_y + dir_y;

            // Check along diagonal path
            while ((temp_x != new_x) && (temp_y != new_y)) begin
                if (board_in[temp_y][temp_x] != 4'd15) begin
                    path_clear = 0;
                end
                temp_x = temp_x + dir_x;
                temp_y = temp_y + dir_y;
            end

            if (path_clear) begin
                cb_valid_move = 1; // Bishop move is valid if path is clear
            end
            cb_next_state = CB_DONE;
        end

        CB_DONE: begin
            cb_valid_output = 1;
        end
    endcase
end

endmodule
