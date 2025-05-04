/*******************************************************************************
* File: check_knight.sv
* Author: Aniruddh Chauhan
* Date: 2025-04-27
* Description: Knight move checker module
*******************************************************************************/

module check_knight (
    input logic CLOCK_50,
    input logic reset_n,

    input logic [2:0] old_x, old_y,
    input logic [2:0] new_x, new_y,
    input logic [2:0] h_delta, v_delta,
    input logic [3:0] piece_type,
    input logic [3:0] board_in [8][8],

    output logic move_valid,
    output logic checker_done
);

typedef enum logic [1:0] {
    CK_IDLE,
    CK_CHECK_MOVE,
    CK_DONE
} ck_state_t;

ck_state_t ck_current_state, ck_next_state;

always_ff @(posedge CLOCK_50 or negedge reset_n) begin
    if (!reset_n)
        ck_current_state <= CK_IDLE;
    else
        ck_current_state <= ck_next_state;
end

always_comb begin
    ck_next_state = ck_current_state;
    move_valid = 0;
    checker_done = 0;

    case (ck_current_state)
        CK_IDLE: begin
            ck_next_state = CK_CHECK_MOVE;
        end

        CK_CHECK_MOVE: begin
            if ((h_delta == 2 && v_delta == 1) || (h_delta == 1 && v_delta == 2)) begin
                move_valid = 1; // Knight "L" move
            end
            ck_next_state = CK_DONE;
        end

        CK_DONE: begin
            checker_done = 1;
        end
    endcase
end

endmodule
