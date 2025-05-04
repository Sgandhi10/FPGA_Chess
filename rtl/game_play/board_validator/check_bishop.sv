/*******************************************************************************
* File: check_bishop.sv
* Author: Aniruddh Chauhan
* Date: 2025-04-27
* Description: Bishop move checker module
*******************************************************************************/

module check_bishop (
    input logic clk,
    input logic reset_n,
    input logic [2:0] old_x, old_y,
    input logic [2:0] new_x, new_y,
    input logic [2:0] h_delta, v_delta,
    input logic [3:0] piece_type,
    input logic [3:0] board_in [8][8],

    output logic cb_valid_move,
    output logic cb_valid_output
);

typedef enum logic [1:0] {
    CB_IDLE,
    CB_CHECK_MOVE,
    CB_DONE
} cb_state_t;

cb_state_t cb_current_state, cb_next_state;

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
            cb_next_state = CB_CHECK_MOVE;
        end

        CB_CHECK_MOVE: begin
            if (h_delta == v_delta) begin
                cb_valid_move = 1; // Diagonal move
            end
            cb_next_state = CB_DONE;
        end

        CB_DONE: begin
            cb_valid_output = 1;
        end
    endcase
end

endmodule
