/*******************************************************************************
* File: check_queen.sv
* Author: Aniruddh Chauhan
* Date: 2025-04-27
* Description: Queen move checker module
*******************************************************************************/

module check_queen (
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
    CQ_IDLE,
    CQ_CHECK_MOVE,
    CQ_DONE
} cq_state_t;

cq_state_t cq_current_state, cq_next_state;

always_ff @(posedge CLOCK_50 or negedge reset_n) begin
    if (!reset_n)
        cq_current_state <= CQ_IDLE;
    else
        cq_current_state <= cq_next_state;
end

always_comb begin
    cq_next_state = cq_current_state;
    move_valid = 0;
    checker_done = 0;

    case (cq_current_state)
        CQ_IDLE: begin
            cq_next_state = CQ_CHECK_MOVE;
        end

        CQ_CHECK_MOVE: begin
            if ((h_delta == 0 || v_delta == 0) || (h_delta == v_delta)) begin
                move_valid = 1; // Queen = Rook + Bishop
            end
            cq_next_state = CQ_DONE;
        end

        CQ_DONE: begin
            checker_done = 1;
        end
    endcase
end

endmodule
