/*******************************************************************************
* File: check_pawn.sv
* Author: Aniruddh Chauhan
* Date: 2025-04-27
* Description:
*   Pawn movement checker for chess game.
*   Assumes board is flipped so pawns always move "up" (decreasing y).
* Version: 2.0
*******************************************************************************/

module check_pawn (
    input logic clk,
    input logic reset_n,

    input logic [2:0] old_x, old_y,
    input logic [2:0] new_x, new_y,
    input logic [2:0] h_delta, v_delta,
    input logic [3:0] piece_type,
    input logic [3:0] board_in [8][8],
    input logic       valid_input,

    output logic cp_valid_move,    // Whether the move was valid
    output logic cp_valid_output   // Whether checker is done
);

    // FSM states
    typedef enum logic [1:0] {
        CP_IDLE,
        CP_CHECK_VERTICAL,
        CP_CHECK_DIAGONAL,
        CP_DONE
    } cp_state_t;

    cp_state_t cp_current_state, cp_next_state;


 //  assign cp_valid_move = 1'b1;
 //  assign cp_valid_output = 1'b1;

   always_ff @(posedge clk or negedge reset_n) begin
    if (!reset_n) begin
        cp_valid_move <= 1'b0;
        cp_valid_output <= 1'b0;
    end
    else if (valid_input) begin
        if (h_delta == 0) begin
            if (old_y == 6 && v_delta == 2) begin
                if (new_y == 4 &&
                    board_in[5][old_x] == 4'd15 &&
                    board_in[4][old_x] == 4'd15)
                    cp_valid_move <= 1'b1;
            end
            else if (v_delta == 1) begin
                if (board_in[new_y][new_x] == 4'd15)
                    cp_valid_move <= 1'b1;
            end
        end
        else if (h_delta == 1 && v_delta == 1) begin
            if (board_in[new_y][new_x] != 4'd15)
                cp_valid_move <= 1'b1;
        end

        cp_valid_output <= 1'b1; // <-- Always set output done at the end
    end
end

    // State update
    // always_ff @(posedge clk or negedge reset_n) begin
    //     if (!reset_n)
    //         cp_current_state <= CP_IDLE;
    //     else
    //         cp_current_state <= cp_next_state;
    // end

    // // Combinational logic
    // always_comb begin
    //     cp_valid_move = 0;
    //     cp_valid_output = 0;
    //     cp_next_state = cp_current_state;

    //     case (cp_current_state)
    //         CP_IDLE: begin
    //             if (valid_input) begin
    //                 if (h_delta == 0)
    //                     cp_next_state = CP_CHECK_VERTICAL;
    //                 else if (h_delta == 1 && v_delta == 1)
    //                     cp_next_state = CP_CHECK_DIAGONAL;
    //                 else
    //                     cp_next_state = CP_DONE;  // straight to DONE for illegal pattern
    //             end
    //         end

    //         CP_CHECK_VERTICAL: begin
    //             // ---- double‐step from starting rank? ----
    //             if (old_y == 6 && v_delta == 2) begin
    //                 // must still be in‐bounds and both intermediate & landing squares empty
    //                 if (new_y == 4 &&
    //                     board_in[5][old_x] == 4'd15 &&
    //                     board_in[4][old_x] == 4'd15)
    //                     cp_valid_move = 1'b1;
    //             end
    //             // ---- single‐step forward ----
    //             else if (v_delta == 1) begin
    //                 if (board_in[new_y][new_x] == 4'd15)
    //                     cp_valid_move = 1'b1;
    //             end
    //             cp_next_state = CP_DONE;
    //         end

    //         CP_CHECK_DIAGONAL: begin
    //             // diagonal capture only if destination occupied by *some* piece
    //             if (board_in[new_y][new_x] != 4'd15)
    //                 cp_valid_move = 1'b1;
    //             cp_next_state = CP_DONE;
    //         end

    //         CP_DONE: begin
    //             // always pulse done, even if cp_valid_move==0
    //             cp_valid_output = 1'b1;
    //             cp_next_state   = CP_IDLE;
    //         end
    //     endcase
    // end

endmodule
