/*******************************************************************************
* File: board_validator.sv
* Author: Aniruddh Chauhan
* Date: 2025-04-27
* Description: Game logic file/ Chess moves valid/invalid checker
* Version: 1.1
*******************************************************************************/
/*module board_validator (
    input logic         CLOCK_50,
    input logic         reset_n,

    input logic  [2:0]  old_x, old_y,
    input logic  [2:0]  new_x, new_y,
    input logic  [2:0]  piece_type,
    input logic  [3:0]  board_in  [8][8], // 8x8 board input

    output logic [3:0]  board_out [8][8],
    output logic        board_valid
);


//Calcualte distance from old position to new position
//need this to be a pipeline stage since values are needed for checking valid move or not


typedef enum logic [2:0] 
{
	  IDLE,
	  CHECK_VERTICAL,
	  CHECK_DIAGONAL,
	  CHECK_PATH_CLEAR,
	  CHECK_TARGET,
	  MOVE_PIECE,
	  REJECT_MOVE
} state_t;
 	 
state_t current_state, next_state;


//declaration of the variables 

logic path_clear;

logic [2:0] h_delta, v_delta;
logic enemy_piece;
 
 
//Calculate distance between the old positon and the new positon
 
logic [2:0] h_delta_reg, v_delta_reg;
always_ff @(posedge CLOCK_50 or negedge reset_n) begin
    if (!reset_n) begin
        h_delta_reg <= 0;
        v_delta_reg <= 0;
        board_valid <= 0;
        current_state <= IDLE;
    end 
    else begin
        case (current_state)

            IDLE: begin
                // compute deltas here
                h_delta_reg <= (new_x > old_x) ? (new_x - old_x) : (old_x - new_x);
                v_delta_reg <= (new_y > old_y) ? (new_y - old_y) : (old_y - new_y);

                // Transition to next state
                if (piece_type == 4'd5 || piece_type == 4'd11) begin
                    // If it's a pawn
                    if (h_delta_reg == 0)
                        current_state <= CHECK_VERTICAL;
                    else if (h_delta_reg == 1 && v_delta_reg == 1)
                        current_state <= CHECK_DIAGONAL;
                    else
                        current_state <= REJECT_MOVE;
                end
                else begin
                    current_state <= REJECT_MOVE;
                end
            end

            CHECK_VERTICAL: begin
                // Pawn logic for vertical move
                if (piece_type == 4'd5) begin
                    // White pawn
                    if (old_y == 6 && v_delta_reg == 2 && board_in[old_y-1][old_x] == 4'd15 && board_in[new_y][new_x] == 4'd15)
                        current_state <= MOVE_PIECE;
                    else if (v_delta_reg == 1 && board_in[new_y][new_x] == 4'd15 && new_y < old_y)
                        current_state <= MOVE_PIECE;
                    else
                        current_state <= REJECT_MOVE;
                end
                else if (piece_type == 4'd11) begin
                    // Black pawn
                    if (old_y == 1 && v_delta_reg == 2 && board_in[old_y+1][old_x] == 4'd15 && board_in[new_y][new_x] == 4'd15)
                        current_state <= MOVE_PIECE;
                    else if (v_delta_reg == 1 && board_in[new_y][new_x] == 4'd15 && new_y > old_y)
                        current_state <= MOVE_PIECE;
                    else
                        current_state <= REJECT_MOVE;
                end
                else begin
                    current_state <= REJECT_MOVE;
                end
            end

            CHECK_DIAGONAL: begin
                // Pawn diagonal capture
                if (piece_type == 4'd5) begin
                    if (new_y < old_y && board_in[new_y][new_x] != 4'd15) // White pawn capture
                        current_state <= MOVE_PIECE;
                    else
                        current_state <= REJECT_MOVE;
                end
                else if (piece_type == 4'd11) begin
                    if (new_y > old_y && board_in[new_y][new_x] != 4'd15) // Black pawn capture
                        current_state <= MOVE_PIECE;
                    else
                        current_state <= REJECT_MOVE;
                end
                else begin
                    current_state <= REJECT_MOVE;
                end
            end

            MOVE_PIECE: begin
                board_valid <= 1;
                board_out[new_y][new_x] <= board_in[old_y][old_x];
                board_out[old_y][old_x] <= 4'd15;
                current_state <= IDLE; // Go back to IDLE after moving
            end

            REJECT_MOVE: begin
                board_valid <= 0;
                board_out <= board_in;
                current_state <= IDLE; // Go back to IDLE after rejecting
            end

            default: current_state <= IDLE;

        endcase
    end
end

endmodule*/


/*******************************************************************************
* File: board_validator.sv
* Author: Aniruddh Chauhan
* Date: 2025-04-27
* Description: Game logic file / Chess moves valid/invalid checker (FSM Top)
* Version: 2.0
*******************************************************************************/

module board_validator (
    input logic         CLOCK_50,
    input logic         reset_n,

    input logic  [2:0]  old_x, old_y,
    input logic  [2:0]  new_x, new_y,
    input logic  [3:0]  piece_type,  // fixed to [3:0] since you have pieces up to 11
    input logic  [3:0]  board_in  [8][8], // 8x8 board input

    output logic [3:0]  board_out [8][8],
    output logic        board_valid
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

// declaration of variables
logic [2:0] h_delta_reg, v_delta_reg;

// Checker modules' outputs
logic move_valid_pawn;
logic move_valid_rook;
logic move_valid_knight;
logic move_valid_bishop;
logic move_valid_queen;

logic checker_done_pawn;
logic checker_done_rook;
logic checker_done_knight;
logic checker_done_bishop;
logic checker_done_queen;

// Instantiate checker modules
check_pawn pawn_checker (
    .CLOCK_50(CLOCK_50),
    .reset_n(reset_n),
    .old_x(old_x),
    .old_y(old_y),
    .new_x(new_x),
    .new_y(new_y),
    .h_delta(h_delta_reg),
    .v_delta(v_delta_reg),
    .piece_type(piece_type),
    .board_in(board_in),
    .move_valid(move_valid_pawn),
    .checker_done(checker_done_pawn)
);

// similar instantiations for rook, knight, bishop, queen checkers
// (I'll show this separately if you want)


// Top-level FSM
always_ff @(posedge CLOCK_50 or negedge reset_n) begin
    if (!reset_n) begin
        h_delta_reg <= 0;
        v_delta_reg <= 0;
        board_valid <= 0;
        current_state <= IDLE;
    end 
    else begin
        case (current_state)

            IDLE: begin
                // compute deltas
                h_delta_reg <= (new_x > old_x) ? (new_x - old_x) : (old_x - new_x);
                v_delta_reg <= (new_y > old_y) ? (new_y - old_y) : (old_y - new_y);

                // Choose which checker module based on piece_type
                if (piece_type == 4'd5 || piece_type == 4'd11) 
                    current_state <= CHECK_PAWN;
                else if (piece_type == 4'd0 || piece_type == 4'd6)
                    current_state <= CHECK_ROOK;
                else if (piece_type == 4'd1 || piece_type == 4'd7)
                    current_state <= CHECK_KNIGHT;
                else if (piece_type == 4'd2 || piece_type == 4'd8)
                    current_state <= CHECK_BISHOP;
                else if (piece_type == 4'd3 || piece_type == 4'd9)
                    current_state <= CHECK_QUEEN;
                else
                    current_state <= MOVE_STATUS; // invalid piece type goes to MOVE_STATUS which will reject
            end

            CHECK_PAWN: begin
                if (checker_done_pawn) begin
                    if (move_valid_pawn)
                        board_valid <= 1;
                    else
                        board_valid <= 0;
                    current_state <= MOVE_STATUS;
                end
            end

            CHECK_ROOK: begin
                if (checker_done_rook) begin
                    if (move_valid_rook)
                        board_valid <= 1;
                    else
                        board_valid <= 0;
                    current_state <= MOVE_STATUS;
                end
            end

            CHECK_KNIGHT: begin
                if (checker_done_knight) begin
                    if (move_valid_knight)
                        board_valid <= 1;
                    else
                        board_valid <= 0;
                    current_state <= MOVE_STATUS;
                end
            end

            CHECK_BISHOP: begin
                if (checker_done_bishop) begin
                    if (move_valid_bishop)
                        board_valid <= 1;
                    else
                        board_valid <= 0;
                    current_state <= MOVE_STATUS;
                end
            end

            CHECK_QUEEN: begin
                if (checker_done_queen) begin
                    if (move_valid_queen)
                        board_valid <= 1;
                    else
                        board_valid <= 0;
                    current_state <= MOVE_STATUS;
                end
            end

            MOVE_STATUS: begin
                if (board_valid) begin
                    board_out[new_y][new_x] <= board_in[old_y][old_x];
                    board_out[old_y][old_x] <= 4'd15;
                end else begin
                    board_out <= board_in;
                end
                current_state <= IDLE; // always return to IDLE
            end

            default: current_state <= IDLE;

        endcase
    end
end

endmodule
