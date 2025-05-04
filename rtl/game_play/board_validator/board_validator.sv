/*******************************************************************************
* File: board_validator.sv
* Author: Aniruddh Chauhan
* Date: 2025-04-27
* Description: Game logic file / Chess moves valid/invalid checker (FSM Top)
* Version: 2.0
*******************************************************************************/

module board_validator (
    input logic         clk,
    input logic         reset_n,

    input logic  [2:0]  old_x, old_y,
    input logic  [2:0]  new_x, new_y,
    input logic  [3:0]  piece_type,  // fixed to [3:0] since you have pieces up to 11
    input logic  [3:0]  board_in  [8][8], // 8x8 board input
    input logic  [3:0]  valid_input,

    output logic        valid_move,
    output logic        valid_output
);

typedef enum logic [2:0] {
    IDLE,
    CHECK_PAWN,
    CHECK_ROOK,
    CHECK_KNIGHT,
    CHECK_BISHOP,
    CHECK_QUEEN,
    MOVE_STATUS
} state_t;
 
state_t current_state, next_state;

// Checker modules' outputs
logic cp_valid_move;//pawn
logic cr_valid_move;//rook
logic ck_valid_move;//knight
logic cb_valid_move;//bishop
logic cq_valid_move;//queen

logic cp_valid_output;//pawn
logic cr_valid_output;//rook
logic ck_valid_output;//knight
logic cb_valid_output;//bishop
logic cq_valid_output;//queen


// Instantiate checker modules
check_pawn pawn_checker (

    .clk(clk),
    .reset_n(reset_n),
    .old_x(old_x),
    .old_y(old_y),
    .new_x(new_x),
    .new_y(new_y),
    .h_delta(h_delta_reg),
    .v_delta(v_delta_reg),
    .piece_type(piece_type),
    .board_in(board_in),
    //valid_move is the if the move itself was valid or invalid
    .cp_valid_move(cp_valid_move),
    //valid_output is a checkpoint...when it toggles to 1 this means that the move checker files has 
    //gone throught the FSM to validate if the move is valid or not
    .cp_valid_output(cp_valid_output)
   
);

// Instantiate Knight Checker
check_knight knight_checker (
    .clk(clk),
    .reset_n(reset_n),
    .old_x(old_x),
    .old_y(old_y),
    .new_x(new_x),
    .new_y(new_y),
    .h_delta(h_delta_reg),
    .v_delta(v_delta_reg),
    .piece_type(piece_type),
    .board_in(board_in),
    .ck_valid_move(ck_valid_move),
    .ck_valid_output(ck_valid_output) // shared valid_output signal
);

// Instantiate Bishop Checker
check_bishop bishop_checker (
    .clk(clk),
    .reset_n(reset_n),
    .old_x(old_x),
    .old_y(old_y),
    .new_x(new_x),
    .new_y(new_y),
    .h_delta(h_delta_reg),
    .v_delta(v_delta_reg),
    .piece_type(piece_type),
    .board_in(board_in),
    .cb_valid_move(cb_valid_move),
    .cb_valid_output(cb_valid_output) // shared valid_output signal
);

// Instantiate Queen Checker
check_queen queen_checker (
    .clk(clk),
    .reset_n(reset_n),
    .old_x(old_x),
    .old_y(old_y),
    .new_x(new_x),
    .new_y(new_y),
    .h_delta(h_delta_reg),
    .v_delta(v_delta_reg),
    .piece_type(piece_type),
    .board_in(board_in),
    .cq_valid_move(cq_valid_move),
    .cq_valid_output(cq_valid_output) // shared valid_output signal
);

// similar instantiations for rook, knight, bishop, queen checkers
// (I'll show this separately if you want)


// Top-level FSM
always_ff @(posedge clk or negedge reset_n) begin
    if (!reset_n) 
    begin
        current_state <= IDLE;
    end 
    else 
    begin
        //check if all inputs are valid
        case (current_state)
            IDLE: begin
               if (valid_input) 
               begin
                    case (piece_type)
                        4'd5, 4'd11: current_state <= CHECK_PAWN;
                        4'd0, 4'd6:  current_state <= CHECK_ROOK;
                        4'd1, 4'd7:  current_state <= CHECK_KNIGHT;
                        4'd2, 4'd8:  current_state <= CHECK_BISHOP;
                        4'd3, 4'd9:  current_state <= CHECK_QUEEN;
                        default:     current_state <= MOVE_STATUS;
                    endcase
                end
            end
            CHECK_PAWN: begin
                if (cp_valid_output) begin
                    valid_move   <= cp_valid_move;
						  valid_output <= cp_valid_output;
                end
            end

            CHECK_ROOK: begin
                if (cr_valid_output) begin
                    valid_move   <= cr_valid_move;
						  valid_output <= cr_valid_output;
                end
            end

            CHECK_KNIGHT: begin
                if (ck_valid_output) begin
                    valid_move   <= ck_valid_move;
						  valid_output <= ck_valid_output;						  
                end
            end

            CHECK_BISHOP: begin
                if (cb_valid_output) begin
                    valid_move   <= cb_valid_move;
						  valid_output <= cb_valid_output;				
                end
            end

            CHECK_QUEEN: begin
                if (cq_valid_output) begin
                    valid_move <= cq_valid_move;
						  valid_move <= cq_valid_output;
                end
            end

            default: current_state <= IDLE;

    endcase
    end
    end


endmodule
