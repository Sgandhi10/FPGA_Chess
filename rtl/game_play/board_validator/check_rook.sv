/*******************************************************************************
* File: check_rook.sv
* Author: Aniruddh Chauhan
* Date: 2025-04-27
* Description: Rook move checker module
*******************************************************************************/

module check_rook (
    input logic clk,
    input logic reset_n,
    input logic [2:0] old_x, old_y,
    input logic [2:0] new_x, new_y,
    input logic [2:0] h_delta, v_delta,
    input logic [3:0] piece_type,
    input logic [3:0] board_in [8][8],

    output logic cr_valid_move,
    output logic cr_valid_output
);

typedef enum logic [1:0] {
    CR_IDLE,
    CR_CHECK_MOVE,
    CR_DONE
} cr_state_t;

cr_state_t cr_current_state, cr_next_state;

always_ff @(posedge clk or negedge reset_n) begin
    if (!reset_n)
        cr_current_state <= CR_IDLE;
    else
        cr_current_state <= cr_next_state;
end

always_comb begin
    cr_valid_move = 0;
    cr_valid_output = 0;
    cr_next_state = cr_current_state;

    case (cr_current_state)
        CR_IDLE: begin
            cr_next_state = CR_CHECK_MOVE;
        end

        CR_CHECK_MOVE: begin
            if (h_delta == 0 || v_delta == 0) begin
                cr_valid_move = 1; // Vertical or horizontal move
            end
            cr_next_state = CR_DONE;
        end

        CR_DONE: begin
            cr_valid_output = 1;
        end
    endcase
end

endmodule
