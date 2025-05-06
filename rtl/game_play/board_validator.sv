/*******************************************************************************
* File: board.sv
* Author: Aniruddh Chauhan
* Date: 2025-04-27
* Description: Game logic file/ Chess moves valid/invalid checker
* Version: 1.1
*******************************************************************************/
module board_validator (
    input logic         clk,
    input logic         reset_n,

    input logic  [2:0]  old_x,
    input logic  [2:0]  old_y,
    input logic  [2:0]  new_x,
    input logic  [2:0]  new_y,
    input logic  [3:0]  piece_type,  // fixed to [3:0] since you have pieces up to 11
    input logic  [3:0]  board_in  [8][8], // 8x8 board input
    input logic         valid_input,

    output logic        valid_move,
    output logic        valid_output,

    // debug
    output logic [2:0] h_delta, v_delta
);
    logic path_clear;
    logic [2:0] temp_x, temp_y;
    always_comb begin
		valid_move = 0;
        valid_output = 0;
        path_clear = 1; // start assuming clear
        temp_x = 0;
        temp_y = 0;

        h_delta = (new_x > old_x) ? (new_x - old_x) : (old_x - new_x);
        v_delta = (new_y > old_y) ? (new_y - old_y) : (old_y - new_y);

        if (valid_input) begin
            case (piece_type)
                // PAWN
                5, 11: begin
                    if (h_delta == 0 && (old_y > new_y)) begin
                        if (old_y == 6 && v_delta == 2) begin
                            if (new_y == 4 &&
                                board_in[5][old_x] == 4'd15 &&
                                board_in[4][old_x] == 4'd15)
                                valid_move = 1'b1;
                        end
                        else if (v_delta == 1) begin
                            if (board_in[new_y][new_x] == 4'd15)
                                valid_move = 1'b1;
                        end
                    end
                    else if (h_delta == 1 && v_delta == 1) begin
                        if (board_in[new_y][new_x] != 4'd15)
                            valid_move = 1'b1;
                    end
                    valid_output = 1;
                end                
              
               //ROOK
                0, 6: begin
                    path_clear = 1;
                    
                    if (h_delta == 0) begin
                        for (int y = 0; y < 8; y++) begin
                            if (((old_y < new_y) && (y > old_y) && (y < new_y)) ||
                                ((new_y < old_y) && (y > new_y) && (y < old_y))) begin
                                if (board_in[y][old_x] != 4'd15)
                                    path_clear = 0;
                            end
                        end
                    end
                    else if (v_delta == 0) begin
                        for (int x = 0; x < 8; x++) begin
                            if (((old_x < new_x) && (x > old_x) && (x < new_x)) ||
                                ((new_x < old_x) && (x > new_x) && (x < old_x))) begin
                                if (board_in[old_y][x] != 4'd15)
                                    path_clear = 0;
                            end
                        end
                    end
                    else begin
                        path_clear = 0; // not straight
                    end

                    valid_move   = path_clear;
                    valid_output = 1;
                end

                // BISHOP
                2, 8: begin
                    path_clear = 1;
                    if (h_delta == v_delta) begin
                       // Unrolled loop for max path of 7
                        for (int i = 1; i < 8; i++) begin
                            if (i < h_delta) begin
                                temp_x = (new_x > old_x) ? (old_x + i) : (old_x - i);
                                temp_y = (new_y > old_y) ? (old_y + i) : (old_y - i);
                                if (board_in[temp_y][temp_x] != 4'd15)
                                    path_clear = 0;
                            end
                        end

                        valid_move   = path_clear;
                        valid_output = 1;
                    end
                    else begin
                        valid_move   = 0;
                        valid_output = 1;
                    end
                end

                //KNIGHT 
                1,7: begin
                    if ((h_delta == 2 && v_delta == 1) || (h_delta == 1 && v_delta == 2)) begin
                        valid_move = 1;
                    end else begin
                        valid_move = 0;
                    end
                    valid_output = 1;
                end

                //Queen 
                3,9: begin
                    path_clear = 1;
                    if (h_delta == 0) begin
                        for (int y = 0; y < 8; y++) begin
                            if (((old_y < new_y) && (y > old_y) && (y < new_y)) ||
                                ((new_y < old_y) && (y > new_y) && (y < old_y))) begin
                                if (board_in[y][old_x] != 4'd15)
                                    path_clear = 0;
                            end
                        end
                    end else if (v_delta == 0) begin
                        for (int x = 0; x < 8; x++) begin
                            if (((old_x < new_x) && (x > old_x) && (x < new_x)) ||
                                ((new_x < old_x) && (x > new_x) && (x < old_x))) begin
                                if (board_in[old_y][x] != 4'd15)
                                    path_clear = 0;
                            end
                        end
                    end else if (h_delta == v_delta) begin
                        for (int i = 1; i < 8; i++) begin
                            if (i < h_delta) begin
                                temp_x = (new_x > old_x) ? (old_x + i) : (old_x - i);
                                temp_y = (new_y > old_y) ? (old_y + i) : (old_y - i);
                                if (board_in[temp_y][temp_x] != 4'd15)
                                    path_clear = 0;
                            end
                        end
                    end else begin
                        path_clear = 0; // not straight nor diagonal
                    end
                    valid_move   = path_clear; // set here always
                    valid_output = 1;
                end

                // KING
                4, 10: 
                begin
                    if ((h_delta <= 1) && (v_delta <= 1) && (h_delta != 0 || v_delta != 0)) begin
                        valid_move = 1;
                    end else begin
                        valid_move = 0;
                    end
                    valid_output = 1;
                end

            endcase
        end
    end
endmodule
