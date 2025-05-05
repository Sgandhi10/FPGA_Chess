/*******************************************************************************
* File: check_queen.sv
* Author: Aniruddh Chauhan
* Date: 2025-04-27
* Description:
*.
*******************************************************************************/

module check_queen (
    input logic clk,
    input logic reset_n,

    input logic [2:0] old_x, old_y,
    input logic [2:0] new_x, new_y,
    input logic [2:0] h_delta, v_delta,
    input logic [3:0] piece_type,
    input logic [3:0] board_in [8][8],
    input logic       valid_input,

    output logic cq_valid_move,
    output logic cq_valid_output
);

// FSM States
typedef enum logic [1:0] {
    CQ_IDLE,
    CQ_CHECK_PATH,
    CQ_DONE
} cq_state_t;

cq_state_t cq_current_state, cq_next_state;

// Internal signals
logic path_clear;
logic [2:0] temp_x, temp_y;
logic signed [2:0] dir_x, dir_y;

// FSM sequential block
always_ff @(posedge clk or negedge reset_n) begin
    if (!reset_n)
        cq_current_state <= CQ_IDLE;
    else
        cq_current_state <= cq_next_state;
end

// FSM combinational logic
always_comb begin
    // Default values
    cq_valid_move = 1'b0;
    cq_valid_output = 1'b0;
    cq_next_state = cq_current_state;

    case (cq_current_state)
        CQ_IDLE: begin
            if (valid_input) begin
                if ((h_delta == 0) || (v_delta == 0) || (h_delta == v_delta))
                    cq_next_state = CQ_CHECK_PATH; // only move if rook/bishop move pattern
                else
                    cq_next_state = CQ_DONE; 
            end
        end

        CQ_CHECK_PATH: begin
            path_clear = 1'b1; // Assume clear unless blocked

            if (h_delta == 0) begin
                // this means its Vertical move?
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
            else if (v_delta == 0) begin
                // proced to Horizontal move
                if (old_x < new_x) begin
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
            else if (h_delta == v_delta) begin
                // its gotta be Diagonal move i mean come on
                dir_x = (new_x > old_x) ? 1 : -1;
                dir_y = (new_y > old_y) ? 1 : -1;

                temp_x = old_x + dir_x;
                temp_y = old_y + dir_y;

                while ((temp_x != new_x) && (temp_y != new_y)) begin
                    if (board_in[temp_y][temp_x] != 4'd15)
                        path_clear = 1'b0;
                    temp_x = temp_x + dir_x;
                    temp_y = temp_y + dir_y;
                end
            end
            else begin
                path_clear = 1'b0; //damn path is not clear, my fault gang
            end

            // Final decision based ont the path clear or not
            if (path_clear) begin
                cq_valid_move = 1'b1;
                // the baord.sv should handle if its whether the enemy or a frindly
                //pray
            end

            cq_next_state = CQ_DONE;
        end

        CQ_DONE: begin
            cq_valid_output = 1'b1;
            cq_next_state = CQ_IDLE; // Reset
        end

    endcase
end

endmodule
