/*******************************************************************************
* File: board.sv
* Author: Soham Gandhi
* Date: 2025-04-27
* Description: Controls the game board
* Version: 1.1
*******************************************************************************/
import common_enums::*;

module board (
    input logic             CLOCK_50,
    input logic             reset_n,
    input logic             player,
    input logic             curr_player,
    input logic             dir,
    input screen_state_t    sys_state,       

    input logic         key1out, // - dir
    input logic         key2out, // + dir
    input logic         key3out, // enter

    input logic [3:0]   stable_board [8][8], // 8x8 board input

    output logic [3:0]  disp_board [8][8],
    output logic        square_highlight [8][8], // 8x8 board output
    output logic        moved,
    output logic [11:0] output_packet,

    // Debug
    output move_state_t move_state
);
    // move_state_t move_state;
    logic [2:0] x_pos, y_pos, old_xpos, old_ypos;
    logic [3:0] updated_board [8][8];
    logic [3:0] sel_val;

    always_ff @(posedge CLOCK_50 or negedge reset_n) begin
        if (!reset_n) begin
            // Set board to blank
            for (int i = 0; i < 8; i++) begin
                disp_board[i] <= '{default: 15};
            end

            x_pos <= 3;
            y_pos <= 3;

            old_xpos <= 3;
            old_ypos <= 3;

            move_state <= PLAYER_SEL;
            moved <= 0;

            sel_val <= 15;
        end else begin
            if (sys_state == CHESS_SCREEN) begin
                // Finite State Machine for move selection
                case (move_state) 
                    PLAYER_SEL: begin
                        disp_board <= stable_board;
                        moved <= 0;
                        if (player == curr_player) begin
                            move_state <= PIECE_SEL;
                            x_pos <= 3;
                            y_pos <= 3;
                            old_xpos <= 3;
                            old_ypos <= 3;
                        end
                    end
                    PIECE_SEL: begin
                        if (dir) begin
                            if (key1out)
                                x_pos <= x_pos - 1;
                            else if (key2out)
                                x_pos <= x_pos + 1;
                        end else begin
                            if (key1out)
                                y_pos <= y_pos + 1;
                            else if (key2out)
                                y_pos <= y_pos - 1; 
                        end
                        if (key3out) begin
                            if (stable_board[x_pos][y_pos] != 15 &&
                                ((stable_board[x_pos][y_pos] > 5 && ~player) || 
                                (stable_board[x_pos][y_pos] <= 5  &&  player))) 
                            begin
                                old_xpos  <= x_pos;
                                old_ypos  <= y_pos;
                                sel_val   <= stable_board[x_pos][y_pos];
                                move_state <= POS_SEL;
                            end
                        end
                    end
                    POS_SEL: begin
                        disp_board <= updated_board;
                        if (dir) begin
                            if (key1out)
                                x_pos <= x_pos - 1;
                            else if (key2out)
                                x_pos <= x_pos + 1;
                        end else begin
                            if (key1out)
                                y_pos <= y_pos + 1;
                            else if (key2out)
                                y_pos <= y_pos - 1; 
                        end
                        if (key3out) begin
                            if (stable_board[x_pos][y_pos] == 15 || ((stable_board[x_pos][y_pos] > 5 && player) || 
                                (stable_board[x_pos][y_pos] <= 5  &&  ~player))) 
                            begin
                                move_state <= MOVE_VAL;
                                moved <= 1'b1;
                            end else if (((stable_board[x_pos][y_pos] <= 5 && player) || 
                                (stable_board[x_pos][y_pos] > 5  &&  ~player))) begin
                                move_state <= PLAYER_SEL;
                            end
                        end
                    end
                    MOVE_VAL: begin
                        // if valid
                        disp_board <= updated_board;
                        moved <= 1'b0;
                        move_state <= PLAYER_SEL;
                    end
                    default: /* do nothing */;
                endcase
            end
        end
    end

    always_comb begin
        square_highlight = '{default: 0};
        if (player == curr_player) begin
            square_highlight[x_pos][y_pos] = 1;
        end

        for (int i = 0; i < 8; i++) begin
            for (int j = 0; j < 8; j++) begin
                updated_board[i][j] = stable_board[i][j];
            end
        end
        updated_board[old_xpos][old_ypos] = 15;
        updated_board[x_pos][y_pos] = sel_val;

        output_packet = {old_xpos, old_ypos, x_pos, y_pos};
    end
endmodule
