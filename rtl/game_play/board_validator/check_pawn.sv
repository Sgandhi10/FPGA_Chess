/*Module:
    * check_pawn.sv 
    Author: Aniruddh Chauhan
    Date: 2025-04-27
    Description:
    * This module checks if a pawn can attack another piece on a chessboard.
    * It takes the positions of the pawn and the target piece as inputs 
*/

module check_pawn (
    input logic clk,
    input logic reset_n,
    input logic [2:0] old_x, old_y,
    input logic [2:0] new_x, new_y,
    input logic [2:0] h_delta, v_delta,
    input logic [3:0] piece_type,
    input logic [3:0] board_in [8][8],

    output logic cp_valid_move,    // Whether the move was valid
    output logic cp_valid_output   // Whether checker is done
);

typedef enum logic [1:0] {
    CP_IDLE,
    CP_CHECK_VERTICAL,
    CP_CHECK_DIAGONAL,
    CP_DONE
} cp_state_t;

cp_state_t cp_current_state, cp_next_state;

always_ff @(posedge clk or negedge reset_n) begin
    if (!reset_n) begin
        cp_current_state <= CP_IDLE;
    end else begin
        cp_current_state <= cp_next_state;
    end
end

always_comb begin
    cp_valid_move = 0;
    cp_valid_output = 0;
    cp_next_state = cp_current_state;

    case (cp_current_state)
        CP_IDLE: begin
            if (h_delta == 0)
                cp_next_state = CP_CHECK_VERTICAL;
            else if (h_delta == 1 && v_delta == 1)
                cp_next_state = CP_CHECK_DIAGONAL;
            else
                cp_next_state = CP_DONE;
        end

        CP_CHECK_VERTICAL: begin
            if (piece_type == 4'd5) begin
                if ((old_y == 6 && v_delta == 2 && board_in[old_y-1][old_x] == 4'd15 && board_in[new_y][new_x] == 4'd15) ||
                    (v_delta == 1 && board_in[new_y][new_x] == 4'd15 && new_y < old_y))
                    cp_valid_move = 1;
            end else if (piece_type == 4'd11) begin
                if ((old_y == 1 && v_delta == 2 && board_in[old_y+1][old_x] == 4'd15 && board_in[new_y][new_x] == 4'd15) ||
                    (v_delta == 1 && board_in[new_y][new_x] == 4'd15 && new_y > old_y))
                    cp_valid_move = 1;
            end
            cp_next_state = CP_DONE;
        end

        CP_CHECK_DIAGONAL: begin
            if (piece_type == 4'd5) begin
                if (new_y < old_y && board_in[new_y][new_x] != 4'd15)
                    cp_valid_move = 1;
            end else if (piece_type == 4'd11) begin
                if (new_y > old_y && board_in[new_y][new_x] != 4'd15)
                    cp_valid_move = 1;
            end
            cp_next_state = CP_DONE;
        end

        CP_DONE: begin
            cp_valid_output = 1'b1;
        end
    endcase
end

endmodule
