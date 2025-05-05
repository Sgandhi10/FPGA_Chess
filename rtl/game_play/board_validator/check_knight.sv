/*******************************************************************************
* File: check_knight.sv
* Author: Aniruddh Chauhan
* Date: 2025-04-27
* Description: Knight move checker module
*******************************************************************************/

module check_knight (
    input logic clk,
    input logic reset_n,
    input logic [2:0] old_x, old_y,
    input logic [2:0] new_x, new_y,
    input logic [2:0] h_delta, v_delta,
    input logic [3:0] piece_type,
    input logic [3:0] board_in [8][8],
    input logic       valid_input,

    output logic ck_valid_move,
    output logic ck_valid_output
);

typedef enum logic [1:0] {
    CK_IDLE,
    CK_CHECK_MOVE,
    CK_DONE
} ck_state_t;

ck_state_t ck_current_state, ck_next_state;

always_ff @(posedge clk or negedge reset_n) begin
    if (!reset_n)
        ck_current_state <= CK_IDLE;
    else
        ck_current_state <= ck_next_state;
end

always_comb begin
    ck_valid_move = 0;
    ck_valid_output = 0;
    ck_next_state = ck_current_state;

    case (ck_current_state)
        CK_IDLE: begin
            ck_next_state = CK_CHECK_MOVE;
        end

        CK_CHECK_MOVE: begin
            if ((h_delta == 2 && v_delta == 1) || (h_delta == 1 && v_delta == 2)) begin
                ck_valid_move = 1; // Knight L move
            end
            ck_next_state = CK_DONE;
        end

        CK_DONE: begin
            ck_valid_output = 1;
        end
    endcase
end

endmodule
